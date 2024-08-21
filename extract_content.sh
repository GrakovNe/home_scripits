#!/bin/bash

# Check if the required arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <content_directory> <temp_directory>"
    exit 1
fi

# Set the working directory and temp directory
content_dir="$1"
temp_dir="$2"

# Create the temp directory if it doesn't exist
mkdir -p "$temp_dir"

# Function to create hard links with a postfix
create_hardlinks_with_postfix() {
    local src_dir=$1

    # Determine the postfix based on the directory name
    if [[ $src_dir =~ ENG ]]; then
        postfix="eng"
    elif [[ $src_dir =~ RUS ]]; then
        postfix="rus"
    else
        postfix=""
    fi

    # Create an associative array to track filenames
    declare -A existing_files

    # Iterate over all files in the source directory
    for file in "$src_dir"/*; do
        # Extract the file name without the path
        filename=$(basename "$file")

        # Add the postfix before the file extension if applicable
        if [ -n "$postfix" ]; then
            ext="${filename##*.}"
            name="${filename%.*}"
            new_filename="${name}.${postfix}.${ext}"
        else
            new_filename="$filename"
        fi

        # Check for existing files and create a unique filename if needed
        if [[ -e "$temp_dir/$new_filename" ]] || [[ -n "${existing_files[$new_filename]}" ]]; then
            counter=1
            base_new_filename="$new_filename"
            while [[ -e "$temp_dir/$new_filename" ]] || [[ -n "${existing_files[$new_filename]}" ]]; do
                new_filename="${base_new_filename%.*}.$(printf "%02d" $counter).${base_new_filename##*.}"
                ((counter++))
            done
        fi

        # Create the hard link in the temp directory
        ln "$file" "$temp_dir/$new_filename"
        existing_files[$new_filename]=1  # Mark this filename as existing
    done
}

# Create hard links for video files without changes
create_hardlinks_with_postfix "$content_dir"

# Create hard links for directories with audio and subtitles
for dir in "$content_dir"/*/; do
    if [[ "$dir" != "$temp_dir/" ]]; then
        create_hardlinks_with_postfix "$dir"
    fi
done

echo "Hard links creation completed."
