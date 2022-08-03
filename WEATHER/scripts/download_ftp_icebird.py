#!/usr/bin/env python
# coding: utf-8

###########################################################################
## Purpose: Download of weather data for Icebird campaign
## Created on: 20220712
## Last significantly modified: 20220712
## Author: Valentin Ludwig
## Contact: valentin.ludwig@awi.de
## How to use: 
##  - Run the script setup.bash to set up an anaconda environment in which the script works (needs paramiko for SFTP interaction and pip for installing paramiko)
##  - In this script, set the following variables:
##      - In function get_accessdict():
##          - host: address of SFTP server
##          - port: specified port on server
##          - username/password: username and password :-)
##      - In function get_pathdict():
##          - remotepath: Filepath on remote server. For DWD, all the data are in subdirectories of one folder called "data", therefore "data" is set as remotepath.
##          - localpath: Filepathon your local machine to which the data shall be saved
##      - In list skip_dir
## Workflow
#   - Connect to SFTP server using Python's paramiko module  
#   - Compare local and remote files
#       - If a remote file does not exist locally, download it
#       - If a file with the same filename as the remote file exists locally, but the filesizes are different, download it
#       - If a file with the same filename as the remote file exists locally and the filesizes (remote and local) are the same, skip it
#   - Close connection
#   - Central function (sftp_get_recursive) copied from https://stackoverflow.com/questions/6674862/recursive-directory-download-with-paramiko
## Remark:  The decision whether a remote file shall be downloaded if a file with the same filename exists locally could also be done based on the modification time. For this, remote and local modification time would be compared and if the remote modification time is larger than the local modification time (i.e., remote file has been modified after local file), the file would be downloaded. Filesize comparison seems to be more robust though.
###########################################

## Import modules
import paramiko # needed for SFTP interaction
import os,sys # needed for filesize comparison
from stat import S_ISDIR, S_ISREG # needed in sftp_get_recursive function

## Function which downloads the data recursively
def sftp_get_recursive(path, dest, download_names, sftp, verbose = False, print_summary = True):
	"""
	Function to recursively download all data in path to dest. Directory structure is preserved.
	Input: 
		- path: path on remote server (without sftp::// prefix)
		- dest: local path to which data shall be saved
		- sftp: SFTP object as returned by paramiko.SFTPClient.from_transport function
		- verbose (optional): tell me whether or not a file was downloaded
		- print_summary (optional): tell me how many files were downloaded/skipped in each directory
	Output:
		- no variables returned
	"""
	item_list = sftp.listdir_attr(path) # all files and directories on remote path. Note that this does not differentiate between files and directories.
	dest = str(dest) # make sure that local path is given as string
	if not os.path.isdir(dest): # create local path if it does not exist yet
		os.makedirs(dest, exist_ok=True)
	downloaded,skipped = [],[] # lists fopr downloaded/skipped filenames
	for item in item_list: # loop over files on remote server
		if not item.filename in download_names:
			print(f"{item.filename} is not in download_names, will not be downloaded!")
			continue
		mode = item.st_mode # needed to determine whether the remote entry is a file or a directory
		filesize_remote = item.st_size # filesize of remote file
		atime_remote = item.st_atime # access time of remote file
		mtime_remote = item.st_mtime # modification time of remote file
		file_exists = os.path.exists(os.path.join(dest,item.filename)) # check whether file exists locally
		if file_exists:
			filesize_local = os.path.getsize(os.path.join(dest,item.filename)) # get filesize of local file if it exists
		else:
			filesize_local = -999 # set local filesize to arbitrary fill value if it does not exist
		if S_ISDIR(mode): # check if remote file is a directory
			sftp_get_recursive(path + "/" + item.filename, dest + "/" + item.filename, download_names,sftp, verbose = verbose, print_summary = print_summary) # if remote file is a directory, repeat the function
			if verbose == True:
				print("Setting modification time of local file to modification time of remote file")
			os.utime(os.path.join(dest,item.filename),(atime_remote,mtime_remote)) # change local modification and access time such that it is consistent with the remote one
		else:
			if not file_exists: # if the file does not exist at all, download it
				if verbose == True:
					print(f"{os.path.join(dest,item.filename)} does not exist, I download it!")
				sftp.get(path + "/" + item.filename, dest + "/" + item.filename) # download remote file
				if verbose == True:
					print("Setting modification time of local file to modification time of remote file")
				os.utime(os.path.join(dest,item.filename),(atime_remote,mtime_remote)) # change local modification and access time such that it is consistent with the remote one
				downloaded.append(os.path.join(dest,item.filename)) # add filename to list of downloaded filenames
			elif file_exists & (filesize_remote != filesize_local): # if the file exists locally, but the filesize differs from that of the remote file, download it
				if verbose == True:
					print(f"{os.path.join(dest,item.filename)} exists, but size of local and remote file differ. I download it!")
				sftp.get(f"{os.path.join(path,item.filename)}", f"{os.path.join(dest,item.filename)}") # download remote file
				downloaded.append(os.path.join(dest,item.filename)) # add filename to list of downloaded filenames
				if verbose == True:
					print("Setting modification time of local file to modification time of remote file")
				os.utime(os.path.join(dest,item.filename),(atime_remote,mtime_remote))# change local modification and access time such that it is consistent with the remote one
			else: # do nothing if file exists and filesizes are identical
				if verbose == True:
					print(f"{os.path.join(dest,item.filename)} exists and size of local and remote file are identical, I skip it!")
				skipped.append(os.path.join(dest,item.filename)) # add filename to listb of skipped filenames
				pass
	if print_summary: # print a summary (how many files were downloaded/skipped for each directory)
		try: # if variable "item" exists, print the summary
			print(f"{os.path.dirname(os.path.join(path,item.filename))}: {len(downloaded)} file(s) downloaded, {len(skipped)} file(s) skipped")
		except UnboundLocalError: # if it does not exist, pass
			pass
                
