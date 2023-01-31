#! /vendor/bin/sh

SILENT_LOGGING_9900=/data/vendor/gps/silentGnssLogging
SILENT_LOGGING_ISSUETRACKER=/data/vendor/gps/silentGnssLoggingIssueTracker
SILENT_LOGGING_FILE_ISSUETRACKER=/vendor/etc/gnss/gps.issuetracker.cfg

CONFIGFILE=/vendor/etc/gnss/gps.cfg
DAEMONFILE=/vendor/bin/hw/gpsd

if [ -d "$SILENT_LOGGING_ISSUETRACKER" ] ; then 
	if [ -e "$SILENT_LOGGING_FILE_ISSUETRACKER" ] ; then
		CONFIGFILE=/vendor/etc/gnss/gps.issuetracker.cfg
	else
		CONFIGFILE=/vendor/etc/gnss/gps.debug.cfg
	fi
fi

if [ -d "$SILENT_LOGGING_9900" ] ; then 
	CONFIGFILE=/vendor/etc/gnss/gps.debug.cfg
fi

exec $DAEMONFILE -c $CONFIGFILE
