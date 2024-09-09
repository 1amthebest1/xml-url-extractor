#!/bin/bash

# Function to extract URLs from a file
extract_urls() {
    local input_file=$1
    local output_file=$2

    # Extract only valid URLs (preserving special characters like &) and save to the output file
    grep -Eo '(http|https)://[a-zA-Z0-9./?=_&%-]*' "$input_file" >> "$output_file"
    echo "URLs extracted and saved to $output_file"
}

# Function to handle .gz files
handle_gz_files() {
    local gz_file=$1
    local output_file=$2

    echo "Found .gz file: $gz_file"

    # Check if gzip is installed
    if ! command -v gzip &> /dev/null; then
        read -p "gzip is not installed. Would you like to install it? (y/n): " choice
        if [[ $choice == "y" ]]; then
            sudo apt-get update && sudo apt-get install -y gzip
            echo "gzip installed successfully."
        else
            echo "Skipping .gz file processing."
            return
        fi
    fi

    # Download the .gz file using wget
    wget "$gz_file" -O temp.gz

    # Extract and grep for URLs inside the .gz file
    gunzip -c temp.gz | grep -Eo '(http|https)://[a-zA-Z0-9./?=_&%-]*' >> "$output_file"
    echo "URLs extracted from $gz_file and appended to $output_file"
    
    # Clean up
    rm temp.gz
}

# Function to handle .xml files
handle_xml_files() {
    local xml_file=$1
    local output_file=$2

    echo "Found .xml file: $xml_file"

    # Download the .xml file using wget
    wget "$xml_file" -O temp.xml

    # Extract and grep for URLs inside the .xml file
    grep -Eo '(http|https)://[a-zA-Z0-9./?=_&%-]*' temp.xml >> "$output_file"
    echo "URLs extracted from $xml_file and appended to $output_file"
    
    # Clean up
    rm temp.xml
}

# Main script logic
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file=$1

# Prompt for output file or path
read -p "Enter the output file/path for extracted URLs: " output_file

# Extract URLs from the provided input file
extract_urls "$input_file" "$output_file"

# Loop to continuously process .xml files until none are found
while true; do
    # Check for .gz files and process them
    gz_files_found=false
    grep -Eo '(http|https)://[a-zA-Z0-9./?=_&%-]+\.gz' "$input_file" | while read -r gz_file; do
        handle_gz_files "$gz_file" "$output_file"
        gz_files_found=true
    done

    # Check for .xml files and process them
    xml_files_found=false
    grep -Eo '(http|https)://[a-zA-Z0-9./?=_&%-]+\.xml' "$input_file" | while read -r xml_file; do
        handle_xml_files "$xml_file" "$output_file"
        xml_files_found=true
    done

    # If no .xml files or .gz files were found in the current loop, break
    if [[ "$xml_files_found" == false && "$gz_files_found" == false ]]; then
        echo "No more .xml or .gz files found. Exiting loop."
        break
    fi

    # Extract URLs from the newly downloaded XML files
    extract_urls temp.xml "$output_file"
done

echo "Processing complete."
