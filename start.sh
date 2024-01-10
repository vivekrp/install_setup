#!/bin/bash

# Usage function to display help for the script
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  --install-yes                 Automatically install without prompting"
  echo "  --install-no                  Skip the installation process"
  echo "  --setup-yes                   Automatically setup without prompting"
  echo "  --setup-no                    Skip the setup process"
  echo "  --bun-version VERSION         Specify a version of Bun to install"
  echo "  --github-token TOKEN          GitHub token for authentication"
  echo "  --doppler-token TOKEN         Doppler token for secure secrets access"
  echo "  --doppler-project PROJECT     Doppler project to use"
  echo "  --doppler-config CONFIG       Doppler config to use"
  echo ""
  echo "Example:"
  echo "  $0 --install-yes --setup-yes --github-token TOKEN --doppler-token TOKEN --doppler-project PROJECT --doppler-config CONFIG"
  exit 1
}

# Initialize variables
INSTALL=""
SETUP=""
GITHUB_TOKEN=""
DOPPLER_TOKEN=""
DOPPLER_PROJECT=""
DOPPLER_CONFIG=""
BUN_VERSION=""

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
  --install-yes)
    INSTALL="yes"
    ;;
  --install-no)
    INSTALL="no"
    ;;
  --setup-yes)
    SETUP="yes"
    ;;
  --setup-no)
    SETUP="no"
    ;;
  --bun-version)
    if [ -n "$2" ] && [[ $2 != --* ]]; then
      BUN_VERSION="$2"
      shift
    else
      echo "Error: Argument for $1 is missing" >&2
      exit 1
    fi
    ;;
  --github-token)
    if [ -n "$2" ] && [[ $2 != --* ]]; then
      GITHUB_TOKEN="$2"
      shift
    else
      echo "Error: Argument for $1 is missing" >&2
      exit 1
    fi
    ;;
  --doppler-token)
    if [ -n "$2" ] && [[ $2 != --* ]]; then
      DOPPLER_TOKEN="$2"
      shift
    else
      echo "Error: Argument for $1 is missing" >&2
      exit 1
    fi
    ;;
  --doppler-project)
    if [ -n "$2" ] && [[ $2 != --* ]]; then
      DOPPLER_PROJECT="$2"
      shift
    else
      echo "Error: Argument for $1 is missing" >&2
      exit 1
    fi
    ;;
  --doppler-config)
    if [ -n "$2" ] && [[ $2 != --* ]]; then
      DOPPLER_CONFIG="$2"
      shift
    else
      echo "Error: Argument for $1 is missing" >&2
      exit 1
    fi
    ;;
  *)
    echo "Unrecognized argument: $1" >&2
    usage
    ;;
  esac
  shift
done

# After the argument parsing loop
echo "INSTALL: $INSTALL"
echo "SETUP: $SETUP"
echo "GITHUB_TOKEN: $GITHUB_TOKEN"
echo "DOPPLER_TOKEN: $DOPPLER_TOKEN"
echo "DOPPLER_PROJECT: $DOPPLER_PROJECT"
echo "DOPPLER_CONFIG: $DOPPLER_CONFIG"

# Check if all required arguments are provided and echo the missing ones
check_required_args() {
  local missing_args=()
  [ -z "$INSTALL" ] && missing_args+=("--install-yes or --install-no")
  [ -z "$SETUP" ] && missing_args+=("--setup-yes or --setup-no")
  [ -z "$GITHUB_TOKEN" ] && missing_args+=("--github-token TOKEN")
  [ -z "$DOPPLER_TOKEN" ] && missing_args+=("--doppler-token TOKEN")
  [ -z "$DOPPLER_PROJECT" ] && missing_args+=("--doppler-project PROJECT")
  [ -z "$DOPPLER_CONFIG" ] && missing_args+=("--doppler-config CONFIG")
  if [ ${#missing_args[@]} -ne 0 ]; then
    echo "Missing required arguments: ${missing_args[*]}"
    usage
  fi
}
check_required_args

# Define install function
install() {
  curl -sL https://raw.githubusercontent.com/vivekrp/install_setup/main/install.sh | bash
}

# Define setup function
setup() {
  # Execute setup function with the environment variables
  export GITHUB_TOKEN="$GITHUB_TOKEN"
  export DOPPLER_TOKEN="$DOPPLER_TOKEN"
  export DOPPLER_PROJECT="$DOPPLER_PROJECT"
  export DOPPLER_CONFIG="$DOPPLER_CONFIG"
  # Download setup.sh for debugging purposes
  curl -sL https://raw.githubusercontent.com/vivekrp/install_setup/main/setup.sh | bash
}

end() {
  curl -sL https://raw.githubusercontent.com/vivekrp/install_setup/main/end.sh | bash
}

# Add the both functions to the current shell session
export -f setup install

append_to_shell_config() {
  local shell_config="$1"

  # Check if the install function is already in the shell config to avoid duplicates
  if ! grep -q "install()" "$shell_config"; then
    {
      echo -e "\n# Install function for environment configuration"
      declare -f install
      echo "export -f install"
    } >>"$shell_config"
  fi

  if ! grep -q "setup()" "$shell_config"; then
    {
      echo -e "\n# Setup function for environment configuration"
      declare -f setup
      echo "export -f setup"
    } >>"$shell_config"
  fi
}

sourceProfile() {
  # shellcheck disable=SC1091
  source "$HOME/.profile"
}

configure_shell() {
  if [ -f "$HOME/.zshrc" ]; then
    append_to_shell_config "$HOME/.zshrc"
    sourceProfile
  elif [ -f "$HOME/.bashrc" ]; then
    append_to_shell_config "$HOME/.bashrc"
    sourceProfile
  elif [ -f "$HOME/.bash_profile" ]; then
    append_to_shell_config "$HOME/.bash_profile"
    sourceProfile
  fi
}
configure_shell

# If --install-yes is provided, execute the install function
if [ "$INSTALL" == "yes" ]; then
  install
elif [ "$INSTALL" == "no" ]; then
  echo "Skipping install as per the environment variable."
else
  echo "No valid install environment variable provided. Set SETUP to 'yes' to execute install or 'no' to skip it."
  exit 1
fi

if [ "$SETUP" == "yes" ]; then
  setup
elif [ "$SETUP" == "no" ]; then
  echo "Skipping setup as per the environment variable."
else
  echo "No valid setup environment variable provided. Set SETUP to 'yes' to execute setup or 'no' to skip it."
  exit 1
fi

# end function
end
