#!/usr/bin/python3
##***********************************************************************************************************************************************************
## jellyfin-sleep-check.py : part of the Jellyfin-Inhibit-Sleep application
##
## Suspend the computer when the InactivityTimout is reached unless the configured user/system inputs are detected.
## This will also suspend the system if the Logon Screen (lightdm/slick greeter) is active.
## Note as of 2024-04-24 the Linux Mint Logon Screen has not configurable suspend timeout and never suspends (not useful after a power cut with Wake on lan).
##
##
## Thanks to txhammer68 for active viewers code https://gist.github.com/txhammer68/64d5888bf8822c9d0762533237ad6958
## The idea for this solution came from https://github.com/jonschz/jellyfin-plugin-preventsleep/issues/8#issuecomment-2799851649
##
##

## User Configuration Settings

# The inactivity_timeout setting is the time before suspend in minutes.  It will override user settings if the value is less that user suspend timeouts.
inactivity_timeout = 50 # (Default = 50) minutes - 


##--------------------------------------------------------------------------------------------------
## TESTING CODE CONFIGURATION : Start
##--------------------------------------------------------------------------------------------------
##
## Allows you to test the script.
##

is_testing_code = False # TESTING CODE Change to True to run testing code (Default = False)
test_active_file_lock = 5  # (seconds) TESTING CODE Time you want to allow yourself to start a second session and check that the lock file works.

##--------------------------------------------------------------------------------------------------
## TESTING CODE CONFIGURATION : End
##--------------------------------------------------------------------------------------------------


import os
import select
import datetime
from datetime import datetime, timedelta, timezone

this_python_script = os.path.basename(__file__)
this_pid = os.getpid()

lock_file = "/var/lock/jellyfin-sleep-check.py"
#lock_file = "./locktest-jellyfin-sleep-check.py" # TESTING CODE


log_file = "/var/log/jellyfin-inhibit-sleep.log"
#log_file = "" # TESTING CODE - log to stdout (e.g. cmd window)

session_active_file = "/usr/sbin/jellyfin-inhibit-sleep/jellyfin-inhibit-session-active" # File to let sleep-check.py know that systemd-inhibit is active if a new session-check.py starts and finds sessions whilst sleep-check.py is waiting to sleep.
#session_active_file = "./jellyfin-inhibit-session-active" # TESTING CODE


##***********************************************************************************************************************************************************
## Configure logging : Start
##***********************************************************************************************************************************************************
# Using Rotating File Handler to ensure we do not create large log files.

import logging
from logging.handlers import RotatingFileHandler

log_file = "/var/log/jellyfin-inhibit-sleep/sleep-check.log"
#log_file = "./test-sleep-logging.log"
#log_file = "" # TESTING CODE - log to stdout (e.g cmd window)

#logging choices DEBUG, INFO, WARNING, ERROR, CRITICAL
log_level = logging.INFO

#log_formatter = logging.Formatter('%(asctime)s %(name) %(levelname)s %(funcName)s(%(lineno)d) %(message)s')
log_format = logging.Formatter('%(asctime)s PID=%(process)d: linenum(%(lineno)d):  %(levelname)-8s - %(message)s')
#logFile = './test-logging.log'

my_handler = RotatingFileHandler(log_file, mode='a', maxBytes=5*1024*1024, 
                                 backupCount=2, encoding=None, delay=0)
my_handler.setFormatter(log_format)
my_handler.setLevel(log_level)

app_log = logging.getLogger('root')
#app_log = logging.getLogger('JISA_shared_logger')
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
    app_log.info(f'RUNNING {this_python_script} - (PID={this_pid}) no other instance is running')
    ## TESTING CODE : Start ---------------------------------------------------------------------------
    if (is_testing_code) :
        app_log.warning('TESTING CODE - !!!!!!!!!!   isTestCode = True   !!!!!!!!!! - WARNING')
        app_log.warning('TESTING CODE - !!!!!!!!!!   isTestCode = True   !!!!!!!!!! - WARNING')
        for i in range(test_active_file_lock, 0, -1):
            time.sleep(1)
            app_log.debug (f'{i} : test_active_file_lock - Lock File = {lock_file}')
    ## TESTING CODE : End -----------------------------------------------------------------------------

##***********************************************************************************************************************************************************
## Lockfile Check : End
##***********************************************************************************************************************************************************


##***********************************************************************************************************************************************************
## Define User Input files to check for user input : Start
##***********************************************************************************************************************************************************

## Keyboard File
keyboard_find = os.popen("find /dev|grep input|grep kbd").read().strip()

if (keyboard_find):

    keyboard_file = open(keyboard_find, "rb" )
    app_log.info(f'Found file for keyboard input - using : {keyboard_file}')

