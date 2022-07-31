#!/bin/bash
SCRIPTPATH="$HOME/ICEBIRD/BUOYS/scripts"
LOGFILEPATH="$HOME/ICEBIRD/BUOYS/logfiles"
timestamp=$(/bin/date +%Y%m%d_%H%M%S)
#/usr/bin/Rscript $SCRIPTPATH/atwaice_get-obs_icebird.R>>$LOGFILEPATH/logfile_download_$timestamp.txt # buoy plots
#/usr/bin/Rscript $SCRIPTPATH/plot_buoy_tracks_forecasts_icebird.R>>$LOGFILEPATH/logfile_plot_$timestamp.txt # buoy plots
/usr/bin/Rscript $SCRIPTPATH/atwaice_get-obs_icebird.R #buoy plots
/usr/bin/Rscript $SCRIPTPATH/plot_buoy_tracks_forecasts_icebird.R>&$LOGFILEPATH/logfile_plot_$timestamp.txt ## buoy plots
