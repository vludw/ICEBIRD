##################################
## Purpose: Plot buoy data and SIDFEx forecasts for selected buoys during the Icebird campaign.
## Created by: Valentin Ludwig (valentin.ludwig@awi.de)
## Creation date: 20220726
###################################
rm(list=ls()) # Clean up before starting
## Load modules ##
require(SIDFEx)
require(spheRlab)

## Preparations ##
index = sidfex.load.index() # load SIDFEx index
tids = c("300534062174040","300534062171030","300534062175050") # targets of interest
up.to.date = TRUE # boolean to decide whether new forecasts and observations shall be downloaded
if (up.to.date){ # boolean to decide whether new forecasts and observations shall be downloaded
	res = sidfex.download.fcst(comparison.mode=FALSE,from.scratch = FALSE) # download forecasts
	res = sidfex.download.obs(TargetID = tids) # download observations
}
today = format(Sys.time(),("%Y%m%d")) # today's date (needed for savenames)

home.dir = Sys.getenv("HOME") # get home directory
plot.dir = file.path(home.dir,"04_EVENTS/03_ICEBIRD/04_BUOYS/plots") # plots will be saved here

## Load observations and determine plot domain ##
obs.all = list()  # list for observations
tids.res.list = c() # list with Target IDs. Needed to determine center of plot (middle buoy is selected based on Target ID, last point of this buoy will be the center of the map)
for (i.tid in 1:length(tids)){ # loop over targets
	obs.all[[i.tid]] = sidfex.read.obs(TargetID = tids[i.tid]) # add current target to list
	tids.res.list = c(tids.res.list,obs.all[[i.tid]]$TargetID) # add target ID to list
}

ind.center.tid = which(tids.res.list == "300534062171030") # middle buoy (there is also one Northern and one Southern buoy)
n.obs = length(obs.all[[ind.center.tid]]$data$Lon) # number of data points
center.plot.lon = c(obs.all[[ind.center.tid]]$data$Lon[n.obs]) # last longitude/latitude will be center of the plot domain
center.plot.lat = c(obs.all[[ind.center.tid]]$data$Lat[n.obs]) # last longitude/latitude will be center of the plot domain

## Plot trajectories ##
plot.name = paste0("obs_fcst_tracks_",today,".pdf") # name of plot
pdf(file.path(plot.dir,"maps",plot.name)) # open PDF file for plotting
pir = sl.plot.init(projection = "polar",polar.lonlatrot = c(center.plot.lon,center.plot.lat,0),polar.latbound = 87, do.init.device=F) # open plot
sl.plot.naturalearth(pir, what="land", resolution="medium") # fill continents
sl.plot.naturalearth(pir, what="coastline", resolution="medium") # add coastlines
sl.plot.lonlatgrid(pir,labels = T) # add grid and labels
cs = c("darkgreen","darkblue","darkred") # colors for buoys
startind.obs = c(35,90,90) # start indices for observations (earlier measurements were still aboard, determined manually)

for (i.obs in 1:length(obs.all)){ # loop over observations
	# Observations
	obs.tid = obs.all[[i.obs]] # Get observation for current target
	n.obs = length(obs.tid$data$Lon) # number of datapoints
	sl.plot.lines(pir,lon = obs.tid$data$Lon[startind.obs[i.obs]:n.obs], obs.tid$data$Lat[startind.obs[i.obs]:n.obs],col = cs[i.obs],lwd = 2) # plot observation
	
	# Forecasts
	ind.tid = index[index$TargetID == obs.tid$TargetID,] # index with only current target
	reltime.tid = sidfex.ydoy2reltime(RefYear = 2022,RefDayOfYear = 1, Year = ind.tid$InitYear,DayOfYear = ind.tid$InitDayOfYear) # relative time (used for determining most recent forecast)
	idoy.latest = ind.tid$InitDayOfYear[which.max(reltime.tid)] # get latest initialisation day
	iy.latest = ind.tid$InitYear[which.max(reltime.tid)] # get latest initialisation year
	ind.latest = ind.tid[ind.tid$InitDayOfYear == idoy.latest & ind.tid$InitYear == iy.latest,] # get index with only latest forecast
	#fcst = sidfex.read.fcst(files = ind.tid) # get index with all forecasts for this target
	fcst = sidfex.read.fcst(files = ind.latest) # get index with only latest forecast
	fcst.rot = sidfex.rot.fcst(fcst = fcst) # rotate forecast so that it matches the initial point of the observations
	for (i.fcst in 1:length(fcst.rot$res.list)){ # loop over forecasts
		sl.plot.lines(pir,lon = fcst.rot$res.list[[i.fcst]]$data$Lon, fcst.rot$res.list[[i.fcst]]$data$Lat,col = cs[i.obs],lwd = 1,lty = "dashed") # plot forecast
	}
}
legend("topleft",legend = c(tids,"Forecasts"),lty = "solid",lwd = c(rep(2,3),1), col = c(cs,"black")) # add legend
dev.off() # close plot

## Plot speed-angle plots ##
xpos = c(-1.5,-1.5,-1.5) # x positions for text
ypos = c(2,1.9,1.8) # y positions for text
for (i.obs in 1:length(obs.all)){ # loop over observations
	obs.tid = obs.all[[i.obs]] # Get observation for current target
	ind.tid = index[index$TargetID == obs.tid$TargetID,] # get index with all forecasts for current target
	plot.name = paste0("speedangle_",obs.tid$TargetID,"_",today,".pdf") # name of plot
	pdf(file.path(plot.dir,"speedangle",plot.name)) # open file
	colbar = sidfex.plot.speedangle(index = ind.tid,col.by = "DaysLeadTime",device = NULL) # make speedangle plot
	text(x = xpos[1],y = ypos[1], label = paste0("IMEI: ",unique(ind.tid$TargetID)),cex = 1) # put IMEI on plot
	text(x = xpos[2],y = ypos[2], label = paste0("Number of forecasts: ",length(ind.tid$File)),cex = 1) # put number of init on plot
	text(x = xpos[3],y = ypos[3], label = paste0("Plotted on: ",today),cex = 1) # add date to plot
	dev.off()
	
}



