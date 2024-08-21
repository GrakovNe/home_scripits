#!/bin/bash

# Check if a directory is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <folder>"
    exit 1
fi

folder="$1"

# Loop through each .mkv file in the directory
for video_file in "$folder"/*.mkv; do
    [ -e "$video_file" ] || continue

    # Get the base name without extension
    base_name=$(basename "$video_file" .mkv)

    # Initialize arrays for audio and subtitle files
    audio_files=()
    subtitle_files=()

    # Look for corresponding audio and subtitle files
    for file in "$folder"/"$base_name"*; do
        if [[ "$file" == "$video_file" ]]; then
            continue
        elif [[ "$file" == *.srt || "$file" == *.ass ]]; then
            subtitle_files+=("$file")
        elif [[ "$file" == *.mka || "$file" == *.ac3 || "$file" == *.dts || "$file" == *.mp3 || "$file" == *.aac ]]; then
            audio_files+=("$file")
        fi
    done

    # Construct the mkvmerge command
    output_file="$folder/${base_name}_merged.mkv"
    mkvmerge_cmd=("mkvmerge" "-o" "$output_file")

    # Add the video track
    mkvmerge_cmd+=("--language" "0:rus" "$video_file")

    # Add audio tracks if found
    for audio_file in "${audio_files[@]}"; do
        lang_code=$(echo "$audio_file" | grep -oP "\.[a-z]{3}\." | head -1 | sed 's/\.//g') # Extract first language code from filename
        if [[ -n "$lang_code" ]]; then
            mkvmerge_cmd+=("--language" "0:$lang_code" "$audio_file")
        fi
    done

    # Add subtitle tracks if found
    for subtitle_file in "${subtitle_files[@]}"; do
        lang_code=$(echo "$subtitle_file" | grep -oP "\.[a-z]{3}\." | head -1 | sed 's/\.//g') # Extract first language code from filename
        if [[ -n "$lang_code" ]]; then
            mkvmerge_cmd+=("--sub-charset" "0:utf-8" "--language" "0:$lang_code" "$subtitle_file")
        fi
    done

    # Run the mkvmerge command
    "${mkvmerge_cmd[@]}"

    echo "Created: $output_file"
done
