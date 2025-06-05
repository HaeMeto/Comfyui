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

echo "[$(date)] Launching ComfyUI on port 3001..." 

#  ^{^t  ^o INI PENTING: Jangan gunakan "&"  ^`^t gunakan `exec` agar proses utama takeover
nohup /workspace/ComfyUI/venv/bin/python /workspace/ComfyUI/main.py --listen --port 3001 > /workspace/ComfyUI.log 2>&1 &
#exec /workspace/ComfyUI/venv/bin/python /workspace/ComfyUI/main.py --listen --port 3001
execute_script "/post_start.sh" "Running post-start script..."
echo "Start script(s) finished, pod is ready to use."

sleep infinity
