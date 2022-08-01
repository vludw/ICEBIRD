#!/bin/bash
## PURPOSE: Run the Python script which operationally downloads the weather data from DWD. This script is called by a cronjob every day between 6 am and 9 am local time, every ten minutes.
## INSTRUCTIONS
## You need a conda environment in which the Python module paramiko is installed. This should reside in the path specified by $CONDAPATH/envs. If it is not called icebird, change the name accordingly. If the scripts are at different locations than what is specified in this script, make sure to adapt the filepaths. Then, the script can be run by /bin/bash path_to_script/scriptname.bash, possibly after making it executable by using chmod +x scriptname.bash. Output is written to a logfile in $LOGFILEPATH.

## SET FILEPATHS AND TIMESTAMPS
TIMESTAMP_LOGFILE=$(/bin/date +%Y%m%d_%H%M%S) # logfiles of download script will be saved here
TIMESTAMP_BACKUP=$(/bin/date +%Y%m%d) # this will be used for naming the backup directory
CONDAPATH="$HOME/opt/anaconda3" # conda environment for running the download script resides here
SCRIPTPATH="$HOME/ICEBIRD/WEATHER/scripts" # path to this script
LOGFILEPATH="$HOME/ICEBIRD/WEATHER/logfiles" # path for logfiles of download
DATAPATH="$HOME/ICEBIRD/WEATHER/data" # path to which data will be downloaded
BACKUPPATH="$HOME/ICEBIRD/WEATHER/daily_data/data_$TIMESTAMP_BACKUP" # path where backup will be saved

## RUN DOWNLOAD
source $CONDAPATH/bin/activate $CONDAPATH/envs/icebird # activate the conda environment
python -W ignore $SCRIPTPATH/download_ftp_icebird.py>>$LOGFILEPATH/logfile_$TIMESTAMP_LOGFILE.txt # run download script

## RUN BACKUP
if [ ! -d $BACKUPPATH ] # check if backup directory exists, if not, create it
then
	mkdir -p $BACKUPPATH
fi
cp -pruv $DATAPATH/* $BACKUPPATH/>>$LOGFILEPATH/logfile_$TIMESTAMP_LOGFILE.txt # do the backup, append output to download logfile

