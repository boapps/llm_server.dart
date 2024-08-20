#!/bin/bash

echo "script run"

# Function to convert a file to a C++ header format
convert_to_header() {
    input_file=$1
    output_file=$2
    name=$(basename "$input_file" | sed 's/\./_/g' | sed 's/-/_/g')

    {
        echo "unsigned char ${name}[] = {"
        od -v -t x1 -An "$input_file" | sed -E 's/([0-9a-fA-F]+)/0x\1, /g'
        echo "};"
        echo "unsigned int ${name}_len = $(wc -c < "$input_file");"
    } > "$output_file"
}

# List of files to process
files=(
    "colorthemes.css"
    "style.css"
    "theme-beeninorder.css"
    "theme-ketivah.css"
    "theme-mangotango.css"
    "theme-playground.css"
    "theme-polarnight.css"
    "theme-snowstorm.css"
    "index.html"
    "index-new.html"
    "index.js"
    "completion.js"
    "system-prompts.js"
    "prompt-formats.js"
    "json-schema-to-grammar.mjs"
)

cd llama.cpp/examples/server
for file in "${files[@]}"; do
    convert_to_header "public/$file" "$file.hpp"
done
cd ../../..
