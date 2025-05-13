#!/bin/sh
######################
# Author: Saqui
# Date: 5th-May
# Version: V1
# This script will download code from GitHub, compile and Restart Services
######################
set -x    # to turn on debug mode, to show command before output
set -e  #exit the script when there is an error, but it doesn't work if there is a pipe
set -o pipefail  # that is why this command is used too
echo "Go to The-Hub Directory"

# --- Configuration ---
target_dir="root/folder/of/the/python/application"
repo_url="https://github.com/repository/url"  # change to your own github url
username="[githubusername]"    # change to your own username
access_token="[github-access-token]"      # change to your own github access token
remote_url="https://${username}:${access_token}@github.com/repository/url"      # after @ sign change to your own github url
# --- End Configuration ---

# Function to handle errors and exit
handle_error() {
  local message="$1"
  echo "Error: $message" >&2
  exit 1
}

# Check if the target directory exists
if [ -d "$target_dir" ]; then
  echo "Changing directory to: $target_dir"
  cd "$target_dir" || handle_error "Could not change directory to $target_dir"

  # Check if it's a Git repository
  if [ -d ".git" ]; then
    echo "Pulling the latest code from the private repository..."
    sudo git pull "$remote_url" main || handle_error "Failed to pull code from the private repository."
    echo "Successfully pulled the latest code."
    echo "************************************"
    echo "Running Migration..."
    python manage.py migrate
    echo "Migration Successful"
    echo "********************"
    echo "Restarting nginx and Gunicorn"
    sudo systemctl restart nginx
    sudo systemctl restart gunicorn
    echo "Service Restarted"
  else
    echo "Warning: '$target_dir' exists but does not appear to be a Git repository."
    echo "Please ensure this is the correct location."
  fi

else
  echo "Directory '$target_dir' does not exist."
fi

exit 0
