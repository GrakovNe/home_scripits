#!/bin/bash

# Check for the correct number of arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_directory>"
    exit 1
fi

# Input directory
input_directory="$1"

# Temporary directory
temp_directory="/mnt/external/temp"

# Create temporary directory
mkdir -p "$temp_directory"

# Run extract_content.sh
/root/automations/extract_content.sh "$input_directory" "$temp_directory"

# Check for success
if [ $? -ne 0 ]; then
    echo "Error executing extract_content.sh"
    rm -rf "$temp_directory"
    exit 1
fi

# Run merge_in_one_container.sh
/root/automations/merge_in_one_container.sh "$temp_directory"

# Check for success
if [ $? -ne 0 ]; then
    echo "Error executing merge_in_one_container.sh"
    rm -rf "$temp_directory"
    exit 1
fi

# Run clean_up_unmerged.sh
/root/automations/clean_up_unmerged.sh "$temp_directory"

# Check for success
if [ $? -ne 0 ]; then
    echo "Error executing clean_up_unmerged.sh"
    rm -rf "$temp_directory"
    exit 1
fi

# Run classify_and_copy.sh
filebot -rename --action duplicate --format "/mnt/external/Anime/{n}/Season {s00.pad(2)}/{n} S{s00}E{e00}" -non-strict "$temp_directory" --db TheTVDB >> /root/automations/log.txt 2>&1

# Clean up temporary directory
rm -rf "$temp_directory"

echo "Process completed successfully."
