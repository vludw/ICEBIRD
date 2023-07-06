## DESCRIPTION OF SCRIPTS AND FILES FOR THE DOWNLOAD OF WEATHER DATA
- config.bash: Sets the filepaths and access data for the download. This should be the only file which needs to be updated for the next campaign.
- cronjobline_weather.txt: This is the line which needs to be put in the user's crontab for the operational download. ALready in the user icebird's crontab.
- download_ftp_icebird.py: This script downloads the data.
- filelist.txt: This file contains a list with all the directory and filenames which shall be downloaded operationally. In case you want to download other files than those specified in the file, you need to add them here.
- icebird.yml: A file from which you can create the conda environment in which this script is run.
- setup.bash: This script installs the conda environment. Only needs to be run once and only if you run the download on a new computer.
- start_download_ftp_icebird.bash: This bash script executes the download, i.e., it calls the Python script. This is the script which is called by the cronjob.