## Access data for SFTP server
def get_accessdict(): # get credentials and address for SFTP login
	"""
	Get address and credentials of the SFTP server.
	Input:
		- no input required
	Output:
		- dictionary with host, port, password and username
	"""
	host = os.getenv("HOST") # host name
	port = int(os.getenv("PORT")) # host name
	username = os.getenv("USERNAME") # host name
	password = os.getenv("PASSWORD") # host name
	accessdict = {"host":host,"port":port,"password":password,"username":username} # dictionary with credentials
	return accessdict

## Filepaths on local machine and remote SFTP server
def get_pathdict(): # get remote and local filepaths
	"""
	Get filepaths.
	Input:
		- no input required
	Output:
		- dictionary with local and remote filepath
	"""
	remotepath = os.getenv("REMOTEPATH") # set path on remote SFTP SERVER
	localpath = os.getenv("LOCALPATH") # set path on local machine
	pathdict = {"remotepath":remotepath,"localpath":localpath} # dictionary with paths
	return pathdict

## Connection to SFTP
def open_sftp(accessdict):
	"""
	Open connection to SFTP server and login.
	Input:
		- accessdict: dictionary with address and credentials, returned by function get_accessdict()
	Output:
		- SFTP and transport object which will be used for downloading
	"""
	transport = paramiko.Transport((accessdict["host"], accessdict["port"])) # open connection    
	transport.connect(username = accessdict["username"], password = accessdict["password"]) # connect to server    
	sftp = paramiko.SFTPClient.from_transport(transport) # open SFTP connection
	return sftp,transport

## Close connection to SFTP server
def close_sftp(sftp,transport):
	"""
	Close connection to SFTP server.
	Input:
		- SFTP and transport object as returned by function open_sftp
	Output:
		- no output
	"""
	sftp.close() # log out of SFTP server
	transport.close() # close connection


# Skip directories
filepath = os.getenv("SCRIPTPATH")
f_downloadnames = open(os.path.join(filepath,"filelist.txt"), mode = "r")
f_lines_tmp = f_downloadnames.readlines()
download_names = [f_line_tmp[:-1] for f_line_tmp in f_lines_tmp]
# Get access data
accessdict,pathdict = get_accessdict(), get_pathdict() # dictionaries are needed for the SFTP connection

# Connect to SFTP server
sftp,transport = open_sftp(accessdict) # get SFTP object

# Download data
sftp_get_recursive(pathdict["remotepath"], pathdict["localpath"],download_names,sftp,verbose = False, print_summary = True) # download data

# Close connection
close_sftp(sftp,transport) # close connection
print("Download done.")

