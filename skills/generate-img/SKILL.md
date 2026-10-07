---
name: generate-img
description: Generate or edit images with OpenAI GPT Image 2.5 (Sunburst/Flare) through a bundled bash script. Use when asked to "generate an image", "create an illustration/diagram/logo/mockup", "edit this image", "remove the background", or to produce any visual asset. The model is quite capable as long as the specification is clear.
---

# generate-img

Generate and edit images with `scripts/generate-img.sh` (relative to this skill directory). The script calls the OpenAI Images API, saves each image to disk, and prints the absolute path of each image on stdout (one per line). Logs go to stderr.

`OPENAI_API_KEY` is already set in the environment. Do not ask for it, and do not check or print it.

## Usage

```bash
SCRIPT=<skill-dir>/scripts/generate-img.sh

# Generate
$SCRIPT "<prompt>"
$SCRIPT -s 1536x1024 -q high "<prompt>"          # landscape diagram with small text
$SCRIPT -b transparent "<prompt>"                 # logo / sticker / cutout (png or webp)
$SCRIPT -n 3 -q low "<prompt>"                     # 3 cheap drafts
$SCRIPT -o ./assets/hero.png "<prompt>"            # explicit output path (only when n=1)

# Edit (1 to 16 input images, uses /images/edits)
$SCRIPT -e photo.png "Change only the sky to sunset. Keep everything else the same."
$SCRIPT -e person.png -e jacket.png "Image 1: person. Image 2: jacket. Dress the person in the jacket..."
```

| Flag | Values | Default |
|---|---|---|
| `-m, --model` | `gpt-image-2.5-sunburst` (best quality, best edit precision), `gpt-image-2.5-flare` (faster, about gpt-image-2 quality) | sunburst |
| `-s, --size` | `auto` or `WxH`. Common: `1024x1024`, `1536x1024`, `1024x1536`, `2048x2048`, `2048x1152`, `3840x2160`, `2160x3840` | `auto` |
| `-q, --quality` | `low`, `medium`, `high`, `xhigh`, `max`, `auto` | `medium` |
| `-b, --background` | `auto`, `opaque`, `transparent` | `auto` |
| `-n, --count` | 1 to 10 | 1 |
| `-f, --format` | `png`, `jpeg`, `webp` | `png` |
| `-o, --output` | file path (ignored when n>1) | `/tmp/openai_<ts>_<i>.<fmt>` |
| `-e, --edit` | input image path, can repeat | none |

Custom size rules: both edges are multiples of 16, max edge 3840, aspect ratio 3:1 or less, total pixels from 655,360 to 8,294,400. Sizes above 2560x1440 are experimental.

Notes:
- A request can take up to 2 minutes. Use a long timeout on the bash call.
- If ImageMagick `convert` is installed, the script trims flat borders from the output. The final size can be smaller than the requested size.
- Transparent backgrounds need `png` or `webp`.

## Choosing settings

- **Model:** use Sunburst by default. Use Flare when speed matters more than quality (many drafts, quick ideation), or when Flare already gives an acceptable result for the same prompt.
- **Quality:** use `low` for drafts and exploration, and `medium` for most final images. Use `high` for small or dense text, infographics, slides, close-up portraits, and identity-sensitive edits. Use `xhigh` or `max` only when `high` does not meet a specific requirement. A higher level costs more time and money, and it does not always give a better result.
- **Size:** use `1536x1024` for diagrams, slides, and landscape scenes. Use `1024x1536` for posters, phone UI, and portraits. Use `1024x1024` for icons and logos.

## Prompting guide (GPT Image 2.5)

These rules come from OpenAI's GPT Image 2.5 prompting guide.

