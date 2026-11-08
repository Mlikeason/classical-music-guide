#!/bin/sh
set -eu

# Export the original website icon at the size required by the iOS asset catalog.
# Keep its colors, artwork and composition; do not generate a replacement design.
project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
/usr/bin/sips --resampleHeightWidth 1024 1024 \
  "$project_root/apple-touch-icon.png" \
  --out "$project_root/ios/ClassicalGuide/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
