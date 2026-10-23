#!/bin/bash

TEMP_RPM="/tmp/bitwarden-latest.rpm"

echo -e "\033[1;34m[*] Querying GitHub API for the latest Bitwarden RPM...\033[0m"

# Query GitHub API and ensure we grab ONLY the first standard .rpm link (excluding commercial)
RPM_URL=$(curl -s https://api.github.com/repos/bitwarden/clients/releases/latest | grep "browser_download_url" | grep -i "\.rpm" | grep -v "commercial" | head -n 1 | cut -d '"' -f 4)

if [ -z "$RPM_URL" ]; then
    echo -e "\033[1;31m[-] Error: Could not automatically resolve the latest RPM download link from GitHub.\033[0m"
    exit 1
fi

echo -e "\033[1;34m[*] Found latest package: $RPM_URL\033[0m"
echo -e "\033[1;34m[*] Downloading package...\033[0m"

# Clean up any stale files
rm -f "$TEMP_RPM"

# Download the RPM binary with a progress bar
curl -L --progress-bar -o "$TEMP_RPM" "$RPM_URL"

# Verify that the downloaded file is a valid RPM package header
if [ -f "$TEMP_RPM" ] && file "$TEMP_RPM" | grep -q "RPM"; then
    echo -e "\033[1;33m[*] Valid RPM verified. Upgrading/Installing via DNF (may prompt for password)...\033[0m"
    
    sudo dnf install -y "$TEMP_RPM"
    
    # Clean up
    rm -f "$TEMP_RPM"
    echo -e "\033[1;32m[+] Bitwarden update process finished successfully!\033[0m"
else
    echo -e "\033[1;31m[-] Error: Downloaded file is not a valid RPM package.\033[0m"
    rm -f "$TEMP_RPM"
    exit 1
fi
