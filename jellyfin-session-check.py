#!/usr/bin/python3
##***********************************************************************************************************************************************************
## jellyfin-session-check.py : part of the Jellyfin-Inhibit-Sleep application
##
## Interrupt PC sleep/suspend mode if jellyfin has active viewers
##
## Thanks to txhammer68 for active viewers code https://gist.github.com/txhammer68/64d5888bf8822c9d0762533237ad6958
## The idea for this solution came from https://github.com/jonschz/jellyfin-plugin-preventsleep/issues/8#issuecomment-2799851649
##
## Please read the README.txt for help
##

## YOU MUST DO THIS BELOW.....
##
## Create your own API key for your Jellyfin Server.
## 1) Log in to Jellyfin as admin.
## 2) Go to Dashboard->API Keys.
## 3) Create an API key, you can use the name Jellyfin-Inhibit-Sleep if required.
## 4) Copy "YOUR" API key into the jellyfin_apikey variable below within the quotes e.g. jellyfin_apikey = "312bfe2caaa541ad8517c64a505c6048"
##
##***********************************************************************************************************************************************************

## User configurable settings

session_poll_timer = 45 # (Default = 45) seconds. How often you want to re-check the Jellyfin server for session information whilst a session is active.

jellyfin_apikey = "YOUR JELLYFIN API KEY HERE" # Your Jellyfin API Token - see note below


##***********************************************************************************************************************************************************
## YOU MUST DO THE ABOVE !!
##
## Create your own API key for your Jellyfin Server.
## 1) Log in to Jellyfin as admin.
## 2) Go to Dashboard->API Keys.
## 3) Create an API key, you can use the name Jellyfin-Inhibit-Sleep.
## 4) Copy "YOUR" API key into the jellyfin_apikey variable above within the quotes e.g. jellyfin_apikey = "312bfe2caaa541ad8517c64a505c6048"
##
##***********************************************************************************************************************************************************


##--------------------------------------------------------------------------------------------------
## TESTING CODE CONFIGURATION : Start
##--------------------------------------------------------------------------------------------------
##
## Allows you to test the script without having to use a Jellyfin client.
## It imitatates a session streaming response 'IsActive' for the geturl
##

is_testing_code = False # TESTING CODE Change to True to imitate a streaming session (Default = False)
test_active_file_lock = 5  # (seconds) TESTING CODE Time you want to allow yourself to start a second session and check that the lock file works.
testing_session_time = 75  # (seconds) TESTING CODE Time you want to run as "IsActive = True" in secs.

##--------------------------------------------------------------------------------------------------
## TESTING CODE CONFIGURATION : End
##--------------------------------------------------------------------------------------------------


import json
import requests
import os
import datetime
import time
from datetime import datetime
from datetime import timedelta, timezone

this_python_script = os.path.basename(__file__)
this_pid = os.getpid()

lock_file = "/var/lock/jellyfin-session-check.py"
#lock_file = "./locktest-jellyfin-session-check.py" # TESTING CODE

session_active_file = "/usr/sbin/jellyfin-inhibit-sleep/jellyfin-inhibit-session-active" # File to let sleep-check.py know that systemd-inhibit is active if a new session-check.py starts and finds sessions whilst sleep-check.py is waiting to sleep.
#session_active_file = "./jellyfin-inhibit-session-active" # TESTING CODE


##***********************************************************************************************************************************************************
## Configure logging : Start
##***********************************************************************************************************************************************************
# Using Rotating File Handler to ensure we do not create large log files.

import logging
from logging.handlers import RotatingFileHandler

log_file = "/var/log/jellyfin-inhibit-sleep/session-check.log"
#log_file = "./test-sleep-logging.log" #TESTING CODE
#log_file = "" # TESTING CODE - log to stdout (e.g cmd window)

#logging.basicConfig(filen
log_level = logging.INFO

#log_format = logging.Formatter('%(asctime)s %(name)s %(funcName)s.format(this_python_script) PID=%(process)d: %(levelname)-8s - %(message)s') # does not work
log_format = logging.Formatter('%(asctime)s PID=%(process)d: linenum(%(lineno)d):  %(levelname)-8s - %(message)s')
#logFile = './test-logging.log' # TESTING CODE

my_handler = RotatingFileHandler(log_file, mode='a', maxBytes=5*1024*1024, 
                                 backupCount=2, encoding=None, delay=0)
my_handler.setFormatter(log_format)
my_handler.setLevel(log_level)

app_log = logging.getLogger('root')
app_log.setLevel(log_level)
app_log.addHandler(my_handler)

##***********************************************************************************************************************************************************
## Configure logging : End
##***********************************************************************************************************************************************************


app_log.info(f'STARTING {this_python_script} (PID={this_pid})')


##***********************************************************************************************************************************************************
## Lockfile Check : start
##***********************************************************************************************************************************************************
## Check to see if another instance of this script is running.  If it is, exit this script and leave the other running.

import sys
import time
import fcntl

file_handle = None

