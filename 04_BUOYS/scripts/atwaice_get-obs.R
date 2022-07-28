# 
# This script can be used to download drifter data (with wget) according to the 
# list provided by Mario. It also contains a function for stitching together the
# daily .csv files into a single ASCII table.
# 

require(SIDFEx)

atwaice_stitch_csv_together <- function(filepath.in, filepath.out, targetID){
  #=============================================================================#
  # This function looks up all .csv files in 'filepath.in' that contain the given
  # 'targetID'. It then creates a SIDFEx-obs-compatible table, glueing all .csv 
  # files together basically, and stores it in <filepath.out>/<targetID>.txt.
  #=============================================================================#
  
  # a flag for using a different routine when it's an old buoy
  flag_alternative = FALSE 
  
  # file name (<IMEI.txt>)
  fn.out = paste0(filepath.out, targetID, ".txt")
  
  # find all csv files for a given targetID 
  files = Sys.glob(paste0(filepath.in, "*", targetID , "*.csv"))
  Nfiles = length(files)
  
  # if the buoy is old, we might need to look it up by its manufacturer name
  if (Nfiles < 1){
    targetID_alternative = dat_MAN[which(dat_IMEI==targetID)]
    files = Sys.glob(paste0(filepath.in, "*", targetID_alternative , "*.txt"))
    Nfiles = length(files)
    if (Nfiles==1){
      flag_alternative = TRUE
    } else {
      warning("no files for this targetID")
      return(NULL)
    }
  }
  
  # CASE 1: new buoy type, i.e. daily csv files
  if (!flag_alternative){
    # init a list (it's not pretty to do it like this, but it works)
    buoy.data. = list()
    
    for (i in 1:Nfiles){
      dat = read.table(files[i], stringsAsFactors = FALSE,sep = ",",header = TRUE)   
      tm = as.POSIXlt(dat$Data..Date.GMT.,tz = "GMT")
      data.row = cbind(tm$year+1900,tm$yday+1+(tm$hour+
                                                 (tm$min+(tm$sec/60))/60)/24,dat$LATITUDE,dat$LONGITUDE)
      
      buoy.data.[[i]] = data.row
    }
    
    Nrows = length(unlist(buoy.data.)) / 4
    
    # init output table
    buoy.data = data.frame(Year=numeric(Nrows)*NA,POS_DOY=numeric(Nrows)*NA,
                           Lat=numeric(Nrows)*NA,Lon=numeric(Nrows)*NA)
    
    # fill output table from list of arrays (buoy.data.)
    row.cnt = 1
    for (i in 1:Nfiles){
      Nrow = length(buoy.data.[[i]][,1])
      
      buoy.data[row.cnt:(row.cnt+Nrow-1),] = buoy.data.[[i]]
      
      row.cnt = row.cnt + Nrow 
    }
  } else {
    # CASE 2: old buoy type, i.e. complete .txt file
    dat = read.table(files[1], sep = ",", skip = 1)
    
    tm = as.POSIXlt(dat$V1,tz = "GMT")
    data.row = cbind(tm$year+1900,tm$yday+1+(tm$hour+
                                               (tm$min+(tm$sec/60))/60)/24,dat$V3,dat$V4)
    Nrows = length(tm)
    buoy.data = data.frame(Year=numeric(Nrows)*NA,POS_DOY=numeric(Nrows)*NA,
                           Lat=numeric(Nrows)*NA,Lon=numeric(Nrows)*NA)
    buoy.data[,] = data.row
    
  }
  
  # write table
  write.table(buoy.data, file = fn.out, append = FALSE, quote = FALSE, 
              col.names = TRUE, row.names = FALSE)
}

##################################################

# list of drifters for ATWAICE
drifterlist = "/home/a/a270209/SIDFEx/scripts/drifter_table"  

# where to store the data from the ftp server
fp_dwld = "/home/a/a270209/SIDFEx/index/obs_atwaice_tmp/"
fp_out = "/home/a/a270209/SIDFEx/index/observations/"

dat = read.table(drifterlist, colClasses=c(rep("character", 7)))

dat_AWI  = dat$V1  # AWI internal name
dat_MAN  = dat$V2  # name from manufacturer
dat_IMEI = dat$V3  # official IMEI

# Helge, this is the line where you add the IMEIs I'll send to you from the ship. 
# Remove the current one, which is just for testing.
ATWAICE_SIDFEX_IMEI_LIST = c("300534062174040","300534062171030","300534062175050")

# download all files from ftp server that match the resp. IMEI number
for (buoy_id in ATWAICE_SIDFEX_IMEI_LIST){
  
  # check if buoy is old or not
  if (dat$V7[which(dat_IMEI==buoy_id)]=="V2"){
    buoy_id = dat_MAN[which(dat_IMEI==buoy_id)]
  }
  system(paste0('wget -A', '"*', buoy_id,'*"',' -nH -m --no-remove-listing --reject',
                ' "index.html" -c --progress=dot -N --secure-protocol=auto ',
                '--no-proxy --passive-ftp --ftp-user=mhoppmann ',
                '--ftp-password=mhoppmannirD9 --no-check-certificate ',
                'ftps://ldmanager.southteksl.com:21 -P ', fp_dwld))

  atwaice_stitch_csv_together(fp_dwld, fp_out, buoy_id)
  
}


