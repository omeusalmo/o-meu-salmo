#!/usr/bin/env python3
"""Gera o frame HTML de um reel narrado no estilo DEVOCIONAL (igual ao
02-qua-reel-salmo-23/meupastor.mp4): versículo único centralizado, tag da
emoção, número fantasma, "ouça com o som ligado". Estático + narração muxada.
SEM headline de posicionamento, SEM chips, SEM CTA de download (é post
compartilhado como os outros, não anúncio).
Uso: python3 gerar-reel-narrado.py <num> [9x16|4x5]  -> escreve /tmp/reel-frame.html
4x5 (1080x1350) é o formato do feed do Instagram/Facebook — o composer da Meta
rejeita 9:16 fora do Reels (aceita só de 4:5 a 16:9)."""
import sys

# num: (emoção, cor de acento, versículo com <br>, ref)
PSALMS = {
    121: ("Esperança", "#7C90F0",
          '"O meu socorro vem do Senhor,<br>que fez os céus e a terra."'),
    100: ("Gratidão", "#E2B95C",
          '"Servi ao Senhor com alegria,<br>e apresentai-vos a ele com cântico."'),
    4:   ("Sono", "#8FC287",
          '"Em paz me deitarei e dormirei,<br>porque só tu, Senhor,<br>me fazes habitar em segurança."'),
    150: ("Louvor", "#E2B95C",
          '"Tudo quanto tem fôlego<br>louve ao Senhor."'),
    23:  ("Esperança", "#7C90F0",
          '"O Senhor é o meu pastor;<br>nada me faltará."'),
}

# formato: (altura, padding do slide, top do logo, bottom do cue, tamanho da
# marca d'água, bottom da marca d'água, gap tag/deco). Largura é sempre 1080.
LAYOUTS = {
    "9x16": (1920, "220px 90px 300px", 200, 230, 520, -80, 52),
    "4x5":  (1350, "150px 90px 190px", 120, 120, 400, -60, 44),
}


def frame_html(num, fmt="9x16"):
    emo, cor, verse = PSALMS[num]
    h, pad, logo_top, cue_bottom, wm_size, wm_bottom, gap = LAYOUTS[fmt]
    return f"""<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<link href="https://fonts.googleapis.com/css2?family=Cormorant:ital,wght@0,300;1,300;1,400&family=Instrument+Sans:wght@400;500&display=swap" rel="stylesheet">
<style>
*{{margin:0;padding:0;box-sizing:border-box;}}
body{{width:1080px;height:{h}px;overflow:hidden;}}
.slide{{width:1080px;height:{h}px;background:linear-gradient(165deg,#080B1C 0%,#10142C 45%,#141a38 75%,#22307c 100%);display:flex;flex-direction:column;align-items:center;justify-content:center;padding:{pad};position:relative;}}
.watermark{{font-family:'Cormorant',serif;font-size:{wm_size}px;font-weight:300;color:{cor};opacity:0.06;position:absolute;bottom:{wm_bottom}px;right:-30px;line-height:1;letter-spacing:-24px;}}
.accent-bar{{position:absolute;top:0;left:0;right:0;height:4px;background:linear-gradient(90deg,transparent 0%,{cor} 40%,{cor} 60%,transparent 100%);opacity:0.5;}}
.bookmark{{position:absolute;top:0;left:50%;transform:translateX(-50%);width:34px;height:50px;background:#5567EA;clip-path:polygon(0 0,100% 0,100% 100%,50% 70%,0 100%);opacity:0.9;}}
.logo{{position:absolute;top:{logo_top}px;left:0;right:0;text-align:center;font-family:'Instrument Sans',sans-serif;font-size:26px;font-weight:500;color:#FFFFFF;opacity:0.3;letter-spacing:6px;text-transform:uppercase;}}
.tag{{font-family:'Instrument Sans',sans-serif;font-size:26px;font-weight:500;letter-spacing:8px;text-transform:uppercase;color:{cor};opacity:0.95;margin-bottom:{gap}px;}}
.deco{{width:70px;height:2px;background:linear-gradient(90deg,transparent,{cor},transparent);opacity:0.5;margin:0 auto {gap}px;}}
.verse{{font-family:'Cormorant',serif;font-size:66px;font-weight:300;font-style:italic;color:#FFFFFF;line-height:1.5;text-align:center;max-width:920px;}}
.refwrap{{margin-top:64px;display:flex;flex-direction:column;align-items:center;gap:14px;}}
.refline{{width:36px;height:2px;background:#C4A86A;opacity:0.45;}}
.ref{{font-family:'Instrument Sans',sans-serif;font-size:28px;font-weight:400;color:#C4A86A;opacity:0.9;letter-spacing:3px;}}
.cue{{position:absolute;bottom:{cue_bottom}px;left:0;right:0;text-align:center;font-family:'Instrument Sans',sans-serif;font-size:24px;font-weight:400;color:#FFFFFF;opacity:0.4;letter-spacing:2px;}}
</style></head><body>
<div class="slide">
  <div class="bookmark"></div>
  <div class="accent-bar"></div>
  <div class="watermark">{num}</div>
  <div class="logo">O Meu Salmo</div>
  <div class="tag">{emo}</div>
  <div class="deco"></div>
  <div class="verse">{verse}</div>
  <div class="refwrap"><div class="refline"></div><div class="ref">Salmos {num} · narração do app</div></div>
  <div class="cue">ouça com o som ligado</div>
</div></body></html>"""


if __name__ == "__main__":
    num = int(sys.argv[1])
    fmt = sys.argv[2] if len(sys.argv) > 2 else "9x16"
    open("/tmp/reel-frame.html", "w").write(frame_html(num, fmt))
    print(f"Salmo {num}: frame devocional gerado ({fmt})")
