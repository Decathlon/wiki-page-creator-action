# wiki-page-creator-action
The target of this action is to publish Wiki pages using the provided markdown: into the repository, commits or as the result of a previous action.

## Getting Started
To use this action simply add it to your `main.workflow` file.

```
action "wiki-page-creator-action" {
  uses = "decathlon/wiki-page-creator-action@master"
  needs = ["Create Release Notes"]
  secrets = [
    "GH_PAT",
  ]
  env = {
    ACTION_MAIL = "my@mail.com"
    ACTION_NAME = "myusername"
    OWNER = "decathlon"
    REPO_NAME = "my-sample-repo"
  }
}
```

To be able to push the new Wiki Page, the action requires some environment variables/secrets:
* **GH_PAT**: (required) GitHub Private Access Token used for the clone/push operations. The token is used for security reasons, instead of the username/password, and because is the only way to access to repositories for organizations using SSO. To create it follow the [GitHub Documentation](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line).
* **ACTION_MAIL**: (required) email used to push new wiki pages into the target repository
* **ACTION_NAME**: (required) username to use in the push command
* **OWNER**: (required) repository owner name.
* **REPO_NAME**: (required) repository name where you want to upload the wiki page to.
* **MD_FOLDER**: (optional - default is the current folder) folder to scan for markdown files
* **SKIP_MD**: (optional - all files will be processed) comma separated list of files to skip during the analysis (files you don't want to publish)
* **WIKI_PUSH_MESSAGE**: (optional - sample message will use instead) Custom push message for your wiki pages.

## Example
The following one is the workflow we are using to push the release notes to our project wikis.

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
  uses = "Decathlon/release-notes-generator-action@master"
  secrets = ["GITHUB_TOKEN"]
  needs = ["action-filter"]
  env = {
    USE_MILESTONE_TITLE = "true"
    OUTPUT_FOLDER = "temp_release_notes"
  }
}

action "Upload Release Notes on Wiki" {
  uses = "Decathlon/wiki-page-creator-action@master"
  needs = ["Create Release Notes"]
  secrets = [
    "GH_PAT",
  ]
  env = {
    ACTION_MAIL = "myuser@users.noreply.github.com"
    ACTION_NAME = "myPushingUser"
    OWNER = "decathlon"
    REPO_NAME = "my-sample-repo"
    SKIP_MD = "README.md"
    MD_FOLDER = "temp_release_notes"
  }
}
```

In this example the workflow is started `on milestone`; the first action is filtering on the `closed` action of the milestone (if milestone is created, renamed, ... the other steps are skipped).

The `create-release-notes-action` is taking care to the markdown file creation (check [here](https://github.com/Decathlon/release-notes-generator-action) if your need more information). The output file is stored into the `temp_release_notes`.

Then the `wiki-page-creator-action` is taking all the MD files into the `temp_release_notes` folder (skipping a README.md file if found) and is uploading them to the provided wiki repo.

# Credits
The code of this actions began on [mmornati](https://github.com/mmornati) github workspace. 