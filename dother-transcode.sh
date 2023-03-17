#!/usr/bin/env bash

# Loop through input parameters looking for "--help" and "--version"
noEncode=false
if [ $# -eq 0 ]; then
    noEncode=true
else
    for param in "$@"; do
	    if [ "$param" = "--help" ] || [ "$param" = "-h" ] || [ "$param" = "--version" ]; then
		    noEncode=true
        fi
    done
fi

if [ "$noEncode" = true ]; then
    exec docker run --rm -v "$(pwd)":"$(pwd)" -w "$(pwd)" ghcr.io/ttys0/other-transcode:sw-latest "$@"
else
    # Number of arguments minus 1
    num_args=$(($#-1))

    # input file path (assuming last argument is the input file)
    input_file_path="${@:$#}"

    # Generate absolute file path and split into diretory and filename
    absolute_input=$(realpath "$input_file_path")
    directory=$(dirname "$absolute_input")
    filename=$(basename "$absolute_input")

    # docker command
    exec docker run --rm -v "$directory":/src -v "$(pwd)":/out -w /out ghcr.io/ttys0/other-transcode:sw-latest "${@:1:$num_args}" "/src/$filename"
fi