
#' Create .\emph{skyscapeR.horizon} object from Az/Alt data
#'
#' This function creates a \emph{skyscapeR.horizon} object from measurements of
#' azimuth and apparent altitude.
#' @param az Array of azimuth values
#' @param alt Array of apparent altitude values.
#' @param alt.unc (Optional) Either a single value or an array of altitude
#' uncertainty.
#' @param loc Location, a vector containing the latitude and longitude of
#' the location, in this order.
#' @param name Name of site.
#' @seealso \code{\link{plot.skyscapeR.horizon}}
#' @export
#' @seealso \code{\link{createHWT}}, \code{\link{downloadHWT}}
#' @examples
#' # Create a skyscapeR.horizon from 5 measurements:
#' az <- c(0,90,180,270,360)
#' alt <- c(0,5,5,0,0)
#' hor <- createHor(az, alt, 0.1, c(40.1,-8), 'Test')
#' plot(hor)
createHor = function(az, alt, alt.unc, loc, name) {
  # return result
  hor <- c()
  hor$metadata$name <- name
  # in other places loc is latitude, longitude, height, here is it only latitude and longitude...
  # a decision needs to be made consistent over skyscapeR
  hor$metadata$georef <- loc; names(hor$metadata$georef) <- c('Lat','Lon'); dim(hor$metadata$georef) <- c(1,2)

  hor$data <- data.frame(az = az, alt = alt)
  if (!missing(alt.unc)) {
    if (length(alt.unc) > 1 & length(alt.unc) < length(az)) {
      stop('Altitude uncertainty must be either a single value or have the same length as "az"')
    } else {
      if (length(alt.unc) == 1 ) { alt.unc <- rep(alt.unc, length(az)) }
      hor$data$alt.unc <- alt.unc
    }
  }
  class(hor) <- "skyscapeR.horizon"
  return(hor)
}



#' Exports a \emph{skyscapeR.horizon} object into \emph{Stellarium} format
#'
#' This function exports any \emph{skyscapeR.horizon} object into the landscape
#' format of \emph{Stellarium}, ready to be imported.
#' @param hor Horizon data in \emph{skyscapeR.horizon} format.
#' @param name Horizon name to be displayed in \emph{Stellarium}, if different
#' from one in \emph{skyscapeR.horizon} object.
#' @param author (Optional) Author, to be included in \emph{landscape.ini} file.
#' @param description (Optional) Description, to be included in \emph{landscape.ini} file.
#' @param ground_col Colour of ground. Defaults to \emph{Stellarium}'s default.
#' @param hor_col Colour of horizon line. Defaults to \emph{Stellarium}'s default.
#' @seealso \code{\link{createHor}}, \code{\link{downloadHWT}}, \code{\link{plot.skyscapeR.horizon}}
#' @references \href{http://www.stellarium.org/}{Stellarium: a free open source planetarium}
#' @export
#' @import utils
#' @examples
#' # Downloads horizon data from HeyWhatsThat and exports it into Stellarium:
#' hor <- downloadHWT('HIFVTBGK')
#' exportHor(hor, name='Test', description='Test horizon export to Stellarium')
exportHor = function(hor, name, author="skyscapeR", description, ground_col, hor_col) {
  if (class(hor) != 'skyscapeR.horizon') { stop('No skyscapeR.horizon object found.') }

  if (missing(name)) { name = hor$name }
  if (missing(description)) { description <- paste0("Horizon created using skyscapeR ", packageVersion('skyscapeR'), ".") }
  if (substr(description,nchar(description),nchar(description)) != ".") { description <- paste0(description,". Horizon created using skyscapeR ", packageVersion('skyscapeR'), ".") }
  if (missing(ground_col)) {ground_col = ".15,.45,.15"}
  if (missing(hor_col)) {hor_col = ".75,.45,.45"}

  # Horizon data
  data <- data.frame(x = hor$data$az, y = hor$data$alt)
  write.table(data, file="horizon.txt", sep = " ", row.names=F, col.names=F)

  # Landscape.ini file
  fileConn<-file("landscape.ini")
  string.text <- c("[landscape]", paste0("name = ",name), "type = polygonal", paste0("author = ",author),
                   paste0("description = ", description), "polygonal_horizon_list = horizon.txt",
                   "polygonal_angle_rotatez = 0", paste0("ground_color = ",ground_col),
                   paste0("horizon_line_color =  ",hor_col), "",
                   "[location]", "planet = Earth", paste0("latitude = ",hor$metadata$georef[1,1],"d"),
                   paste0("longitude = ",hor$metadata$georef[1,2],"d"), paste0("altitude = ",round(hor$metadata$georef[1,3]*0.304,0)))
  writeLines(string.text, fileConn)
  close(fileConn)

  # Save as zip file: for windows RTools (incl. path settings) is needed

  zip(zipfile=paste0(name,'-horizon.zip'), files=c("landscape.ini", "horizon.txt"))
  file.remove(c('landscape.ini', 'horizon.txt'))
}



