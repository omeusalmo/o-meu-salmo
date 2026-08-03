#!/bin/bash
# Monta um reel narrado DEVOCIONAL (estilo meupastor.mp4): frame estático +
# narração real do app muxada. Uso: ./gerar-reel-narrado.sh <num_salmo>
set -e
NUM=$1
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
export PATH="/opt/homebrew/bin:$PATH"
DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$DIR/../../.."
AUDIO="$ROOT/app/assets/audios/salmo_$(printf %03d "$NUM").mp3"
OUTDIR="$ROOT/instagram/reels-narrados"; mkdir -p "$OUTDIR"
OUT="$OUTDIR/salmo-$NUM.mp4"
TMP=$(mktemp -d)

# 1. frame HTML -> screenshot (--virtual-time-budget: espera a webfont carregar)
python3 "$DIR/gerar-reel-narrado.py" "$NUM" >/dev/null
"$CHROME" --headless=new --disable-gpu --virtual-time-budget=6000 \
  --screenshot="$TMP/frame.png" --window-size=1080,1920 --hide-scrollbars \
  "file:///tmp/reel-frame.html" 2>/dev/null

# 2. grão estático de média-zero (quebra banding do gradiente escuro)
python3 - "$TMP/frame.png" <<'PY'
import numpy as np, sys
from PIL import Image
f=sys.argv[1]; np.random.seed(42)
g=np.repeat((np.random.rand(1920,1080,1)*2-1)*5.0,3,axis=2)
im=np.asarray(Image.open(f).convert('RGB')).astype(np.float32)
Image.fromarray(np.clip(im+g,0,255).astype(np.uint8)).save(f)
PY

# 3. loop do frame pela duração do áudio + muxa a narração
ffmpeg -y -loop 1 -i "$TMP/frame.png" -i "$AUDIO" \
  -r 30 -c:v libx264 -crf 16 -preset slow -pix_fmt yuv420p -x264-params "aq-mode=3" \
  -c:a aac -b:a 128k -shortest -movflags +faststart "$OUT" 2>&1 | tail -1

rm -rf "$TMP"
echo "✓ $OUT ($(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUT")s)"
