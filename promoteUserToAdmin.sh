#!/bin/zsh

set -euo pipefail

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run this script with sudo/root privileges."
    exit 1
fi

current_user=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && !/loginwindow/ { print $3 }')

if [[ -z $current_user ]]; then
    echo "No active logged-in user detected."
    exit 2
fi

if dseditgroup -o checkmember -m "$current_user" admin | grep -q "yes"; then
    echo "User '$current_user' is already an admin."
    exit 0
fi

dseditgroup -o edit -a "$current_user" -t user admin
echo "User '$current_user' has been added to the admin group."