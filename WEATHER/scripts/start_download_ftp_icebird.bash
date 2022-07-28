#!/bin/bash
CONDAPATH="$HOME/opt/anaconda3"
if [ "$(whoami)" == "vludwig" ]; then
	SCRIPTPATH="$HOME/04_EVENTS/03_ICEBIRD/03_REPO/WEATHER/scripts"
	LOGFILEPATH="$HOME/04_EVENTS/03_ICEBIRD/03_REPO/WEATHER/logfiles"
elif [ "$(whoami)" == "icebird" ]; then
	SCRIPTPATH="$HOME/ICEBIRD/REPO/WEATHER/scripts"
	LOGFILEPATH="$HOME/ICEBIRD/REPO/WEATHER/logfiles"
fi
source $CONDAPATH/bin/activate $CONDAPATH/envs/icebird
timestamp=$(/bin/date +%Y%m%d_%H%M%S)
python -W ignore $SCRIPTPATH/download_ftp_icebird.py>>$LOGFILEPATH/logfile_$timestamp.txt
