#!/usr/bin/env sh
# Author: Ricardo Madriz
# Utility functions for columsn and such

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo_error() {
   echo -e "${RED}$@${NC}"
}
echo_green() {
   echo -e "${GREEN}$@${NC}"
}
echo_warning() {
   echo -e "${YELLOW}$@${NC}"
}
