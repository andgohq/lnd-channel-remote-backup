# lnd-channel-backup
Monitors LND's channel.backup file for changes and uploads those changes to Dropbox when detected

This script is forked from https://github.com/jlopp/bitcoin-utils/blob/master/lnd-channel-backup-dropbox.sh

## Setup

1. ssh to umbrel.

2. Run the command:

```sh
wget

sudo apt update
sudo apt install -y inotify-tools jq
```
