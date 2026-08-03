#!/usr/bin/env python3
"""Gera o frame HTML de um reel narrado no estilo DEVOCIONAL (igual ao
02-qua-reel-salmo-23/meupastor.mp4): versículo único centralizado, tag da
emoção, número fantasma, "ouça com o som ligado". Estático + narração muxada.
SEM headline de posicionamento, SEM chips, SEM CTA de download (é post
compartilhado como os outros, não anúncio).
Uso: python3 gerar-reel-narrado.py <num>  -> escreve /tmp/reel-frame.html"""
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


def frame_html(num):
    emo, cor, verse = PSALMS[num]
    return f"""<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<link href="https://fonts.googleapis.com/css2?family=Cormorant:ital,wght@0,300;1,300;1,400&family=Instrument+Sans:wght@400;500&display=swap" rel="stylesheet">
<style>
*{{margin:0;padding:0;box-sizing:border-box;}}
body{{width:1080px;height:1920px;overflow:hidden;}}
.slide{{width:1080px;height:1920px;background:linear-gradient(165deg,#080B1C 0%,#10142C 45%,#141a38 75%,#22307c 100%);display:flex;flex-direction:column;align-items:center;justify-content:center;padding:220px 90px 300px;position:relative;}}
.watermark{{font-family:'Cormorant',serif;font-size:520px;font-weight:300;color:{cor};opacity:0.06;position:absolute;bottom:-80px;right:-30px;line-height:1;letter-spacing:-24px;}}
.accent-bar{{position:absolute;top:0;left:0;right:0;height:4px;background:linear-gradient(90deg,transparent 0%,{cor} 40%,{cor} 60%,transparent 100%);opacity:0.5;}}
.bookmark{{position:absolute;top:0;left:50%;transform:translateX(-50%);width:34px;height:50px;background:#5567EA;clip-path:polygon(0 0,100% 0,100% 100%,50% 70%,0 100%);opacity:0.9;}}
.logo{{position:absolute;top:200px;left:0;right:0;text-align:center;font-family:'Instrument Sans',sans-serif;font-size:26px;font-weight:500;color:#FFFFFF;opacity:0.3;letter-spacing:6px;text-transform:uppercase;}}
.tag{{font-family:'Instrument Sans',sans-serif;font-size:26px;font-weight:500;letter-spacing:8px;text-transform:uppercase;color:{cor};opacity:0.95;margin-bottom:52px;}}
.deco{{width:70px;height:2px;background:linear-gradient(90deg,transparent,{cor},transparent);opacity:0.5;margin:0 auto 52px;}}
.verse{{font-family:'Cormorant',serif;font-size:66px;font-weight:300;font-style:italic;color:#FFFFFF;line-height:1.5;text-align:center;max-width:920px;}}
.refwrap{{margin-top:64px;display:flex;flex-direction:column;align-items:center;gap:14px;}}
.refline{{width:36px;height:2px;background:#C4A86A;opacity:0.45;}}
.ref{{font-family:'Instrument Sans',sans-serif;font-size:28px;font-weight:400;color:#C4A86A;opacity:0.9;letter-spacing:3px;}}
.cue{{position:absolute;bottom:230px;left:0;right:0;text-align:center;font-family:'Instrument Sans',sans-serif;font-size:24px;font-weight:400;color:#FFFFFF;opacity:0.4;letter-spacing:2px;}}
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
    open("/tmp/reel-frame.html", "w").write(frame_html(num))
    print(f"Salmo {num}: frame devocional gerado")
