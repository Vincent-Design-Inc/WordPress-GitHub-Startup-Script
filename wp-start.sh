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

# Function to set up the proper environment variables and run the plugin install script
install_plugins() {
    local input_string="$1"
    local search_folder="$HOME/Library/Application Support/Local/ssh-entry"

    # Split the string into an array based on dashes or underscores
    IFS="-_" read -ra parts <<< "$input_string"

    # Create an array to store matching files
    local matching_files=()

    # Create an associative array to store both filename and CD paths
    local filenames=()
    local cd_paths=()

    # Loop through each part of the split string and search for files
    for part in "${parts[@]}"; do
        # Use grep to search for files containing the string and add them to the matching_files array
        files_containing_part=$(grep -ril "$part" "$search_folder")
        matching_files+=("$files_containing_part")
    done

    # Deduplicate the list of matching files
    matching_files=($(echo "${matching_files[@]}" | tr ' ' '\n' | sort -u))

    # Loop through each matching file
    for file in "${matching_files[@]}"; do
        if [[ "$file" == *".sh" ]]; then
            # Extract the filename without the path and .sh extension
            filename=$(basename "$file" .sh)

            cd "$search_folder"

            cd_line=$(grep -m 1 "cd " "$filename.sh")

            if [ -n "$cd_line" ]; then
                # Extract the path from the cd line
                path=$(echo "$cd_line" | awk -F 'cd ' '{print $2}' | tr -d '"')

                # Store the filename and the path in their respective arrays
                filenames+=("$filename")
                cd_paths+=("$path")
            fi
        fi
    done

    # Debugging: remove the following lines
    echo "Found the following matching files:"
    for i in "${matching_files[@]}"; do
        echo "- $i"
    done
    pause
    echo '---------------------------------------------'
    echo "Found the following files:"
    for i in "${filenames[@]}"; do
        echo "- $i"
    done
    pause
    echo '---------------------------------------------'
    echo "Found the following paths:"
    for i in "${cd_paths[@]}"; do
        echo "- $i"
    done
    echo '---------------------------------------------'

    export MYSQL_HOME="$HOME/Library/Application Support/Local/run/$filenames/conf/mysql"
    export PHPRC="$HOME/Library/Application Support/Local/run/$filenames/conf/php"
    export WP_CLI_CONFIG_PATH="/Applications/Local.app/Contents/Resources/extraResources/bin/wp-cli/config.yaml"
    export WP_CLI_DISABLE_AUTO_CHECK_UPDATE=1
    export PATH="$HOME/Library/Application Support/Local/lightning-services/mysql-8.0.16+6/bin/darwin/bin:$PATH"
    export PATH="$HOME/Library/Application Support/Local/lightning-services/php-8.1.23+0/bin/darwin/bin:$PATH"
    export PATH="/Applications/Local.app/Contents/Resources/extraResources/bin/wp-cli/posix:$PATH"
    export PATH="/Applications/Local.app/Contents/Resources/extraResources/bin/composer/posix:$PATH"
    export MAGICK_CODER_MODULE_PATH="$HOME/Library/Application Support/Local/lightning-services/php-8.1.23+0/bin/darwin/ImageMagick/modules-Q16/coders"

    cd "$cd_paths"
    # Update wp-config.php with the proper mysql host
    sed -i '' "s#define( 'DB_HOST', '.*' )#define( 'DB_HOST', '$HOME/Library/Application Support/Local/run/$filenames/mysql/mysqld.sock' )#" wp-config.php

    cd "$cd_paths/wp-content/themes/$input_string"
    "./plugins.sh"

    cd "$cd_paths"
    # Revert wp-config.php change
    sed -i '' "s#define( 'DB_HOST', '.*' )#define( 'DB_HOST', 'localhost' )#" wp-config.php
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

# Step 2: Set up repository and add starter
git init
git fetch --depth=1 -n git@github.com:Vincent-Design-Inc/starter-theme-3.git

# Step 2a: Create a new GitHub repository using GitHub CLI
gh repo create "Vincent-Design-Inc/$folder_name" --private

echo "---------------------------------------------"

# Step 2b: Add the remote repository
git remote add origin "git@github.com:Vincent-Design-Inc/$folder_name.git"

echo "---------------------------------------------"

current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
initial_commit_message="Initial commit - $current_date_time"

# Step 2c: Set up initial commit message
git reset --hard $(git commit-tree FETCH_HEAD^{tree} -m "$initial_commit_message")

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

# Step 3a: Set up development dependencies
composer install
yarn install
yarn build

echo "---------------------------------------------"

# Step 4: Perform an initial push to GitHub, and set up repository secrets
git push -u origin main

echo "---------------------------------------------"

# Step 4a: Set up repository secrets
echo "Setting REMOTE_TARGET to /www/wp-content/themes/$folder_name/"
gh secret set REMOTE_TARGET --body "/www/wp-content/themes/$folder_name/"
echo "Adding REMOTE_USER. Set this on GitHub once ready to start deploying"
gh secret set REMOTE_USER --body "org+vincent-design+"
echo "Setting PHP_VERSION to 8.1.  Change on GitHub if needed"
gh secret set PHP_VERSION --body "8.1"

echo "---------------------------------------------"

# Step 5: Install plugins
echo "Installing plugins (cmd: install_plugins($folder_name))"
cd "$HOME/Local Sites"
#install_plugins "$folder_name"

echo "---------------------------------------------"

echo "Setup completed successfully."

echo "---------------------------------------------"

# Step 6: Ask the user if they want to open the project in Visual Studio Code
read -p "Do you want to open the project in Visual Studio Code? (y/n): " open_vscode
if [ "$open_vscode" == "y" ] || [ "$open_vscode" == "Y" ]; then
    if command -v code &> /dev/null; then
        # The 'code' command-line tool is available
        code .
    else
        echo "Visual Studio Code (code) is not installed or not in your $PATH. Please open the project manually in VS Code."
    fi
fi
