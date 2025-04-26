#!/usr/bin/bash
#***********************************************************************************************************************************************************
# configeditor.bash : part of the Jellyfin-Inhibit-Sleep Application
#
#
# Inhibit PC sleep/suspend mode if jellyfin has active viewers
#
# Thanks to txhammer68 for active viewers code https://gist.github.com/txhammer68/64d5888bf8822c9d0762533237ad6958
# The idea for this solution came from https://github.com/jonschz/jellyfin-plugin-preventsleep/issues/8#issuecomment-2799851649
#
#

:<< 'COMMENT'
    Bash program to configure the Jellyfin API key into the jellyfin-session-check.py file.
    It will check that the length is 32 characters long.
    Also allows configuration of the Session Polling Timer and the Inactivity Timeout.
COMMENT

session_check_filename='/usr/sbin/jellyfin-inhibit-sleep/jellyfin-session-check.py'
#session_check_filename='./test-session-replace.py'
sleep_check_filename='/usr/sbin/jellyfin-inhibit-sleep/jellyfin-sleep-check.py'
#sleep_check_filename='./test-sleep-replace.py'

MenuHeader () {

        clear -x

        printf "\n  Jellyfin Inhibit Sleep Application - User Settings Configurator\n"
        printf "  ---------------------------------------------------------------\n\n"
}

ShowSettings () {

        printf "  Your existing user settings:-\n\n"

        jellyfin_apikey=$(grep "jellyfin_apikey = " $session_check_filename)
        jellyfin_apikey=$(cut -d# -f1 <<< "$jellyfin_apikey")
        jellyfin_apikey=$(tr -d '\n' <<< "$jellyfin_apikey")
        newuser_apikey=$(grep "YOUR JELLYFIN API KEY HERE" <<< "$jellyfin_apikey")
        blank_apikey="jellyfin_apikey = \"\" "

        if [ -n "$newuser_apikey" ] || [ "$jellyfin_apikey" == "$blank_apikey" ]; then
            printf "    jellyfin_apikey = \"\"    (!!! WARNING !!! --- NO API Key --- !!! WARNING !!!)\n"
            else
            printf "    $jellyfin_apikey\n"
        fi
        if [ -n "$newjellyfin_apikey" ]; then
            printf "     New Value : $newjellyfin_apikey\n\n"
        else
            printf "\n\n"
        fi

        session_poll_timer=$(grep "session_poll_timer = " $session_check_filename)
        session_poll_timer=$(cut -d# -f1 <<< "$session_poll_timer")
        printf "    $session_poll_timer (Default 45) seconds\n"
        if [ -n "$newsession_poll_timer" ]; then
            printf "     New Value : $newsession_poll_timer\n\n"
        else
            printf "\n\n"
        fi

        inactivity_timeout=$(grep "inactivity_timeout = " $sleep_check_filename)
        inactivity_timeout=$(cut -d# -f1 <<< "$inactivity_timeout")
        printf "    $inactivity_timeout (Default 50) minutes (0 = Off)\n"
        if [ -n "$newinactivity_timeout" ]; then
            printf "     New Value : $newinactivity_timeout\n\n\n"
        else
            printf "\n\n"
        fi

        #if [ -n "$newuser_apikey" ]; then
        #    printf "!!! WARNING !!! You need to setup a NEW API Key.\n\n"
        #    printf "Please select NEW API key in the menu and follow the instructions.\n\n\n"
        #fi
}


NewAPIKey (){

        MenuHeader
        printf "\n"
        printf "  Your exisiting user setting:-\n\n"
        printf "   $jellyfin_apikey\n\n\n"
        unset apikey
        printf "Please Enter YOUR JELLYFIN API KEY (Ctrl-Shft-V to paste):\n"
        read apikey
        length=${#apikey}
        if [[ $length -ne 32 ]]; then
                clear -x
                printf "\n"
                printf "  WARNING :\n"
                printf "  WARNING : The Jellyfin API Key should be 32 charaters long.\n"
                printf "  WARNING :\n"
                printf "  WARNING :            Yours is $length characters long.\n"
                printf "  WARNING :\n"
        fi

                newjellyfin_apikey="jellyfin_apikey = \"$apikey\""

                unset ans
                #while [[ $ans != [yYnN] ]];
                while true
                do
                    printf "\n"
                    printf "    New Value : $newjellyfin_apikey\n\n"
                    printf "  Do you wish to keep this API key [yY,nN]?"
                    read -sn 1 ans
                    case $ans in
                        "y" | "Y")
                            break
                            #unset ans
                        ;;
                        'n' | 'N')
                            unset apikey
                            unset newapikey
                            unset newjellyfin_apikey
                            unset ans
                            break
                        ;;
                        *)
                            printf "\n\n  Invalid Choice !! - Please Try Again......\n\n"
                        ;;
                    esac
                done
}


NewSessionPoll (){
        MenuHeader
        printf "  Existing Value : $session_poll_timer (Default 30) seconds\n\n"
        unset number_spt
        until [[ $number_spt =~ ^[1-9][0-9]*$ ]]; do
            read -r -p "  Please enter a new session_poll_timer value (number only > 0): " number_spt
        done

        newsession_poll_timer="session_poll_timer = $number_spt"
        printf "    New Session Poll Timer value : $newsession_poll_timer\n"
}


NewTimer (){
        MenuHeader
        printf "  Exisiting Value : $inactivity_timeout (Default 60) minutes\n\n"
        unset number_ito
        printf "   Note : Set to 0 to disable Inactivity Timeout\n\n"
        until [[ $number_ito =~ ^[0-9][0-9]*$ ]]; do # Allow 0 to swicth off Timeout
            read -r -p "  Please enter a new InactivityTimout value (number only): " number_ito
        done

        newinactivity_timeout="inactivity_timeout = $number_ito"
        printf "    New Inactivity Timer value : $newinactivity_timeout\n"
}

WriteFiles (){
        MenuHeader
        printf "  Write values to the application files\n\n"

        if [ -n "$newjellyfin_apikey" ]; then
            printf "   WRITE : $newjellyfin_apikey \n   To file : $session_check_filename\n\n"
        fi
        if [ -n "$newsession_poll_timer" ]; then
            printf "   WRITE : $newsession_poll_timer \n   To file : $session_check_filename\n\n"
        fi
        if [ -n "$newinactivity_timeout" ]; then
            printf "   WRTIE : $newinactivity_timeout \n   To file : $sleep_check_filename\n\n\n"
        fi

        unset ans
        while [[ $ans != [yYnN] ]];
        do
            printf "  Do you wish to WRITE these values to the application files [yY,nN]?"
            read -sn 1 ans
            case $ans in
                "y" | "Y")
                    
                    if [ -n "$newjellyfin_apikey" ]; then
                        sed -i -e "s|$jellyfin_apikey|jellyfin_apikey = \"${apikey}\" |g" $session_check_filename
                        unset newjellyfin_apikey
                    fi

                    if [ -n "$newsession_poll_timer" ]; then
                        sed -i -e "s|$session_poll_timer|session_poll_timer = ${number_spt} |g" $session_check_filename
                        unset newsession_poll_timer
                    fi

                    if [ -n "$newinactivity_timeout" ]; then
                        sed -i -e "s|$inactivity_timeout|inactivity_timeout = ${number_ito} |g" $sleep_check_filename
                        unset newinactivity_timeout
                    fi
                    clear -x
                    MenuHeader
                    printf "\n\n\n    Changes have been written to the file(s)\n\n"
                    printf "    Please wait........."
                    sleep 2
                ;;
                'n' | 'N')
                    #unset apikey
                    #unset newapikey
                    #unset newjellyfin_apikey
                    unset ans
                    break
                ;;
                *)
                    printf "\n\n  Invalid Choice !! - Please Try Again......\n\n"
                ;;
            esac
        done
}

