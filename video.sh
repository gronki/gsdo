#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ERUP_DIR="$SCRIPT_DIR/data/erup"

function process_dir {
	echo "Processing: $1"
	#if [ -f "$1/erup.mp4" ]; then
	#		echo "skipping $1"
	#			continue
	#fi

	ffmpeg \
		-framerate 15 \
		-i "$1/f%03d.png" \
		-vf "crop=iw-mod(iw\,2):ih-mod(ih\,2)" \
		-c:v libx264 -crf 18 -pix_fmt yuv420p -y \
		"$1/erup.mp4" 
}

if [ -d "$1" ]; then
	process_dir "$1"
else
	find "$ERUP_DIR" -type d -mindepth 1 | while read f; do
	echo "input $f"
	process_dir "$f" || continue
	done
fi
