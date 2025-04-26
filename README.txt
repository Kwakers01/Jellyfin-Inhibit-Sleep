----------------------------------------------------------------------------------------------------------


WARNING.......

This document is OLD: Last updated 25/04/2025

Please use the README.MD file instead.






----------------------------------------------------------------------------------------------------------
Jellyfin Inhibit Sleep (Linux Application)
------------------------------------------

Designed for Linux.

Tested on: 

python3 --version: Python 3.12.3
lsb_release -a: Linux Mint 22 wilma
cat /etc/upstream-release/lsb-release: Ubuntu 24.04 noble "Ubuntu Noble Numbat"
Jellyfin version: 10.10.7
Test Date: Friday 25 April 2025


Installation
------------

Requirements:-

This application runs on Linux.
You need root access (sudo) to install and run this application.


Auto Install
------------

Download the files and unzip.

Open a terminal window in the working directory.


1) Run the install file:-
chmod +x ./install.bash
sudo ./install.bash

2) Run the config editor:-
chmod +x ./configeditor.bash
sudo ./configeditor.bash

3) Follow the instructions on "How to create your own jellyfin_apikey for your Jellyfin Server" (also detailed below in the manual installation).
 

Auto Uninstall
--------------

Open a terminal window and run the uninstall file:-
cd /usr/sbin/jellyfin-inhibit-sleep
sudo ./uninstall.bash


------------------------------------------------------------------------------------------------------------------------------------------------------
Manual Install & Uninstall
--------------------------

copy over the files

sudo mkdir /usr/sbin/jellyfin-inhibit-sleep
sudo mkdir /var/log/sbin/jellyfin-inhibit-sleep

sudo cp ./jellyfin-session-check.py /usr/sbin/jellyfin-inhibit-sleep/jellyfin-session-check.py
sudo cp ./jellyfin-sleep-check.py /usr/sbin/jellyfin-inhibit-sleep/jellyfin-sleep-check.py
sudo cp ./jellyfin-inhibit-sleep.bash /usr/sbin/jellyfin-inhibit-sleep/jellyfin-inhibit-sleep.bash
sudo cp ./install.bash /usr/sbin/jellyfin-inhibit-sleep/install.bash
sudo cp ./uninstall.bash /usr/sbin/jellyfin-inhibit-sleep/uninstall.bash
sudo cp ./configeditor.bash /usr/sbin/jellyfin-inhibit-sleep/configeditor.bash
sudo cp ./README.txt /usr/sbin/jellyfin-inhibit-sleep/README.txt
sudo cp ./README.md /usr/sbin/jellyfin-inhibit-sleep/README.md

Note: install, uninstall and README copied over for future use.

Change the attributes for the .bash files

sudo chmod +x /usr/sbin/jellyfin-inhibit-sleep/jellyfin-inhibit-sleep.bash
sudo chmod +x /usr/sbin/jellyfin-inhibit-sleep/install.bash
sudo chmod +x /usr/sbin/jellyfin-inhibit-sleep/uninstall.bash
sudo chmod +x /usr/sbin/jellyfin-inhibit-sleep/configeditor.bash


Configure Root Crontab
----------------------

edit the root crontab

sudo crontab -e

add the following to the end of the file:-
* * * * * '/usr/sbin/jellyfin-inhibit-sleep/jeelyfin-inhibit-sleep.bash'


e.g. the end of the file should look something like this:-
# 
# For more information see the manual pages of crontab(5) and cron(8)
# 
# m h  dom mon dow   command
#
* * * * * '/usr/sbin/jellyfin-inhibit-sleep/jellyfin-inhibit-sleep.bash'


Your API Key - REQUIRED - get from your Jellyfin server (see below for instructions)
------------

This is required otherwise the python script cannot access the Jellyfin server to get session data.

