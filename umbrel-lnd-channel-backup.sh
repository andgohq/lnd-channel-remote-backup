#!/bin/bash

# SET DROPBOX API KEY FOR UPLOADS
DROPBOX_APITOKEN="ADD_OAUTH_LONG_LIVED_TOKEN_WITH_WRITE_ACCESS_HERE"

# SET LND DIR
DATADIR="/home/umbrel/umbrel/lnd"

# SET WORK DIR
WORKINGDIR="/home/umbrel"

# SET A DEVICE NAME TO BE USED FOR BACKUPS
BACKUPFOLDER="channel-backups"


# SETUP
# --------------

setup_files_and_folders () {
	# channel.backup file details
	CHANFILEDIR=data/chain/bitcoin/mainnet
	BACKUPFILE=channel.backup
	SOURCEFILE=$DATADIR/$CHANFILEDIR/$BACKUPFILE

	# Make sure necessary folders exist
	if [[ ! -e ${WORKINGDIR} ]]; then
	        mkdir -p ${WORKINGDIR}
	fi
	cd ${WORKINGDIR}

	if [[ ! -e ${BACKUPFOLDER} ]]; then
	        mkdir -p ${BACKUPFOLDER}
	fi
	cd ${BACKUPFOLDER}
}


# CHECKS
# --------------

online_check () {
	wget -q --tries=10 --timeout=20 --spider http://google.com
	if [[ $? -eq 0 ]]; then
	        ONLINE=true
	else
	        ONLINE=false
	fi
	#echo "Online: "$ONLINE
}

dropbox_api_check () {
	VALID_DROPBOX_APITOKEN=false
	curl -s -X POST https://api.dropboxapi.com/2/users/get_current_account \
	    --header "Authorization: Bearer "$DROPBOX_APITOKEN | grep rror
	if [[ ! $? -eq 0 ]] ; then
	        VALID_DROPBOX_APITOKEN=true
	else
		echo "Invalid Dropbox API Token!"
	fi
}

dropbox_upload_check () {
	UPLOAD_TO_DROPBOX=false
	if [ ! -z $DROPBOX_APITOKEN ] ; then
		online_check
		if [ $ONLINE = true ] ; then
			dropbox_api_check
		else
			echo "Please check that the internet is connected and try again."
		fi

		if [ $VALID_DROPBOX_APITOKEN = true ] ; then
			UPLOAD_TO_DROPBOX=true
		fi
	fi
}


# UPLOAD
# --------------

upload_to_dropbox () {
	FINISH=$(curl -s -X POST https://content.dropboxapi.com/2/files/upload \
	    --header "Authorization: Bearer "${DROPBOX_APITOKEN}"" \
	    --header "Dropbox-API-Arg: {\"path\": \"/"$BACKUPFOLDER"/"$1"\",\"mode\": \"overwrite\",\"autorename\": true,\"mute\": false,\"strict_conflict\": false}" \
	    --header "Content-Type: application/octet-stream" \
	    --data-binary @$1)
	# echo $FINISH
	UPLOADTIME=$(echo $FINISH | jq -r .server_modified)
	if [ "$UPLOADTIME" != "null" ] ; then
		echo "Successfully uploaded!"
	else
		echo "Unknown error when uploading..."
	fi
}

# RUN CHECKS AND IF PASS, EXECUTE BACKUP TO DROPBOX
run_dropbox_backup () {
	dropbox_upload_check
	if [ $UPLOAD_TO_DROPBOX = true ] ; then
		upload_to_dropbox $1
	fi
}


##############
# RUN SCRIPT
##############

run_backup_on_change () {
	    echo "Copying backup file..."
	    BACKUPFILE_TIMESTAMPED=$BACKUPFILE-$(date +%s)
	    cp $SOURCEFILE $BACKUPFILE_TIMESTAMPED
	    md5sum $SOURCEFILE > $BACKUPFILE_TIMESTAMPED.md5
	    sed -i 's/\/.*\///g' $BACKUPFILE_TIMESTAMPED.md5

	    echo
	    echo "Uploading backup file: '"${BACKUPFILE_TIMESTAMPED}"'..."
	    run_dropbox_backup $BACKUPFILE_TIMESTAMPED
	    echo "---"
	    echo "Uploading signature: '"${BACKUPFILE_TIMESTAMPED}.md5"'..."
	    run_dropbox_backup $BACKUPFILE_TIMESTAMPED.md5
}

run () {
	setup_files_and_folders
	run_backup_on_change
	while true; do
	    inotifywait $SOURCEFILE
	    run_backup_on_change
	    echo
	done
}

run
