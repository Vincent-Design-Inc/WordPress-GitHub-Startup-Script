# GitHub Repository Setup Script

This script automates the process of setting up a new theme using our starter with a GitHub repository for WordPress projects. It performs the following tasks:

1. Creates a folder in the current directory based on a provided name (or a default name if none is provided). The folder name is converted to lowercase with dashes for spaces.

2. Clones the [starter-theme-3](https://github.com/Vincent-Design-Inc/starter-theme-3) repository from GitHub into the newly created folder.

3. Updates the `style.css` file with the Theme Name based on user input (or a default name if none is provided). The Theme Name is converted to title case.

4. Creates a new GitHub repository under our GitHub organization.

5. Changes the remote repository URL to the newly-created GitHub repository.

6. Installs development dependencies with composer and yarn, and performs the initial `yarn build`.

7. Performs an initial commit with a commit message that includes the date and time of the commit.

8. (Optional) Open the theme in VSCode via the `code` command line tool.  The script will let you know if it's not available.


## Usage
1. Ensure you have the following prerequisites installed on your system (the script will check to make sure they are installed):
   - Git
   - GitHub CLI (`gh`)
     - **If you need GitHub CLI, install it with Homebrew: `brew install gh`**
     - **Make sure you have authorized GitHub CLI using `gh auth login`**

2. Save the script to a file, e.g., `wp-start.sh`, in your project themes directory and make it executable:
   `chmod +x wp-start.sh`

    Run the script:
    `./wp-start.sh [FOLDER_NAME] [THEME_NAME]`

    If you do not provide a folder or theme name, the script will prompt you to enter a folder name.

    - **FOLDER_NAME (optional):** Specify the desired folder name (lowercase with dashes for spaces) for your project.
    - **THEME_NAME (optional):** Specify the desired Theme Name (title case) for your project.
