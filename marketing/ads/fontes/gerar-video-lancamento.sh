#!/bin/bash
# Gera o vídeo de lançamento (Salmo 23 sendo lido, teleprompter mudo) a partir
# dos 6 estados HTML em fontes/video-frames/. Requer ffmpeg (brew install ffmpeg).
# Uso: cd marketing/ads/fontes && ./gerar-video-lancamento.sh

set -e
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
export PATH="/opt/homebrew/bin:$PATH"
DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$DIR/../lancamento/anuncio-video-story.mp4"
TMP=$(mktemp -d)

for i in 0 1 2 3 4 5; do
  "$CHROME" --headless=new --disable-gpu --screenshot="$TMP/state-$i.png" \
    --window-size=1080,1920 --hide-scrollbars \
    "file://$DIR/video-frames/state-$i.html" 2>/dev/null
done

D=1.8   # segundos que cada linha fica em foco (incluindo a transição)
T=0.5   # duração do crossfade
N=6
INPUTS=""; FILT=""; PREV=0
for i in $(seq 0 $((N-1))); do INPUTS="$INPUTS -loop 1 -t 14 -i $TMP/state-$i.png"; done
for i in $(seq 1 $((N-1))); do
  OFFSET=$(echo "$i * ($D - $T)" | bc)
  LABEL="v$i"; [ "$i" -eq $((N-1)) ] && LABEL="vout"
  FILT="$FILT[$PREV][$i]xfade=transition=fade:duration=$T:offset=$OFFSET[$LABEL];"
  PREV=$LABEL
done
FILT="${FILT%;}"
TOTAL=$(echo "($N-1) * ($D - $T) + $D" | bc)

ffmpeg -y $INPUTS -filter_complex "$FILT" -map "[vout]" -t "$TOTAL" \
  -r 30 -pix_fmt yuv420p -movflags +faststart -an "$OUT" 2>&1 | tail -3

rm -rf "$TMP"
echo "✓ $OUT ($(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUT")s)"
