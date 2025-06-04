CF_DIR="/workspace/cloudflared"
TOKEN="eyJhIjoiNzg1NjIwNGViZmIwM2E0NzM3NjQzZTcyNmJhYzQ2NDgiLCJ0IjoiNTU3MDQzYjgtMGY5My00OWZjLWJjZDUtMjRjYzM3NDZmZmM4IiwicyI6Ik9UQTFaalk0T0RjdE1XRmlPUzAwTURCakxXSXhPR0l0TURjMk5qZ3lNelF6TUdFNCJ9"

echo "[$(date)] Starting setup..."

# Install lsof jika belum ada
command -v fuser >/dev/null 2>&1 || (apt update -qq && apt install -y -qq psmisc)




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