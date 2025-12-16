#!/bin/bash

# Use the ~/bioc directory
cd ~/bioc/anvilvrsproj

# check what versions are available
pyenv local

# if version not available install with:
# pyenv install 3.11.14

# Set the Python version for this directory
pyenv local 3.11.14

# Create a new virtual environment
python -m venv vrs_env

# Activate it
source vrs_env/bin/activate

# 1. Downgrade tools for firecloud
pip install "setuptools<58" "pip<23.1"

# 2. Install firecloud
pip install firecloud==0.16.38

# 3. Upgrade tools for the main package
pip install --upgrade setuptools pip

# 4. Install vrs_anvil_toolkit
pip install vrs_anvil_toolkit

# 5. Install ga4gh.vrs[extras] and plugin_system
pip install ga4gh.vrs[extras] plugin_system
