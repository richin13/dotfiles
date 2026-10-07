#!/usr/bin/env bash
# =============================================================================
# generate-image.sh — Generate or edit images via OpenAI's image API
#
# USAGE:
#   generate-image.sh [OPTIONS] <prompt>
#
# ARGUMENTS:
#   <prompt>          Required. Text description of the desired image.
#                     Wrap in quotes if it contains spaces.
#
# OPTIONS:
#   -m, --model       Image model. Default: gpt-image-2.5-sunburst
#                     gpt-image-2.5-sunburst  best quality and edit precision
#                     gpt-image-2.5-flare     faster, ~gpt-image-2 quality
#   -s, --size        Image dimensions. Default: auto
#                     auto or WIDTHxHEIGHT. Common: 1024x1024 | 1536x1024 |
#                     1024x1536 | 2048x2048 | 2048x1152 | 3840x2160 | 2160x3840
#                     Edges multiple of 16, max 3840, ratio <= 3:1,
#                     655,360..8,294,400 total px (>2560x1440 is experimental)
#   -q, --quality     Render quality. Default: medium
#                     Allowed: low | medium | high | xhigh | max | auto
#   -b, --background  Background. Default: auto
#                     Allowed: auto | opaque | transparent (png/webp only)
#   -n, --count       Number of images to generate (1–10). Default: 1
#                     When n>1, each image is saved separately and all
#                     paths are printed (one per line).
#   -f, --format      Output format. Default: png
#                     Allowed: png | jpeg | webp
#   -o, --output      Output file path (overrides /tmp default).
#                     Ignored when --count > 1.
#   -e, --edit        Source image file to edit. Can be repeated up to 16
#                     times for multiple input images. Switches to the
#                     /images/edits endpoint.
#   -h, --help        Show this message and exit.
#
# OUTPUT:
#   Prints the absolute path(s) of the saved image file(s) to stdout,
#   one path per line. All other messages go to stderr.
#   Exit code 0 on success, non-zero on failure.
#
# EXAMPLES:
#   generate-image.sh -b transparent "Flat vector logo of a fox, isolated"
#   generate-image.sh "A red panda in a cherry blossom tree"
#   generate-image.sh --size 1536x1024 --quality high "A foggy mountain at dawn"
#   generate-image.sh -s auto -q low -n 3 "Abstract watercolor swirls"
#   generate-image.sh --format jpeg --output /tmp/hero.jpg "A neon cityscape"
#   generate-image.sh --edit photo.png "Remove the background"
#   generate-image.sh -e img1.png -e img2.png "Combine into a collage"
#
# REQUIREMENTS:
#   - curl      (HTTP requests)
#   - jq        (JSON parsing)
#   - base64    (image decoding)
#   - OPENAI_API_KEY env var (assumed to be set in the environment)
# =============================================================================

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────────────────────────
MODEL="gpt-image-2.5-sunburst"
SIZE="auto"
BACKGROUND="auto"
QUALITY="medium"
COUNT=1
FORMAT="png"
OUTPUT=""
PROMPT=""
EDIT_IMAGES=()

# ── Helpers ───────────────────────────────────────────────────────────────────
usage() {
  grep '^#' "$0" | sed 's/^# \{0,1\}//' | sed 's/^#//'
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

info() {
  echo "$*" >&2
}

# ── Argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage; exit 0 ;;
    -m|--model)
      MODEL="$2"; shift 2 ;;
    -b|--background)
      BACKGROUND="$2"; shift 2 ;;
    -s|--size)
      SIZE="$2"; shift 2 ;;
    -q|--quality)
      QUALITY="$2"; shift 2 ;;
    -n|--count)
      COUNT="$2"; shift 2 ;;
    -f|--format)
      FORMAT="$2"; shift 2 ;;
    -o|--output)
      OUTPUT="$2"; shift 2 ;;
    -e|--edit)
      EDIT_IMAGES+=("$2"); shift 2 ;;
    -*)
      die "Unknown option: $1. Run with --help for usage." ;;
    *)
      # First non-option arg is the prompt
      PROMPT="$1"; shift ;;
  esac
done

# ── Validation ────────────────────────────────────────────────────────────────
[[ -z "$PROMPT" ]]          && die "A prompt is required. Run with --help for usage."
[[ -z "${OPENAI_API_KEY:-}" ]] && die "OPENAI_API_KEY environment variable is not set."

command -v curl   &>/dev/null || die "'curl' is required but not installed."
command -v jq     &>/dev/null || die "'jq' is required but not installed."
command -v base64 &>/dev/null || die "'base64' is required but not installed."

[[ "$COUNT" =~ ^[0-9]+$ ]] && [[ "$COUNT" -ge 1 ]] && [[ "$COUNT" -le 10 ]] \
  || die "--count must be an integer between 1 and 10."

