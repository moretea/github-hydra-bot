# Github + Hydra bot

The purpose of this bot is to have hydra build a specific SHA when commanded to.

## Configuration

You must set:
```
RACK_ENV=production # to prevent leaking of e.g. stack traces over HTTP.
BOT_NAME=some_bot_name
ACCESS_FILE=path_to_acces_file
OAUTH_TOKEN=token
GITHUB_OWNER=nixos
GITHUB_REPO=nixpkgs
WEBHOOK_SECRET=yaddayadda
```

## Access list
For now I would suggest to use an cronjob to update the ACCESS file.
`curl https://api.github.com/orgs/nixos/public_members | jq .[].login -r > tmp_file && mv tmp_file /path/to/access-file`
(the mv is to ensure atomicity, note that the tmp file should be on the same filesystem as the access file.)
