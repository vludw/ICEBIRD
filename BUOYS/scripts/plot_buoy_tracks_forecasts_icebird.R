##################################
## Purpose: Plot buoy data and SIDFEx forecasts for selected buoys during the Icebird campaign.
## Created by: Valentin Ludwig (valentin.ludwig@awi.de)
## Creation date: 20220726
###################################
rm(list=ls()) # Clean up before starting
## Load modules ##
require(SIDFEx)
require(spheRlab)

## Functions

make.map <- function(obs.all,pir,large = TRUE){
	ind.center.tid = which(tids.res.list == "300534062171030") # middle buoy (there is also one Northern and one Southern buoy)
	n.obs = length(obs.all[[ind.center.tid]]$data$Lon) # number of data points
	center.plot.lon = c(obs.all[[ind.center.tid]]$data$Lon[n.obs]) # last longitude/latitude will be center of the plot domain
	center.plot.lat = c(obs.all[[ind.center.tid]]$data$Lat[n.obs]) # last longitude/latitude will be center of the plot domain
	first.day.obs = round(obs.all[[ind.center.tid]]$data$POS_DOY[1],1)
	first.year.obs = obs.all[[ind.center.tid]]$data$Year[1]
	first.date.obs.jul = paste0(first.year.obs,"-",first.day.obs)
	first.date.obs = as.Date(first.date.obs.jul,format = "%Y-%j")
	first.date.obs.str = paste0("Observation starts: ",first.date.obs)
	
	last.day.obs = obs.all[[ind.center.tid]]$data$POS_DOY[n.obs]
	last.year.obs =obs.all[[ind.center.tid]]$data$Year[n.obs]
	last.date.obs.jul = paste0(last.year.obs,"-",last.day.obs)
	last.date.obs = as.Date(last.date.obs.jul,format = "%Y-%j")
	last.date.obs.str = paste0("Observation stops: ",last.date.obs)
	## Plot trajectories ##
	if (large){
		plot.name = paste0("obs_fcst_tracks_large_",today,".pdf") # name of plot
	}else{
		plot.name = paste0("obs_fcst_tracks_zoom_",today,".pdf") # name of plot
	}
	pdf(file.path(plot.dir.maps,plot.name)) # open PDF file for plotting
	if (large){
		pir = sl.plot.init(projection = "polar",polar.lonlatrot = c(center.plot.lon,center.plot.lat,0),polar.latbound = 87, do.init.device=F,main = paste0("\n Buoy tracks on ",today)) # open plot
	}else{
		pir = sl.plot.init(projection = "polar",polar.lonlatrot = c(center.plot.lon,center.plot.lat,0),polar.latbound = 89, do.init.device=F,main = paste0("\n Buoy tracks on ",today)) # open plot
	}
	
	#sl.plot.text(pir,lon = -12,lat = 83.5, label = paste0("Last measurement: ",last.date), cex = 1)
	sl.plot.naturalearth(pir, what="land", resolution="medium") # fill continents
	sl.plot.naturalearth(pir, what="coastline", resolution="medium") # add coastlines
	sl.plot.lonlatgrid(pir,labels = T) # add grid and labels
	cs = c("darkgreen","darkblue","darkred") # colors for buoys
	startind.obs = c(35,90,90) # start indices for observations (earlier measurements were still aboard, determined manually)
	for (i.obs in 1:length(obs.all)){ # loop over observations
		# Observations
		obs.tid = obs.all[[i.obs]] # Get observation for current target
		n.obs = length(obs.tid$data$Lon) # number of datapoints
		obs.tid.truncated = sidfex.remaptime.obs(obs = obs.tid,newtime.YearDayOfYear = list(Year = obs.tid$data$Year[startind.obs[i.obs]:n.obs], DayOfYear = obs.tid$data$POS_DOY[startind.obs[i.obs]:n.obs])) # remap to valid period (after deployment)
		obs.lon = obs.tid.truncated$data$Lon
		obs.lat = obs.tid.truncated$data$Lat
		if (!large){
			obs.doy.int = unique(floor(obs.tid.truncated$data$POS_DOY)) # remap to daily valeus for map (will be marked by crosses)
			obs.year.int = unique(floor(obs.tid.truncated$data$Year)) # remap to daily valeus for map (will be marked by crosses)
			obs.remap.daily = sidfex.remaptime.obs(obs = obs.tid.truncated,newtime.YearDayOfYear = list(Year = obs.year.int, DayOfYear = obs.doy.int)) # remap to daily valeus for map (will be marked by crosses)
			sl.plot.points(pir,lon = obs.remap.daily$data$Lon[!is.na(obs.remap.daily$data$Lon)], obs.remap.daily$data$Lat[!is.na(obs.remap.daily$data$Lat)],col = cs[i.obs],pch = 4) # add marker for daily points
			
		}

		sl.plot.lines(pir,lon = obs.lon, lat = obs.lat,col = cs[i.obs],lwd = 2) # plot observation
		sl.plot.points(pir,lon = obs.lon[1], obs.lat[1],col = cs[i.obs],pch = 0) # add marker for start
		# Forecasts
		ind.tid = index[index$TargetID == obs.tid$TargetID,] # index with only current target
		reltime.tid = sidfex.ydoy2reltime(RefYear = 2022,RefDayOfYear = 1, Year = ind.tid$InitYear,DayOfYear = ind.tid$InitDayOfYear) # relative time (used for determining most recent forecast)
		idoy.latest = ind.tid$InitDayOfYear[which.max(reltime.tid)] # get latest initialisation day
		iy.latest = ind.tid$InitYear[which.max(reltime.tid)] # get latest initialisation year
		ind.latest = ind.tid[ind.tid$InitDayOfYear == idoy.latest & ind.tid$InitYear == iy.latest,] # get index with only latest forecast
		#fcst = sidfex.read.fcst(files = ind.tid) # get index with all forecasts for this target
		fcst = sidfex.read.fcst(files = ind.latest) # get index with only latest forecast
		fcst.rot = sidfex.rot.fcst(fcst = fcst) # rotate forecast so that it matches the initial point of the observations
		first.year.fcst = fcst.rot$res.list[[1]]$data$Year[1]
		first.day.fcst = fcst.rot$res.list[[1]]$data$DayOfYear[1]
		
		first.date.fcst.jul = paste0(first.year.fcst,"-",first.day.fcst)
		first.date.fcst = as.Date(first.date.fcst.jul,format = "%Y-%j")
		first.date.fcst.str = paste0("Forecast starts: ",first.date.fcst)
		
		
		
		n.fcst = length(fcst.rot$res.list[[1]]$data$DayOfYear)
		
		last.year.fcst = fcst.rot$res.list[[1]]$data$Year[n.fcst]
		last.day.fcst = fcst.rot$res.list[[1]]$data$DayOfYear[n.fcst]
		last.date.fcst.jul = paste0(last.year.fcst,"-",last.day.fcst)
		last.date.fcst = as.Date(last.date.fcst.jul,format = "%Y-%j")
		last.date.fcst.str = paste0("Forecast stops: ",last.date.fcst)

		
		
		today.str = paste0("Today: ",format(Sys.time(),format = "%Y-%m-%d"))
		for (i.fcst in 1:length(fcst.rot$res.list)){ # loop over forecasts
			sl.plot.lines(pir,lon = fcst.rot$res.list[[i.fcst]]$data$Lon, lat = fcst.rot$res.list[[i.fcst]]$data$Lat,col = cs[i.obs],lwd = 1,lty = "dashed") # plot forecast
			sl.plot.points(pir,lon = fcst.rot$res.list[[i.fcst]]$data$Lon[1], lat = fcst.rot$res.list[[i.fcst]]$data$Lat[1],col = cs[i.obs],pch = 1) # plot observation
			if (!large){
				fcst.remap.daily = sidfex.remaptime.fcst(fcst = fcst.rot,newtime.DaysLeadTime = 0:10) # remap to daily valeus for map (will be marked by crosses)
				sl.plot.points(pir,lon = fcst.remap.daily$res.list[[1]]$data$Lon, fcst.remap.daily$res.list[[1]]$data$Lat,col = cs[i.obs],pch = 2) # plot forecast	
				# days.jul = fcst.remap.daily$res.list[[1]]$data$DayOfYear
				# years = fcst.remap.daily$res.list[[1]]$data$Year
				# date.jul = as.Date(paste0(years,"-",days.jul),format = "%Y-%j")
				# days = format(date.jul,"%d")
				# months = format(date.jul,"%m")
				# date.str = paste0(months,"-",days)
				#sl.plot.text(pir,lon = fcst.remap.daily$res.list[[1]]$data$Lon[1], lat = fcst.remap.daily$res.list[[1]]$data$Lat[1],col = cs[i.obs],label = date.str[1],pos = 1) # plot forecast	
			}
		}
	}
	if (large){
		legend("bottomleft",legend = c(tids,"Forecasts","First observation point","First forecast point"),lty = c(rep("solid",4),NA,NA),lwd = c(rep(2,3),1,NA,NA), col = c(cs,"black","black","black"),pch = c(rep(NA,4),0,1),bg = "white") # add legend
	}else{
		legend("bottomleft",legend = c(tids,"Forecasts","First observation point","First forecast point","Daily marker (obs)", "Daily marker (fcst)"),lty = c(rep("solid",4),rep(NA,4)),lwd = c(rep(2,3),1,rep(NA,3)), col = c(cs,rep("black",5)),pch = c(rep(NA,4),0,1,4,2),bg = "white") # add legend
	}
	
	legend("bottomright",legend = c(today.str,first.date.obs.str,last.date.obs.str,first.date.fcst.str,last.date.fcst.str),lty = "solid",lwd = 0, col = "white",bg = "white") # add last measurement date
	print(first.date.obs)
	dev.off() # close plot
}
## Preparations ##
index = sidfex.load.index() # load SIDFEx index
tids = c("300534062174040","300534062171030","300534062175050") # targets of interest
up.to.date = T # boolean to decide whether new forecasts and observations shall be downloaded
do.map = T # create map with observed and forecasted drift trajectories: Yes or no? You decide!
do.speedangle = T # create speedangle plot: Yes or no? You decide!
read.obs.from.local = T # read observations from locally downloaded txt file
if (up.to.date){ # boolean to decide whether new forecasts and observations shall be downloaded
	res = sidfex.download.fcst(comparison.mode=FALSE,from.scratch = FALSE) # download forecasts
	res = sidfex.download.obs(TargetID = tids) # download observations
}
today = format(Sys.time(),("%Y%m%d")) # today's date (needed for savenames)