#' Download horizon data from \emph{HeyWhatsThat}
#'
#' This function downloads previously created horizon data
#' from \emph{HeyWhatsThat}, given its ID, and saves it as
#' a \emph{skyscapeR.horizon} object.
#' @param HWTID This is the 8 character ID attributed by
#' \emph{HeyWhatsThat.com}
#' @export
#' @import utils
#' @references \href{http://heywhatsthat.com/}{HeyWhatsThat.com}
#' @seealso \code{\link{createHWT}}
#' @examples
#' # Retrieve horizon data for \href{https://www.heywhatsthat.com/?view=HIFVTBGK}{Liverpool Cathedral}:
#' hor <- downloadHWT('HIFVTBGK')
downloadHWT <- function(HWTID) {
  if (nchar(HWTID) != 8) { stop('Incorrect HeyWhatsThat ID.') }

  ## Horizon metadata
  test <- readLines(paste0("http://www.heywhatsthat.com/iphone/pan.cgi?id=",HWTID))
  hor <- c()

  # Lat/Lon/Elev
  mypattern = '<div class=\"details_data\">([^<]*)</div>'
  datalines = grep(mypattern,test,value=TRUE)
  getexpr = function(s,g)substring(s,g,g+attr(g,'match.length')-1)
  gg = gregexpr(mypattern,datalines)
  matches = mapply(getexpr,datalines,gg)
  result = gsub(mypattern,'\\1',matches)
  names(result) = NULL
  result[c(1,2,4)]

  Lat <- as.numeric(strtrim(result[1],regexpr("&deg", result[1])[1]-1))
  if (substr(result[1],nchar(result[1]),nchar(result[2])) == "S") { Lat <- -Lat }
  Lon <- as.numeric(strtrim(result[2],regexpr("&deg", result[2])[1]-1))
  if (substr(result[2],nchar(result[2]),nchar(result[2])) == "W") { Lon <- -Lon }
  aux <- strtrim(result[4],regexpr("&nbsp;", result[4])[1]-1)
  Elev <- as.numeric(substr(aux,2,nchar(aux)))

  # Site Name
  grep("pan_top_title", test)
  mypattern = '<div id=\"pan_top_title\" class=\"ellipsis\" style=\"position: absolute; top: 46px; width: 296px\">([^<]*)</div>'
  datalines = grep(mypattern,test,value=TRUE)
  getexpr = function(s,g)substring(s,g,g+attr(g,'match.length')-1)
  gg = gregexpr(mypattern,datalines)
  matches = mapply(getexpr,datalines,gg)
  result = gsub(mypattern,'\\1',matches)
  names(result) = NULL
  Name <- result

  ## Horizon data
  hor.ex <- unique(substr(list.files(tempdir()),1,8)) # check if already downloaded

  if (sum(HWTID == hor.ex) == 0) {
    if (NROW(hor.ex) > 500) {
      # delete oldest
      details <- file.info(file.path(tempdir(),list.files(file.path(tempdir()))))
      details <- details[with(details, order(as.POSIXct(ctime))), ]
      files <- unique(substr(rownames(details),10,17))[1]
      files <- paste0(file.path(tempdir()),"/",c(files, paste0(files,"-0-1")), ".png")
      file.remove(files)
    }

    # download new one
    curdir <- getwd()
    setwd(tempdir())
    download.file(paste0('http://www.heywhatsthat.com/api/horizon.csv?id=',HWTID,'&resolution=.125'), mode ='wb', destfile=paste0(HWTID,'.csv'), quiet=T)
    setwd(curdir)
  }

  horizon <- read.csv(file.path(tempdir(), paste0(HWTID, '.csv')))

  ## Apparent altitude Error
  delta <- 9.73  # 9.73m for SRTM data
  horizon$error <- rep(NA,NROW(data))
  for (i in 1:NROW(horizon)) {
    hor.alt <- horizon$altitude[i]
    delta.elev <- horizon$distance..m.[i] * tan( hor.alt * pi/180)
    aux0 <- atan( delta.elev / horizon$distance..m.[i]  ) * 180/pi
    aux1 <- atan( (delta.elev + delta) / horizon$distance..m.[i]  ) * 180/pi
    aux2 <- atan( (delta.elev - delta) / horizon$distance..m.[i]  ) * 180/pi
    horizon$error[i] <- mean(abs(c(aux1,aux2)-aux0))
  }

  # return result
  hor$metadata <- c()
  hor$metadata$ID <- HWTID
  hor$metadata$name <- Name
  hor$metadata$georef <- c(Lat, Lon, Elev); names(hor$metadata$georef) <- c('Lat','Lon', 'Elev'); dim(hor$metadata$georef) <- c(1,3)
  hor$metadata$elevation <- Elev

# bin.bottom of az needs to be increased with half binsize (0.125) to match the apparent alttiude value
# (which is determined for the whole bin)
# I think that interpolations (hor2alt) works well for az=0 and 360, both with apparent altitude being average(hor$data$alt[1],hor$data$alt[2880])
# was not yet able to test if exportHor can handle this (with or without '+0.125/2' the zip is not properly represented in Stellarium).

  hor$data <- data.frame(az = horizon$bin.bottom+0.125/2, alt = horizon$altitude, alt.unc = horizon$error)

  class(hor) <- "skyscapeR.horizon"
  return(hor)
}


