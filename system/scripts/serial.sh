#!/bin/bash
#
# serial.sh - Serial port setup script

# Source any environment customizations:
. /etc/dinit/system/scripts/env

#	Initializes the serial ports on your system
#
# chkconfig: 2345 50 75
# description: This initializes the settings of the serial port
#
# FILE_VERSION: 19981128
#
# Distributed with setserial and the serial driver.  We need to use the
# FILE_VERSION field to assure that we don't overwrite a newer rc.serial
# file with a newer one.
#
# XXXX For now, the autosave feature doesn't work if you are
# using the multiport feature; it doesn't save the multiport configuration
# (for now).  Autosave also doesn't work for the hayes devices.
#

RCLOCKFILE=/var/lock/subsys/serial
DIRS="/lib/modules/`uname -r`/misc /lib/modules /usr/lib/modules ."
PATH=/bin:/sbin:/usr/bin
DRIVER=serial
DRIVER_NAME=serial
MODULE_REGEXP="serial\b"

ALLDEVS="/dev/ttyS?"
if /bin/ls /dev/ttyS?? >& /dev/null ; then
	ALLDEVS="$ALLDEVS /dev/ttyS??"
fi

SETSERIAL=""
if test -x /bin/setserial ; then
	SETSERIAL=/bin/setserial
elif test -x /sbin/setserial ; then
	SETSERIAL=/sbin/setserial
fi

#
# See if the serial driver is loaded
#
LOADED=""
if test -f /proc/devices; then
	if grep -q " ttyS$" /proc/devices ; then
		LOADED="yes"
	else
		LOADED="no"
	fi
fi

#
# Find the serial driver
#
for i in $DIRS
do
	if test -z "$MODULE" -a -f $i/$DRIVER.o ; then
		MODULE=$i/$DRIVER.o
	fi
done

if ! test -f /proc/modules ; then
	MODULE=""
fi

#
# Handle System V init conventions...
#
case $1 in
start)
	action="start";
	;;
stop)
	action="stop";
	;;
*)
	action="start";
esac

if test $action  = stop ; then
	if test -n ${SETSERIAL} -a "$LOADED" != "no" -a \
           `head -1 /etc/serial.conf`X = "###AUTOSAVE###X" ; then
		echo -n "Saving state of serial devices... "
		grep "^#" /etc/serial.conf > /etc/.serial.conf.new
		${SETSERIAL} -G -g ${ALLDEVS} >> /etc/.serial.conf.new
		mv /etc/serial.conf /etc/.serial.conf.old
		mv /etc/.serial.conf.new /etc/serial.conf
		echo "done."
	fi
	if test -n "$MODULE" ; then
		module=`grep $MODULE_REGEXP /proc/modules | awk '{print $1}'`
		if test -z "$module" ; then
			echo "The $DRIVER_NAME driver is not loaded."
			rm -f ${RCLOCKFILE}
			exit 0
		fi
		if rmmod $module ; then :; else
			echo "The $DRIVER_NAME driver could NOT be unloaded."
			exit 1;
		fi
		echo "The $DRIVER_NAME driver has been unloaded."
	fi
	rm -f ${RCLOCKFILE}
	exit 0
fi

#
# If not stop, it must be a start....
#

if test -n "$MODULE" -a "$LOADED" != "yes" ; then
	if insmod -f $MODULE $DRIVER_ARG ; then
          true
	else
		echo "Couldn't load $DRIVER_NAME driver."
		exit 1
	fi
fi

if test -f /etc/serial.conf ; then
        if test -n ${SETSERIAL} ; then
		grep -v ^# < /etc/serial.conf | while read device args
		do
                    if [ ! "$device" = "" -a ! "$args" = "" ]; then
                        ${SETSERIAL} -z $device $args
                    fi
		done
	fi
else
	echo "###AUTOSAVE###" > /etc/serial.conf
fi

touch ${RCLOCKFILE}
${SETSERIAL} -bg ${ALLDEVS}