else :
    keyboard_file = "NOFILE"
    app_log.warning('NO FILE FOUND for keyboard input')

## Mouse File
mouse_file = "/dev/input/mice"

if (os.path.exists(mouse_file)):
    mouse_file = open(mouse_file, "rb" )
    app_log.info(f'Found file for mouse input - using : {mouse_file}')

else :
    mouse_file = "NOFILE"
    app_log.warning('NO FILE FOUND for mouse input')



## NOTE : BELOW detection settings NEED WORK........
##
## NOTE : The below are arbitary settings to give you an idea of how you could check for input.
## NOTE : You could use a 'ps' or 'netstat' for example.

## SSH File - NOT TESTED

ssh_file = "/dev/input/SSH INPUT DEVICE?"

if (os.path.exists(ssh_file)):
    ssh_file = open(ssh_file, "rb" )
    app_log.info(f'Found file for ssh input - using : {ssh_file}')

else :
    ssh_file = "NOFILE"
    app_log.debug('NO INPUT DETECTION FOUND for ssh input')


## VNC File - QUICK TEST done using X11VncServer

vnc_file = "/dev/input/VNC INPUT DEVICE?"
#vnc_file = "/dev/fb0" # not this one.
#vnc_file = "/dev/input/event0" # not this one or the other events e.g. event0 to event11

if (os.path.exists(vnc_file)):
    vnc_file = open(vnc_file, "rb" )
    app_log.info(f'Found file for vnc input - using : {vnc_file}')

else :
    vnc_file = "NOFILE"
    app_log.debug('NO INPUT DETECTION FOUND for vnc input')

##***********************************************************************************************************************************************************
## Define User Input files to check for user input : End
##***********************************************************************************************************************************************************


##***********************************************************************************************************************************************************
## Define Input Event to check for user input : Start
##***********************************************************************************************************************************************************

def getInputEvent(filename):

    #Checks for mouse movement or keyboard depending on filename - tested on linux mint.
    #Could possible check tty, ssh or other depending on filename used, but this would need testing.

    inputevent = 0
    r, w, e = select.select([ filename ], [], [], 0)
    if filename in r:
        os.read(filename.fileno(), 50)
        inputevent = 1
    return inputevent

##***********************************************************************************************************************************************************
## Define Input Event to check for user input : End
##***********************************************************************************************************************************************************


##***********************************************************************************************************************************************************
## Main Program : Start
##***********************************************************************************************************************************************************

if (inactivity_timeout == 0):
    app_log.info(f'TERMINATING {this_python_script} - InactivityTimout is set to 0 (Do not suspend')
    sys.exit(0)

now_time = datetime.now(timezone.utc)
app_log.debug(f'{now_time} = now_time UTC')
timeout_time = (now_time + timedelta(minutes = inactivity_timeout))
app_log.debug(f'{timeout_time} = timeout_time UTC: system will suspend at this time if not activity.')

while (now_time.timestamp() < timeout_time.timestamp()):
    now_time = datetime.now(timezone.utc)

    # Check for mouse or keyboard input.  If detected end this script without suspending the system.
    if (mouse_file != "NOFILE"):
        MouseInput = getInputEvent(mouse_file)
        if (MouseInput == 1):
            app_log.info("DETECTED - User Input : mouse")
            break
    if (keyboard_file != "NOFILE"):
        KeyboardInput = getInputEvent(keyboard_file)
        if (KeyboardInput == 1):
            app_log.info("DETECTED - User Input : keyboard")
            break

    # SSH & VNC Detection do not work at the moment - NEEDS WORK 
    if (ssh_file != "NOFILE"):
        SshInput = getInputEvent(ssh_file)
        if (SshInput == 1):
            app_log.debug("DETECTED - ssh input")
            break
    if (vnc_file != "NOFILE"):
        VncInput = getInputEvent(vnc_file)
        if (VncInput == 1):
            app_log.debug("DETECTED - vnc input")
            break

    # Check to see if the cronjob has re-run and found an active user streaming session,
    # in which case we need to end this script without suspending the system.
    if (os.path.isfile(session_active_file)) :
            app_log.info('DETECTED - session_active_file - Jellyfin Active User Streaming Session Detected....')
            break

keyboard_file.close();
mouse_file.close();

if (now_time.timestamp() >= timeout_time.timestamp()):
    app_log.critical('SUSPENDING SYSTEM due to TIMEOUT TIME')
    time.sleep(2)
    os.system('systemctl suspend')
    time.sleep(5)
    app_log.info('SYSTEM RESTORED')

else:
    app_log.info(f'TERMINATING {this_python_script} (PID={this_pid})')
    app_log.info(f'...........................................................Finished')

exit(0)

##***********************************************************************************************************************************************************
## Main Program : End
##***********************************************************************************************************************************************************


