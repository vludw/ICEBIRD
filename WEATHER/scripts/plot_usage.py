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
from scipy.stats import linregress

## Set quota (allowed of amount data) in MB
quota = 7e3

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
lr_usage = linregress(timedel,usage)
## Plotting
# Open Figure
fig = plt.figure(figsize = (7,7))
ax = fig.add_subplot(111)
# Labels and title
#ax.set_xlabel("Date")
ax.set_ylabel("Data usage [MB]")
ax.set_title("Data usage during Icebird 2022")
# Plot usage and lines
ax.plot(timedel,usage,label = "Data used",linewidth = 2,color = "steelblue")
ax.plot(timedel_all, lr_usage.slope*timedel_all + lr_usage.intercept,label = "Linear regression",linestyle = "dashed",color = "steelblue")
ax.hlines(quota,0,len(days_all),label = "Max quota",color = "black")
ax.plot([0,len(days_all)],[0,quota],c = "grey",linestyle = "dashed",label = "Daily allowed rate")
# Adjust axis design
ax.set_xlim([0,len(days_all)])
ax.set_ylim([0,1.02*quota])
ax.set_xticks(timedel_all)
ax.set_xticklabels(days_all,rotation = 45)
ax.set_yticks(np.arange(0,1.05*quota,.1*quota))
# Add grid and legend
ax.grid()
ax.legend(loc = "lower right")
fig.savefig("datausage.pdf",bbox_inches = "tight")
plt.close(fig)

## Tell me when quota will be exceeded
ind_exceeded = np.int16(np.floor((quota - lr_usage.intercept)/lr_usage.slope))
usage_end = np.ceil(timedel_all.max()*lr_usage.slope - lr_usage.intercept)
quota_remaining = quota - usage[-1]
days_remaining = len(days_all) - np.where(days[-1]==days_all)[0][0]
print(f"Current rate: {np.round(lr_usage.slope,2)} MB/day")
if ind_exceeded < len(days_all):
    print(f"Quota of {quota} MB will be exceeded on {days_all[ind_exceeded]} at current rate of usage ({np.round(lr_usage.slope,2)} MB/day).")
    print(f"Quota would need to be reduced to {np.round(quota_remaining/days_remaining,2)} MB/day to stay within {quota} MB limit.")
    print(f"Quota would need to be extended to {usage_end} MB at current rate of usage.")
