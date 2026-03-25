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
    if ! mkdir -p "${logDir}"; then
        echo "ERROR: Unable to create log directory at ${logDir}"
        exit 1
    fi
fi

if ! touch "${logFile}" 2>/dev/null; then
    echo "ERROR: Unable to write log file at ${logFile}"
    exit 1
fi

# Logging function for this script. to use it, just call 'log "your message"' in your script
logd() {
    local message
    message="$(date "+%Y-%m-%d %H:%M:%S") [${scriptName}]: $*"
    echo "${message}" >> "${logFile}"
    echo "${message}"
}

logd "$(printf "%0.s# " {1..10}) Starting ${scriptName} script $(printf "%0.s# " {1..10})"
# Code for this script goes here below this line
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Variables for the application part of this script
scriptDir=$(dirname "${0}")
installomatorScript="${scriptDir}/Installomator/Installomator.sh"
labelsFile="${scriptDir}/Installomator/Labels.txt"
monitoringStartTime=$(date "+%Y-%m-%d_%H-%M-%S")
failureLogFile="${logDir}/InstallomatorMonitoringLog_${monitoringStartTime}.log"
failureLogCreated=false
failureCount=0
processedCount=0

normalizeLabel() {
    local rawLabel="$1"
    local normalizedLabel="${rawLabel#"${rawLabel%%[![:space:]]*}"}"
    normalizedLabel="${normalizedLabel%"${normalizedLabel##*[![:space:]]}"}"

    if [[ -z "${normalizedLabel}" ]] || [[ "${normalizedLabel}" == \#* ]]; then
        return 1
    fi

    printf '%s\n' "${normalizedLabel}"
}

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

# Count actionable labels in Labels file
totalLabels=0
while IFS= read -r label || [[ -n "${label}" ]]; do
    if normalizeLabel "${label}" >/dev/null; then
        ((totalLabels++))
    fi
done < "${labelsFile}"

logd "Found ${totalLabels} actionable labels in ${labelsFile}"

if [[ ${totalLabels} -eq 0 ]]; then
    logd "No actionable labels found in ${labelsFile}"
    logd "$(printf "%0.s# " {1..10}) Finished ${scriptName} script $(printf "%0.s# " {1..10})"
    exit 0
fi

# Read each line from Labels.txt and execute Installomator.sh
while IFS= read -r label || [[ -n "${label}" ]]; do
    normalizedLabel=$(normalizeLabel "${label}") || {
        continue
    }
    
    ((processedCount++))
    logd "Processing label ${processedCount}/${totalLabels}: ${normalizedLabel}"
    
    # Execute Installomator with the label and capture output
    installomatorOutput=$("${installomatorScript}" "${normalizedLabel}" 2>&1)
    installomatorExitCode=$?

    if [[ ${installomatorExitCode} -eq 0 ]]; then
        logd "SUCCESS: Installomator completed for label: ${normalizedLabel}"
    else
        ((failureCount++))
        lastLine=$(printf '%s\n' "${installomatorOutput}" | tail -n 1)
        logd "ERROR: Installomator failed for label: ${normalizedLabel}"
        logd "Exit code: ${installomatorExitCode}"
        if [[ -n "${lastLine}" ]]; then
            logd "Last output line: ${lastLine}"
        fi
        
        # Create/initialize failure log file if not exists
        if [[ "${failureLogCreated}" == false ]]; then
            {
                echo "Installomator Monitoring Failure Log - Started: $(date "+%Y-%m-%d %H:%M:%S")"
                echo
            } > "${failureLogFile}"
            failureLogCreated=true
            logd "Created failure log file: ${failureLogFile}"
        fi
        
        # Persist full Installomator output for troubleshooting.
        {
            echo "-----"
            echo "Timestamp: $(date "+%Y-%m-%d %H:%M:%S")"
            echo "Label: ${normalizedLabel}"
            echo "Exit code: ${installomatorExitCode}"
            echo "Output:"
            if [[ -n "${installomatorOutput}" ]]; then
                printf '%s\n' "${installomatorOutput}"
            else
                echo "[no output captured]"
            fi
            echo
        } >> "${failureLogFile}"
    fi
    
done < "${labelsFile}"

logd "Processed all ${processedCount} actionable labels from ${labelsFile}"

# Summary
if [[ "${failureLogCreated}" == true ]]; then
    logd "Failures detected (${failureCount}/${processedCount}). See detailed log at: ${failureLogFile}"
else
    logd "All labels processed successfully with no failures detected"
fi

# End of code for this script
logd "$(printf "%0.s# " {1..10}) Finished ${scriptName} script $(printf "%0.s# " {1..10})"
if [[ ${failureCount} -gt 0 ]]; then
    exit 1
fi

exit 0