1. **Define the result and its use.** Name the deliverable (product photo, ad, infographic, UI mockup, slide, logo) and the audience. This sets the level of polish.
2. **Use a fixed order.** Scene/background, then subject, then key details, then constraints. For complex requests, use short labeled sections or line breaks, not one long paragraph.
3. **Describe visible details.** Name the medium (photo, watercolor, flat vector, 3D render), materials, textures, colors, and lighting. Mood words alone are weak. For wide, cinematic, low-light, rain, or neon scenes, also give scale, atmosphere, and color.
4. **Photorealism:** write "photorealistic" or "real photograph" in the prompt. Describe the image as a candid shot taken in the moment, and ask for real texture (pores, wrinkles, worn fabric, imperfections). Lens or camera terms (35mm, 50mm, shallow depth of field) control the general look only, not exact optics. Do not use words that suggest studio polish if you want a natural result.
5. **Composition:** give framing (close-up, wide, top-down), angle (eye-level, low-angle), and placement ("logo top-right", "subject centered, empty space on the left").
6. **People:** give body framing, scale, gaze, and contact with objects. For example: "full body visible, feet included", "looking down at the open book, not at the camera", "hands gripping the handlebars".
7. **Exact text:** put the literal text in "quotes" or ALL CAPS. Give font style, size, color, and position. Say how many times the text appears ("render the tagline exactly once"). Spell unusual words or brand names letter by letter. Add "no extra text". Use `-q high` for small text.
8. **Constraints:** write the exclusions: "no watermark", "no extra text", "no logos or trademarks".
9. **Edits: separate what changes from what stays.** Write "Change only X. Keep everything else the same." Then list what to keep: identity, face, pose, geometry, layout, lighting, camera angle, labels, colors. For small local edits, also say not to change saturation, contrast, or nearby objects.
10. **Multiple input images:** give each image a number and a role. For example: "Image 1: product photo. Image 2: style reference. Apply the style of Image 2 to Image 1." Say which element goes where, and tell the model to match lighting, perspective, scale, and shadows.
11. **Transparent assets:** use `-b transparent` and write "isolated subject on a fully transparent background, no scenery, no solid backdrop, no checkerboard, no drop shadow". For each later edit, write "preserve the transparent background" again.
12. **Iterate.** Start with a clean base prompt. Then change one thing per step and pass the previous output with `-e`. Write the preserve list again each step to stop drift. If a region must stay identical to the pixel, composite the edited part onto the original image.
13. **Use world knowledge.** The model knows real places, periods, and events. For example, "Bethel, New York, August 1969" gives a Woodstock scene. You do not need to explain context the model already knows.

### Prompt patterns

**Infographic / diagram / slide** (write it as a spec, `-s 1536x1024 -q high`):
```
Create a simple biology diagram titled "Cellular Respiration at a Glance" for high school students.
Show how glucose turns into energy inside a cell. Include glycolysis, the Krebs cycle, and the electron transport chain.
Use arrows to connect the steps, and label the main molecules: glucose, pyruvate, ATP, NADH, FADH2, CO2, O2, and H2O.
Make it look like a clean classroom handout or slide, with a white background, simple icons, clear labels, and easy-to-read text.
Avoid tiny text, extra decoration, or anything that makes the diagram hard to understand.
```
Put the real numbers, labels, and data in the prompt. Ask for readable typography and no decorative clutter.

**Photorealistic:**
```
Create a photorealistic candid photograph of an elderly sailor standing on a small fishing boat.
He has weathered skin with visible wrinkles, pores, and sun texture. He is calmly adjusting a net while his dog sits nearby on the deck.
Shot like a 35mm film photograph, medium close-up at eye level, 50mm lens. Soft coastal daylight, shallow depth of field, subtle film grain, natural color balance.
The image should feel honest and unposed. No glamorization, no heavy retouching.
```

**Logo** (`-b transparent -n 4`):
```
Create an original, non-infringing logo for a company called Field & Flour, a local bakery.
Warm, simple, and timeless. Clean vector-like shapes, strong silhouette, balanced negative space.
Must read clearly at small and large sizes. Flat design, minimal strokes, no gradients.
Fully transparent background. A single centered logo with generous padding, clean alpha edges, no backdrop, no checkerboard, no watermark.
```

**Ad / marketing** (write it as a creative brief): give the brand, audience, vibe, scene, and the exact copy in quotes. Add "Render the tagline exactly once, clearly and legibly. No extra text, no watermarks, no unrelated logos."

**UI mockup:** describe the product as if it already ships. Give the layout, hierarchy, spacing, and real UI elements (header, list items, buttons). Do not use concept-art words. Example: "It should look like a real, well-designed app. Place the UI in an iPhone frame."

**Comic / story:** give 1 panel per story beat: "4 equal panels. Panel 1: ... Panel 2: ...". Make each panel concrete and about one action.

**Edit (surgical):**
```
Remove the flower from the man's hat. Change only that. Keep his face, expression, pose, clothing,
lighting, background, framing, and color grading exactly the same.
```

**Sketch to render:** "Turn this drawing into a photorealistic image. Keep the layout, perspective, and proportions of the sketch. Add realistic materials and lighting. Do not add new elements or text."

## Workflow

1. Turn the user request into a structured prompt with the rules above. Do not just pass the request through unchanged.
2. Choose the size, quality, and model. For uncertain concepts, make 2 or 3 drafts with `-q low` first.
3. Run the script and capture the path(s) printed on stdout.
4. Read the output image to check it: text spelling, labels, preserved details, unwanted changes, and alpha channel (if transparency was requested).
5. If the result fails a requirement, edit it with `-e <output>` and one targeted change. Do not regenerate from scratch.
6. Move or copy the file to where the user wants it. Give the user the final path.

## Errors

- `ERROR: API error: ...`: the request was rejected (moderation, invalid parameter, quota). Read the message. Do not retry a moderation or user error with the same prompt. Change the prompt first.
- Network or 5xx failures: retry once.
