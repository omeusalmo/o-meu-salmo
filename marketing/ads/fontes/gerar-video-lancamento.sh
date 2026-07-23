#!/bin/bash
# Gera o vídeo de lançamento (1080x1920, mudo, Reels/Stories):
# headline de posicionamento fixo no topo + Salmo 23 preenchendo letra a letra
# (efeito karaokê via clip-path) + chips + CTA cobalt. Requer ffmpeg + Chrome + numpy/PIL.
# Uso: cd marketing/ads/fontes && ./gerar-video-lancamento.sh
set -e
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
export PATH="/opt/homebrew/bin:$PATH"
DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$DIR/../lancamento/anuncio-video-story.mp4"
HTMLD=$(mktemp -d); PNGD=$(mktemp -d); GRAIND=$(mktemp -d)

N=60; FPS=12; HOLD=30   # 60 frames fill (5s) + 30 hold (2.5s) = 7.5s

# 1. HTML determinístico por frame
python3 "$DIR/gerar-video-fill.py" batch >/dev/null
cp /tmp/fillframes/*.html "$HTMLD/"

# 2. screenshot de cada frame
i=0
for f in $(ls "$HTMLD"/f*.html | sort); do
  printf -v n "%03d" "$i"
  # --virtual-time-budget: espera a webfont carregar antes de capturar; sem isso
  # frames caem em fallback e o texto muda de tamanho entre frames.
  "$CHROME" --headless=new --disable-gpu --virtual-time-budget=6000 \
    --screenshot="$PNGD/frame-$n.png" \
    --window-size=1080,1920 --hide-scrollbars "file://$f" 2>/dev/null
  i=$((i+1))
done
# hold no frame final
last=$(printf "%03d" $((N-1)))
for h in $(seq 1 "$HOLD"); do
  printf -v n "%03d" $((N-1+h)); cp "$PNGD/frame-$last.png" "$PNGD/frame-$n.png"
done

# 3. grão estático de média-zero em TODOS os frames (idêntico => não pisca; quebra o
#    banding do gradiente escuro que, sob x264, gerava flicker frame a frame)
python3 - "$PNGD" "$GRAIND" <<'PY'
import numpy as np, glob, os, sys
from PIL import Image
src, dst = sys.argv[1], sys.argv[2]
np.random.seed(42)
grain = np.repeat((np.random.rand(1920,1080,1)*2-1)*5.0, 3, axis=2)  # ±5 níveis, fixo
for f in sorted(glob.glob(f'{src}/frame-*.png')):
    im = np.asarray(Image.open(f).convert('RGB')).astype(np.float32)
    Image.fromarray(np.clip(im+grain,0,255).astype(np.uint8)).save(os.path.join(dst, os.path.basename(f)))
PY

# 4. encode alta qualidade (crf baixo + aq-mode3 no gradiente liso)
ffmpeg -y -framerate "$FPS" -i "$GRAIND/frame-%03d.png" -r 30 \
  -c:v libx264 -crf 16 -preset slow -pix_fmt yuv420p \
  -x264-params "aq-mode=3:aq-strength=1.0" -movflags +faststart -an "$OUT" 2>&1 | tail -2

rm -rf "$HTMLD" "$PNGD" "$GRAIND"
echo "✓ $OUT ($(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUT")s)"
