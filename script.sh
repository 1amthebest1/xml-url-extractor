#!/bin/bash

# Function to fetch and extract URLs from a given sitemap URL
fetch_urls_from_sitemap() {
    local sitemap_url="$1"
    curl -s "$sitemap_url" | grep -oP '(?<=<loc>)[^<]+' >> "$output_file"
}

# Function to process a list of sitemap URLs from a file
process_url_file() {
    local file_path="$1"
    while IFS= read -r url; do
        echo "Fetching $url..."
        fetch_urls_from_sitemap "$url"
    done < "$file_path"
}

# Check if the user provided a URL or a file path
if [ $# -lt 1 ]; then
    echo "Usage: $0 <url_or_file_path>"
    exit 1
fi

input="$1"
output_file="urls_list.txt"

# Clear the output file if it exists
> "$output_file"

if [[ "$input" =~ ^http ]]; then
    # Single URL provided
    echo "Fetching $input..."
    fetch_urls_from_sitemap "$input"
elif [[ -f "$input" ]]; then
    # File path provided
    echo "Processing file $input..."
    process_url_file "$input"
else
    echo "Invalid input. Please provide a URL or a file path."
    exit 1
fi

echo "URL extraction complete. URLs saved in $output_file"
