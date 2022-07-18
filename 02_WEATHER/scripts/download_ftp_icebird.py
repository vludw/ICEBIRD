#!/usr/bin/env python
# coding: utf-8

# # Download of weather data for Icebird campaign

# This notebook downloads weather data for the 2022 Icebird campaign. The data are provided by the german weather service (DWD) via an SFTP server. 

# ### Workflow
#     - Connect to SFTP server using Python's paramiko module  
#     - Compare local and remote files
#         - If a remote file does not exist locally, download it
#         - If a file with the same filename as the remote file exists locally, but the filesizes are different, download it
#         - If a file with the same filename as the remote file exists locally and the filesizes (remote and local) are the same, skip it
#     - Close connection
#     - Central function (sftp_get_recursive) shamelessly copied from https://stackoverflow.com/questions/6674862/recursive-directory-download-with-paramiko

# ### Remark
# The decision whether a remote file shall be downloaded if a file with the same filename exists locally could also be done based on the modification time. For this, remote and local modification time would be compared and if the remote modification time is larger than the local modification time (i.e., remote file has been modified after local file), the file would be downloaded. Filesize comparison seems to be more robust though.

# In[1]:


##########################################
## Created on: 20220712
## Last significantly modified: 20220712
## Author: Valentin Ludwig
## Contact: valentin.ludwig@awi.de
###########################################


# In[2]:


## Import modules
import paramiko # needed for SFTP interaction
import os,sys # needed for filesize comparison
from stat import S_ISDIR, S_ISREG # needed in sftp_get_recursive function

# In[3]:


def sftp_get_recursive(path, dest, sftp, verbose = False, print_summary = True):
    """
        Function to recursively download all data in path to dest. Directory structure is preserved.
        Input: 
            - path: path on remote server (without sftp::// prefix)
            - dest: local path to which data shall be saved
            - sftp: SFTP object as returned by paramiko.SFTPClient.from_transport function
            - verbose (optional): tell me whether or not a file was downloaded
            - print_summary (optional): tell me how many files were downloaded/skipped in each directory
            
        - Output:
            - no variables returned
    """
    item_list = sftp.listdir_attr(path) # all files and directories on remote path. Note that this does not differentiate between files and directories.
    dest = str(dest) # make sure that local path is given as string
    if not os.path.isdir(dest): # create local path if it does not exist yet
        os.makedirs(dest, exist_ok=True)
    downloaded,skipped = [],[] # lists fopr downloaded/skipped filenames
    for item in item_list: # loop over files on remote server
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
            sftp_get_recursive(path + "/" + item.filename, dest + "/" + item.filename, sftp, verbose = verbose, print_summary = print_summary) # if remote file is a directory, repeat the function
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
                


# In[4]:


def get_accessdict(): # get credentials and address for SFTP login
    """
    Get address and credentials of the SFTP server.
    Input:
        - no input required
    Output:
        - dictionary with host, port, password and username
    """
    host = "data.dwd.de" # host name
    port = 2424 # port number  
    password = "C7UFYvD7Rb.*4ub;gq;Y" # password
    username = "awiarkti" # username
    accessdict = {"host":host,"port":port,"password":password,"username":username} # dictionary with credentials
    return accessdict


# In[5]:


def get_pathdict(): # get remote and local filepaths
    """
    Get filepaths.
    Input:
        - no input required
    Output:
        - dictionary with local and remote filepath
    """
    remotepath = "data" # set path on remote SFTP SERVER
    localpath = os.path.join(os.getenv("HOME"),"04_EVENTS/03_ICEBIRD/02_WEATHER/data") # set path on local machine
    pathdict = {"remotepath":remotepath,"localpath":localpath} # dictionary with paths
    return pathdict


# In[6]:


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


# In[7]:


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


# In[8]:


accessdict,pathdict = get_accessdict(), get_pathdict() # dictionaries are needed for the SFTP connection


# In[9]:


sftp,transport = open_sftp(accessdict) # get SFTP object


# In[10]:


sftp_get_recursive(pathdict["remotepath"], pathdict["localpath"], sftp,verbose = False, print_summary = True) # download data


# In[11]:


close_sftp(sftp,transport) # close connection
print("Download done.")

