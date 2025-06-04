Copy instal_comfyui.sh ke jupiter di pod
jalan kan dengan perintah
    sed -i -e 's/\r$//' install_comfyui.sh
chmod +x install_comfyui.sh && ./install_comfyui.sh

di settingan runpod tambahkan di Container Start Command
    bash /workspace/start.sh && bash