Create your own API key for your Jellyfin Server.
1) Using your web browser, log in to your Jellyfin server as the admin user.
2) Click on the three bars in the top left hand corner and go to Administration -> Dashboard -> Advanced -> API Keys.
3) Next the t API Keys there is a + button.  Click on the + button and create an API key.
4) In the "App Name" field, type "Jellyfin-Inhibit-Sleep" and click ok. You will then be shown a list of your API Keys.
5) sudo nano /usr/sbin/jellyfin-inhibit-sleep/jellyfin-session-check.py and find the variable jellyfin_apikey (it should be on line 28 of the code)
6) Copy "YOUR" API key for the app "Jellyfin-Inhibit-Sleep" into the jellyfin_apikey = "YOUR JELLYFIN API KEY HERE" variable within the quotes e.g. jellyfin_apikey = "c2a54c557f6f4fb7bbfd40827d29b18a" where c2a54c557f6f4fb7bbfd40827d29b18a is "YOUR" API key.
7) Save the file and close nano.


User Timeouts Configuration
---------------------------

inactivity_timeout
------------------

1) sudo nano /usr/sbin/jellyfin-inhibit-sleep/jellyfin-sleep-check.py
2) Change the value of inactivity_timeout = 30 to however log you want your inactivity timeout to be in minutes (it should be on line 15). If set to 0 the application will not suspend the system. 

After 50 minutes (Default setting) the system will suspend as long as the following has not happened:-

 * There has been user input from the keyboard or mouse.
 * There has been other "configured" input activity e.g ssh session, vnc session (future update) 
 * A user has started a streaming session with jellyfin.J

Note: I am not sure at the moment (need to test) how users "inactivity suspend settings" and this apps "inactivity_timeout" settings affect each other.  So if you get strange suspends you may want to check out this setting and your users own "inactivity suspend settings" in your Linux GUI or .conf files.


session_poll_timer
----------------

How often you want to re-check the Jellyfin server for session information whilst a session is active in seconds (Default = )

1) sudo nano /usr/sbin/jellyfin-inhibit-sleep/jellyfin-session-check.py
2) Change the value of session_poll_timer = 25 to however log you want your inactivity timeout to be in minutes (it should be on line 15)

If the application finds an active user streaming session running on the Jellyfin server, it will poll the server every 25 secs to check if it is still active.




Manual Uninstall
----------------

sudo crontab -e
hash out or remove the line
* * * * * '/usr/sbin/jellyfin-inhibit-sleep/jellyfin-inhibit-sleep.bash'


To remove the application files:

sudo rm -r /usr/sbin/jellyfin-inhibit-sleep/

To remove the lock files:

sudo rm /var/lock/jellyfin-session-check.py
sudo rm /var/lock/jellyfin-sleep.check.py

To remove the log files: 

sudo rm -r /var/log/jellyfin-inhibit-sleep






------------------------------------------------------------------------------------------------------------------------------------------------------------

Logfiles and Testing
--------------------


Log File
--------

If you are having issues there are log files which may help in the following directory:-

/var/log/jellyfin-inhibit-sleep/

Note : you can change the logging information in the .py scripts.
logging choices DEBUG, INFO, WARNING, ERROR, CRITICAL
change log_level = logging.INFO to the level you want.


Testing - imitates a Jellyfin client
--------------------------------------

The variable is_test_code can be change to True if you want to test the code without having to use your Jellyfin client.  
Change to True to imitate a streaming session.

--------------------------------------------------------------------------------------------------------------------------------

How the application works
-------------------------

A cron job is created to run the two following scripts every minute:  

jellyfin-session-check.py which runs with systemd-inhibit and checks for a Jellyfin user session, if it does not find one the script ends.
jellyfin-sleep-check.py which checks to see if there is any user activiy and if not, suspends the computer after an inactivity timeout period.



jellyfin-session-check.py
------------------------- 

When run it does the following :-

1) When run, it inhibits the system from shutting down until it has finished using systemd-inhibit.

2) It creates a lock file : /var/lock/jellyfin-session-check.py - this is used to ensure that only one instance of the jellyfin-session-check.py process is ever run.

3) It checks to see if there is an active Jellyfin session. If not active, the python script ends and the system-inhibit is cancelled.

3) If there is an active Jellyfin session:-

