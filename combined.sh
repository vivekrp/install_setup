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
curl -s https://raw.githubusercontent.com/vivekrp/install_setup/main/install.sh | bash

# Check if install.sh was successful
if [ $? -eq 0 ]; then
  # Define setup function
  setup() {
    curl -s https://raw.githubusercontent.com/vivekrp/install_setup/main/setup.sh | bash
  }

  # Append setup function to the appropriate shell configuration file
  if [ -f "$HOME/.bashrc" ]; then
    echo 'setup' >>"$HOME/.bashrc"
  elif [ -f "$HOME/.zshrc" ]; then
    echo 'setup' >>"$HOME/.zshrc"
  elif [ -f "$HOME/.profile" ]; then
    echo 'setup' >>"$HOME/.profile"
  fi

  # Execute setup function with the environment variables
  export GITHUB_TOKEN="$GITHUB_TOKEN"
  export DOPPLER_TOKEN="$DOPPLER_TOKEN"
  export DOPPLER_PROJECT="$DOPPLER_PROJECT"
  export DOPPLER_CONFIG="$DOPPLER_CONFIG"
  setup

else
  echo "Installation failed."
  exit 1
fi
