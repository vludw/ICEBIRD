#!/bin/bash
## PURPOSE: Run the Python script which operationally downloads the weather data from DWD. This script is called by a cronjob every day between 6 am and 9 am local time, every ten minutes.
## INSTRUCTIONS
## You need a conda environment in which the Python module paramiko is installed. This should reside in the path specified by $CONDAPATH/envs. If it is not called icebird, change the name accordingly. If the scripts are at different locations than what is specified in this script, make sure to adapt the filepaths. Then, the script can be run by /bin/bash path_to_script/scriptname.bash, possibly after making it executable by using chmod +x scriptname.bash. Output is written to a logfile in $LOGFILEPATH.

SCRIPTPATH="$HOME/ICEBIRD/WEATHER/scripts" # path to this script

source $SCRIPTPATH/config.bash
## RUN DOWNLOAD
source $CONDAPATH/bin/activate $CONDAPATH/envs/icebird # activate the conda environment
python -W ignore $SCRIPTPATH/download_ftp_icebird.py>>$LOGFILEPATH/logfile_$TIMESTAMP_LOGFILE.txt # run download script

## RUN BACKUP
if [ ! -d $BACKUPPATH ] # check if backup directory exists, if not, create it
then
	mkdir -p $BACKUPPATH
fi
cp -pruv $DATAPATH/* $BACKUPPATH/>>$LOGFILEPATH/logfile_$TIMESTAMP_LOGFILE.txt # do the backup, append output to download logfile

