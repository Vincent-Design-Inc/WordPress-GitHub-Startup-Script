# GitHub Repository Setup Script

This script automates the process of setting up a new theme using our starter with a GitHub repository for WordPress projects. It performs the following tasks:

1. Creates a folder in the current directory based on a provided name (or a default name if none is provided). The folder name is converted to lowercase with dashes for spaces.

2. Clones the [starter-theme-3](https://github.com/Vincent-Design-Inc/starter-theme-3) repository from GitHub into the newly created folder.

3. Updates the `style.css` file with the Theme Name based on user input (or a default name if none is provided). The Theme Name is converted to title case.

4. Creates a new GitHub repository under our GitHub organization.

5. Changes the remote repository URL to the newly-created GitHub repository.

6. Performs an initial commit with a commit message that includes the date and time of the commit.

## Usage
1. Ensure you have the following prerequisites installed on your system:
   - Git
   - GitHub CLI (`gh`)

2. Save the script to a file, e.g., `setup.sh`, in your project themes directory and make it executable:
   `chmod +x setup.sh`

    Run the script:
    `./setup.sh [FOLDER_NAME] [THEME_NAME]`

        FOLDER_NAME (optional): Specify the desired folder name (lowercase with dashes for spaces) for your project. If not provided, you will be prompted to enter the folder name.
        THEME_NAME (optional): Specify the desired Theme Name (title case) for your project. If not provided, you will be prompted to enter the Theme Name.

    Follow the prompts to enter folder and theme names if not provided as arguments.

    The script will create the folder, clone the starter theme repository, update the style.css file, create a new GitHub repository, set the remote URL, and perform an initial commit.

    You will be prompted for any necessary inputs during the script execution.

    Your project is now set up on GitHub, and the initial commit is pushed to the repository.

Happy coding!

