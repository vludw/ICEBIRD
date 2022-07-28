#!/bin/bash
CONDAPATH="/Users/vludwig/opt/anaconda3"
SCRIPTPATH="/Users/vludwig/04_EVENTS/03_ICEBIRD/02_WEATHER/scripts"
LOGFILEPATH="/Users/vludwig/04_EVENTS/03_ICEBIRD/02_WEATHER/logfiles"
source $CONDAPATH/bin/activate $CONDAPATH/envs/icebird
timestamp=$(/bin/date +%Y%m%d_%H%M%S)
python -W ignore $SCRIPTPATH/download_ftp_icebird.py>>$LOGFILEPATH/logfile_$timestamp.txt
