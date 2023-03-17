#!/usr/bin/env bash

# Docker image name
image="ghcr.io/ttys0/other-transcode:sw-latest"

# Check to see if docker exists
if ! command -v docker &> /dev/null; then
    echo "Docker cannot be found on this system"
    exit
fi

# Check if docker image $image exists
if ! docker image inspect "$image" &> /dev/null; then
    echo "Docker image $image cannot be found on this system"
    exit
fi

# Initiate 'noEncode' flag and empty arrays for files and non-file parametes
noEncode=false
files=()
newparams=()

# Check if there are any parameters, if not set 'noEncode' flag
if [ $# -eq 0 ]; then
    noEncode=true
else
    # Loop through all input parameters
    for param in "$@"; do
        # Set 'noEncode' flag if '--help', '-h' or '--version' appear in parameters
	    if [ "$param" = "--help" ] || [ "$param" = "-h" ] || [ "$param" = "--version" ]; then
		    noEncode=true
        fi

        # Seperate files from the rest of the parameters
        if [ -f "$param" ]; then
            files+=("$param")
        else
            newparams+=("$param")
        fi
    done
fi

# If 'noEncode' flag has been set, run simplified docker command
if [ "$noEncode" = true ]; then
    exec docker run --rm -v "$(pwd)":"$(pwd)" -w "$(pwd)" "$image" "$@"
else
    # Loop throught each file in files
    for file in "${files[@]}"; do
        # Generate absolute file path and split into diretory and filename
        absolute_input=$(realpath "$file")
        directory=$(dirname "$absolute_input")
        filename=$(basename "$absolute_input")

        # Run docker command
        docker run --rm -v "$directory":/src -v "$(pwd)":/out -w /out "$image" "${newparams[@]}" "/src/$filename"
    done
fi