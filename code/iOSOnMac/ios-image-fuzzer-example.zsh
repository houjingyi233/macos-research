#!/bin/zsh

# Path to the logfile
LOGFILE="image-logfile.txt"

# Directory containing PNG files
PNG_DIR="image.app/img"

# Start the processing
{
    # Loop through all PNG files in the directory
    for img in "$PNG_DIR"/*.png; do
        echo "Processing file: $img"

        # Process each image with all 12 permutations
        for i in {1..12}; do
            echo "Applying permutation $i to $img"
            ./runner image.app/image "$img" $i
        done
    done
} | tee "$LOGFILE"
