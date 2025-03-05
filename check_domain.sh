#!/bin/bash

# Domain list checker for https://github.com/Mr-Precise/liberty-pre

if [[ $# -ne 1 ]]; then
    echo "[Usage]: $0 <list.txt>"
    exit 1
fi

IN_FILE_LIST="$1"

# Check file exists
if [[ ! -f "$IN_FILE_LIST" ]]; then
    echo "[Error]: File '$IN_FILE_LIST' not found!"
    exit 1
fi

# Function to check if a domain resolves to an IP (IPv4 or IPv6)
check_domain() {
    local domain="$1"
    local ipv4 ipv6
    
    ipv4=$(host -t A "$domain" 2>/dev/null | awk '/has address/ {print $NF}')
    ipv6=$(host -t AAAA "$domain" 2>/dev/null | awk '/has IPv6 address/ {print $NF}')
    
    if [[ -z "$ipv4" && -z "$ipv6" ]]; then
        echo "$domain is not resolving to an IP (or blocked by provider?)."
    fi
}

# Read the domain list from file and check domains
while IFS= read -r domain; do
    domain=$(echo "$domain" | tr -d '\r' | xargs)  # Remove carriage returns and trim spaces (windows is shit)
    [[ -z "$domain" || "$domain" =~ ^# ]] && continue  # Skip empty lines and comments
    check_domain "$domain"
done < "$IN_FILE_LIST"
