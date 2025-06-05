#!/bin/bash

# Set up workspace

cd /workspace
python3 -m venv jupyter-env
source jupyter-env/bin/activate
pip install --upgrade pip

pip install jupyterlab
