const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const OUT = path.join(__dirname, 'carrossel-ansiedade');

const slides = [
  {
    name: 'slide-01-hook',
    html: `<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;1,300;1,400&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body { width:1080px; height:1080px; overflow:hidden; }
.slide {
  width:1080px; height:1080px;
  background: linear-gradient(160deg, #0A1628 0%, #0E1F3E 50%, #1A3A6E 100%);
  display:flex; flex-direction:column;
  align-items:center; justify-content:center;
  padding:90px;
  position:relative;
}
.tag {
  font-family:'DM Sans', sans-serif;
  font-size:13px; font-weight:500;
  letter-spacing:3px; text-transform:uppercase;
  color:#A78BFA; opacity:0.9;
  margin-bottom:40px;
}
.headline {
  font-family:'Cormorant Garamond', serif;
  font-size:58px; font-weight:300; font-style:italic;
  color:#FFFFFF; line-height:1.25;
  text-align:center;
}
.headline em { font-style:normal; font-weight:400; color:#A78BFA; }
.swipe {
  position:absolute; bottom:60px;
  font-family:'DM Sans', sans-serif;
  font-size:13px; font-weight:300;
  color:#FFFFFF; opacity:0.3;
  letter-spacing:2px;
}
.logo {
  position:absolute; top:50px; left:60px;
  font-family:'DM Sans', sans-serif;
  font-size:12px; font-weight:500;
  color:#FFFFFF; opacity:0.25;
  letter-spacing:1px; text-transform:uppercase;
}
.deco {
  width:40px; height:1px;
  background:#A78BFA; opacity:0.5;
  margin: 0 auto 40px;
}
</style></head><body>
<div class="slide">
  <div class="logo">O Meu Salmo</div>
  <div class="tag">Coleção Ansiedade</div>
  <div class="deco"></div>
  <div class="headline">Quando a ansiedade<br>aperta o peito…<br><em>há salmos escritos<br>exatamente para isso.</em></div>
  <div class="swipe">deslize →</div>
</div>
</body></html>`
  },
  {
    name: 'slide-02-salmo-94',
    html: `<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;1,300;1,400&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body { width:1080px; height:1080px; overflow:hidden; }
.slide {
  width:1080px; height:1080px;
  background: linear-gradient(160deg, #0A1628 0%, #0D1A36 60%, #12244A 100%);
  display:flex; flex-direction:column;
  align-items:center; justify-content:center;
  padding:100px;
  position:relative;
}
.num {
  font-family:'Cormorant Garamond', serif;
  font-size:160px; font-weight:300;
  color:#A78BFA; opacity:0.07;
  position:absolute; top:30px; right:50px;
  line-height:1;
}
.tag {
  font-family:'DM Sans', sans-serif;
  font-size:12px; font-weight:500;
  letter-spacing:3px; text-transform:uppercase;
  color:#A78BFA; opacity:0.7;
  margin-bottom:50px;
}
.verse {
  font-family:'Cormorant Garamond', serif;
  font-size:40px; font-weight:300; font-style:italic;
  color:#FFFFFF; line-height:1.5;
  text-align:center;
}
.ref {
  font-family:'DM Sans', sans-serif;
  font-size:13px; font-weight:300;
  color:#C9A96E; opacity:0.8;
  margin-top:50px; letter-spacing:1px;
}
.logo {
  position:absolute; bottom:50px;
  font-family:'DM Sans', sans-serif;
  font-size:11px; font-weight:500;
  color:#FFFFFF; opacity:0.2;
  letter-spacing:1px; text-transform:uppercase;
}
.line {
  width:30px; height:1px;
  background:#C9A96E; opacity:0.4;
  margin: 40px auto 0;
}
</style></head><body>
<div class="slide">
  <div class="num">94</div>
  <div class="tag">Ansiedade</div>
  <div class="verse">"Quando os meus pensamentos<br>se multiplicam dentro de mim,<br>o teu consolo alegra<br>a minha alma."</div>
  <div class="ref">Salmos 94:19</div>
  <div class="line"></div>
  <div class="logo">O Meu Salmo</div>
</div>
</body></html>`
  },
  {
    name: 'slide-03-salmo-46',
    html: `<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;1,300;1,400&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body { width:1080px; height:1080px; overflow:hidden; }
.slide {
  width:1080px; height:1080px;
  background: linear-gradient(160deg, #0A1628 0%, #0D1A36 60%, #12244A 100%);
  display:flex; flex-direction:column;
  align-items:center; justify-content:center;
  padding:100px;
  position:relative;
}
.num {
  font-family:'Cormorant Garamond', serif;
  font-size:160px; font-weight:300;
  color:#A78BFA; opacity:0.07;
  position:absolute; top:30px; right:50px; line-height:1;
}
.tag {
  font-family:'DM Sans', sans-serif;
  font-size:12px; font-weight:500;
  letter-spacing:3px; text-transform:uppercase;
  color:#A78BFA; opacity:0.7; margin-bottom:50px;
}
.verse {
  font-family:'Cormorant Garamond', serif;
  font-size:42px; font-weight:300; font-style:italic;
  color:#FFFFFF; line-height:1.5; text-align:center;
}
.ref {
  font-family:'DM Sans', sans-serif;
  font-size:13px; font-weight:300;
  color:#C9A96E; opacity:0.8;
  margin-top:50px; letter-spacing:1px;
}
.logo {
  position:absolute; bottom:50px;
  font-family:'DM Sans', sans-serif;
  font-size:11px; font-weight:500;
  color:#FFFFFF; opacity:0.2;
  letter-spacing:1px; text-transform:uppercase;
}
</style></head><body>
<div class="slide">
  <div class="num">46</div>
  <div class="tag">Ansiedade</div>
  <div class="verse">"Deus é o nosso refúgio<br>e fortaleza, socorro<br>bem presente nas<br>tribulações."</div>
  <div class="ref">Salmos 46:1</div>
  <div class="logo">O Meu Salmo</div>
</div>
</body></html>`
  },
  {
    name: 'slide-04-salmo-55',
    html: `<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;1,300;1,400&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body { width:1080px; height:1080px; overflow:hidden; }
.slide {
  width:1080px; height:1080px;
  background: linear-gradient(160deg, #0A1628 0%, #0D1A36 60%, #12244A 100%);
  display:flex; flex-direction:column;
  align-items:center; justify-content:center;
  padding:100px; position:relative;
}
.num {
  font-family:'Cormorant Garamond', serif;
  font-size:160px; font-weight:300;
  color:#A78BFA; opacity:0.07;
  position:absolute; top:30px; right:50px; line-height:1;
}
.tag {
  font-family:'DM Sans', sans-serif;
  font-size:12px; font-weight:500;
  letter-spacing:3px; text-transform:uppercase;
  color:#A78BFA; opacity:0.7; margin-bottom:50px;
}
.verse {
  font-family:'Cormorant Garamond', serif;
  font-size:46px; font-weight:300; font-style:italic;
  color:#FFFFFF; line-height:1.5; text-align:center;
}
.ref {
  font-family:'DM Sans', sans-serif;
  font-size:13px; font-weight:300;
  color:#C9A96E; opacity:0.8;
  margin-top:50px; letter-spacing:1px;
}
.logo {
  position:absolute; bottom:50px;
  font-family:'DM Sans', sans-serif;
  font-size:11px; font-weight:500;
  color:#FFFFFF; opacity:0.2;
  letter-spacing:1px; text-transform:uppercase;
}
</style></head><body>
<div class="slide">
  <div class="num">55</div>
  <div class="tag">Ansiedade</div>
  <div class="verse">"Lança o teu peso<br>sobre o Senhor,<br>e ele te sustentará."</div>
  <div class="ref">Salmos 55:22</div>
  <div class="logo">O Meu Salmo</div>
</div>
</body></html>`
  },
  {
    name: 'slide-05-salmo-121',
    html: `<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;1,300;1,400&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body { width:1080px; height:1080px; overflow:hidden; }
.slide {
  width:1080px; height:1080px;
  background: linear-gradient(160deg, #0A1628 0%, #0D1A36 60%, #12244A 100%);
  display:flex; flex-direction:column;
  align-items:center; justify-content:center;
  padding:100px; position:relative;
}
.num {
  font-family:'Cormorant Garamond', serif;
  font-size:160px; font-weight:300;
  color:#A78BFA; opacity:0.07;
  position:absolute; top:30px; right:50px; line-height:1;
}
.tag {
  font-family:'DM Sans', sans-serif;
  font-size:12px; font-weight:500;
  letter-spacing:3px; text-transform:uppercase;
  color:#A78BFA; opacity:0.7; margin-bottom:50px;
}
.verse {
  font-family:'Cormorant Garamond', serif;
  font-size:44px; font-weight:300; font-style:italic;
  color:#FFFFFF; line-height:1.5; text-align:center;
}
.ref {
  font-family:'DM Sans', sans-serif;
  font-size:13px; font-weight:300;
  color:#C9A96E; opacity:0.8;
  margin-top:50px; letter-spacing:1px;
}
.logo {
  position:absolute; bottom:50px;
  font-family:'DM Sans', sans-serif;
  font-size:11px; font-weight:500;
  color:#FFFFFF; opacity:0.2;
  letter-spacing:1px; text-transform:uppercase;
}
</style></head><body>
<div class="slide">
  <div class="num">121</div>
  <div class="tag">Ansiedade</div>
  <div class="verse">"O meu socorro vem<br>do Senhor, que fez<br>o céu e a terra."</div>
  <div class="ref">Salmos 121:2</div>
  <div class="logo">O Meu Salmo</div>
</div>
</body></html>`
  },
  {
    name: 'slide-06-salmo-62',
    html: `<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;1,300;1,400&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body { width:1080px; height:1080px; overflow:hidden; }
.slide {
  width:1080px; height:1080px;
  background: linear-gradient(160deg, #0A1628 0%, #0D1A36 60%, #12244A 100%);
  display:flex; flex-direction:column;
  align-items:center; justify-content:center;
  padding:100px; position:relative;
}
.num {
  font-family:'Cormorant Garamond', serif;
  font-size:160px; font-weight:300;
  color:#A78BFA; opacity:0.07;
  position:absolute; top:30px; right:50px; line-height:1;
}
.tag {
  font-family:'DM Sans', sans-serif;
  font-size:12px; font-weight:500;
  letter-spacing:3px; text-transform:uppercase;
  color:#A78BFA; opacity:0.7; margin-bottom:50px;
}
.verse {
  font-family:'Cormorant Garamond', serif;
  font-size:44px; font-weight:300; font-style:italic;
  color:#FFFFFF; line-height:1.5; text-align:center;
}
.ref {
  font-family:'DM Sans', sans-serif;
  font-size:13px; font-weight:300;
  color:#C9A96E; opacity:0.8;
  margin-top:50px; letter-spacing:1px;
}
.logo {
  position:absolute; bottom:50px;
  font-family:'DM Sans', sans-serif;
  font-size:11px; font-weight:500;
  color:#FFFFFF; opacity:0.2;
  letter-spacing:1px; text-transform:uppercase;
}
</style></head><body>
<div class="slide">
  <div class="num">62</div>
  <div class="tag">Ansiedade</div>
  <div class="verse">"Descansa só em Deus,<br>ó minha alma, porque<br>d'Ele vem a minha<br>esperança."</div>
  <div class="ref">Salmos 62:5</div>
  <div class="logo">O Meu Salmo</div>
</div>
</body></html>`
  },
  {
    name: 'slide-07-cta',
    html: `<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;1,300;1,400&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body { width:1080px; height:1080px; overflow:hidden; }
.slide {
  width:1080px; height:1080px;
  background: linear-gradient(160deg, #0E1F3E 0%, #1A3A6E 60%, #1E4080 100%);
  display:flex; flex-direction:column;
  align-items:center; justify-content:center;
  padding:100px; position:relative;
}
.tag {
  font-family:'DM Sans', sans-serif;
  font-size:12px; font-weight:500;
  letter-spacing:3px; text-transform:uppercase;
  color:#A78BFA; opacity:0.8; margin-bottom:50px;
}
.deco { width:40px; height:1px; background:#A78BFA; opacity:0.4; margin:0 auto 50px; }
.title {
  font-family:'Cormorant Garamond', serif;
  font-size:52px; font-weight:300; font-style:italic;
  color:#FFFFFF; line-height:1.3; text-align:center;
  margin-bottom:60px;
}
.features {
  display:flex; flex-direction:column; gap:18px;
  align-items:center;
}
.feature {
  font-family:'DM Sans', sans-serif;
  font-size:16px; font-weight:300;
  color:#FFFFFF; opacity:0.7;
  letter-spacing:1px;
}
.sep { color:#A78BFA; opacity:0.4; margin: 0 12px; }
.url {
  margin-top:60px;
  font-family:'DM Sans', sans-serif;
  font-size:14px; font-weight:400;
  color:#C9A96E; opacity:0.8;
  letter-spacing:2px;
}
.brand {
  margin-top:16px;
  font-family:'DM Sans', sans-serif;
  font-size:11px; font-weight:500;
  color:#FFFFFF; opacity:0.25;
  letter-spacing:2px; text-transform:uppercase;
}
</style></head><body>
<div class="slide">
  <div class="tag">O Meu Salmo</div>
  <div class="deco"></div>
  <div class="title">150 Salmos.<br>8 emoções.<br>Narração em áudio.</div>
  <div class="features">
    <div class="feature">Ansiedade <span class="sep">·</span> Sono <span class="sep">·</span> Gratidão <span class="sep">·</span> Luto</div>
    <div class="feature">Esperança <span class="sep">·</span> Perdão <span class="sep">·</span> Louvor <span class="sep">·</span> Proteção</div>
  </div>
  <div class="url">omeusalmo.com.br</div>
  <div class="brand">Gratuito · Android</div>
</div>
</body></html>`
  }
];

slides.forEach(({ name, html }) => {
  const htmlPath = path.join(OUT, `${name}.html`);
  const pngPath = path.join(OUT, `${name}.png`);
  fs.writeFileSync(htmlPath, html);
  try {
    execSync(`"${CHROME}" --headless=new --disable-gpu --screenshot="${pngPath}" --window-size=1080,1080 --hide-scrollbars "file://${htmlPath}" 2>/dev/null`, { timeout: 15000 });
    console.log(`✓ ${name}.png`);
  } catch (e) {
    console.error(`✗ ${name}: ${e.message}`);
  }
});
console.log(`\nSalvo em: ${OUT}`);
