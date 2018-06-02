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

REMOTE_HOST=

if [ "x$REMOTE_HOST" = "x" ]; then
  echo "Please configure REMOTE_HOST by updating this script"
  exit 1
fi

echo "-- Uploading jobs"
#Upload any job that still needs to run
jobs=`find . -maxdepth 2 -type f -name 'run.sh'`
mayNeedToUploadRunner=false
for job in $jobs; do
    jobDir="`dirname "$job"`"
    if [ -e "$jobDir/run.log" ]; then
        echo "Skipping $job, has a run.log already"
    else
      mayNeedToUploadRunner=true
      chmod a+x "$jobDir/run.sh"
      #Copy assests
      rsync --recursive --inplace --executability --progress --exclude run.sh "$jobDir" "$REMOTE_HOST":remotebashing/
      #Copy run script
      rsync --recursive --inplace --executability --progress "$jobDir" "$REMOTE_HOST":remotebashing/
    fi
done

if [ "$mayNeedToUploadRunner" = true ]; then
  rsync --inplace --executability --progress "runNext.sh" "$REMOTE_HOST":remotebashing/
fi

echo "-- Downloading results"
rsync --append --size-only --recursive --progress --exclude run.sh --exclude runNext.pid "$REMOTE_HOST":remotebashing/ .

echo "-- Forking execution"
ssh "$REMOTE_HOST" '/usr/bin/screen -d -m remotebashing/runNext.sh'
