#!/bin/bash
#
# cgconfig.sh - Initializes cgconfig service
#

# Source any environment customizations:
. /etc/dinit/system/scripts/env

# Start libcgroup services:
if [ ! -d /sys/fs/cgroup ]; then
  exit 1
fi

echo " /usr/sbin/cgconfigparser -l /etc/cgconfig.conf"

# Start/Stop the workload manager
#
# Copyright IBM Corporation. 2008
#
# Authors:     Balbir Singh <balbir@linux.vnet.ibm.com>
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2.1 of the GNU Lesser General Public License
# as published by the Free Software Foundation.
#
# This program is distributed in the hope that it would be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# cgconfig Control Groups Configuration Startup
# chkconfig: - 5 95
# description: This script runs the cgconfigparser utility to parse and setup
#              the control group filesystem. It uses /etc/cgconfig.conf
#              and parses the configuration specified in there.

### BEGIN INIT INFO
# Provides:             cgconfig
# Required-Start:
# Required-Stop:
# Should-Start:         ypbind
# Should-Stop:          ypbind
# Short-Description:    Create and setup control group filesystem(s)
# Description:          Create and setup control group filesystem(s)
### END INIT INFO

# get correct location of binaries from configure
prefix=/usr;exec_prefix=${prefix};sbindir=${exec_prefix}/sbin
CGCONFIGPARSER_BIN=$sbindir/cgconfigparser
CONFIG_FILE=/etc/cgconfig.conf
servicename=cgconfig
lockfile=/var/lock/subsys/$servicename

# read the config
CREATE_DEFAULT=yes
if [ -e /etc/sysconfig/cgconfig ]; then
        . /etc/sysconfig/cgconfig
fi

create_default_groups() {
	defaultcgroup=

        if [ -f /etc/cgrules.conf ]; then
	    read user ctrl defaultcgroup <<< \
		    $(grep -m1 '^\*[[:space:]]\+' /etc/cgrules.conf)
            if [ -n "$defaultcgroup" -a "$defaultcgroup" = "*" ]; then
                echo "/etc/cgrules.conf incorrect"
                echo "Overriding it"
                defaultcgroup=
            fi
        fi

        if [ -z $defaultcgroup ]
        then
            defaultcgroup=sysdefault/
        fi

        #
        # Find all mounted subsystems and create comma-separated list
        # of controllers.
        #
        controllers=`lssubsys 2>/dev/null | tr '\n' ',' | sed s/.$//`

        #
        # Create the default group, ignore errors when the default group
        # already exists.
        #
        cgcreate -f 664 -d 775 -g $controllers:$defaultcgroup 2>/dev/null

        #
        # special rule for cpusets
        #
        if echo $controllers | grep -q -w cpuset; then
                cpus=`cgget -nv -r cpuset.cpus /`
                cgset -r cpuset.cpus=$cpus $defaultcgroup
                mems=`cgget -nv -r cpuset.mems /`
                cgset -r cpuset.mems=$mems $defaultcgroup
        fi

        #
        # Classify everything to default cgroup. Ignore errors, some processes
        # may exit after ps is run and before cgclassify moves them.
        #
        cgclassify -g $controllers:$defaultcgroup `ps --no-headers -eL o tid` \
                 2>/dev/null || :
}

start() {
        echo -n "Starting cgconfig service: "
	if [ -f "$lockfile" ]; then
            echo "lock file already exists"
            return 0
        fi

        if [ $? -eq 0 ]; then
                if [ ! -s $CONFIG_FILE ]; then
                    echo $CONFIG_FILE "is not configured"
                    return 6
                fi

                $CGCONFIGPARSER_BIN -l $CONFIG_FILE
                retval=$?
                if [ $retval -ne 0 ]; then
                    echo "Failed to parse " $CONFIG_FILE
                    return 1
                fi
        fi

        if [ $CREATE_DEFAULT = "yes" ]; then
                create_default_groups
        fi

        touch "$lockfile"
        retval=$?
        if [ $retval -ne 0 ]; then
            echo "Failed to touch $lockfile"
            return 1
        fi
        #log_success_msg
        return 0
}

stop() {
    echo -n "Stopping cgconfig service: "
    /usr/sbin/cgclear -l /etc/cgconfig.conf
    rm -f "$lockfile"
    #log_success_msg
    return 0
}

trapped() {
    #
    # Do nothing
    #
    true
}

usage() {
    echo "$0 <start|stop|restart|condrestart|status>"
    exit 2
}

common() {
    #
    # main script work done here
    #
    trap "trapped ABRT" ABRT
    trap "trapped QUIT" QUIT
    trap "trapped TERM" TERM
    trap "trapped INT"   INT
}

restart() {
	common
	stop
	start
}

RETVAL=0

case $1 in
    'stop')
        common
        stop
        RETVAL=$?
        ;;
    'start')
        common
        start
        RETVAL=$?
        ;;
    'restart'|'reload')
	restart
        RETVAL=$?
        ;;
    'condrestart')
        if [ -f "$lockfile" ]; then
            restart
            RETVAL=$?
        fi
        ;;
    'status')
        if [ -f "$lockfile" ]; then
            echo "Running"
            exit 0
        else
            echo "Stopped"
            exit 3
        fi
	;;
    *)
        usage
        ;;
esac

exit $RETVAL