HelpInfo (){
        MenuHeader
        #printf "  Help\n"
        #printf "How to get your API Key\n\n"

#This is required otherwise the python script cannot access the Jellyfin server to get session data.

printf "  How to create your own jellyfin_apikey for your Jellyfin Server.\n\n"
printf " 1) Using your web browser, log in to your Jellyfin server as the admin user.\n"
printf " 2) Click on the three bars in the top left hand corner and go to :\n"
printf "       Administration -> Dashboard -> Advanced -> API Keys.\n"
printf " 3) Next to the words API Keys, there is a + button.\n"
printf "    Click on the + button and create an API key.\n"
printf " 4) In the \"App Name\" field, type \"Jellyfin-Inhibit-Sleep\" and click ok.\n"
printf "    You will see a list of your API Keys. Copy the API Key to your clipboard.\n"
printf " 5) Come back to this program and select \"Enter a [N]ew API Key\" from the menu.\n"
printf " 6) Paste the key into the program using CTRL-SHFT-V and agree to the prompts.\n"
printf " 7) From the menu screen, select \"[W]rite changes to file\" and select \"[Y]\"\n\n"

printf " session_poll_timer :"
printf " How often you want to re-check the Jellyfin server for\n"
printf "          user session information whilst a session is active.\n"

printf " inactivity_timeout :"
printf " Inactivity timeout setting is the time before suspend in\n"
printf "          minutes. It can override user sleep settings if the value is too low.\n\n"

printf "  Press any key"
read -sn 1

}


# Main Program ----------------------------------------------------------------------------------


HelpInfo # show the help screen first
clear -x
if [ $USER == "root" ]; then
printf "\n You are running as the root user\n\n"
sleep 1

unset ans
while [[ $ans != [nNsSiIwWhHqQ] ]];
        do

        MenuHeader
        ShowSettings

        printf "  Enter a [N]ew API key.\n"
        printf "  Change [S]ession_poll_timer\n"
        printf "  Change [I]nactivity_timeout\n"
        printf "  [W]rite changes to file\n"
        printf "  [H]elp\n"
        printf "  [Q]uit Configurator\n\n"
        printf "  Please enter your choice [nN,sS,iI,wW,hH,qQ]"
        read -sn1 ans
        printf "\n\n"
        case $ans in
            'n' | 'N')
                NewAPIKey
                unset ans
            ;;
            's' | 'S')
                NewSessionPoll
                unset ans
            ;;
            'i' | 'I')
                NewTimer
                unset ans
            ;;
            'w' | 'W')
                WriteFiles
                unset ans
            ;;
            'h' | 'H')
                HelpInfo
                unset ans
            ;;
            'q' | 'Q')
                printf "\nExiting Setup\n"
                
            ;;
            *)
                printf "\n\nInvalid Choice !! - Please Try Again......\n\n"
            ;;
        esac
done


else

    MenuHeader
    printf " You are NOT the root user !!\n\n"
    printf " To configure the application you must run this program as root i.e.:\n"
    printf "    sudo ./configeditor.bash\n\n"

fi


