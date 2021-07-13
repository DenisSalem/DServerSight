#! /bin/bash

# Copyright 2021 Denis Salem
#
# This file is part of DServerSight.
#
# DServerSight is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version
#
# DServerSight is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with DServerSight. If not, see <http://www.gnu.org/licenses/>.

# TODO : Watch memory as well.

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
            cpu_threshold)       cpu_threshold=${VALUE} ;;     
            mem_threshold)    mem_threshold=${VALUE} ;;     
            *)   
    esac    
done

if test -z "$cpu_threshold" || test -z "$mem_threshold"
then
	echo -e "usage: process_hunger.sh cpu_threshold=\"cpu load_value\"  mem_threshold=\"memory_usage_value\""
	exit  -1
fi

pid_cpu_mem_command=`ps aux | sort -nrk 3 | awk -v cpu_threshold=$cpu_threshold -v mem_threshold=$mem_threshold '$2 != "PID" && (int($3)>=cpu_threshold || int($4)>=mem_threshold) {out=$2"\t"$3"\t"$4"\t"$11; for (i=12;i<=NF;i++){out=out" "$i}; print "\t"out}';`
if test ! -z "$pid_cpu_mem_command"
then
	mkdir -p /var/log/DServerSight/
	touch /var/log/DServerSight/ProcessHunger.log
	date +"%d-%m-%Y %H:%M:%S" >> /var/log/DServerSight/ProcessHunger.log 
	echo -e "\tPID\tCPU\tMEM\tCOMMAND"  >> /var/log/DServerSight/ProcessHunger.log 
	echo -e "$pid_cpu_mem_command"  >> /var/log/DServerSight/ProcessHunger.log 
fi
