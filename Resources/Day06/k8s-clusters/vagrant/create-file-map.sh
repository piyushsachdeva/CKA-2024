#!/bin/bash

# Set the root directory
ROOT_DIR="k8s-vmware-cluster"

# Create the root folder
mkdir -p "$ROOT_DIR"

# Move into the root folder
cd "$ROOT_DIR"

# Create the needed files
touch Vagrantfile common.sh master.sh worker.sh

# Confirm creation
echo "✅ Project structure created successfully:"
tree .

# If 'tree' command is not installed, fallback
if [ $? -ne 0 ]; then
  echo "k8s-vmware-cluster/"
  echo "├── Vagrantfile"
  echo "├── common.sh"
  echo "├── master.sh"
  echo "└── worker.sh"
  echo "└── disable-swap.sh"
  

fi
