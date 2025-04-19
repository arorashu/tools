#!/bin/bash

# Check if fzf is installed
if ! command -v fzf &>/dev/null; then
  echo "fzf is not installed. Please install fzf to use this script."
  exit 1
fi

# Get the root of the Git repository
repo_root=$(git rev-parse --show-toplevel)
if [ $? -ne 0 ]; then
  echo "Not inside a Git repository. Exiting."
  exit 1
fi

# Change to the repository root
cd "$repo_root" || exit 1

# Function to get tracked files
get_tracked_files() {
  git ls-files
}

# Function to select files with fzf
select_files() {
  get_tracked_files | fzf --multi --prompt="Select files to include (Tab to select multiple): "
}

# Function to get output filename
get_output_filename() {
  read -p "Enter the output filename (default: selected_codebase.txt): " output_name
  echo "${output_name:-selected_codebase.txt}"
}

# Function to write selected files to output
write_to_output() {
  local output_file="$1"
  shift
  local selected_files=("$@")
  >"$output_file" # Clear the output file first
  for file in "${selected_files[@]}"; do
    if [ -f "$file" ]; then
      num_lines=$(wc -l <"$file")
      # Write start marker
      echo "## start_of_file: $file, Lines: $num_lines" >>"$output_file"
      # Append file contents
      cat "$file" >>"$output_file"
      # Write end marker
      echo "" >>"$output_file"
      echo "## end_of_file: $file" >>"$output_file"
      # Add an extra newline for clear separation
      echo "" >>"$output_file"
    fi
  done
}

# Main script
selected_files=()
while IFS= read -r file; do
  selected_files+=("$file")
done < <(select_files)

if [ ${#selected_files[@]} -eq 0 ]; then
  echo "No files selected. Exiting."
  exit 0
fi

output_file=$(get_output_filename)
write_to_output "$output_file" "${selected_files[@]}"
echo "Selected files have been written to $output_file"