if [[ "$SIZE" != "auto" ]]; then
  [[ "$SIZE" =~ ^([0-9]+)x([0-9]+)$ ]] || die "Invalid --size '$SIZE'. Use auto or WIDTHxHEIGHT."
  W=${BASH_REMATCH[1]}; H=${BASH_REMATCH[2]}
  LONG=$(( W > H ? W : H )); SHORT=$(( W > H ? H : W )); PX=$(( W * H ))
  (( W % 16 == 0 && H % 16 == 0 ))   || die "--size edges must be multiples of 16."
  (( LONG <= 3840 ))                 || die "--size edges must be <= 3840."
  (( LONG <= SHORT * 3 ))            || die "--size aspect ratio must be <= 3:1."
  (( PX >= 655360 && PX <= 8294400 )) || die "--size total pixels must be 655,360..8,294,400."
fi

case "$QUALITY" in
  low|medium|high|xhigh|max|auto) ;;
  *) die "Invalid --quality '$QUALITY'. Run with --help for allowed values." ;;
esac

case "$FORMAT" in
  png|jpeg|webp) ;;
  *) die "Invalid --format '$FORMAT'. Run with --help for allowed values." ;;
esac

case "$BACKGROUND" in
  auto|opaque) ;;
  transparent) [[ "$FORMAT" != "jpeg" ]] || die "Transparent background needs --format png or webp." ;;
  *) die "Invalid --background '$BACKGROUND'. Run with --help for allowed values." ;;
esac

if [[ ${#EDIT_IMAGES[@]} -gt 16 ]]; then
  die "--edit accepts at most 16 images."
fi
for img in "${EDIT_IMAGES[@]}"; do
  [[ -f "$img" ]] || die "Edit image not found: $img"
done

# ── Call the API ──────────────────────────────────────────────────────────────
if [[ ${#EDIT_IMAGES[@]} -gt 0 ]]; then
  info "Editing ${#EDIT_IMAGES[@]} image(s) with $MODEL [size=$SIZE, quality=$QUALITY, background=$BACKGROUND, format=$FORMAT]..."

  CURL_ARGS=(
    -sS -X POST "https://api.openai.com/v1/images/edits"
    -H "Authorization: Bearer $OPENAI_API_KEY"
    -F "model=$MODEL"
    -F "background=$BACKGROUND"
    -F "prompt=$PROMPT"
    -F "n=$COUNT"
    -F "size=$SIZE"
    -F "quality=$QUALITY"
    -F "output_format=$FORMAT"
  )
  for img in "${EDIT_IMAGES[@]}"; do
    CURL_ARGS+=(-F "image[]=@$img")
  done

  RESPONSE=$(curl "${CURL_ARGS[@]}") || die "curl request failed. Check your network or API key."
else
  REQUEST_BODY=$(jq -cn \
    --arg model   "$MODEL" \
    --arg bg      "$BACKGROUND" \
    --arg prompt  "$PROMPT" \
    --arg size    "$SIZE" \
    --arg quality "$QUALITY" \
    --arg format  "$FORMAT" \
    --argjson n   "$COUNT" \
    '{
      model:         $model,
      prompt:        $prompt,
      size:          $size,
      quality:       $quality,
      output_format: $format,
      background:    $bg,
      n:             $n
    }'
  )

  info "Generating $COUNT image(s) with $MODEL [size=$SIZE, quality=$QUALITY, background=$BACKGROUND, format=$FORMAT]..."

  RESPONSE=$(curl -sS https://api.openai.com/v1/images/generations \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$REQUEST_BODY") || die "curl request failed. Check your network or API key."
fi

# Check for API-level errors
if echo "$RESPONSE" | jq -e '.error' &>/dev/null; then
  API_ERROR=$(echo "$RESPONSE" | jq -r '.error.message')
  die "API error: $API_ERROR"
fi

# ── Decode and save each image ────────────────────────────────────────────────
TIMESTAMP=$(date +%s)

for i in $(seq 0 $((COUNT - 1))); do
  B64=$(echo "$RESPONSE" | jq -r ".data[$i].b64_json") \
    || die "Failed to parse image $((i+1)) from API response."
  [[ "$B64" == "null" || -z "$B64" ]] \
    && die "No image data returned for image $((i+1)). Response: $RESPONSE"

  if [[ -n "$OUTPUT" && "$COUNT" -eq 1 ]]; then
    OUTFILE="$OUTPUT"
  else
    OUTFILE="/tmp/openai_${TIMESTAMP}_$((i+1)).$FORMAT"
  fi

  echo "$B64" | base64 --decode > "$OUTFILE" \
    || die "Failed to decode/write image to $OUTFILE."

  if command -v convert &>/dev/null && [[ "$FORMAT" == "png" || "$FORMAT" == "jpeg" || "$FORMAT" == "webp" ]]; then
    convert "$OUTFILE" -fuzz 5% -trim +repage "$OUTFILE" 2>/dev/null \
      && info "Trimmed whitespace → $OUTFILE"
  fi

  info "Saved image $((i+1))/$COUNT → $OUTFILE"
  echo "$OUTFILE"
done