home.dir = Sys.getenv("HOME") # get home directory
if (Sys.getenv("USER") == "vludwig"){
  plot.dir.maps = file.path(home.dir,"04_EVENTS/03_ICEBIRD/03_REPO/BUOYS/plots/maps") # plots will be saved here
  plot.dir.speedangle = file.path(home.dir,"04_EVENTS/03_ICEBIRD/03_REPO/BUOYS/plots/speedangle") # plots will be saved here
  data.path.local = file.path(home.dir,"04_EVENTS/03_ICEBIRD/03_REPO/BUOYS/data/txt")
}else if (Sys.getenv("USER") == "icebird"){
  plot.dir.maps = file.path(home.dir,"ICEBIRD/BUOYS/plots/maps") # plots will be saved here
  plot.dir.speedangle = file.path(home.dir,"ICEBIRD/BUOYS/plots/speedangle") # plots will be saved here
  data.path.local = file.path(home.dir,"ICEBIRD/BUOYS/data/txt")
}

## Load observations and determine plot domain ##
obs.all = list()  # list for observations
tids.res.list = c() # list with Target IDs. Needed to determine center of plot (middle buoy is selected based on Target ID, last point of this buoy will be the center of the map)
for (i.tid in 1:length(tids)){ # loop over targets
  if (read.obs.from.local){
	  obs.all[[i.tid]] = sidfex.read.obs(TargetID = tids[i.tid],data.path = data.path.local) # add current target to list
  }else{
	  obs.all[[i.tid]] = sidfex.read.obs(TargetID = tids[i.tid]) # add current target to list
  }
	tids.res.list = c(tids.res.list,obs.all[[i.tid]]$TargetID) # add target ID to list
}

