#!/bin/bash
set -euo pipefail

# Fetch the latest Velociraptor release information from GitHub API
response=$(curl -s https://api.github.com/repos/Velocidex/velociraptor/releases/latest)

# Use jq to extract the browser_download_url for the Linux AMD64 binary
download_url=$(echo "$response" | jq -r '[.assets[] | select(.name | test("velociraptor-.*-linux-amd64$")) | .browser_download_url][0]')

# Check if we found a URL
if [ -z "$download_url" ] || [ "$download_url" == "null" ]; then
  echo "Error: Could not find a Linux AMD64 binary in the latest release" >&2
  exit 1
fi

echo "Latest Velociraptor download URL: $download_url"

# Download Velociraptor binary to /tmp and make it executable
curl -L "$download_url" -o ./velociraptor
chmod +x ./velociraptor

# Run the collector using the workspace configuration file
mkdir -p ./datastore
./velociraptor collector --datastore ./datastore/ ./config/spec.yaml