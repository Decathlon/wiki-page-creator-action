<h1>
  <p align="center">
    Wiki Page Creator GitHub Action
  </p>
</h1>
<p align="center">
  This repository provides a GitHub action to <strong>publish Wiki pages <i>with a provided markdown</i></strong> into the Wiki section of your GitHub repository.
</p>

**Table of Contents**

  - [Common usage](#common-usage)
  - [Breaking change](#breaking-change)
  - [Use Github action](#use-github-action)
    - [Settings for v1.0.0+ release (deprecated)](#settings-for-v100-release-deprecated)
    - [Settings for v2.0.0+ release](#settings-for-v200-release)
    - [Environment Variables options](#environment-variables-options)
  - [Full Example (with additional actions to generate content)](#full-example-with-additional-actions-to-generate-content)
    - [Using v1.0.0+](#using-v100)
    - [Using v2.0.0+](#using-v200)
- [Credits](#credits)

## Common usage
The action requires some content _markdown/wiki pages_ that must be generated on a previous step, and located into a specific folder.  
This action scans the folder, adds its files, and finally publishes them to the wiki.

## Breaking change

Starting from August 2019, GitHub team switch [Actions syntax from HCL to YAML](https://help.github.com/en/articles/migrating-github-actions-from-hcl-syntax-to-yaml-syntax).  
The previous syntax will no longer be supported by GitHub on September 30, 2019.

As a consequence, __please use v2.0.0+__ release and note that __all v1.x.x are deprecated__ and will no longer work on September 30, 2019.

## Use Github action

__*Please note that this action requires your repo to already own at least one page in the wiki section: https://github.com/:yourOrganization/:yourRepository/wiki*__

### Settings for v1.0.0+ release (deprecated)

To use this action simply add it to your `main.workflow` file.

```
action "wiki-page-creator-action" {
  uses = "docker://decathlon/wiki-page-creator-action:1.0.0"
  needs = ["Create Release Notes"]
  secrets = [
    "GH_PAT",
  ]
  env = {
    ACTION_MAIL = "my@mail.com"
    ACTION_NAME = "myusername"
    OWNER = "yourGitHubOrganisation"
    REPO_NAME = "yourGitHubRepository"
  }
}
```

### Settings for v2.0.0+ release
```YAML
- name: Upload Release Notes to Wiki
  uses: docker://decathlon/wiki-page-creator-action:2.0.0
  env:
    GH_PAT: ${{ secrets.GH_PAT }}
    ACTION_MAIL: youremail@mail.com
    ACTION_NAME: yourusername
    OWNER: yourGitHubOrganisation
    REPO_NAME: yourGitHubRepository
```

### Environment Variables options

To be able to push the new Wiki Page, the action requires some environment variables/secrets:
* **GH_PAT**: (required) GitHub Private Access Token used for the clone/push operations. The token is used for security reasons, instead of the username/password, and because is the only way to access to repositories for organizations using SSO. To create it follow the [GitHub Documentation](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line).
* **ACTION_MAIL**: (required) email used to push new wiki pages into the target repository
* **ACTION_NAME**: (required) username to use in the push command
* **OWNER**: (required) repository owner name.
* **REPO_NAME**: (required) repository name where you want to upload the wiki page to.
* **MD_FOLDER**: (optional - default is the current folder) folder to scan for markdown files
* **SKIP_MD**: (optional - all files will be processed) comma separated list of files to skip during the analysis (files you don't want to publish)
* **WIKI_PUSH_MESSAGE**: (optional - sample message will use instead) Custom push message for your wiki pages.

## Full Example (with additional actions to generate content)

The following one is the workflow we are using to push the release notes to our project wikis.

In this example the workflow is started `on milestone`; the first action is filtering on the `closed` action of the milestone (if milestone is created, renamed, ... the other steps are skipped).

The `create-release-notes-action` creates the markdown file (check [here](https://github.com/Decathlon/release-notes-generator-action) if your need more information). 
The output file is stored into the `temp_release_notes`.

The `wiki-page-creator-action` takes all the markdown files from the `temp_release_notes` folder (skipping a README.md file if found) and uploads them to the provided wiki repo.

### Using v1.0.0+
```
workflow "Sprint Closure" {
  on = "milestone"
  resolves = ["Upload Release Notes on Wiki"]
}

action "action-filter" {
  uses = "actions/bin/filter@master"
  args = "action closed"
}

action "Create Release Notes" {
  uses = "docker://decathlon/release-notes-generator-action:1.0.0"
  secrets = ["GITHUB_TOKEN"]
  needs = ["action-filter"]
  env = {
    USE_MILESTONE_TITLE = "true"
    OUTPUT_FOLDER = "temp_release_notes"
  }
}

action "Upload Release Notes on Wiki" {
  uses = "docker://decathlon/wiki-page-creator-action:1.0.0"
  needs = ["Create Release Notes"]
  secrets = [
    "GH_PAT",
  ]
  env = {
    ACTION_MAIL = "myuser@users.noreply.github.com"
    ACTION_NAME = "myPushingUser"
    OWNER = "yourGitHubOrganisation"
    REPO_NAME = "yourGitHubRepository"
    SKIP_MD = "README.md"
    MD_FOLDER = "temp_release_notes"
  }
}
```

### Using v2.0.0+

```YAML
on: milestone
name: Milestone Closure
jobs:
  action-filter:
    runs-on: ubuntu-18.04
    steps:
    - uses: actions/checkout@master
    - name: action-filter
      uses: actions/bin/filter@master
      with:
        args: action closed
    - name: Create Release Notes
      uses: docker://decathlon/release-notes-generator-action:2.0.0
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        OUTPUT_FOLDER: temp_release_notes
        USE_MILESTONE_TITLE: "true"
    - name: Upload Release Notes to Wiki
      uses: docker://decathlon/wiki-page-creator-action:latest
      env:
        ACTION_MAIL: myuser@users.noreply.github.com
        ACTION_NAME: myPushingUser
        GH_PAT: ${{ secrets.GH_PAT }}
        MD_FOLDER: temp_release_notes
        OWNER: yourGitHubOrganisation
        REPO_NAME: yourGitHubRepository
        SKIP_MD: README.md
```


# Credits
The code of this actions began on [mmornati](https://github.com/mmornati) github workspace.
