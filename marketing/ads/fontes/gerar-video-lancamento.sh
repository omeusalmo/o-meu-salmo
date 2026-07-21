#!/bin/bash
# Gera o vídeo de lançamento (Salmo 23 sendo lido, teleprompter mudo) a partir
# dos 5 estados HTML em fontes/video-frames/ (4 leitura + 1 outro/CTA).
# Requer ffmpeg (brew install ffmpeg).
# Uso: cd marketing/ads/fontes && ./gerar-video-lancamento.sh

set -e
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
export PATH="/opt/homebrew/bin:$PATH"
DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$DIR/../lancamento/anuncio-video-story.mp4"
TMP=$(mktemp -d)

for i in 0 1 2 3 4; do
  "$CHROME" --headless=new --disable-gpu --screenshot="$TMP/state-$i.png" \
    --window-size=1080,1920 --hide-scrollbars \
    "file://$DIR/video-frames/state-$i.html" 2>/dev/null
done

D=1.8       # segundos por linha lida (leitura, estados 0-3)
T=0.5       # duração do crossfade
OUTRO=3.2   # segundos que o frame final (headline + CTA) fica parado

O1=$(echo "1 * ($D - $T)" | bc)
O2=$(echo "2 * ($D - $T)" | bc)
O3=$(echo "3 * ($D - $T)" | bc)
O4=$(echo "$O3 + ($D - $T)" | bc)
TOTAL=$(echo "$O4 + $OUTRO" | bc)

INPUTS=""; for i in 0 1 2 3 4; do INPUTS="$INPUTS -loop 1 -t 14 -i $TMP/state-$i.png"; done

ffmpeg -y $INPUTS -filter_complex "\
[0][1]xfade=transition=fade:duration=$T:offset=$O1[v1];\
[v1][2]xfade=transition=fade:duration=$T:offset=$O2[v2];\
[v2][3]xfade=transition=fade:duration=$T:offset=$O3[v3];\
[v3][4]xfade=transition=fade:duration=$T:offset=$O4[vout]" \
  -map "[vout]" -t "$TOTAL" -r 30 -pix_fmt yuv420p -movflags +faststart -an "$OUT" 2>&1 | tail -3

rm -rf "$TMP"
echo "✓ $OUT ($(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUT")s)"
