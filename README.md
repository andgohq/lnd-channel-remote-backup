# umbrel-lnd-channel-backup
Monitors LND's channel.backup file for changes and uploads those changes to Dropbox when detected.

This script is for Umbrel only.

This script is forked from https://github.com/jlopp/bitcoin-utils/blob/master/lnd-channel-backup-dropbox.sh

## Requirements

Umbrel: https://getumbrel.com/

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

Edit the following line

```plain
DROPBOX_APITOKEN="ADD_OAUTH_LONG_LIVED_TOKEN_WITH_WRITE_ACCESS_HERE"
```

The api token is obtained by creating a new app in your dropbox account.
The next section describes how to obtain a long lived token.

4. Setup script as systemd service

```sh
sudo nano /etc/systemd/system/backup-channels.service
```

Add the following lines:

```
[Service]
ExecStart=/home/umbrel/umbrel-lnd-channel-backup.sh
Restart=always
RestartSec=1
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=backup-channels
User=umbrel
Group=umbrel

[Install]
WantedBy=multi-user.target
```

After make the above file, start the service.

```sh
sudo systemctl start backup-channels
```

Monitor the log file.

```sh
journalctl -fu backup-channels
```

If there is no problem, the backup file named `channel.backup_{date}` is stored in your Dropbox "Apps" folder.

After confirm that, run the following command to set the service to start on boot.

```sh
sudo systemctl enable backup-channels
```

## How to generate Dropbox access token

1. Go to https://www.dropbox.com/developers/apps/create
2. Select "Scoped access", "app folder" and type globally unique app name

![Dropbox API 1](https://raw.githubusercontent.com/andgohq/umbrel-lnd-channel-backup/main/images/dropbox-1.png)
3. On Permissions tab, check `files.content.write` and click the `Submit` button

![Dropbox API 1](https://raw.githubusercontent.com/andgohq/umbrel-lnd-channel-backup/main/images/dropbox-2.png)

![Dropbox API 1](https://raw.githubusercontent.com/andgohq/umbrel-lnd-channel-backup/main/images/dropbox-3.png)
4. On Settings tab, select `No expiration` on the `Access token expiration` and click `Generate` button on the `Generated access token`

![Dropbox API 1](https://raw.githubusercontent.com/andgohq/umbrel-lnd-channel-backup/main/images/dropbox-4.png)

Paste it to the `DROPBOX_APITOKEN` variable in the script