3a) It creates a session_active_file (/usr/sbin/jellyfin-inhibit-session-active) that is used by jellyfin-sleep-check.py to know if a new session has started so that jellyfin-sleepcheck.py can restart the inactivity_timeout timer.
3b) It continues to re-check the Jellyfin server every session_poll_time (default 50 seconds) until the active session ends.

4) It then removes the session_active_file. and the script ends.



jellyfin-sleep-check.py
-----------------------

When run it does the following :-

1) creates a lock file : /var/lock/jellyfin-sleep-check.py - this is used to ensure that only one instance of the jellyfin-sleep-check.py process is ever run.

2) Checks to see if the inactivity_timeout is set to 0 (do not suspend).  If it is the script ends.

3) Checks for input (3a & 3b) and if there is input it ends the script,thus reseting the inactivity_timeout timer to 0 when called by cron again. 

3a) Checks the /dev/input files for keyboard or mouse input (or other input - future update) if input ends the script.

3b) Checks to see if there is a session_active_file, if one exists ends the script, 

4) If the inactivity_timout timer is reach it will run "systemctl suspend" 

Note: Further work is require to check for ssh input or vnc input.  This may be just a ps ef | grep for a file or a netstat,



Hopefully someone may pick this up and possibly create a plugin to Jellyfin and/or add to it so that the jellyfin-sleep-check.py can also check for input from headless systems e.g. vnc and ssh.

-------------------------------------------------------------------------------------------------------------------------------

How this application came about
-------------------------------

I have spent quite a while testing various ways to potentially inhibit sleep for Jellyfin.

I have not done any programming for many years (BBC Basic, 6502 Assembly, bit of C, some html), but I have an old server and would like to move it from Windows 10 to Linux.  The major issue I have is that I need Jellyfin to be able to inhibit sleep when I am watching a film/tv prgram and also suspend the server afterwards.

It all began with https://github.com/jonschz/jellyfin-plugin-preventsleep/issues/8#issuecomment-2799851649 and txhammer68's python code.

These are the possible solutions I have looked at over a 2 week period:

1) qdbus solution - using txhammer68's code at https://gist.github.com/txhammer68/64d5888bf8822c9d0762533237ad6958.  However I could not find the correct package for his commands and so tried xdotool instead.
2) xdotool solution - I installed xdtool to see if I could replace the qdbus code with xdotool code and yes I got this working.  However, if the computer reboots (e.g. power outage whilst you are away) you get the logon screen (unless you configure autologin).  I'm using "Linux Mint" and I could not find a possible solution to get xdtool to wiggle the mouse on the 'lightdm/slick greeter' logon screen (this is the same issue that txhammer68 has using qdbus).
3) gsettings (for the xdotool issue) - I looked into all the various gsettings variables I could think would solve the issue, but to no avail.

Then, thinking about jonschz comment (https://github.com/jonschz/jellyfin-plugin-preventsleep/issues/8#issuecomment-2799851649) about not being " too setup-dependent", I started to look at what system commands may be available.

4) systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target (and unmask).  Some code I created allowed this to work and would stop the system from going into suspend.  The problem was that when the Jellyfin streaming session finish, any suspend that should of happened would not happen as it had passed.  Also if you mask and unmask without checking what the setting were before you do so, you could unmask a setting that has been masked for a reason.

5) systemd-inhibit --what sleep:shutdown --mode=delay - again this works great at inhibiting suspend with --mode=delay and the delay set in the conf file.  The problem with this is that as soon as the Jellyfin streaming session ends, if the computer was supposed to suspend because of a users suspend settings,if a user has started to use the computer again whilst the streaming session is active, then when it ends the computer suspends even if a user is still using the computer.

6) systemd-inhibit --what sleep:shutdown - the default here is to "block" the suspend, not delay suspend.  This works, but I now had to think how I could get the system to suspend after streaming.  This is what the application is based on.

After a lot of browsing I have hacked together some code and have hopefully come up with something that will work on most system (cross fingers).  If not I have added lots of comments and logging etc. so people should be able to fix any issues.




