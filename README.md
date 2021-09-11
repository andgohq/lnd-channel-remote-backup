# lnd-channel-backup
Monitors LND's channel.backup file for changes and uploads those changes to Dropbox when detected

This script is forked from https://github.com/jlopp/bitcoin-utils/blob/master/lnd-channel-backup-dropbox.sh

## Setup

1. ssh to umbrel.

2. Run the command:

  ```sh
  cd && wget -qN https://raw.githubusercontent.com/andgohq/umbrel-lnd-channel-backup/main/umbrel-lnd-channel-backup.sh && chmod +x umbrel-lnd-channel-backup.sh

  sudo apt update
  sudo apt install -y inotify-tools jq
  ```

3. Edit the umbrel-lnd-channel-backup.sh file and set the following variables:

  ```sh
  nano umbrel-lnd-channel-backup.sh
  ```

  ```plain
  DROPBOX_APITOKEN="ADD_OAUTH_LONG_LIVED_TOKEN_WITH_WRITE_ACCESS_HERE"
  ```
