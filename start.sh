#!/bin/bash

# Initialize variables with default values. These variables are used to store the values of the command-line arguments.
DEBUG="false"
INSTALL=""
SETUP=""
GITHUB_TOKEN=""
DOPPLER_TOKEN=""
DOPPLER_PROJECT=""
DOPPLER_CONFIG=""
BUN_VERSION=""

# All functions are defined below.

# Function to display usage instructions and exit. This function is called when the user provides invalid arguments or when the user provides the --help flag or the -h flag.
usage_instructions() {
  echo "Usage Instructions: $0 [OPTIONS]"
  echo "Options:"
  echo "  --install-yes                 Automatically install without prompting"
  echo "  --install-no                  Skip the installation process"
  echo "  --setup-yes                   Automatically setup without prompting"
  echo "  --setup-no                    Skip the setup process"
  echo "  --github-token TOKEN          GitHub token for authentication"
  echo "  --doppler-token TOKEN         Doppler token for secure secrets access"
  echo "  --doppler-project PROJECT     Doppler project to use"
  echo "  --doppler-config CONFIG       Doppler config to use"
  echo ""
  echo "  --debug                       Enable debug mode for verbose logging (optional)"
  echo "  --bun-version VERSION         Version of Bun to install (optional)"
  echo ""
  echo "Example:"
  echo "  $0 --install-yes --setup-yes --github-token TOKEN --doppler-token TOKEN --doppler-project PROJECT --doppler-config CONFIG"
  exit 1
}

# Check if all required arguments are provided and if not echo an error message with the missing arguments and usage instructions and exit.
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
    usage_instructions
  fi
}

# Function to append the install and setup functions to the shell config file.
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

# Function to configure the shell environment by appending the install and setup functions to the shell config file.
configure_shell() {
  if [ -f "$HOME/.zshrc" ]; then
    append_to_shell_config "$HOME/.zshrc"
    # shellcheck disable=SC1091
    source "$HOME/.zshrc"
    # shellcheck disable=SC1091
    source "$HOME/.profile"
  elif [ -f "$HOME/.bashrc" ]; then
    append_to_shell_config "$HOME/.bashrc"
    # shellcheck disable=SC1091
    source "$HOME/.bashrc"
    # shellcheck disable=SC1091
    source "$HOME/.profile"
  fi
}

# Define install function
install() {
  # Execute install function with the environment variables
  export BUN_VERSION="$BUN_VERSION"
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

# Define end function
end() {
  curl -sL https://raw.githubusercontent.com/vivekrp/install_setup/main/end.sh | bash
}

# Export the functions to the current shell session for use in other shell scripts and functions.
export -f setup install end

# Parse command-line arguments and set variables accordingly to the given values or the default values if no value is provided.
while [[ "$#" -gt 0 ]]; do
  case $1 in
  --debug)
    DEBUG="true"
    ;;
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
    ;;
  esac
  shift
done

# Print the values of the variables if debug mode is enabled in the environment variables.
if [ "$DEBUG" = "true" ]; then
  echo "DEBUG: $DEBUG"
  echo "INSTALL: $INSTALL"
  echo "SETUP: $SETUP"
  echo "GITHUB_TOKEN: $GITHUB_TOKEN"
  echo "DOPPLER_TOKEN: $DOPPLER_TOKEN"
  echo "DOPPLER_PROJECT: $DOPPLER_PROJECT"
  echo "DOPPLER_CONFIG: $DOPPLER_CONFIG"
fi

check_required_args
configure_shell

# If --install-yes is provided, execute the install function
if [ "$INSTALL" == "yes" ]; then
  install
elif [ "$INSTALL" == "no" ]; then
  echo "Skipping install function as per the environment variable."
else
  echo "No valid install environment variable provided. Set SETUP to 'yes' to execute install or 'no' to skip it."
  exit 1
fi

# If --setup-yes is provided, execute the setup function
if [ "$SETUP" == "yes" ]; then
  setup
elif [ "$SETUP" == "no" ]; then
  echo "Skipping setup function as per the environment variable."
else
  echo "No valid setup environment variable provided. Set SETUP to 'yes' to execute setup or 'no' to skip it."
  exit 1
fi

# end function
end
