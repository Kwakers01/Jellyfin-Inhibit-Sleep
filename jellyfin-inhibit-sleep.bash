#! /usr/bin/bash
#***********************************************************************************************************************************************************
# jellyfin-inhibit-sleep.bash : part of the Jellyfin-Inhibit-Sleep Application
#
#
# Inhibit PC sleep/suspend mode if jellyfin has active viewers
#
# Thanks to txhammer68 for active viewers code https://gist.github.com/txhammer68/64d5888bf8822c9d0762533237ad6958
# The idea for this solution came from https://github.com/jonschz/jellyfin-plugin-preventsleep/issues/8#issuecomment-2799851649
#
# This file is run using root crontab:
# sudo crontab -e
# * * * * * /usr/sbin/jellyfin-inhibit-sleep/jellyfin-inhibit-sleep.bash
#

systemd-inhibit --what sleep:shutdown /usr/bin/python3 '/usr/sbin/jellyfin-inhibit-sleep/jellyfin-session-check.py'
/usr/bin/python3 '/usr/sbin/jellyfin-inhibit-sleep/jellyfin-sleep-check.py'

