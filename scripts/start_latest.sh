#!/bin/bash

# Execute script if exists
execute_script() {
    local script_path=$1
    local script_msg=$2
    if [[ -f ${script_path} ]]; then
        echo "${script_msg}"
        bash ${script_path}
    fi
}

CF_DIR="/workspace/cloudflared"
TOKEN="eyJhIjoiNzg1NjIwNGViZmIwM2E0NzM3NjQzZTcyNmJhYzQ2NDgiLCJ0IjoiODVlMGI1ZmEtYjdlMy00NGE0LTlmY2YtNWU1OTg4NGZkZGY5IiwicyI6IlltTXpPR0l4TjJJdE1XUTBOUzAwWVRnekxXSXdaamN0WlROa1lUa3pZV0ZoT0RObSJ9"

echo "[$(date)] Starting setup..." 

# Install lsof jika belum ada
command -v fuser >/dev/null 2>&1 || (apt update -qq && apt install -y -qq psmisc)
command -v fuser >/dev/null 2>&1 || (apt update -qq && apt install -y -qq nano)
# Stop dan matikan nginx jika aktif
echo "[$(date)] Stopping nginx..." 
(systemctl stop nginx 2>/dev/null || true) 2>&1 
(systemctl disable nginx 2>/dev/null || true) 2>&1
(pkill -f nginx || true) 2>&1 

# Pastikan port 3001 tidak digunakan
echo "[$(date)] Freeing port 3001..." 
(fuser -k 3001/tcp || true) 2>&1


# Install Cloudflare Tunnel jika belum ada
if [ ! -f "$CF_DIR/cloudflared" ]; then
    echo "[$(date)] Installing Cloudflare Tunnel..." 
    mkdir -p $CF_DIR
    curl -L -o $CF_DIR/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
    chmod +x $CF_DIR/cloudflared
    mv cloudflared /usr/local/bin/
fi

# Cek apakah service cloudflared sudah ada
if systemctl list-units --type=service | grep -q cloudflared.service; then
    echo "Cloudflared service sudah terinstall dan aktif."
else
    # Cek juga keberadaan file /etc/init.d/cloudflared sebagai fallback
    if [ -f /etc/init.d/cloudflared ]; then
        echo "Cloudflared service sudah terinstall di /etc/init.d/cloudflared."
    else
        echo "Cloudflared service belum ada, akan diinstall..."
        nohup $CF_DIR/cloudflared service install $TOKEN > /workspace/cloudflared.log 2>&1 &
        # nohup $CF_DIR/cloudflared tunnel --url http://localhost:3001 --token $TOKEN > /workspace/cloudflared.log 2>&1 &
    fi
fi

echo "[$(date)]  ^|^e All processes launched in background." 
# Jalankan ComfyUI dan log output
echo "[$(date)] Launching ComfyUI on port 3001..." 

#  ^{^t  ^o INI PENTING: Jangan gunakan "&"  ^`^t gunakan `exec` agar proses utama takeover
nohup /workspace/ComfyUI/venv/bin/python /workspace/ComfyUI/main.py --listen --port 3001 > /workspace/ComfyUI.log 2>&1 &
#exec /workspace/ComfyUI/venv/bin/python /workspace/ComfyUI/main.py --listen --port 3001 

# Tunggu 5 detik agar ComfyUI sempat start (opsional)
sleep 5

# Cek port 8888 sedang digunakan atau tidak
if fuser 8888/tcp >/dev/null 2>&1; then
  echo "Jupyter Notebook sudah berjalan di port 8888."
else
  echo "Jupyter Notebook belum berjalan."
  # Jalankan Jupyter di background
  echo "[$(date)] Starting Jupyter Notebook..."
  #nohup  jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root > /workspace/jupyter.log 2>&1 &
  #exec jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
  # Start jupyter lab

    if [[ $JUPYTER_PASSWORD ]]; then
            echo "Starting Jupyter Lab..."
            mkdir -p /workspace && \
            cd / && \
            nohup jupyter lab --allow-root --no-browser --port=8888 --ip=* --FileContentsManager.delete_to_trash=False --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* --ServerApp.preferred_dir=/workspace &> /jupyter.log &
            echo "Jupyter Lab started"
    fi
    
fi

execute_script "/post_start.sh" "Running post-start script..."
echo "Start script(s) finished, pod is ready to use."

sleep infinity