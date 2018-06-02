#!/bin/bash
# Remote bashing
# Copyright (C) 2018 Bram Neijt <bneijt@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

set -e
cd "`dirname "$0"`"

# Lock on my PID
me=$$
if [ -e "runNext.pid" ]; then
  possiblyAlive=$(<runNext.pid)
  if [ "$me" != "$possiblyAlive" ]; then
    #Check if the known pid is still alive
    if [ -n "$possiblyAlive" -a -e "/proc/$possiblyAlive" ]; then
      echo "Already running"
      exit 0
    fi
  fi
fi

echo -n "$me" > runNext.pid

jobs=`find . -maxdepth 2 -type f -name 'run.sh'`
hadToExecuteJob=false
for job in $jobs; do
    jobDir="`dirname "$job"`"
    if [ -e "$jobDir/run.log" ]; then
        echo "Already done $job"
    else
        hadToExecuteJob=true
        echo "Starting $job"
        (cd $jobDir; ./run.sh > run.log 2>&1; echo FINISHED >> run.log )
    fi
done

if [ "$hadToExecuteJob" = true ]; then
  #Retry, there may be more at this point
  exec $0
else
  echo "Done all jobs"
  exit 0
fi