#' Create and download horizon data from \emph{HeyWhatsThat}
#'
#' This function send a data request to \emph{HeyWhatsThat}, for the
#' creation of a horizon profile for a give Lat/Lon and elevation. It
#'  then downloads the data and saves it as a \emph{skyscapeR.horizon}
#'   object.
#' @param lat The latitude of the location.
#' @param lon The longitude of the location.
#' @param elevation (Optional) The elevation of the observer above
#' ground level in metres. Default is 1.6 metres (eye level).
#' @param name (Optional) Name for horizon.
#' @param src (Optional) Request source ID for \emph{HeyWhatsThat}. Default is
#'  'skyscapeR'. Only change this if you have ben given a source ID by the
#'  creator of \emph{HeyWhatsThat}.
#' @param verbose (Optional) Boolean switch to control output. Default is \emph{TRUE}.
#' @export
#' @import utils httr
#' @references \href{http://heywhatsthat.com/}{HeyWhatsThat.com}
#' @seealso \code{\link{downloadHWT}}
#' @examples
#' \dontrun{
#' # Create and retrive horizon data for the London Mithraeum:
#' hor <- createHWT(lat=ten(51,30,45), lon=ten(0,5,26.1), name='London Mithraeum')
#' }
createHWT <- function(lat, lon, elevation=1.6, name, src='skyscapeR', verbose=T) {
  if (verbose) { cat('Sending request to HeyWhatsThat servers...') }
  test <- httr::GET(url=paste0('http://www.heywhatsthat.com/api/query?src=',src,'&lat=',lat,'&lon=',lon,'&elev_agl=',elevation))
  if (test$headers$`x-app-status` == '200 OK') {
    if (verbose) { cat('Done.\nWaiting for computation to finish...') }
  } else { stop(test$headers$`x-app-status`) }
  HWT.ID <- substr(httr::content(test),1,8)
  Sys.sleep(30)

  t <- 0
  while (t==0) {
    test <- httr::GET(url=paste0('http://www.heywhatsthat.com/api/ready?src=',src,'&id=',HWT.ID))
    t <- as.numeric(substr(httr::content(test),1,1))
    Sys.sleep(60)
  }
  if (verbose) { cat('Done.\nDownloading data...') }
  hor <- downloadHWT(HWT.ID)
  hor$metadata$name <- name
  if (verbose) { cat('Done.\n') }
  return(hor)
}
