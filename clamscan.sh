#!/usr/bin/env bash


function clamscan_dir {

    scan_dir=$1
    echo "--- Scanning dir: $scan_dir"

    # Temporary file
    list_file=$(mktemp -t clamscan.XXXXXX) || exit 1

    # Location of log file
    esc_scan_dir=$(echo "$scan_dir" | tr '[/ ]' '_')
    log_file="/Library/Logs/clamav/clamscan_${esc_scan_dir}.log"
    echo "--- Logfile is: $log_file"

    # Make list of new files
    echo "--- Listing files to: $list_file"
    if [ -f  "$log_file" ]
    then
        # use newer files then logfile
        logfile_mod=$(stat -f '%c' $log_file)
        now=$(date +%s)
        delta=$(expr $now - $logfile_mod)
        # search a full day behind to catch any files modified between when the file list was created and the scan finish
        mod_seconds=$(expr $delta + 86400)
        mod_min=$(expr $mod_seconds / 60)
        mod_days=$(expr $mod_min / 60 / 24)
        echo "--- Searching for files modified since the log file was updated: $log_file"
        echo "--- Searching for files modified in the last $mod_days days"
        # find "$scan_dir" -type f -cnewer "$log_file" -print >> "$list_file"
        find "$scan_dir" -mount -type f -cmin $mod_min -print >> "$list_file"
    else
        # scan last 60 days
        echo "--- Searching for files modified in the last 60 days"
        find "$scan_dir" -mount -type f -ctime -60 -print >> "$list_file"
    fi


    if [ -s "$list_file" ]
    then
        echo "--- Scanning files"
        echo "--- Temp file is: ${log_file}.tmp"

        # Scan files
        clamscan --quiet --cross-fs=no --follow-dir-symlinks=0 --follow-file-symlinks=0  i -f "$list_file" > "${log_file}.tmp"
        mv "${log_file}.tmp" "${log_file}"

        # If there were infected files detected, send email alert
        if [ `cat $log_file | grep Infected | grep -v 0 | wc -l` != 0 ]
        then
            # HOSTNAME=`hostname`
            # echo "$(egrep "FOUND" $log_file)" | mail -s "VIRUS PROBLEM on $HOSTNAME" -r     clam@nas.local you@yourhost.com
            echo "--- !!!!! INFECTED FILES FOUND"
            echo "$(egrep "FOUND" $log_file)"
        else
            echo "--- No infected files found"
        fi
    else
        echo "--- No files found to scan"

        # remove the empty file, contains no info
        rm -f "$list_file"
    fi
}


# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# update virus database
echo "--- Updating virus db"
freshclam


# read directories to scan from command line or use default
if [ $# -gt 0 ]; then
  scan_dirs=( "$@" )
else
  scan_dirs=('/Volumes/Mac HD/' '/Volumes/Mac SD1/' '/Volumes/Secure/' '/Volumes/Ext/');
fi


for i in "${scan_dirs[@]}"
do
    # check to see if directory exists
    if [ -d "$i" ]; then
        clamscan_dir "$i"
    else
        echo "--- dir not found/connected, skipping: $i"
    fi
done


exit

