#!/bin/bash

# Initialize variables
FOLDER_PATH=""
IMAGE_TAG=""
REGISTRY_NAME=""
PREFIX=""

# Parse named parameters
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --folder-path) FOLDER_PATH="$2"; shift ;;
        --image-tag) IMAGE_TAG="$2"; shift ;;
        --registry-name) REGISTRY_NAME="$2"; shift ;;
        --image-prefix) PREFIX="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Check if all required parameters are provided
if [ -z "$FOLDER_PATH" ] || [ -z "$IMAGE_TAG" ] || [ -z "$REGISTRY_NAME" ] || [ -z "$PREFIX" ]; then
    echo "Usage: $0 --folder-path <folder_path> --image-tag <image_tag> --registry-name <registry_name> --image-prefix <prefix>"
    exit 1
else
    echo "Parameters:"
    echo "  Folder Path: $FOLDER_PATH"
    echo "  Image Tag: $IMAGE_TAG"
    echo "  Registry Name: $REGISTRY_NAME"
    echo "  Image Prefix: $PREFIX"
fi

# Check if the provided folder path exists
if [ ! -d "$FOLDER_PATH" ]; then
    echo "The folder path $FOLDER_PATH does not exist."
    exit 1
fi

shopt -s nullglob
bicep_files=("$FOLDER_PATH"/*.bicep)
shopt -u nullglob

if [ ${#bicep_files[@]} -eq 0 ]; then
    echo "No .bicep files found in the folder $FOLDER_PATH."
    exit 1
fi

# Loop through all .bicep files in the specified folder
for bicep_file in "${bicep_files[@]}"; do
    # Get the file name without the extension
    repo_name=$(basename "$bicep_file" .bicep)
    
    # Publish the Bicep module to the registry
    echo "Publishing $bicep_file to $REGISTRY_NAME/$PREFIX/$repo_name:$IMAGE_TAG"
    az bicep publish --file "$bicep_file" --target "br:$REGISTRY_NAME/$PREFIX/$repo_name:$IMAGE_TAG"
done

echo "All Bicep modules have been published."