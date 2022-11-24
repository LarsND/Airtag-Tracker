#!/bin/bash

ORIG_ITEM_LOC="/Users/$USER/Library/Caches/com.apple.findmy.fmipcore/Items.data"
TEMP_ITEM_LOC="/tmp/airtag_tems.data"
STORAGE_LOG_LOC="/Users/$USER/AirTag-logs/"
#Number of seconds between starting to relog the items
WAIT_REFRESH_FINDMY_SECONDS=10
WAIT_BETWEEN_LOOP_SECONDS=110
DELETE_LOGS_AFTER_DAYS=30

while :
do
    echo "Deleting logs older than $DELETE_LOGS_AFTER_DAYS days..."
    find "$STORAGE_LOG_LOC"*.csv -type f -ctime +$DELETE_LOGS_AFTER_DAYS -maxdepth 0 -delete
	echo "Starting and refreshing Find My..."
    osascript -e 'tell application "FindMy" to set bounds of window 1 to {-3000, 0, 100, 100}' &> /dev/null
    sleep $WAIT_REFRESH_FINDMY_SECONDS
    osascript -e 'quit app "FindMy"'
    #Set filename to correct date
    STORAGE_LOGNAME="${STORAGE_LOG_LOC}airtag-history-$(date +%F).csv"
	echo "Create a copy of the Items.data file to prevent changes while the script is running"
	cp -pr "$ORIG_ITEM_LOC" "$TEMP_ITEM_LOC"

    #Create buffer array to temporarily store data before writing to the file
    TEMP_DATA_ARRAY=()

	echo "Check if .csv exists, otherwise create a file"
	if [ ! -f "$STORAGE_LOGNAME" ]
	then
	echo "If .csv does not exist, creating one"
	#Header for the CSV file (currently set up to append to the file)
	echo datetime,serialnumber,producttype,productindentifier,vendoridentifier,antennapower,systemversion,batterystatus,locationpositiontype,locationlatitude,locationlongitude,locationtimestamp,locationverticalaccuracy,locationhorizontalaccuracy,locationfloorlevel,locationaltitude,locationisinaccurate,locationisold,locationfinished,addresslabel,addressstreetaddress,addresscountrycode,addressstatecode,addressadministrativearea,addressstreetname,addresslocality,addresscountry,addressareaofinteresta,addressareaofinterestb >> "$STORAGE_LOGNAME"
	fi

	echo "Check how many Airtags to process"
	airtagsnumber=`cat "$TEMP_ITEM_LOC" | jq ".[].serialNumber" | wc -l`
	echo "Number of Airtags to process: $airtagsnumber"
	airtagsnumber=`echo "$(($airtagsnumber-1))"`

	for j in $(seq 0 $airtagsnumber)
	do
	echo Processing airtag number $j

	datetime=`date +"%Y-%m-%d:%T"`

	serialnumber=`cat "$TEMP_ITEM_LOC" | jq ".[$j].serialNumber"`
	producttype=`cat "$TEMP_ITEM_LOC" | jq ".[$j].productType.type"`
	productindentifier=`cat "$TEMP_ITEM_LOC" | jq ".[$j].productType.productInformation.productIdentifier"`
	vendoridentifier=`cat "$TEMP_ITEM_LOC" | jq ".[$j].productType.productInformation.vendorIdentifier"`
	antennapower=`cat "$TEMP_ITEM_LOC" | jq ".[$j].productType.productInformation.antennaPower"`
	systemversion=`cat "$TEMP_ITEM_LOC" | jq ".[$j].systemVersion"`
	batterystatus=`cat "$TEMP_ITEM_LOC" | jq ".[$j].batteryStatus"`
	locationpositiontype=`cat "$TEMP_ITEM_LOC" | jq ".[$j].location.positionType"`
	locationlatitude=`cat "$TEMP_ITEM_LOC" | jq ".[$j].location.latitude"`
	locationlongitude=`cat "$TEMP_ITEM_LOC" | jq ".[$j].location.longitude"`
	locationtimestamp=`cat "$TEMP_ITEM_LOC" | jq ".[$j].location.timeStamp"`
	locationverticalaccuracy=`cat "$TEMP_ITEM_LOC" | jq ".[$j].location.verticalAccuracy" | sed 's/null/0/g'`
	locationhorizontalaccuracy=`cat "$TEMP_ITEM_LOC" | jq ".[$j].location.horizontalAccuracy" | sed 's/null/0/g'`
	locationfloorlevel=`cat "$TEMP_ITEM_LOC" | jq ".[$j].location.floorlevel" | sed 's/null/0/g'`
	locationaltitude=`cat "$TEMP_ITEM_LOC" | jq ".[$j].location.altitude" | sed 's/null/0/g'`
	locationisinaccurate=`cat "$TEMP_ITEM_LOC" | jq ".[$j].location.isInaccurate" | awk '{ print "\""$0"\"" }'`
	locationisold=`cat "$TEMP_ITEM_LOC" | jq ".[$j].location.isOld" | awk '{ print "\""$0"\"" }' `
	locationfinished=`cat "$TEMP_ITEM_LOC" | jq ".[$j].location.locationFinished" | awk '{ print "\""$0"\"" }' `
	addresslabel=`cat "$TEMP_ITEM_LOC" | jq ".[$j].address.label" | sed 's/null/""/g'`
	addressstreetaddress=`cat "$TEMP_ITEM_LOC" | jq ".[$j].address.streetAddress"| sed 's/null/""/g'`
	addresscountrycode=`cat "$TEMP_ITEM_LOC" | jq ".[$j].address.countryCode"| sed 's/null/""/g'`
	addressstatecode=`cat "$TEMP_ITEM_LOC" | jq ".[$j].address.stateCode" | sed 's/null/""/g'`
	addressadministrativearea=`cat "$TEMP_ITEM_LOC" | jq ".[$j].address.administrativeArea"| sed 's/null/""/g'`
	addressstreetname=`cat "$TEMP_ITEM_LOC" | jq ".[$j].address.streetName"| sed 's/null/""/g'`
	addresslocality=`cat "$TEMP_ITEM_LOC" | jq ".[$j].address.locality"| sed 's/null/""/g'`
	addresscountry=`cat "$TEMP_ITEM_LOC" | jq ".[$j].address.country"| sed 's/null/""/g'`
	addressareaofinteresta=`cat "$TEMP_ITEM_LOC" | jq ".[$j].address.areaOfInterest[0]" | sed 's/null/""/g'`
	addressareaofinterestb=`cat "$TEMP_ITEM_LOC" | jq ".[$j].address.areaOfInterest[1]" | sed 's/null/""/g'`

    TEMP_DATA_ARRAY+=($datetime,$serialnumber,$producttype,$productindentifier,$vendoridentifier,$antennapower,$systemversion,$batterystatus,$locationpositiontype,$locationlatitude,$locationlongitude,$locationtimestamp,$locationverticalaccuracy,$locationhorizontalaccuracy,$locationfloorlevel,$locationaltitude,$locationisinaccurate,$locationisold,$locationfinished,$addresslabel,$addressstreetaddress,$addresscountrycode,$addressstatecode,$addressadministrativearea,$addressstreetname,$addresslocality,$addresscountry,$addressareaofinteresta,$addressareaofinterestb)

	done

    echo "Write the data to the csv file"
    for item in "${TEMP_DATA_ARRAY[@]}"
    do
	    echo $item >> "$STORAGE_LOGNAME"
    done

    echo "Cleaning up temp files"
    rm "$TEMP_ITEM_LOC"
	echo "Sleep for $WAIT_BETWEEN_LOOP_SECONDS seconds"
	sleep $WAIT_BETWEEN_LOOP_SECONDS

done
