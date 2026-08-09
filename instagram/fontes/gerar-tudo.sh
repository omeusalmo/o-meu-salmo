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
shot "$DIR/cards/dia-01-domingo-esperanca.html" "$FILA/01-dom-card-esperanca/post.png"  1080,1350
shot "$DIR/cards/dia-03-terca-ansiedade.html"   "$FILA/03-sex-card-ansiedade/post.png"  1080,1350
shot "$DIR/cards/dia-05-quinta-sono.html"       "$FILA/04-dom-card-sono/post.png"       1080,1350
shot "$DIR/cards/dia-02-segunda-gratidao.html"  "$FILA/06-sex-card-gratidao/post.png"   1080,1350
shot "$DIR/cards/dia-04-quarta-perdao.html"     "$FILA/07-dom-card-perdao/post.png"     1080,1350
shot "$DIR/cards/dia-06-sexta-louvor.html"      "$FILA/09-sex-card-louvor/post.png"     1080,1350
shot "$DIR/cards/dia-07-sabado-protecao.html"   "$FILA/10-dom-card-protecao/post.png"   1080,1350
shot "$DIR/cards/tema-ansiedade-salmo-46.html"  "$FILA/13-sex-card-ansiedade/post.png"  1080,1350
shot "$DIR/cards/tema-luto-salmo-34.html"       "$FILA/14-dom-card-luto/post.png"       1080,1350
shot "$DIR/cards/tema-gratidao-salmo-103.html"  "$FILA/17-dom-card-gratidao/post.png"   1080,1350
shot "$DIR/cards/tema-sono-salmo-127.html"      "$FILA/18-qua-card-sono/post.png"       1080,1350
shot "$DIR/cards/tema-esperanca-salmo-27.html"  "$FILA/20-dom-card-esperanca/post.png"  1080,1350

# especial (post 11, 4:5)
# especial (post 11, carrossel 6 slides 4:5, mesmo sistema visual do kit de ads)
for f in "$DIR"/carrossel-lancamento/*.html; do
  shot "$f" "$FILA/11-especial-lancamento-producao/$(basename "${f%.html}").png" 1080,1350
done

# founder (4:5)
shot "$DIR/founder/founder-por-que-fiz.html"        "$FILA/16-sex-founder-por-que-fiz/post.png"         1080,1350
shot "$DIR/founder/founder-gratis-sem-anuncio.html"  "$FILA/19-sex-founder-gratis-sem-anuncio/post.png"  1080,1350

# carrossel do app (post 00, 4:5)
for f in "$DIR"/carrossel-app/*.html; do
  shot "$f" "$FILA/00-pin-carrossel-app/$(basename "${f%.html}").png" 1080,1350
done

# carrossel ansiedade (post 05, 4:5)
for f in "$DIR"/carrossel-ansiedade/*.html; do
  shot "$f" "$FILA/05-qua-carrossel-ansiedade/$(basename "${f%.html}").png" 1080,1350
done

# carrossel como funciona (post 15, 4:5)
for f in "$DIR"/carrossel-como-funciona/*.html; do
  shot "$f" "$FILA/15-qua-carrossel-como-funciona/$(basename "${f%.html}").png" 1080,1350
done

# reels (9:16)
shot "$DIR/reels/reel-salmo-23.html"  "$FILA/02-qua-reel-salmo-23/fundo.png"   1080,1920
shot "$DIR/reels/reel-salmo-121.html" "$FILA/08-qua-reel-salmo-121/fundo.png"  1080,1920
shot "$DIR/reels/reel-salmo-42.html"  "$FILA/12-qua-reel-salmo-42/fundo.png"   1080,1920

echo "Fila atualizada: $FILA"
