#!/usr/bin/env python3
"""Gera frames HTML de um reel narrado (devocional, orgânico) com fill dourado.
Rodapé de marca suave (sem CTA de download — app ainda em teste fechado).
Uso: python3 gerar-reel-narrado.py <num> <n_frames>  -> /tmp/reelframes/f###.html"""
import sys, os, html as H

PSALMS = {
    121: dict(titulo="O Senhor, Nosso Guardião", chip="Esperança", cor="#7C90F0",
              linhas=["Elevo os meus olhos para os montes;",
                      "de onde me vem o socorro?",
                      "O meu socorro vem do Senhor,",
                      "que fez os céus e a terra."]),
    100: dict(titulo="Louvai ao Senhor", chip="Gratidão", cor="#E2B95C",
              linhas=["Celebrai com júbilo ao Senhor,",
                      "todos os habitantes da terra.",
                      "Servi ao Senhor com alegria,",
                      "e apresentai-vos com cântico."]),
}


def head(num, p):
    ps = PSALMS[num]
    lens = [len(l) for l in ps["linhas"]]
    total = sum(lens)
    filled = p * total
    before = 0
    rows = []
    for i, line in enumerate(ps["linhas"]):
        local = max(0.0, min(1.0, (filled - before) / lens[i]))
        before += lens[i]
        right = round((1 - local) * 100, 2)
        esc = H.escape(line)
        rows.append(
            f'    <div class="line"><span class="dim">{esc}</span>'
            f'<span class="lit" style="clip-path:inset(0 {right}% 0 0)">{esc}</span></div>'
        )
    return f"""<!DOCTYPE html><html><head><meta charset="UTF-8">
<link href="https://fonts.googleapis.com/css2?family=Cormorant:ital,wght@1,400&family=Playfair+Display:ital,wght@0,600;1,600&family=Instrument+Sans:wght@400;500;600&display=swap" rel="stylesheet">
<style>
*{{margin:0;padding:0;box-sizing:border-box;}}
body{{width:1080px;height:1920px;overflow:hidden;}}
.ad{{width:1080px;height:1920px;position:relative;background:radial-gradient(120% 70% at 50% 0%,#182a6e 0%,#10142C 40%,#080B1C 100%);}}
.bookmark{{position:absolute;top:0;left:50%;transform:translateX(-50%);width:34px;height:50px;background:#5567EA;opacity:.85;clip-path:polygon(0 0,100% 0,100% 100%,50% 70%,0 100%);}}
.top{{position:absolute;top:180px;left:80px;right:80px;text-align:center;}}
.eyebrow{{font-family:'Instrument Sans',sans-serif;font-weight:600;font-size:24px;letter-spacing:6px;text-transform:uppercase;color:#FFFFFF;opacity:.38;margin-bottom:30px;}}
.psalm{{font-family:'Playfair Display',serif;font-weight:600;font-size:96px;line-height:1;letter-spacing:-.01em;color:#EEF0FC;}}
.psalm em{{font-style:italic;color:#5567EA;}}
.sub{{font-family:'Instrument Sans',sans-serif;font-weight:400;font-size:30px;color:#8C97D4;margin-top:26px;letter-spacing:.3px;}}
.reader{{position:absolute;top:820px;left:96px;right:96px;}}
.line{{position:relative;margin-bottom:40px;white-space:nowrap;}}
.dim,.lit{{font-family:'Cormorant',serif;font-style:italic;font-weight:400;font-size:54px;line-height:1.2;}}
.dim{{color:#8C97D4;opacity:.30;}}
.lit{{position:absolute;top:0;left:0;color:#C4A86A;}}
.bottom{{position:absolute;left:0;right:0;bottom:150px;text-align:center;}}
.chip{{display:inline-block;font-family:'Instrument Sans',sans-serif;font-weight:500;font-size:24px;border:1px solid {ps['cor']}55;background:{ps['cor']}1f;color:{ps['cor']};border-radius:999px;padding:11px 30px;margin-bottom:30px;}}
.brand{{font-family:'Instrument Sans',sans-serif;font-weight:500;font-size:26px;color:#C4A86A;opacity:.85;letter-spacing:.5px;}}
</style></head><body>
<div class="ad">
  <div class="bookmark"></div>
  <div class="top">
    <div class="eyebrow">O Meu Salmo</div>
    <div class="psalm">Salmo <em>{num}</em></div>
    <div class="sub">{ps['titulo']}</div>
  </div>
  <div class="reader">
{chr(10).join(rows)}
  </div>
  <div class="bottom">
    <div class="chip">{ps['chip']}</div><br>
    <div class="brand">omeusalmo.com.br</div>
  </div>
</div></body></html>"""


if __name__ == "__main__":
    num = int(sys.argv[1]); N = int(sys.argv[2]) if len(sys.argv) > 2 else 40
    os.makedirs("/tmp/reelframes", exist_ok=True)
    for f in os.listdir("/tmp/reelframes"):
        os.remove(f"/tmp/reelframes/{f}")
    for k in range(N):
        open(f"/tmp/reelframes/f{k:03d}.html", "w").write(head(num, k / (N - 1)))
    print(f"Salmo {num}: {N} frames")
