# ZIP Workspace

This Action is based upon [10up's WordPress Plugin Deploy](https://github.com/10up/action-wordpress-plugin-deploy) and zips the current workspace.
 
It can exclude files as defined in either `.distignore` or `.gitattributes`.

### ☞ For updating the readme and items in the assets directory between releases, please see our [WordPress.org Plugin Readme/Assets Update Action](https://github.com/10up/action-wordpress-plugin-asset-update)

## Configuration

### Optional environment variables
* `FILENAME` - Filename of the generated ZIP file, defaults to `workspace.zip`
* `SUBDIRECTORY` - Subdirectory to put the zipped files into, e.g. for WordPress plug-ins
* `WORKING_DIRECTORY` - Subdirectory in which the rsync command is executed, e.g. when using monorepos

## Excluding files from deployment
If there are files or directories to be excluded from deployment, such as tests or editor config files, they can be specified in either a `.distignore` file or a `.gitattributes` file using the `export-ignore` directive. If a `.distignore` file is present, it will be used; if not, the Action will look for a `.gitattributes` file and barring that, will write a basic temporary `.gitattributes` into place before proceeding so that no Git/GitHub-specific files are included.

`.distignore` is useful particularly when there are built files that are in `.gitignore`, and is a file that is used in [WP-CLI](https://wp-cli.org/). For modern plugin setups with a build step and no built files committed to the repository, this is the way forward. `.gitattributes` is useful for plugins that don't run a build step as a part of the Actions workflow and also allows for GitHub's generated ZIP files to contain the same contents. If you would like to attach a ZIP file with the proper contents that decompresses to a folder name without version number as WordPress generally expects, you can add steps to your workflow that generate the ZIP and attach it to the GitHub release (concrete examples to come).

### Sample baseline files

#### `.distignore`

**Notes:** `.distignore` is for files to be ignored **only**; it does not currently allow negation like `.gitignore`. This comes from its current expected syntax in WP-CLI's [`wp dist-archive` command](https://github.com/wp-cli/dist-archive-command/). It is possible that this Action will allow for includes via something like a `.distinclude` file in the future, or that WP-CLI itself makes a change that this Action will reflect for consistency. It also will need to contain more than `.gitattributes` because that method **also** respects `.gitignore`.

```
/.wordpress-org
/.git
/.github
/node_modules

.distignore
.gitignore
```

#### `.gitattributes`

```gitattributes
# Directories
/.wordpress-org export-ignore
/.github export-ignore

# Files
/.gitattributes export-ignore
/.gitignore export-ignore
```


## Example Workflow Files

To get started, you will want to copy the contents of one of these examples into `.github/workflows/deploy.yml` and push that to your repository. You are welcome to name the file something else.

### Deploy on pushing a new tag

```yml
name: Create ZIP file
on:
  push:
    tags:
    - "*"
jobs:
  tag:
    name: New tag
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Build # Remove or modify this step as needed
      run: |
        npm install
        npm run build
    - name: WordPress Plugin Deploy
      uses: schakko/action-zip-workspace@stable
      env:
        FILENAME: "my-custom-workspace.zip"
```
