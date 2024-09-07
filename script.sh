#!/bin/bash

# Function to fetch and extract URLs from a given sitemap URL
fetch_urls_from_sitemap() {
    local sitemap_url="$1"
    
    # Check if the URL points to a .gz file
    if [[ "$sitemap_url" =~ \.gz$ ]]; then
        echo "Processing gzipped sitemap: $sitemap_url..."
        curl -s "$sitemap_url" | gunzip | grep -oP '(?<=<loc>)[^<]+' >> "$output_file"
    else
        echo "Fetching sitemap: $sitemap_url..."
        curl -s "$sitemap_url" | grep -oP '(?<=<loc>)[^<]+' >> "$output_file"
    fi
}

# Function to process a list of sitemap URLs from a file
process_url_file() {
    local file_path="$1"
    while IFS= read -r url; do
        fetch_urls_from_sitemap "$url"
    done < "$file_path"
}

# Check if the user provided a URL or a file path
if [ $# -lt 1 ]; then
    echo "Usage: $0 <url_or_file_path>"
    exit 1
fi

input="$1"

# Prompt the user for the output file path
read -p "Enter the output file path: " output_file

# Clear the output file if it exists
> "$output_file"

if [[ "$input" =~ ^http ]]; then
    # Single URL provided
    fetch_urls_from_sitemap "$input"
elif [[ -f "$input" ]]; then
    # File path provided
    process_url_file "$input"
else
    echo "Invalid input. Please provide a URL or a file path."
    exit 1
fi

echo "URL extraction complete. URLs saved in $output_file"
