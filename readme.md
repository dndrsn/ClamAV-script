# Clam AV Incremental Scan Script #


## Description ##

Incremental scan using Clam AV for OS X (probably works on Linux).  Based heavily on the script posted [here](http://serverfault.com/questions/479922/how-to-scan-only-last-24-hours-files-with-clamav).

* Does a virus definition DB update before scanning
* Scans the directories specified at the CLI or a set of default volumes (if they are present)
* Scans all files that have been modified since the last time the scan was run for a given volume or directory.
* Reports a list of infected files to the console

## Installation & Usage ##

### Installation ###

* Install clamav using Homebrew

        brew update
        brew install clamav


### Usage ###

Run using sudo.  

Specify directories via the CLI:

    sudo ./clamscan.sh /some/dir/ /another/dir
        
Edit the default directories in the script and run:

    sudo ./clamscan.sh



## TODO ##

* Create necessary directories automatically if they don't exist.  Right now relies on some prexisting directories
* Fix syntax error which occurs after all dirs/volumes have finished scanning.  Doesn't affect functionality
* Add support for system notifications on scan complete and/or virus found
* Add some way to see progress.  Perhaps tee the output instead of just redirecting.


## Closing Thoughts ##

Not really sure if this is worthwhile at all.  

1. The point of this was to speed up scans.  Using find to search all files by modification date on a large volume takes a good deal of time.  It still takes a long time.
2. Since updated virus definitions may detect viruses is older files that haven't changed, this doesn't obviate the need to run a full scan on all files.  So what's the point?
3. I expect a clever virus can outwit the OS file modification timestamps.  I'm guessing it can, so this whole thing may be based on a terribly flawed idea.

## Disclaimer ##
This script is provided "as is" without warranty of any kind, either expressed or implied and is to be used at your own risk.  