if (do.map){


	make.map(obs.all = obs.all, pir = pir,large = TRUE)
	make.map(obs.all = obs.all, pir = pir,large = FALSE)

	
}

if (do.speedangle){
	## Plot speed-angle plots ##
	xpos = c(-1.5,-1.5,-1.5) # x positions for text
	ypos = c(2,1.9,1.8) # y positions for text
	for (i.obs in 1:length(obs.all)){ # loop over observations
		obs.tid = obs.all[[i.obs]] # Get observation for current target
		ind.tid = index[index$TargetID == obs.tid$TargetID,] # get index with all forecasts for current target
		plot.name = paste0("speedangle_",obs.tid$TargetID,"_",today,".pdf") # name of plot
		pdf(file.path(plot.dir.speedangle,plot.name)) # open file
		colbar = sidfex.plot.speedangle(index = ind.tid,col.by = "DaysLeadTime",device = NULL) # make speedangle plot
		text(x = xpos[1],y = ypos[1], label = paste0("IMEI: ",unique(ind.tid$TargetID)),cex = 1) # put IMEI on plot
		text(x = xpos[2],y = ypos[2], label = paste0("Number of forecasts: ",length(ind.tid$File)),cex = 1) # put number of init on plot
		text(x = xpos[3],y = ypos[3], label = paste0("Plotted on: ",today),cex = 1) # add date to plot
		dev.off()
		
	}
}



