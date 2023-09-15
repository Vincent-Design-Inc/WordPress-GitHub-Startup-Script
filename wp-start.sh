#!/usr/bin/env bash

# Check if the required commands are available
command -v git >/dev/null 2>&1 || { echo >&2 "Git is not installed. Please install Git before running this script."; exit 1; }
command -v gh >/dev/null 2>&1 || { echo >&2 "GitHub CLI (gh) is not installed. Please install GitHub CLI before running this script."; exit 1; }

# Function to prompt for input with a default value
function prompt_with_default {
    local prompt="$1"
    local default="$2"
    local value
    read -p "$prompt [$default]: " value
    echo "${value:-$default}"
}

org_name="Vincent-Design-Inc"  # Organization name, used in repo creation steps

# Step 1: Create a folder in the current directory
if [ $# -eq 0 ]; then
    folder_name=$(prompt_with_default "Enter folder name (lowercase with dashes for spaces)" "my-theme-folder")
else
    folder_name="$1"
fi

# Ensure the folder name is lowercase with dashes for spaces
folder_name=$(echo "$folder_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Create the folder
if [ -d "$folder_name" ]; then
    echo "Folder '$folder_name' already exists. Aborting."
    exit 1
fi

mkdir "$folder_name"
cd "$folder_name"

# Step 2: Clone the GitHub repository
git clone git@github.com:Vincent-Design-Inc/starter-theme-3.git .

# Step 3: Update style.css with the Theme Name
if [ $# -lt 2 ]; then
    theme_name=$(prompt_with_default "Enter Theme Name (Title Case with spaces)" "My Theme")
else
    theme_name="$2"
fi

# Update style.css with the Theme Name
sed -i "s/Theme Name:.*/Theme Name: $theme_name/" style.css

# Step 4: Create a new GitHub repository using GitHub CLI
gh repo create "$org_name/$folder_name" --private

# Step 5: Change the remote repository URL
git remote set-url origin "git@github.com:$org_name/$folder_name.git"

# Step 6: Perform an initial commit with date and time in the message
current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
initial_commit_message="Initial commit - $current_date_time"

git add .
git commit -m "$initial_commit_message"
git push -u origin main

echo "Setup completed successfully."
