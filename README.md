# Operational download of weather data and download and plotting of buoy trajectories and drift forecasts during the Icebird Summer 2022 campaign.
#### Author: Valentin Ludwig (valentin.ludwig@awi.de)
#### Created: 20220725
#### Last updated (repo): 20220801
#### Last updated (README): 20220801


### PURPOSE
During the IceBird campaign, weather data are provided by DWD via a dedicated SFTP server. This repository contains the software to download those data operationally each day. To this end, the laptop boots automatically at 5:45 am. Then, the script looks for new data on the SFTP server and downloads them. You can specify in the script which data you want to download automatically.
### UPDATES
20220801: Handling of buoy data now obsolete as they were taken from the ice at the end of the ATWAICE campaign.
20221012: Removed info about how to handle buoy data (was only needed for IceBird Summer 2022)
### CONTENTS
- WEATHER: directory which contains scripts for downloading DWD weather forecasts, as well as the data themselves
	- data: Mirror of DWD FTP server. Updated each day every ten minutes between 6 am and 9 am local time. Data will be overwritten with the newer version on the next day
	- daily_data: Backup of data directory. Contains a folder data_YYYYMMDD with the data from the respective day in YYYYMMDD format. Updated after each download.
	- logfiles: Logfiles of the operationally run download scripts
	- scripts: Scripts for operational download
		- icebird.yml: File for creating the conda environment.
		- download_ftp_icebird.py: Python script for the download of the DWD data via a dedicated SFTP server
		- start_download_ftp_icebird.bash: Bash script which is called by cronjob. Basically a wrapper around the download_ftp_icebird.py script. Called by cronjob every 10 minutes between 6 and 9 am local time.

### HOW TO USE
- Weather data: 
	- Execute the script WEATHER/scripts/setup.bash. In this script, you need to specify the path to your local anaconda installation. It will then create the conda environment which you need for running the download script.
	- Set the filepaths in the file WEATHER/scripts/config.bash. This is called in the processing and all variables which are needed are defined here. No need for other changes.
	- Execute the script WEATHER/scripts/start_download_ftp_icebird.bash.
	- A remark: Only the files and directories whose filenames are specified in the file WEATHER/scripts/filelist.txt are downloaded. Other files will not be downloaded!
	- Forecasts: If you are familiar with and have installed the SIDFEx software package, adapt filepaths in the script plot_buoy_tracks_forecasts_icebird.R and follow the instructions there. If you are not familiar with SIDFEx, contact the SIDFEx team (helge.goessling@awi.de or valentin.ludwig@awi.de) for instructions.
- Operational execution:
	- Copy the lines in the .txt files WEATHER/scripts/cronjobline_weather.txt into the user's crontab (open it via crontab -e). The default settings will execute the weather data download daily between 6 am and 9 am local time every ten minutes.
	- For booting the laptop automatically, add the line in the txt file cronjobline_autoboot.txt into the sudo user's crontab (open with sudo crontab -e). This line sends a signal to boot the laptop at 05:45 am local time the next day. It is called at 6 am local time, i. e., the laptop boots automatically at 05:45 am the next day and at 6 am this cronjob sends the signal to boot it again on the next day at 05:45 am, making sure that this loop is maintained and the laptop boots each day. IMPORTANT NOTE: To start the loop, the wake up signal needs to be sent manually once! For this, just execute the line 'sudo /usr/sbin/rtcwake -t $(date +\%s -d "tomorrow 05:45") ' in the command line once, at an arbitrary time of the day.

### OTHER NOTES
The software was developed and tested on AWI laptop bkli05l015 under Ubuntu 2020 for the user icebird. If you run it on this laptop and with the icebird user, it should work straightaway after updating the SFTP credentials and, if you want, the filepaths. On other Linux machines, it should also work after adapting the filepaths and installing the Python packages. On MacOS, it should also work pretty quickly, but the file paths, both those in the scripts and those called in the crontab's might look differently. On a MacOS machine, you can also do the autoboot via the Settings (Settings --> Battery --> Schedule), then you don't need the stuff in the sudo user's crontab. On Windows, probably more modifications will be needed, but I do not know anything about this.
