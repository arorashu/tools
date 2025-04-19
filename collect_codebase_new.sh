#!/bin/bash

# Define the output file
output_file="codebase.txt"

# Clear the output file if it exists
>"$output_file"

# Add directory structure section
echo "## Directory Structure" >>"$output_file"
git ls-files | sort >>"$output_file"
echo "" >>"$output_file"

# Process each tracked file from Git
git ls-files | while read -r file; do
  # Skip the output file itself
  if [ "$file" = "$output_file" ]; then
    continue
  fi

  # Skip media files
  case "$file" in
  *.png | *.mp4 | *.mpg | *.jpg | *.jpeg | *.gif | *.avi | *.mov | *.svg)
    continue
    ;;
  esac

  # Ensure it’s a regular file
  if [ ! -f "$file" ]; then
    continue
  fi

  # Check file size (in bytes)
  size=$(wc -c <"$file")
  if [ "$size" -gt $((500 * 1024)) ]; then
    echo "Skipping large file: $file ($size bytes)"
    continue
  fi

  # Count the number of lines in the file
  num_lines=$(wc -l <"$file")
  # Write the header with filename and line count
  echo "## File: $file, Lines: $num_lines" >>"$output_file"
  # Append the file contents
  cat "$file" >>"$output_file"
  # Write end marker
  echo "" >>"$output_file"
  echo "## end_of_file: $file" >>"$output_file"
  # Add an extra newline for clear separation
  echo "" >>"$output_file"
done
