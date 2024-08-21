root@amc:~/automations# cat clean_up_unmerged.sh
#!/bin/bash

# Check for the correct number of arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Set the directory variable
DIR="$1"

# Check if the argument is a directory
if [ ! -d "$DIR" ]; then
    echo "Error: $DIR is not a directory."
    exit 1
fi

# Remove files that do not end with _merged.mkv
find "$DIR" -type f ! -name '*_merged.mkv' -exec rm -f {} +

echo "Cleanup complete."
