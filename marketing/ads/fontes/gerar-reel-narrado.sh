#!/bin/bash
# Monta um reel narrado completo: fill dourado (intro) + hold pela duração do áudio
# + narração real do app muxada. Uso: ./gerar-reel-narrado.sh <num_salmo>
set -e
NUM=$1
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
export PATH="/opt/homebrew/bin:$PATH"
DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$DIR/../../.."   # o-meu-salmo/
AUDIO="$ROOT/app/assets/audios/salmo_$(printf %03d "$NUM").mp3"
OUTDIR="$ROOT/instagram/reels-narrados"; mkdir -p "$OUTDIR"
OUT="$OUTDIR/salmo-$NUM.mp4"
PNGD=$(mktemp -d); GRAIND=$(mktemp -d)

NFILL=40; FILLFPS=7   # ~5.7s de fill
ALEN=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$AUDIO")

# 1. HTML dos frames de fill + screenshot (espera webfont)
python3 "$DIR/gerar-reel-narrado.py" "$NUM" "$NFILL" >/dev/null
i=0
for f in $(ls /tmp/reelframes/f*.html | sort); do
  printf -v n "%03d" "$i"
  "$CHROME" --headless=new --disable-gpu --virtual-time-budget=6000 \
    --screenshot="$PNGD/f-$n.png" --window-size=1080,1920 --hide-scrollbars "file://$f" 2>/dev/null
  i=$((i+1))
done
# hold: repete o frame final até cobrir o áudio (fill dura NFILL/FILLFPS s)
FILLSEC=$(echo "scale=3; $NFILL/$FILLFPS" | bc)
HOLDSEC=$(echo "scale=3; $ALEN-$FILLSEC+0.5" | bc)
HOLDN=$(echo "($HOLDSEC*$FILLFPS+1)/1" | bc)
last=$(printf "%03d" $((NFILL-1)))
for h in $(seq 1 "$HOLDN"); do printf -v n "%03d" $((NFILL-1+h)); cp "$PNGD/f-$last.png" "$PNGD/f-$n.png"; done

# 2. grão estático de média-zero (anti-banding, não pisca)
python3 - "$PNGD" "$GRAIND" <<'PY'
import numpy as np, glob, os, sys
from PIL import Image
src,dst=sys.argv[1],sys.argv[2]; np.random.seed(42)
g=np.repeat((np.random.rand(1920,1080,1)*2-1)*5.0,3,axis=2)
for f in sorted(glob.glob(f'{src}/f-*.png')):
    im=np.asarray(Image.open(f).convert('RGB')).astype(np.float32)
    Image.fromarray(np.clip(im+g,0,255).astype(np.uint8)).save(os.path.join(dst,os.path.basename(f)))
PY

# 3. vídeo (fill+hold) + muxa a narração real
ffmpeg -y -framerate "$FILLFPS" -i "$GRAIND/f-%03d.png" -i "$AUDIO" \
  -r 30 -c:v libx264 -crf 16 -preset slow -pix_fmt yuv420p -x264-params "aq-mode=3" \
  -c:a aac -b:a 128k -shortest -movflags +faststart "$OUT" 2>&1 | tail -2

rm -rf "$PNGD" "$GRAIND"
echo "✓ $OUT ($(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUT")s)"
