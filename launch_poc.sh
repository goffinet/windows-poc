#!/bin/bash
apt -y install screen
screen -S winpoc -d -m bash -c 'cd && exec bash -x /data/windowspoc/winpoc.sh'