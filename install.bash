#! /usr/bin/bash
#***********************************************************************************************************************************************************
# install.bash : part of the Jellyfin-Inhibit-Sleep Application
#
#
# Inhibit PC sleep/suspend mode if jellyfin has active viewers
#
# Thanks to txhammer68 for active viewers code https://gist.github.com/txhammer68/64d5888bf8822c9d0762533237ad6958
# The idea for this solution came from https://github.com/jonschz/jellyfin-plugin-preventsleep/issues/8#issuecomment-2799851649
#
#

MenuHeader () {

        clear -x

        printf "\n  Jellyfin Inhibit Sleep - Application Installer\n"
        printf "  ----------------------------------------------\n\n"
}


CopyFiles (){

printf " Copying Files.......\n\n"
# This will re-install the default settings for jellyfin-inhibit-sleep application.  Existing user settings will be overwritten.

# Install jelly-inhibit-files to root user

sudo mkdir -v /usr/sbin/jellyfin-inhibit-sleep
sudo mkdir -v /var/log/jellyfin-inhibit-sleep

sudo cp -v ./jellyfin-session-check.py /usr/sbin/jellyfin-inhibit-sleep/jellyfin-session-check.py
sudo cp -v ./jellyfin-sleep-check.py /usr/sbin/jellyfin-inhibit-sleep/jellyfin-sleep-check.py
sudo cp -v ./jellyfin-inhibit-sleep.bash /usr/sbin/jellyfin-inhibit-sleep/jellyfin-inhibit-sleep.bash
sudo cp -v ./install.bash /usr/sbin/jellyfin-inhibit-sleep/install.bash
sudo cp -v ./uninstall.bash /usr/sbin/jellyfin-inhibit-sleep/uninstall.bash
sudo cp -v ./configeditor.bash /usr/sbin/jellyfin-inhibit-sleep/configeditor.bash
sudo cp -v ./README.txt /usr/sbin/jellyfin-inhibit-sleep/README.txt
sudo cp -v ./README.md /usr/sbin/jellyfin-inhibit-sleep/README.md

sudo chmod -v +x /usr/sbin/jellyfin-inhibit-sleep/jellyfin-inhibit-sleep.bash
sudo chmod -v +x /usr/sbin/jellyfin-inhibit-sleep/install.bash
sudo chmod -v +x /usr/sbin/jellyfin-inhibit-sleep/uninstall.bash
sudo chmod -v +x /usr/sbin/jellyfin-inhibit-sleep/configeditor.bash

# Also chmod the ./directory bash files so they can easily be used if needed
sudo chmod -v +x ./uninstall.bash
sudo chmod -v +x ./configeditor.bash

}

AddCrontab (){

# Add job to root users crontab without duplicates
# this will re-install the default settings for the cronjob
# note : searching for the cronjob command ONLY incase the default timers have been changed.

croncmd="'/usr/sbin/jellyfin-inhibit-sleep/jellyfin-inhibit-sleep.bash'"
cronjob="* * * * * $croncmd"

printf " Updating crontab with $cronjob\n\n"

(sudo crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -

}



# Main Program ----------------------------------------------------------------------------------------------------

MenuHeader

printf " This program needs to be installed on the computer that is runnning:-\n\n"
printf "   * Linux operating system\n"
printf "   * with a Jellyfin Server installed\n"
printf "   * You must have root privilages i.e. know the root password\n\n"
#printf " To install this application you must run this program as root i.e.:\n"
#printf "    sudo ./install.bash\n\n"

if [ $USER == "root" ]; then
printf " You are running as the root user\n\n"





if [ -d "/usr/sbin/jellyfin-inhibit-sleep" ]; then

    printf "  WARNING : Directory Exists: /usr/sbin/jellyfin-inhibit-sleep\n"
    printf "  WARNING : The Jellyfin Inhibit Sleep Application is ALREADY INSTALLED.\n\n"

    printf "  NOTE : You CAN install over the TOP of the existing application.\n"
    printf "  NOTE : BE AWARE that your settings will all return to DEFAULT and\n"
    printf "  NOTE : you will need to re-configure your Jellyfin API Key with:\n"
    printf "  NOTE :        sudo ./configeditor.bash\n"
fi
    unset ans
        #while [[ $ans != [yYnN] ]];
        while true
        do
            printf "\n"
            printf "  Do you want to INSTALL the application? [yY,nN] "
            read -n 1 ans
            case $ans in
                "y" | "Y")
                    printf "\n"
                    printf "\n"
                    printf "  Copying files and directories.....\n"
                    #printf "RUN FUNCTION : CopyFiles\n" # TESTING CODE
                    CopyFiles #Function
                    printf "\n"
                    printf "  Adding crontab entires.....\n"
                    #printf "RUN FUNCTION : AddCrontab\n" # TESTING CODE
                    AddCrontab #Function
                    printf "\n"
                    printf "  All DONE - Installation has FINISHED\n\n"
                    printf "  REQUIRED : You MUST enter your Jellyfin API Key !!!\n\n"
                    printf "  please run : sudo ./configeditor.bash\n\n"
                    break
                ;;
                'n' | 'N')
                    printf "\n\n"
                    printf "  Installation CANCELLED - NOTHING has been installed\n\n"
                    unset ans
                    break
                ;;
                *)
                    printf "\n\n  Invalid Choice !! - Please Try Again......\n\n"
                ;;
            esac
        done

else
    printf " You are NOT the root user !!\n\n"
    printf " To install this application you must run this program as root i.e.:\n"
    printf "    sudo ./install.bash\n\n"

fi

