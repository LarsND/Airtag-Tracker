# AirTag Data Logger
## WARNING: This script will not work on a MacOS version newer then 14.3.1 (Sonoma). Apple started encrypting the data after this version.

This script logs the location data of AirTags using the Find My app on macOS. The data is saved in CSV format for further analysis.

## Requirements

- macOS
- The [jq](https://stedolan.github.io/jq/) command-line tool

## Usage

1. Clone this repository to your local machine.

2. Open the `airtag_logger.sh` file and edit the following variables to suit your needs:
    - `ORIG_ITEM_LOC` - the path to the original `Items.data` file (defaults to `/Users/$USER/Library/Caches/com.apple.findmy.fmipcore/Items.data`).
    - `TEMP_ITEM_LOC` - the path to the temporary `Items.data` file (defaults to `/tmp/airtag_tems.data`).
    - `STORAGE_LOG_LOC` - the directory where the log files will be saved (defaults to `/Users/$USER/AirTag-logs/`).
    - `WAIT_REFRESH_FINDMY_SECONDS` - the number of seconds to wait before refreshing the Find My app (defaults to `10`).
    - `WAIT_BETWEEN_LOOP_SECONDS` - the number of seconds to wait between each loop of the script (defaults to `110`).
    - `DELETE_LOGS_AFTER_DAYS` - the number of days after which log files will be deleted (defaults to `30`).

3. Run the `airtag_logger.sh` file using the following command:
    ```
    sh airtag_logger.sh
    ```

4. The script will run indefinitely until interrupted by the user. It will log the location data of all AirTags associated with your Apple ID every `WAIT_BETWEEN_LOOP_SECONDS` seconds. The log files will be saved in the `STORAGE_LOG_LOC` directory with filenames in the format `airtag-history-YYYY-MM-DD.csv`.

## License

This script is licensed under the [GPL-3.0 license](LICENSE).

Modified version of @icepick3000's AirtagAlex script.
