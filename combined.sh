#!/bin/bash

# Save this as combined.sh on your server

# Usage function to display help for the script
usage() {
  echo "Usage: $0 --github-token TOKEN --doppler-token TOKEN --doppler-project PROJECT --doppler-config CONFIG"
  exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
  --github-token)
    GITHUB_TOKEN="$2"
    shift
    ;;
  --doppler-token)
    DOPPLER_TOKEN="$2"
    shift
    ;;
  --doppler-project)
    DOPPLER_PROJECT="$2"
    shift
    ;;
  --doppler-config)
    DOPPLER_CONFIG="$2"
    shift
    ;;
  *) usage ;;
  esac
  shift
done

# Check if all required arguments are provided
if [ -z "$GITHUB_TOKEN" ] || [ -z "$DOPPLER_TOKEN" ] || [ -z "$DOPPLER_PROJECT" ] || [ -z "$DOPPLER_CONFIG" ]; then
  usage
fi

# Download and execute install.sh
curl -s https://raw.githubusercontent.com/vivekrp/install_setup/main/install.sh | bash -s -- --bun-version "$BUN_VERSION" --github-token "$GITHUB_TOKEN" --doppler-token "$DOPPLER_TOKEN" --doppler-project "$DOPPLER_PROJECT" --doppler-config "$DOPPLER_CONFIG"

# Check if install.sh was successful
if [ $? -eq 0 ]; then
  # Download and execute setup.sh
  curl -s https://raw.githubusercontent.com/vivekrp/install_setup/main/setup.sh | GITHUB_TOKEN="$GITHUB_TOKEN" DOPPLER_TOKEN="$DOPPLER_TOKEN" bash
else
  echo "Installation failed."
  exit 1
fi
