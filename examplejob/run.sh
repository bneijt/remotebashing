#!/bin/bash
set -x
date
uname -a
hostname
free -m
df -alh
echo "Created on the remote host" > file.txt
