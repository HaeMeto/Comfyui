#!/bin/bash

# Aktifkan virtual environment
source /workspace/jupyter-env/bin/activate

# Jalankan Jupyter dengan opsi yang sudah diperbaiki
jupyter lab \
  --allow-root \
  --no-browser \
  --port=8888 \
  --ip=0.0.0.0 \
  --FileContentsManager.delete_to_trash=False \
  --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' \
  --ServerApp.token="" \
  --ServerApp.password="" \
  --ServerApp.allow_origin="*" \
  --ServerApp.preferred_dir=/workspace