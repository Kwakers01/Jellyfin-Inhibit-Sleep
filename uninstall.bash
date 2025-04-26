#! /usr/bin/bash
#***********************************************************************************************************************************************************
# uninstall.bash : part of the Jellyfin-Inhibit-Sleep Application
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

        printf "\n  Jellyfin Inhibit Sleep - Application Uninstaller\n"
        printf "  ------------------------------------------------\n\n"

}



DeleteCrontab (){

    #Remove job from root user crontab - note search on just the comand in case someone has change the timers
    croncmd="'/usr/sbin/jellyfin-inhibit-sleep/jellyfin-inhibit-sleep.bash'"
    cronjob="* * * * * $croncmd"
    (sudo crontab -l | grep -v -F "$croncmd" ) | crontab -
    printf "\n crontab entry deleted\n"

}


DeleteFiles (){


    # This will remove ALL files for jellyfin-inhibit-sleep application.
    printf " Deleting Application......\n\n"
    #Remove jellyfin-inhibit-sleep and it's contents
    sudo rm -v -r /usr/sbin/jellyfin-inhibit-sleep/
    printf "\n Deleting Lock Files.......\n\n"
    #remove the lock files - used to ensure we do not have duplicate processes
    sudo rm -v /var/lock/jellyfin-session-check.py
    sudo rm -v /var/lock/jellyfin-sleep-check.py

if [ "$1" = "delete" ]; then
    printf "\n Deleting Log Files.......\n\n"
    #Remove the log files- NOTE : You will be asked if you want to remove log files (incase of later re-install)
    sudo rm -v -r /var/log/jellyfin-inhibit-sleep
fi

}


# Main Program ----------------------------------------------------------------------------------------------------

MenuHeader

unset keeplog

#printf " To install this application you must run this program as root i.e.:\n"
#printf "    sudo ./install.bash\n\n"

if [ $USER == "root" ]; then
printf " You are running as the root user\n\n"





if [ -d "/usr/sbin/jellyfin-inhibit-sleep" ]; then

    printf "  WARNING : Directory EXISTS: /usr/sbin/jellyfin-inhibit-sleep\n"
    printf "  WARNING : The Jellyfin Inhibit Sleep Application is INSTALLED.\n\n"

else
    printf "  WARNING : Directory does NOT exist: /usr/sbin/jellyfin-inhibit-sleep\n"
    printf "  WARNING : The Jellyfin Inhibit Sleep Application is NOT INSTALLED.\n\n"

    printf " You can still UNINSTALL to ensure that the lock files and logs are deleted,\n"
    printf " but you will see errors as some (or all) files will not exists\n\n"



fi



printf "\n"
printf " Log file : /var/log/jellyfin-inhibit-sleep/session-check.log\n"
printf " Log file : /var/log/jellyfin-inhibit-sleep/sleep-check.log\n\n"
unset ans
        #while [[ $ans != [yYnN] ]];
        while true
        do

            printf "  Do you want to DELETE the log files? [yY,nN] "
            read -n 1 ans
            case $ans in
                "y" | "Y")
                    keeplog="delete"
                    break
                ;;
                'n' | 'N')
                    keeplog="keep"
                    break
                ;;
                *)
                    printf "\n\n"
                    printf "  Invalid Choice !! - Please Try Again......\n"
                ;;
            esac
        done

printf "\n\n"

    unset ans
        #while [[ $ans != [yes,YES,no,NO] ]];
        while true
        do

            read -p "  Do you want to UNINSTALL this application? [yes/YES,no/NO] " ans
            case $ans in
                "yes" | "YES")
                    printf "\n\n"
                    printf "Deleting crontab entires.....\n"
                    #printf "RUN FUNCTION : DeleteCrontab\n" # TESTING CODE
                    DeleteCrontab #Function
                    if [ "$keeplog" = "keep" ]; then
                        printf "\n"
                        printf "The LOG files will NOT been deleted\n"
                    fi
                    printf "\n"
                    printf "Deleting files and directories.....\n\n"
                    #printf "RUN FUNCTION : DeleteFiles\n" # TESTING CODE
                    DeleteFiles $keeplog #Function
                    if [ "$keeplog" = "keep" ]; then
                        printf "\n"
                        printf "The LOG files have NOT been deleted : /var/log/jellyfin-inhibit-sleep/*\n\n"
                    else
                        printf "\n"
                        printf "ALL files and directories have been deleted\n\n"
                    fi
                    printf "Uninstall has FINISHED\n\n"
                    break
                ;;
                'no' | 'NO')
                    printf "\n\n"
                    printf "  Uninstall CANCELLED - NOTHING has been deleted\n\n"
                    unset ans
                    break
                ;;
                *)
                    printf "\n"
                    printf "  Invalid Choice !! - Please Try Again......\n"
                ;;
            esac
        done

else
    printf " You are NOT the root user !!\n\n"
    printf " To uninstall this application you must run this program as root i.e.:\n"
    printf "    sudo ./uninstall.bash\n\n"

fi

