#!/bin/bash

# Script to generate app icon set from source image
# Usage: ./generate_icons.sh

set -e  # Exit on error

# Configuration
SOURCE_IMAGE="assets/images/app_icon_flo_v1.png"
OUTPUT_DIR="macos/Runner/Assets.xcassets/AppIcon.appiconset"

# Required icon sizes for macOS
declare -a SIZES=(16 32 64 128 256 512 1024)

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  App Icon Generator${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# Check if source image exists
if [ ! -f "$SOURCE_IMAGE" ]; then
    echo -e "${RED}Error: Source image not found at $SOURCE_IMAGE${NC}"
    exit 1
fi

# Check if output directory exists
if [ ! -d "$OUTPUT_DIR" ]; then
    echo -e "${YELLOW}Creating output directory...${NC}"
    mkdir -p "$OUTPUT_DIR"
fi

# Get source image dimensions
SOURCE_WIDTH=$(sips -g pixelWidth "$SOURCE_IMAGE" | tail -n1 | awk '{print $2}')
SOURCE_HEIGHT=$(sips -g pixelHeight "$SOURCE_IMAGE" | tail -n1 | awk '{print $2}')

echo -e "Source image: ${YELLOW}$SOURCE_IMAGE${NC}"
echo -e "Dimensions: ${YELLOW}${SOURCE_WIDTH}x${SOURCE_HEIGHT}${NC}"
echo ""

# Check if source is square
if [ "$SOURCE_WIDTH" != "$SOURCE_HEIGHT" ]; then
    echo -e "${YELLOW}Warning: Source image is not square. It will be resized to square.${NC}"
    echo ""
fi

# Generate each required size
echo -e "${GREEN}Generating icon sizes...${NC}"
echo ""

for SIZE in "${SIZES[@]}"; do
    OUTPUT_FILE="$OUTPUT_DIR/app_icon_$SIZE.png"

    echo -e "  Creating ${YELLOW}${SIZE}x${SIZE}${NC} → $OUTPUT_FILE"

    # Use sips to resize the image
    sips -z $SIZE $SIZE "$SOURCE_IMAGE" --out "$OUTPUT_FILE" > /dev/null 2>&1

    # Verify the output file was created
    if [ ! -f "$OUTPUT_FILE" ]; then
        echo -e "${RED}    Failed to create $OUTPUT_FILE${NC}"
        exit 1
    fi
done

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  Icon generation complete!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo -e "Generated icons in: ${YELLOW}$OUTPUT_DIR${NC}"
echo ""
echo "Generated sizes:"
for SIZE in "${SIZES[@]}"; do
    FILE="$OUTPUT_DIR/app_icon_$SIZE.png"
    if [ -f "$FILE" ]; then
        FILE_SIZE=$(du -h "$FILE" | cut -f1)
        echo -e "  • ${SIZE}x${SIZE} - $FILE_SIZE"
    fi
done
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "  1. Rebuild your app: flutter build macos --release"
echo "  2. Package as DMG: ./package_dmg.sh"
echo ""
