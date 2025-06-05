#!/bin/bash

SERVICE_NAME="jupyterlab.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
VENV_PATH="/workspace/jupyter-env"
USER_NAME=$(whoami)
JUPYTER_PORT=8888
JUPYTER_WORKDIR="/workspace"

echo "Membuat service file systemd untuk JupyterLab..."

sudo tee $SERVICE_PATH > /dev/null <<EOF
[Unit]
Description=JupyterLab Service
After=network.target

[Service]
Type=simple
User=$USER_NAME
ExecStart=/workspace/start_jupyter.sh
WorkingDirectory=$JUPYTER_WORKDIR
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "Reload systemd daemon..."
sudo systemctl daemon-reload

echo "Enable service agar start otomatis saat boot..."
sudo systemctl enable $SERVICE_NAME

echo "Start service JupyterLab..."
sudo systemctl start $SERVICE_NAME

echo "Status service:"
sudo systemctl status $SERVICE_NAME --no-pager
