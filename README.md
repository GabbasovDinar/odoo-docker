# odoo-docker
Docker Compose for Odoo 16.0

## Overview
This **docker compose** project is inspired by [Odoocker](https://github.com/odoocker/odoocker) with slight modifications to better suit specific use cases. All commands described in [Odoocker's documentation](https://github.com/odoocker/odoocker/blob/16.0/README.md) are available here unless overridden or excluded as specified in this documentation.


# The `.env` File Changes

## New Environment Variables

The following variables have been added to enhance functionality:

- To enable Odoo Enterprise:
  
    ```
    USE_ODOO_ENTERPRISE=true
    ```
- To specify the Enterprise repository URL (you can use your own fork):

    ```
    ENTERPRISE_REPO_URL=https://github.com/odoo/enterprise.git
    ```

**Note:** The **Odoo Enterprise** repository is private, and you can only access it if you have appropriate permissions. If you do not have access to the official repository, you can use your own fork of the repository by specifying the URL of your fork in the `ENTERPRISE_REPO_URL` variable.

## Removed Environment Variables

The following variables are no longer required:

```
GITHUB_USER
ENTERPRISE_USER
ENTERPRISE_ACCESS_TOKEN
```

## Updated Environment Variables

- The `GITHUB_ACCESS_TOKEN` variable is now used exclusively to authenticate and clone private repositories, including the Enterprise repository and third-party addons.

# The `odoo/Dockerfile` Changes

- **ARG Variables:**
  - Adjusted to align with the latest `.env` changes.
- **yq Integration:**
  - Added `yq` for YAML file parsing to dynamically process the `third-party-addons.yml` file.
- **Git Authentication:**
  - Configured Git to use `x-access-token` with `GITHUB_ACCESS_TOKEN` for secure cloning of private repositories.
- **Script-Based Automation:**
  - Included two new scripts:
    - `clone_enterprise.sh` for downloading Enterprise addons.
    - `clone_third_party_addons.sh` for managing third-party repositories and modules.

# Scripts

## `clone_enterprise.sh`

This script automates the process of downloading Odoo Enterprise addons:
- **Trigger:** Activated if `USE_ODOO_ENTERPRISE=true`.
- **Repository:** The URL specified in the `ENTERPRISE_REPO_URL` variable.
- **Authentication:** Uses `GITHUB_ACCESS_TOKEN` for access.
- **Target Directory:** Enterprise addons are downloaded to the `ENTERPRISE_ADDONS` directory.

## `clone_third_party_addons.sh`

This script handles third-party addons defined in the `third-party-addons.yml` file. Here's how it works:

### Key Features

- **Addons Management:**
  - Key `addons`: Specifies which addons to copy to `THIRD_PARTY_ADDONS`. If not specified, all repository contents are copied.
  - Key `exclude`: Specifies addons to exclude from copying. All other contents are copied.
- **Requirements Installation:**
  - Searches each repository for a `requirements.txt` file and consolidates all dependencies into a single `third-party-addons-requirements.txt` file.
  - Installs the consolidated requirements using `pip`.
- **Repository Cleanup:**
  - After copying addons and processing dependencies, source repositories are deleted to save space in the Docker image.

**Note:** These keys (`addons` and `exclude`) are new and are not related to Git Aggregator. They are used exclusively by the script responsible for forming the `THIRD_PARTY_ADDONS` folder. If both keys are specified, the `addons` key takes priority. Only the specified addons will be copied, and any addons listed in `exclude` will be ignored in the process.

### `third-party-addons.yml` Format

Define repositories, addons, and exclusions in `third-party-addons.yml`. 

Example:
```yml
./web:
    remotes:
        oca: https://github.com/oca/web.git
    merges:
        -
            remote: oca
            ref: "16.0"
            depth: 1
    addons: web_editor,web_grid
    exclude: web_notify
```

### How to Add a New Repository

- Add the repository details to `third-party-addons.yml` under a new key.
- Specify `addons` (optional) or `exclude` (optional) keys as needed.
- The script will automatically process the new repository during the next Docker build.

### Why Use Git Aggregator?

Git Aggregator is used to **aggregate** multiple Git repositories and their branches into a single repository, which makes it easier to work with multiple modules across different repositories. It is particularly useful for projects like Odoo, where you may need to pull in different versions of modules, often from different sources, and merge them into a single working environment.

In the context of this project, Git Aggregator is used to **fetch the required versions of modules** from various repositories and ensure they are properly merged into the desired branch. This allows for better management of dependencies and ensures that the necessary modules are always available and up to date.

For more detailed information, you can visit the official [Git Aggregator Documentation.](https://github.com/acsone/git-aggregator/blob/master/README.rst)
