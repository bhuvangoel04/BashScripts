#!/bin/bash

# ==============================================================================
# Daily Git Sync for Project
#
# Description:
# This script automates the process of syncing a project with a Git
# repository. It performs the following actions daily:
# 1. Navigates to the specified Strapi project directory.
# 2. Pulls the latest changes from the remote repository to prevent conflicts.
# 3. Checks for any local changes (e.g., database updates, new media,
#    admin panel configurations that modify files).
# 4. If local changes are detected, it adds all files, commits them with a
#    standardized message, and pushes them to the remote repository.
# Author: https://github.com/bhuvangoel04
# ==============================================================================

# --- CONFIGURATION ---
# !!! IMPORTANT: UPDATE THESE VARIABLES !!!

# The absolute path to your Strapi project's root directory.
# Example: PROJECT_DIR="/var/www/my-project"
PROJECT_DIR="/path/to/your/project"

# The name of the branch you want to sync.
# Example: GIT_BRANCH="main" or GIT_BRANCH="master"
GIT_BRANCH="main"

# The name of your remote repository (usually "origin").
REMOTE_NAME="origin"

# The commit message for automated commits.
COMMIT_MESSAGE="chore(auto-sync): Daily automatic backup of Strapi changes"

# --- SCRIPT LOGIC ---
# Do not edit below this line unless you know what you are doing.

# Echo the current date and time for logging purposes.
echo "================================================="
echo "Starting Strapi Git sync on $(date)"
echo "================================================="

# Check if the project directory exists.
if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: Project directory not found at $PROJECT_DIR"
  exit 1
fi

# Navigate to the project directory. Exit if the command fails.
cd "$PROJECT_DIR" || { echo "Error: Failed to navigate to project directory."; exit 1; }

echo "Successfully changed directory to $PROJECT_DIR"
echo "Current branch: $(git rev-parse --abbrev-ref HEAD)"

# Step 1: Pull the latest changes from the remote repository.
# This helps avoid push conflicts if changes were made on another machine.
echo "--> Pulling latest changes from '$REMOTE_NAME/$GIT_BRANCH'..."
git pull $REMOTE_NAME $GIT_BRANCH
if [ $? -ne 0 ]; then
    echo "Error: 'git pull' failed. Please check for merge conflicts or connection issues."
    exit 1
fi
echo "Pull complete."

# Step 2: Check for local changes.
# The `git status --porcelain` command outputs a list of modified/new files.
# If the output is empty, the working directory is clean.
echo "--> Checking for local changes..."
if [ -n "$(git status --porcelain)" ]; then
  # Changes were found.
  echo "Local changes detected. Proceeding with commit and push."

  # Step 3: Add all changes to the staging area.
  echo "--> Staging all changes..."
  git add .
  if [ $? -ne 0 ]; then
      echo "Error: 'git add' failed."
      exit 1
  fi

  # Step 4: Commit the changes.
  echo "--> Committing changes with message: '$COMMIT_MESSAGE'"
  git commit -m "$COMMIT_MESSAGE"
  if [ $? -ne 0 ]; then
      echo "Error: 'git commit' failed. This might happen if there's nothing to commit after a pull."
      # This is not a fatal error, so we can continue.
  fi

  # Step 5: Push the commit to the remote repository.
  echo "--> Pushing changes to '$REMOTE_NAME/$GIT_BRANCH'..."
  git push $REMOTE_NAME $GIT_BRANCH
  if [ $? -ne 0 ]; then
      echo "Error: 'git push' failed. Check your authentication (SSH key) and permissions."
      exit 1
  fi
  echo "Push successful."
else
  # No changes were found.
  echo "No local changes detected. Directory is clean."
fi

echo "================================================="
echo "Strapi Git sync finished on $(date)"
echo "================================================="
echo ""

exit 0
