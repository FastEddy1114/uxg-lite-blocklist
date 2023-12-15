#!/bin/bash
# Wait two minutes to begin
sleep 120

# Create log file
{
echo "Blocklist update started"
}  > /persistent/system/blocklist-processing.txt

# UXG-Lite IPv4 iptables/ipset lists start with UBIOS4
real_list='UBIOS4'
# Search config to find GUID of FireHOL ipset list
real_list+=$(grep -B3 "FireHOL" /data/udapi-config/udapi-net-cfg.json | head -n 1 | awk '{print $2}' | sed -e 's/"//g' -e 's/,//')
[[ -z "$real_list" ]] && { echo "aborting"; exit 1; } || echo "Will update FireHOL list ID $real_list"

# Create temp list
ipset_list="temporary-list"

# Find UXG-Lite uptime
uxgliteupt=$(uptime | awk '{print $4}')

# Check for existence of blocklist backup file
backupexists="/persistent/system/blocklist-backup.bak"

if [ -e $backupexists ]
then
	backupexists="TRUE"
else
	backupexists="FALSE"
fi

# Define function
process_blocklist () {
	# Delete ipset list name of temporary-list if it exists
	/usr/sbin/ipset -! destroy $ipset_list
	
	# Create new blank temporary-list
	/usr/sbin/ipset create $ipset_list hash:net

	# loop through firehol block lists and parse them for CIDR entries
	for url in https://iplists.firehol.org/files/firehol_level1.netset https://iplists.firehol.org/files/firehol_level2.netset https://iplists.firehol.org/files/firehol_webclient.netset https://iplists.firehol.org/files/firehol_abusers_1d.netset https://iplists.firehol.org/files/myip.ipset https://iplists.firehol.org/files/iblocklist_onion_router.netset
	do
		echo "Fetching and processing $url"
		{
		echo "Processing blocklist"
		date
		echo $url
		} >> /persistent/system/blocklist-processing.txt
		curl "$url" | awk '/^[1-9]/ { print $1 }' | xargs -n1 /usr/sbin/ipset -! add $ipset_list
	done

	# Determine if temporary-list is empty and if not back it up
	tlcontents=$(/usr/sbin/ipset list $ipset_list | grep -A1 "Members:" | sed -n '2p')

	if [ -z "$tlcontents" ]
	then 
		echo "Temporary list is empty, not backing up or swapping list. Leaving current list and contents in place."
		{
		echo "Temporary list is empty, not backing up or swapping list. Leaving current list and contents in place."
		date
		} >> /persistent/system/blocklist-processing.txt
	else 
		/usr/sbin/ipset save $ipset_list -f /persistent/system/blocklist-backup.bak
		/usr/sbin/ipset swap $ipset_list "$real_list"
		echo "Blocklist is updated and backed up"
		{
		echo "Blocklist is updated and backed up"
		date
		} >> /persistent/system/blocklist-processing.txt
	fi

	# Write blocklist contents to the log file
	{
	echo "Blocklist contents"
	/usr/sbin/ipset list -s "$real_list"
	} >> /persistent/system/blocklist-processing.txt
		
	{
	echo "Blocklist processing finished"
	date
	} >> /persistent/system/blocklist-processing.txt
 
	# Delete temporary-list from memory
	/usr/sbin/ipset -! destroy $ipset_list
	echo "Blocklist processing finished"
}

# Logic to determine script/function execution
if [ "$uxgliteupt" == "min," ] && [ "$backupexists" = "TRUE" ]
then
	echo "UXG-Lite uptime is less than one hour, and backup list is found" 
	echo "Loading previous version of blocklist. This will speed up provisioning"
	{
	echo "UXG-Lite uptime is less than one hour, and backup list is found" 
	echo "Loading previous version of blocklist. This will speed up provisioning"
	date
	} >> /persistent/system/blocklist-processing.txt
	# Restore blocklist from backup file
	/usr/sbin/ipset restore -f /persistent/system/blocklist-backup.bak
	/usr/sbin/ipset swap $ipset_list "$real_list"
	/usr/sbin/ipset -! destroy $ipset_list
	{
	echo "Blocklist contents"
	/usr/sbin/ipset list -s "$real_list"
	echo "Restoration of blocklist backup complete"
	date
	} >> /persistent/system/blocklist-processing.txt
	echo "Restoration of blocklist backup complete"
elif [ "$uxgliteupt" == "min," ] && [ "$backupexists" == "FALSE" ]
then
	echo "UXG-Lite uptime is less than one hour, but backup list is not found"
	echo "Proceeding to create new blocklist. This will delay provisioning, but ensure you are protected"
	{
	echo "UXG-Lite uptime is less than one hour, but backup list is not found"
	echo "Proceeding to create new blocklist. This will delay provisioning, but ensure you are protected"
	date
	} >> /persistent/system/blocklist-processing.txt
	# Call function
	process_blocklist
	echo "First time creation of blocklist complete"
else
	echo "Routine processing of blocklist started"
	{
	echo "Routine processing of blocklist started"
	date
	} >> /persistent/system/blocklist-processing.txt
	# Call function
	process_blocklist
	echo "Routine processing of blocklist complete"
fi
