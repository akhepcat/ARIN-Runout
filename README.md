ARIN-Runout
===========

Quick and crappy code to plot ARIN IPv4 runout trending

Check the wiki https://github.com/akhepcat/ARIN-Runout/wiki for an example graph.

Requirements:
	You will need to install the  getopt, ggplot2, nlme, splines, and scales libraries into your local R.
	i.e., from 'R' console:  install.packages("package")

Usage:
 * Install the two scripts, 'RunRate.sh' and 'ArinRunout.R' someplace with executable permissions
 * Edit RunRate.sh and change the 'DATA' and 'WEBROOT' variables to point to the location you want.
 * Use 'cron' to exec the 'RunRate.sh' once-a-week and have the graphs automatically generated.
 * Use 'cron' to exec the 'WebIndex.sh' once-a-week after 'RunRate' to build all the html
 * The script is a little noisy, so you may want to redirect output to /dev/null


By default, the ArinRunout.R code will build three different graphs:
 * 1 year
 * Y2K  to date
 * from Epoch

