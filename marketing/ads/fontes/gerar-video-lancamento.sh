#!/bin/bash
# Gera o vídeo de lançamento (1080x1920, mudo, Reels/Stories):
# headline de posicionamento fixo no topo + Salmo 23 preenchendo letra a letra
# (efeito karaokê via clip-path) + chips + CTA cobalt. Requer ffmpeg + Chrome.
# Uso: cd marketing/ads/fontes && ./gerar-video-lancamento.sh
set -e
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
export PATH="/opt/homebrew/bin:$PATH"
DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$DIR/../lancamento/anuncio-video-story.mp4"
HTMLD=$(mktemp -d); PNGD=$(mktemp -d)

N=60          # frames do preenchimento
FPS=12        # 60/12 = 5s de fill
HOLD=30       # frames repetidos do final = 2.5s parado no CTA

# 1. HTML determinístico por frame (progresso p in [0,1])
python3 "$DIR/gerar-video-fill.py" batch >/dev/null
cp /tmp/fillframes/*.html "$HTMLD/" 2>/dev/null || true

# 2. screenshot de cada frame
i=0
for f in $(ls "$HTMLD"/f*.html | sort); do
  printf -v n "%03d" "$i"
  "$CHROME" --headless=new --disable-gpu --screenshot="$PNGD/frame-$n.png" \
    --window-size=1080,1920 --hide-scrollbars "file://$f" 2>/dev/null
  i=$((i+1))
done

# 3. segura o frame final (CTA) por HOLD frames
last=$(printf "%03d" $((N-1)))
for h in $(seq 1 "$HOLD"); do
  printf -v n "%03d" $((N-1+h))
  cp "$PNGD/frame-$last.png" "$PNGD/frame-$n.png"
done

# 4. monta o vídeo
ffmpeg -y -framerate "$FPS" -i "$PNGD/frame-%03d.png" \
  -r 30 -pix_fmt yuv420p -movflags +faststart -an "$OUT" 2>&1 | tail -2

rm -rf "$HTMLD" "$PNGD"
echo "✓ $OUT ($(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUT")s)"
