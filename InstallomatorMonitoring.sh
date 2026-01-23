#!/bin/zsh
#
# Version: 1.0
# Name: Installomator Monitoring
# Author: 
# Created: 2026-01-23
# Updated: 2026-01-23
# Description: - Reads labels from Labels.txt file
#              - Executes Installomator.sh for each label
#              - Processes each line of the labels file sequentially
#              - Logs execution status for monitoring
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
scriptDir=$(dirname "${0}")
installomatorScript="${scriptDir}/Installomator/Installomator.sh"
labelsFile="${scriptDir}/Installomator/Labels.txt"
monitoringStartTime=$(date "+%Y-%m-%d_%H-%M-%S")
failureLogFile="${logDir}/InstallomatorMonitoringLog_${monitoringStartTime}.log"
failureLogCreated=false

# Check if Installomator script exists
if [[ ! -f "${installomatorScript}" ]]; then
    logd "ERROR: Installomator script not found at ${installomatorScript}"
    exit 1
fi

# Check if Labels file exists
if [[ ! -f "${labelsFile}" ]]; then
    logd "ERROR: Labels file not found at ${labelsFile}"
    exit 1
fi

# Count total lines in Labels file
totalLabels=$(wc -l < "${labelsFile}" | tr -d ' ')
logd "Found ${totalLabels} labels in ${labelsFile}"

# Start code here for the application part of this script
lineNumber=0

# Read each line from Labels.txt and execute Installomator.sh
while IFS= read -r label || [[ -n "${label}" ]]; do
    # Skip empty lines
    if [[ -z "${label}" ]]; then
        continue
    fi
    
    ((lineNumber++))
    logd "Processing label ${lineNumber}/${totalLabels}: ${label}"
    
    # Execute Installomator with the label and capture output
    installomatorOutput=$("${installomatorScript}" "${label}" 2>&1)
    installomatorExitCode=$?
    
    # Check the last line for exit code status
    lastLine=$(echo "${installomatorOutput}" | tail -n 1)
    
    # Check if exit code is 0
    if [[ "${lastLine}" == *"exit code 0"* ]] && [[ ${installomatorExitCode} -eq 0 ]]; then
        logd "SUCCESS: Installomator completed for label: ${label}"
    else
        logd "ERROR: Installomator failed for label: ${label}"
        logd "Last output line: ${lastLine}"
        logd "Exit code: ${installomatorExitCode}"
        
        # Create/initialize failure log file if not exists
        if [[ "${failureLogCreated}" == false ]]; then
            echo "Installomator Monitoring Failure Log - Started: $(date "+%Y-%m-%d %H:%M:%S")" > "${failureLogFile}"
            failureLogCreated=true
            logd "Created failure log file: ${failureLogFile}"
        fi
        
        # Append failed label to failure log
        echo "$(date "+%Y-%m-%d %H:%M:%S") - FAILED: ${label} (Exit code: ${installomatorExitCode})" >> "${failureLogFile}"
    fi
    
done < "${labelsFile}"

logd "Processed all ${lineNumber} labels from ${labelsFile}"

# Summary
if [[ "${failureLogCreated}" == true ]]; then
    logd "Failures detected. See detailed log at: ${failureLogFile}"
else
    logd "All labels processed successfully with no failures detected"
fi

# End of code for this script
logd "$(printf "%0.s# " {1..10}) "Finished ${scriptName} script  "$(printf "%0.s# " {1..10})"
exit 0
