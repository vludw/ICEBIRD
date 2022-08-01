#!/bin/bash
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

