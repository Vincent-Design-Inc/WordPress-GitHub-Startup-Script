#!/usr/bin/env bash

# Check if the required commands are available
command -v git >/dev/null 2>&1 || { echo >&2 "Git is not installed. Please install Git before running this script."; exit 1; }

# Check for GitHub CLI (gh) and offer to install it using Homebrew
if !command -v gh &> /dev/null; then
    read -p "GitHub CLI (gh) is not installed. Do you want to install it using Homebrew? (y/n): " install_gh

    if [ "$install_gh" == "y" ] || [ "$install_gh" == "Y" ]; then
        if command -v brew &> /dev/null; then
            brew install gh
        else
            echo "Homebrew is not installed. Please install Homebrew and then run 'brew install gh' to install GitHub CLI."
            exit 1
        fi
    else
        echo "GitHub CLI (gh) is required to run this script. Please install it and try again."
        exit 1
    fi
fi

# Function to prompt for input with a default value
function prompt_with_default {
    local prompt="$1"
    local default="$2"
    local value
    read -p "$prompt [$default]: " value
    echo "${value:-$default}"
}

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

echo "---------------------------------------------"

# Step 3: Update style.css and bud.config.js with the theme information
if [ $# -lt 2 ]; then
    theme_name=$(prompt_with_default "Enter Theme Name (Title Case with spaces)" "My Theme")
else
    theme_name="$2"
fi

# Update style.css with the Theme Name
sed -i '' "s/Theme Name:.*/Theme Name: $theme_name/" style.css

# Update bud.config.js with the Foldere Name
sed -i '' "s#app.setPublicPath('.*')#app.setPublicPath('/wp-content/themes/$folder_name/public/')#" bud.config.js

# Step 4: Create a new GitHub repository using GitHub CLI
gh repo create "Vincent-Design-Inc/$folder_name" --private

echo "---------------------------------------------"

# Step 5: Change the remote repository URL
git remote set-url origin "git@github.com:Vincent-Design-Inc/$folder_name.git"

echo "---------------------------------------------"

# Step 6: Set up development dependencies
composer install
yarn install
yarn build

echo "---------------------------------------------"

# Step 7: Perform an initial commit with date and time in the message, and set up repository secrets
current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
initial_commit_message="Initial commit - $current_date_time"

# Step 7a: Set up initial commit
git add .
git commit -m "$initial_commit_message"
git push -u origin main

echo "---------------------------------------------"

# Step 7b: Set up repository secrets
echo "Setting REMOTE_TARGET to /www/wp-content/themes/$folder_name/"
gh secret set REMOTE_TARGET --body "/www/wp-content/themes/$folder_name/"
echo "Adding REMOTE_USER. Set this on GitHub once ready to start deploying"
gh secret set REMOTE_USER --body "org+vincent-design+"
echo "Setting PHP_VERSION to 8.1.  Change on GitHub if needed"
gh secret set PHP_VERSION --body "8.1"

echo "---------------------------------------------"

echo "Setup completed successfully."

echo "---------------------------------------------"

# Step 8: Ask the user if they want to open the project in Visual Studio Code
read -p "Do you want to open the project in Visual Studio Code? (y/n): " open_vscode
if [ "$open_vscode" == "y" ] || [ "$open_vscode" == "Y" ]; then
    if command -v code &> /dev/null; then
        # The 'code' command-line tool is available
        code .
    else
        echo "Visual Studio Code (code) is not installed or not in your $PATH. Please open the project manually in VS Code."
    fi
fi
