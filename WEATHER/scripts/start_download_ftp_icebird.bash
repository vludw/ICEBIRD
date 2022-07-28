#!/bin/bash
CONDAPATH="$HOME/opt/anaconda3"
SCRIPTPATH="$HOME/ICEBIRD/WEATHER/scripts"
LOGFILEPATH="$HOME/ICEBIRD/WEATHER/logfiles"
source $CONDAPATH/bin/activate $CONDAPATH/envs/icebird
timestamp=$(/bin/date +%Y%m%d_%H%M%S)
python -W ignore $SCRIPTPATH/download_ftp_icebird.py>>$LOGFILEPATH/logfile_$timestamp.txt
