# Operational download of weather data and download and plotting of buoy trajectories and drift forecasts during the Icebird Summer 2022 campaign.
#### Author: Valentin Ludwig (valentin.ludwig@awi.de)
#### Created: 20220725
#### Last updated: 20220831


### CONTENTS
- WEATHER: directory which contains scripts for downloading DWD weather forecasts, as well as the data themselves
	- data: Mirror of DWD FTP server. Updated each day every ten minutes between 6 am and 9 am local time. Data will be overwritten with the newer version on the next day
	- daily_data: Backup of data directory. Contains a folder data_YYYYMMDD with the data from the respective day in YYYYMMDD format. Updated after each download.
	- logfiles: Logfiles of the operationally run download scripts
	- scripts: Scripts for operational download
		- icebird.yml: File for creating the conda environment.
		- download_ftp_icebird.py: Python script for the download of the DWD data via a dedicated SFTP server
		- start_download_ftp_icebird.bash: Bash script which is called by cronjob. Basically a wrapper around the download_ftp_icebird.py script. Called by cronjob every 10 minutes between 6 and 9 am local time.
- BUOYS: directory which contains scripts, data and plots of buoys nearby which are possible overflight targets
	- data: Contains the buoy data as csv and txt files.
		- csv: Raw downloaded csv files
		- txt: Buoy data in a format which is compatible with the SIDFEx R package to handle drift forecasts.
	- logfiles: Logfiles of the download and plot scripts which are called operationally.
	- plots: Plots of buoy trajectories and speedangle plots.
		- maps: Daily plot of the trajectories of three buoys nearby. Contains one plot with a larger region and one plot which zooms in on a smaller region.
		- speedangle: Speedangle plot for each buoy containing all the available forecasts.
	- scripts: Scripts for downloading and plotting, as well as an input table.
		- drifter_table: Table with all drift buoys on the server from which buoy data are downloaded.  
		- atwaice_get-obs.R: Script to download the buoy data for the ATWAICE expedition cruise on which the buoys are deployed. Not directly used here, but serves as basis for the script which is used here.
		- atwaice_get-obs_icebird.R: Script for downloading the buoy data, adapted from atwaice_get-obs.R
		- plot_buoy_tracks_forecasts_icebird.py: Script for downloading and plotting new buoy data and forecasts.
		- start_plotting_buoys.bash: Starts the plotting, wrapper around plot_buoy_tracks_forecasts_icebird.R. Called by cronjob each day at 6 am local time.

### HOW TO USE
- Weather data: 
	- Adapt local and remote path in download_ftp_icebird.py, as well as the SFTP credentials. Install Python's paramiko module. More detailed instruction in download_ftp_icebird.py. Further, adapt filepaths in start_download_ftp_icebird.bash. Again, more detailed instructions in start_download_ftp_icebird.bash itself.
- Buoy data:
	- Observations:
		- adapt file paths and FTP credentials in atwaice_get-obs_icebird.R. More details in the script.
	- Forecasts: If you are familiar with and have installed the SIDFEx software package, adapt filepaths in the script plot_buoy_tracks_forecasts_icebird.R and follow the instructions there. If you are not familiar with SIDFEx, contact the SIDFEx team (helge.goessling@awi.de or valentin.ludwig@awi.de) for instructions.
- Operational execution:
	- Copy the lines in the .txt files WEATHER/scripts/cronjobline_weather.txt and BUOYS/scripts/cronjobline_buoys.txt into the user's crontab (open it via crontab -e). The default settings will execute the weather data download daily between 6 am and 9 am local time every ten minutes and the downloading and plotting of buoy data every day at 6 am, once a day.
	- For booting the laptop automatically, add the line "cronjobline_autoboot.txt" into the sudo user's crontab (open with sudo crontab -e). This line sends a signal to boot the laptop at 05:45 am local time the next day. It is called at 6 am local time, i. e., the laptop boots automatically at 05:45 am the next day and at 6 am this cronjob sends the signal to boot it again on the next day at 05:45 am, making sure that this loop is maintained and the laptop boots each day. IMPORTANT NOTE: To start the loop, the wake up signal needs to be sent manually once! For this, just enter the line 'sudo /usr/sbin/rtcwake -t $(date +\%s -d "tomorrow 05:45") ' once, at an arbitrary time of the day.

### OTHER NOTES
The software was developed and tested on AWI laptop bkli05l015 under Ubuntu 2020 for the user icebird. If you run it on this laptop and with the icebird user, it should work straightaway after updating the SFTP credentials and, if you want, the filepaths. On other Linux machines, it should also work after adapting the filepaths and installing the Python/R packages. On MacOS, it should also work pretty quickly, but the file paths, both those in the scripts and those called in the crontab's might look differently. ON a MacOS machine, you can also do the autoboot via the Settings (Settings --> Battery --> Schedule), then you don't need the stuff in the sudo user's crontab.
