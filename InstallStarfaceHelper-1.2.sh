#!/bin/zsh
#
# Version: 1.2
# Name: Apfelwerk-InstallStarfaceHelper
# Author: Benjamin Kollmer, Maksymilian Switon
# Created: 2024-01-25
# Updated: 2025-12-17
# Description: Installs the Starface Helper Tools from a specified package location.
#              This script runs in the background without user interaction.
#              Ensures that the package exists before attempting installation.
#              Logs the installation process.
# 
# Copyright (c) 2023-2025 Apfelwerk Apfelwerk GmbH & Co. KG
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Logging function and variables for this script
loggedInUser=$(stat -f%Su /dev/console)
scriptName=$(basename "${0}" | tr -d " ")
logDir="/Library/Logs/Management"
logFile="${logDir}/$(echo "${scriptName}" | cut -d . -f1).log"

# Creating Log file directory
if [[ ! -d "${logDir}" ]]
then
    mkdir -p "${logDir}"
fi

# Logging function for this script. to use it, just call 'logd "your message"' in your script
logd() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "$logFile"
}

logd "$(printf "%0.s# " {1..10}) Starting ${scriptName} script $(printf "%0.s# " {1..10})"

# Variables for the application part of this script

## Use parameter 4 in the JSS to specify the installtrigger for the starface client
## Parameter Label: Installtrigger
## Example: installStarface73xx
installTrigger=$4

## Path to the Starface Helper Tools package.
pkgPath="/Applications/STARFACE.app/Contents/Resources/StarfaceHelperFiles.pkg"

# Start code here for the application part of this script

# Run the install trigger
logd "Running Jamf install policy event."
/usr/local/bin/jamf policy -event $installTrigger

# Get the running process ID of Starface and kill it
logd "Killing Starface process."
pid=$(pgrep -f "STARFACE")
if [[ -n "$pid" ]]; then
    kill -9 "$pid"
    logd "Starface process (PID: $pid) killed."
else
    logd "No running Starface process found."
fi

sleep 2

# Check if the package exists
if [[ -f "$pkgPath" ]]; then
    logd "Package found, proceeding with installation."

    # Install the package
    sudo installer -pkg "$pkgPath" -target / &> /dev/null
    if [[ $? -eq 0 ]]; then
        logd "Installation successful."
    else
        logd "Error during installation."
    fi
else
    logd "Package not found at $pkgPath. Installation aborted."
fi

logd "$(printf "%0.s# " {1..10}) Finished ${scriptName} script $(printf "%0.s# " {1..10})"
exit 0
