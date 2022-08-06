######################################################
## Purpose: Monitor data usage during Icebird 2022
## Author: Valentin Ludwig (valentin.ludwig@awi.de)
## Creation date: 20220806
## Last modified: 20220806
######################################################

## Import modules ##
import pylab as plt
import numpy as np
import pandas as pd

## Get input data
df = pd.read_csv("datausage.csv")
days = np.array(df["Day"])
hours = np.array(df["Hour"])
minutes = np.array(df["Minute"])
usage = np.array(df["Data"])
days_fraction = days  + hours/24 + minutes/(60*24)
days_all = 20220804+np.arange(18)
timedel = days_fraction-days_fraction[0]
timedel_all = days_all-days_all[0]

## Plotting
# Open Figure
fig = plt.figure(figsize = (7,7))
ax = fig.add_subplot(111)
# Labels and title
ax.set_xlabel("Date")
ax.set_ylabel("Data usage [MB]")
ax.set_title("Data usage during Icebird 2022")
# Plot usage and lines
ax.plot(timedel,usage,label = "Data used",linewidth = 2)
ax.hlines(5e3,0,len(days_all),label = "Max quota",color = "black")
ax.plot([0,len(days_all)],[0,5e3],c = "grey",linestyle = "dashed",label = "Daily allowed rate")
# Adjust axis design
ax.set_xlim([0,len(days_all)])
ax.set_ylim([0,5.1e3])
ax.set_xticks(timedel_all)
ax.set_xticklabels(days_all,rotation = 45)
# Add grid and legend
ax.grid()
ax.legend(loc = "lower right")
time_all = time.localtime()
fig.savefig("datausage_20220806.pdf")
fig.show()

