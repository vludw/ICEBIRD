#!/bin/bash

###########################################################################
## Purpose: Set filepaths for download of DWD weather data during Icebird 2022
## Created on: 20220802
## Last significantly modified: 
## Author: Valentin Ludwig
## Contact: valentin.ludwig@awi.de
###########################################

## SET PATHS USED IN start_download_ftp_icebird.bash
export TIMESTAMP_LOGFILE=$(/bin/date +%Y%m%d_%H%M%S) # timestamp for logfile
export TIMESTAMP_BACKUP=$(/bin/date +%Y%m%d) # timestamp for backup
export CONDAPATH="$HOME/opt/anaconda3" # conda environment for running the download script resides here
export SCRIPTPATH="$HOME/ICEBIRD/WEATHER/scripts" # path for scripts
export LOGFILEPATH="$HOME/ICEBIRD/WEATHER/logfiles" # path for logfiles of download
export DATAPATH="$HOME/ICEBIRD/WEATHER/data" # path to which data will be downloaded
export BACKUPPATH="$HOME/ICEBIRD/WEATHER/data_daily/data_$TIMESTAMP_BACKUP" # path where backup will be saved

## SET PATHS AND ACCESSDATA USED IN download_ftp_icebird.py
export HOST=data.dwd.de # hostname
export PORT=2424 # port number
export PASSWORD=C7UFYvD7Rb.*4ub\;gq\;Y # password
export USERNAME=awiarkti # username
export REMOTEPATH=data # set path on remote SFTP server
export LOCALPATH=$HOME/ICEBIRD/WEATHER/data # set path on local machine
