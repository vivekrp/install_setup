#!/bin/bash

# Usage function to display help for the script
usage() {
  echo "Usage: $0 --github-token TOKEN --doppler-token TOKEN --doppler-project PROJECT --doppler-config CONFIG"
  exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
  --bun-version)
    BUN_VERSION="$2"
    shift
    ;;
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
    # Download setup.sh for debugging purposes
    curl -s https://raw.githubusercontent.com/vivekrp/install_setup/main/setup.sh | bash
  }

  # Append setup function to the appropriate shell configuration file for future use
  append_to_shell_config() {
    local shell_config="$1"
    local setup_command="curl -s https://raw.githubusercontent.com/vivekrp/install_setup/main/setup.sh | /bin/bash"

    # Check if the setup function is already in the shell config to avoid duplicates
    if ! grep -q "setup()" "$shell_config"; then
      {
        echo -e "\n# Setup function for environment configuration"
        echo "setup() {"
        echo "  $setup_command"
        echo "}"
        echo "export -f setup"
      } >>"$shell_config"
    fi
  }

  if [ -f "$HOME/.profile" ]; then
    append_to_shell_config "$HOME/.profile"
    source "$HOME/.profile"
  elif [ -f "$HOME/.zshrc" ]; then
    append_to_shell_config "$HOME/.zshrc"
    source "$HOME/.zshrc"
  elif [ -f "$HOME/.bashrc" ]; then
    append_to_shell_config "$HOME/.bashrc"
    source "$HOME/.bashrc"
  elif [ -f "$HOME/.bash_profile" ]; then
    append_to_shell_config "$HOME/.bash_profile"
    source "$HOME/.bash_profile"
  fi

  # Add the setup function to the current shell session
  export -f setup

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
