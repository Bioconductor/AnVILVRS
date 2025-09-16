#!/bin/bash

# Use the ~/bioc directory
cd ~/bioc/

# Set the Python version for this directory
pyenv local 3.11.13

# Create a new virtual environment
python -m venv AnVILVRS

# Activate it
source AnVILVRS/bin/activate

# 1. Downgrade tools for firecloud
pip install "setuptools<58" "pip<23.1"

# 2. Install firecloud
pip install firecloud==0.16.38

# 3. Upgrade tools for the main package
pip install --upgrade setuptools pip

# 4. Install vrs_anvil_toolkit
pip install git+https://github.com/gks-anvil/vrs_anvil_toolkit.git
