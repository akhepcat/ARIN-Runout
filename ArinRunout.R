#!/usr/bin/Rscript
#
#  Copyright Leif Sawyer, ak.hepcat@gmail.com -  May 16, 2014
#  GPLv3
#  Version 0.4
#

# Shut up!
options(warn=-1)
message("Loading required libraries takes a second...")

# first things first, lets load getopt
library(getopt)

# Allow us to read foreign data-types, such as CSV files
library(foreign)
# We need ggplot and splines to plot our graph and forecast into the future
library(methods)
library(nlme)
library(ggplot2)
library(splines)
library(scales)

# This guy is noisy on startup...
suppressPackageStartupMessages(library(mgcv))

optspec = matrix(c(
	'verbose', 'v', 0, "integer", "Increase verbosity",
	'help'	 , 'h', 0, "logical", "show this help",
	'datadir', 'd', 2, "character", "Directory where ARIN data is stored, defaults to '.'",
	'webdir' , 'w', 2, "character", "Root directory for images, defaults to '.'",
	'timestamp', 't', 2, "character", "Alternate timestamp instead of 'now'"
), byrow=TRUE, ncol=5);
opt = getopt(optspec);

if ( !is.null(opt$help) ) {
  cat(getopt(optspec, usage=TRUE));
  q(status=1);
}

if( is.na(file.info(opt$datadir)$isdir) || !file.info(opt$datadir)$isdir ) {
	message(merge("directory",opt$datadir,"doesn't exist. Defaulting to '.'"))
	data.dir <- '.'
} else {
	data.dir <- opt$datadir
}
if( is.na(file.info(opt$webdir)$isdir) || !file.info(opt$webdir)$isdir ) {
	message(merge("directory",opt$webdir,"doesn't exist. Defaulting to '.'"))
	web.dir <- '.'
} else {
	web.dir <- opt$webdir
}

if ( is.null(opt$timestamp) ) {
	today <- format(Sys.time(), "%Y%m%d")
} else {
	today <- format(as.Date(opt$timestamp,"%Y%m%d"), "%Y%m%d")
}


Datafile <- paste(data.dir, "/ARIN-Delegated-", as.character(today), ".csv", sep="")
Imagefile.y2k <- paste(web.dir, "/Y2K/ARIN-Runout-Y2K-", as.character(today), ".png", sep="")
Imagefile.full <- paste(web.dir, "/Full/ARIN-Runout-Full-", as.character(today), ".png", sep="")
Imagefile.1y <- paste(web.dir, "/12Month/ARIN-Runout-12Month-", as.character(today), ".png", sep="")


# Read our CSV file into a dataframe
mydata <- NULL
try(mydata <- read.csv(Datafile, header=TRUE, sep=",", as.is = 1), silent = TRUE)

if (is.null(mydata)) {
  message(paste("Can't open", Datafile, "for reading. Aborting"))
  q()
} else {
  message(paste("Successfully read", Datafile, "and now parsing data."))
}

date<-as.Date(mydata$DATESTAMP,"%Y-%m-%d")
ips<-mydata$INVENTORY

# Copy the two vectors of data into a data.frame
ArinData <- data.frame(date,ips)

# Plot out the data
ArinPlot = NULL
# Generate the last-12-months graph --
ytd<-subset(ArinData, date>as.Date("2013-01-01"),ips)
try((ArinPlot = ggplot( ArinData, aes(y = ips, x = date) ) + geom_point() + ylim(0,ytd[1:1,]) + xlim(as.Date("2013-01-01"), as.Date("2015-06-01")) + stat_smooth(method = 'gam', formula = y ~ ns(x, df=7), fullrange = TRUE) +
  scale_x_date(breaks = date_breaks("months"), labels = date_format("%Y-%m"), limits=c(as.Date("2013-01-01"), as.Date("2015-06-01"))) + theme(axis.text.x = element_text(angle = 90, vjust = .5)) +
  ggtitle("ARIN IPv4 Runout, 2013-present") ), silent = TRUE)
if (is.null(ArinPlot)) {
  message(paste("Couldn't generate a plot for", today))
} else {
  # Save the graph as a lovely and large PNG
  ggsave(filename = Imagefile.1y, plot = ArinPlot, width=10, height=8)
}

# Generate the Y2K graph
ArinPlot = NULL
ytd<-subset(ArinData, date>as.Date("2000-01-01"),ips)
try((ArinPlot = ggplot( ArinData, aes(y = ips, x = date) ) + geom_point() + ylim(0,ytd[1:1,]) + xlim(as.Date("2000-01-01"), as.Date("2015-06-01")) + stat_smooth(method = 'gam', formula = y ~ ns(x, df=7), fullrange = TRUE) +
  scale_x_date(breaks = date_breaks("3 months"), labels = date_format("%Y-%m"), limits=c(as.Date("2000-01-01"), as.Date("2015-06-01"))) + theme(axis.text.x = element_text(angle = 90, vjust = .5)) +
  ggtitle("ARIN IPv4 Runout, 2000-present")), silent = TRUE)
if (is.null(ArinPlot)) {
  message(paste("Couldn't generate a plot for", today))
} else {
  # Save the graph as a lovely and large PNG
  ggsave(filename = Imagefile.y2k, plot = ArinPlot, width=10, height=8)
}

# Generate the forever graph
ArinPlot = NULL
try((ArinPlot = ggplot( ArinData, aes(y = ips, x = date) ) + geom_point() + ylim(0,max(ips)) + stat_smooth(method = 'gam', formula = y ~ ns(x, df=7), fullrange = TRUE) +
  scale_x_date(breaks = date_breaks("3 months"), labels = date_format("%Y-%m"), limits=c(as.Date("1993-01-01"), as.Date("2015-06-01"))) + theme(axis.text.x = element_text(angle = 90, vjust = .5)) +
  ggtitle("ARIN IPv4 Runout, 1993-present") ), silent = TRUE)
if (is.null(ArinPlot)) {
  message(paste("Couldn't generate a plot for", today))
} else {
  # Save the graph as a lovely and large PNG
  ggsave(filename = Imagefile.full, plot = ArinPlot, width=10, height=8)
}

