#!/bin/bash
# Gera TODOS os PNGs da fila-de-postagem a partir dos HTMLs em fontes/.
# Uso: cd instagram/fontes && ./gerar-tudo.sh
# PNG mora só na fila; aqui só HTML. Editar card → rodar isto.

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
DIR="$(cd "$(dirname "$0")" && pwd)"
FILA="$DIR/../fila-de-postagem"

shot() { # shot <html> <png-destino> <WxH>
  "$CHROME" --headless=new --disable-gpu --screenshot="$2" \
    --window-size="$3" --hide-scrollbars "file://$1" 2>/dev/null \
    && echo "✓ $(basename "$2")"
}

# cards (4:5) → posição na fila
shot "$DIR/cards/dia-01-domingo-esperanca.html" "$FILA/01-dom-card-esperanca.png"  1080,1350
shot "$DIR/cards/dia-03-terca-ansiedade.html"   "$FILA/03-sex-card-ansiedade.png"  1080,1350
shot "$DIR/cards/dia-05-quinta-sono.html"       "$FILA/04-dom-card-sono.png"       1080,1350
shot "$DIR/cards/dia-02-segunda-gratidao.html"  "$FILA/06-sex-card-gratidao.png"   1080,1350
shot "$DIR/cards/dia-04-quarta-perdao.html"     "$FILA/07-dom-card-perdao.png"     1080,1350
shot "$DIR/cards/dia-06-sexta-louvor.html"      "$FILA/09-sex-card-louvor.png"     1080,1350
shot "$DIR/cards/dia-07-sabado-protecao.html"   "$FILA/10-dom-card-protecao.png"   1080,1350

# carrossel do app (post 00, 4:5)
for f in "$DIR"/carrossel-app/*.html; do
  shot "$f" "$FILA/00-pin-carrossel-app/$(basename "${f%.html}").png" 1080,1350
done

# carrossel ansiedade (post 05, 4:5)
for f in "$DIR"/carrossel-ansiedade/*.html; do
  shot "$f" "$FILA/05-qua-carrossel-ansiedade/$(basename "${f%.html}").png" 1080,1350
done

# reels (9:16)
shot "$DIR/reels/reel-salmo-23.html"  "$FILA/02-qua-reel-salmo-23/fundo.png"   1080,1920
shot "$DIR/reels/reel-salmo-121.html" "$FILA/08-qua-reel-salmo-121/fundo.png"  1080,1920

echo "Fila atualizada: $FILA"