def file_is_locked(file_path):
    global file_handle 
    file_handle= open(file_path, 'w')
    try:
        fcntl.lockf(file_handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
        return False
    except IOError:
        return True

app_log.debug(f'Checking for a duplicate process using : Lock File = {lock_file}')

if file_is_locked(lock_file):
    app_log.info(f'FAILED to start {this_python_script} (PID={this_pid}) - Exited as another instance is running.')
    sys.exit(0)
else:
    app_log.info(f'RUNNING {this_python_script} (PID={this_pid}) - no other instance is running')
    ## TESTING CODE : Start ---------------------------------------------------------------------------
    ## To test the Active File Lock, open a cmd window and run another instance of this file. Check logs to see "FAILED to start".
    if (is_testing_code) :
        for i in range(test_active_file_lock, 0, -1):
            time.sleep(1)
            app_log.debug (f'{i} : test_active_file_lock - Lock File = {lock_file}')
    ## TESTING CODE : End -----------------------------------------------------------------------------

##***********************************************************************************************************************************************************
## Lockfile Check : End
##***********************************************************************************************************************************************************


##***********************************************************************************************************************************************************
## Main Program : Start
##***********************************************************************************************************************************************************

## TESTING CODE : Start ---------------------------------------------------------------------------
if (is_testing_code) :
    app_log.warning('TESTING CODE - !!!!!!!!!!   isTestCode = True   !!!!!!!!!! - WARNING')
    app_log.warning('TESTING CODE - !!!!!!!!!!   isTestCode = True   !!!!!!!!!! - WARNING')    
    if (session_poll_timer > testing_session_time) : app_log.error('TESTING CODE - !! PROBLEM !!  session_poll_timer > testing_session_time')
    now_time = datetime.now(timezone.utc)
    app_log.debug(f'TESTING CODE - now_timeUTC : {now_time}')
    timeout_time = (now_time + timedelta(seconds = testing_session_time))
    app_log.debug(f'TESTING CODE - timeout_time UTC : {timeout_time}')
## TESTING CODE : End -----------------------------------------------------------------------------

# Check the jellyfin_apikey
newuser_apikey = "YOUR JELLYFIN API KEY HERE"
if (jellyfin_apikey == newuser_apikey) :
    app_log.critical('Jellyfin API Key issue.')
    app_log.critical('Jellyfin API Key has NOT been configured. Run configeditor.bash')
    app_log.critical('Application cannot talk to the Jellyfin Server. You will get errors !!')
    app_log.critical(f'TERMINATING {this_python_script} (PID={this_pid}')
    app_log.critical(f'...........................................................Finished')
    sys.exit(0)

headers = {
    "accept": "application/json",
    "Authorization": "Mediabrowser Token=" + jellyfin_apikey
}
is_active = True
inhiibited_time = 0 # used for app_log.info
while is_active == True:

    url1 = 'http://localhost:8096/Sessions?activeWithinSeconds=90'
    response = requests.get(url1, headers=headers).json()

    ## TESTING CODE : Start ---------------------------------------------------------------------------
    if (is_testing_code) :
        now_time = datetime.now(timezone.utc)
        if (now_time.timestamp() <= timeout_time.timestamp()):
            app_log.debug('TESTING CODE - Imitating a Jellyfin Session Response [is_active = True]')
            response = [{'IsActive': True,'This is TESTING CODE : Imitating a live streaming response. When finished set is_testing_code = False': True}] # For TESTING ONLY
        else:
            app_log.debug('TESTING CODE - testing_session_time reached - reverting to Jellyfin Servers REAL response')
            response = [] # to ensure the testing finishes and the script does not continue to run if a real session exists.
    ## TESTING CODE : End -----------------------------------------------------------------------------

    #app_log.debug(f'URL get response = {response}')

    if(len(response) > 0) :     
        is_active=response[0].get('IsActive',False)
        if (inhiibited_time == 0) :
            app_log.info('Active User Streaming Session Detected for Jellyfin....')
        
            os.system("touch " + session_active_file)
            if (os.path.isfile(session_active_file)) : 
                app_log.debug('Session Active File : Created')
            else :
                app_log.error('Session Active File : Error creating file !!')
        
        app_log.debug(f'Inhibiting sleep at {session_poll_timer}(s) per poll: Total inhibited time = {inhiibited_time}(s)')

        time.sleep(session_poll_timer)
        inhiibited_time = inhiibited_time + session_poll_timer # used for app_log.info

    else :
        is_active = False
        app_log.info('NO Active Streaming Sessions Detected for Jellyfin....')
        app_log.info(f'Inhibited sleep for a total of {inhiibited_time} secs')

        if (os.path.isfile(session_active_file)) : 
            app_log.debug('Session Active File : Exists - removing')
            os.system("rm " + session_active_file)
            if (os.path.isfile(session_active_file) == False) : 
                app_log.debug('Session Active File : Deleted')
            else :
                app_log.error('Session Active File : Error deleting file !!')

app_log.info(f'TERMINATING {this_python_script} (PID={this_pid})')
app_log.info(f'...........................................................Finished')

exit(0)

##***********************************************************************************************************************************************************
## Main Program : End
##***********************************************************************************************************************************************************


