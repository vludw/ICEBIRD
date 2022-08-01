#!/bin/bash
## Script to set up the conda environment in which the script for downloading weather data from DWD can be run.
## Author: Valentin Ludwig (valentin.ludwig@awi.de
## Created: 20220801
## Last modified: 20220801
echo "Creating environment..."
ENVNAME=icebird2 # name for conda environment
CONDAPATH=$HOME/opt/anaconda3/ # directory where your anaconda is installed
conda create --name $ENVNAME # create the environment
echo "Activating environment..."
source $CONDAPATH/bin/activate $ENVNAME # activate the environment
echo "Installing pip..."
conda install pip # install pip (needed for installing paramiko, which is the Python library for SFTP interaction)
echo "Installing paramiko..."
pip install paramiko # install paramiko
echo "Done!"
