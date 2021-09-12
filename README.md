# lnd-channel-remote-backup

Monitors LND's channel.backup file for changes and uploads those changes to Dropbox when detected.

This script is forked from https://github.com/jlopp/bitcoin-utils/blob/master/lnd-channel-backup-dropbox.sh

## Support environments

- Umbrel - https://getumbrel.com/
- myNode - https://mynodebtc.com/

## Setup

1. ssh to umbrel / myNode

2. Run the command:

```sh
cd && wget -qN https://raw.githubusercontent.com/andgohq/lnd-channel-remote-backup/main/lnd-channel-remote-backup.sh && chmod +x lnd-channel-remote-backup.sh

sudo apt update
sudo apt install -y inotify-tools jq
```

3. Edit the lnd-channel-remote-backup.sh file and set the following variables:

```sh
nano lnd-channel-remote-backup.sh
```

Edit the following lines

```plain
# set the api token obtained from the Dropbox
DROPBOX_APITOKEN="ADD_OAUTH_LONG_LIVED_TOKEN_WITH_WRITE_ACCESS_HERE"
# enable these lines based on your environment
DATADIR=...
WORKINGDIR=...
HOSTNAME=...
```

The api token is obtained by creating a new app in your dropbox account.
The next section describes how to obtain a long lived token.

4. Setup script as systemd service

```sh
sudo nano /etc/systemd/system/lnd-channel-remote-backup.service
```

[Umbrel] Add the following lines:

```
[Service]
ExecStart=/home/umbrel/lnd-channel-remote-backup.sh
Restart=always
RestartSec=1
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=lnd-channel-remote-backup
User=umbrel
Group=umbrel

[Install]
WantedBy=multi-user.target
```

[myNode] Add the following lines:

```
[Service]
ExecStart=/home/admin/lnd-channel-remote-backup.sh
Restart=always
RestartSec=1
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=lnd-channel-remote-backup
User=admin
Group=admin

[Install]
WantedBy=multi-user.target
```


After make the above file, start the service.

```sh
sudo systemctl start lnd-channel-remote-backup
```

Monitor the log file.

```sh
journalctl -fu lnd-channel-remote-backup
```

If there is no problem, the backup file named `channel.backup_{date}` is stored in your Dropbox "Apps" folder.

After confirm that, run the following command to set the service to start on boot.

```sh
sudo systemctl enable lnd-channel-remote-backup
```

## How to generate Dropbox access token

1. Go to https://www.dropbox.com/developers/apps/create
2. Select "Scoped access", "app folder" and type globally unique app name

![Dropbox API 1](https://raw.githubusercontent.com/andgohq/lnd-channel-remote-backup/main/images/dropbox-1.png)
3. On Permissions tab, check `files.content.write` and click the `Submit` button

![Dropbox API 1](https://raw.githubusercontent.com/andgohq/lnd-channel-remote-backup/main/images/dropbox-2.png)

![Dropbox API 1](https://raw.githubusercontent.com/andgohq/lnd-channel-remote-backup/main/images/dropbox-3.png)
4. On Settings tab, select `No expiration` on the `Access token expiration` and click `Generate` button on the `Generated access token`

![Dropbox API 1](https://raw.githubusercontent.com/andgohq/lnd-channel-remote-backup/main/images/dropbox-4.png)

Paste it to the `DROPBOX_APITOKEN` variable in the script
