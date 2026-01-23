#!/bin/zsh
#
# Version: 1.0
# Name: 
# Author: 
# Created: 
# Updated: 
# Description: -
#              -
#              -
#              -
# 
# Copyright (c) 2023 Apfelwerk Apfelwerk GmbH & Co. KG
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Logging function and variables for this script
# Variables for the logging function
scriptName=$(basename "${0}" | tr -d " ")
logDir="/Library/Logs/Management"
logFile="${logDir}/$(echo "${scriptName}" | cut -d . -f1).log"

# Creating Log file directory
if [[ ! -d "${logDir}" ]]
then
    mkdir -p "${logDir}"
fi

# Logging function for this script. to use it, just call 'log "your message"' in your script
logd() {
    echo "$(date "+%Y-%m-%d %H:%M:%S")" "[${scriptName}]: ${*}" >> "${logFile}"
}

logd "$(printf "%0.s# " {1..10}) "Starting ${scriptName} script  "$(printf "%0.s# " {1..10})"
# Code for this script goes here below this line
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Variables for the application part of this script
uid=$(id -u "$loggedInUser")


# Start code here for the application part of this script


# End of code for this script
logd "$(printf "%0.s# " {1..10}) "Finished ${scriptName} script  "$(printf "%0.s# " {1..10})"
exit 0
