#!/bin/bash
## PURPOSE: Run the Python script which operationally downloads the weather data from DWD. This script is called by a cronjob every day between 6 am and 9 am local time, every ten minutes. Data are downloaded if a newer version exists on the SFTP server. Also, the files are created to a backup directory where data are saved for each day (otherwise, they would be overwritten after one day).
## INSTRUCTIONS
## 	- If you run the script for the first time, make sure to create the conda environment which contains the necessary Python packages. This can be done by running the script setup.bash in this directory. 
## 	- If you make any changes to the default file path structure, make sure to adapt them in the files confdig.bash/setup.bash.
##	- Then, the script can be run by /bin/bash /home/icebird/ICEBIRD/WEATHER/scripts/start_download_ftp_icebird.bash. YOu might have to make it executable by using chmod +x scriptname.bash. Output is written to a logfile in $LOGFILEPATH.


SCRIPTPATH="$HOME/ICEBIRD/WEATHER/scripts" # path to this script
touch $HOME/download_started.txt # create a txt file in the home directory. If you are not sure whether this script was run, check if the download_started.txt file exists and when it was created/last touched
source $SCRIPTPATH/config.bash # set the environment variables which are needed for this script. Variables are defined in config.bash.
touch $HOME/sourced_config.txt # create a txt file in the home directory which tells you when the config file was sourced
## RUN DOWNLOAD
source $CONDAPATH/bin/activate $CONDAPATH/envs/icebird # activate the conda environment
python -W ignore $SCRIPTPATH/download_ftp_icebird.py>>$LOGFILEPATH/logfile_$TIMESTAMP_LOGFILE.txt # run download script
touch $HOME/download_finished.txt # create a txt file in the home directory which tells you when the download was finished

## RUN BACKUP
if [ ! -d $BACKUPPATH ] # check if backup directory exists, if not, create it
then
	mkdir -p $BACKUPPATH
fi
cp -pruv $DATAPATH/* $BACKUPPATH/>>$LOGFILEPATH/logfile_$TIMESTAMP_LOGFILE.txt # do the backup, append output to download logfile
touch ~/copying_done.txt
