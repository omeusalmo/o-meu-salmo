const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

// Sistema visual v2 — extraído de docs/v2/index.html
const V2 = {
  nightBase: '#080B1C',
  nightPlus: '#10142C',
  nightLine: '#1E2348',
  muted: '#7080C8',
  text: '#8C97D4',
  cream: '#EEF0FC',
  gold: '#C4A86A',
  cobalt: '#2A47DD',
  cobaltLt: '#5567EA',
};

const EMO = {
  ansiedade:  { dot: '#5567EA', tagline: 'Para a mente que não para de pensar.' },
  sono:       { dot: '#6A9A62', tagline: 'Para a noite que custa a passar.' },
  gratidao:   { dot: '#C99A38', tagline: 'Para a alegria que pede voz.' },
  luto:       { dot: '#9A6A86', tagline: 'Para a saudade que ainda pesa.' },
  esperanca:  { dot: '#2A47DD', tagline: 'Para o amanhã que parece distante.' },
  perdao:     { dot: '#8480AA', tagline: 'Para o peso que precisa de descanso.' },
  louvor:     { dot: '#C99A38', tagline: 'Para o coração que quer celebrar.' },
  protecao:   { dot: '#6A9A62', tagline: 'Para os dias de medo.' },
};

const GRAIN = `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='300' height='300'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='300' height='300' filter='url(%23n)' opacity='1'/%3E%3C/svg%3E")`;

const FONTS = `<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,500;1,400&family=Cormorant:ital,wght@0,300;0,400;0,500;1,300;1,400&family=Instrument+Sans:ital,wght@0,300;0,400;0,500;1,300&display=swap" rel="stylesheet">`;

function base(content, extra = '') {
  return `<!DOCTYPE html>
<html><head><meta charset="UTF-8">${FONTS}
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body { width:1080px; height:1080px; overflow:hidden; background:${V2.nightBase}; }
.slide {
  width:1080px; height:1080px; position:relative;
  background: linear-gradient(165deg, ${V2.nightBase} 0%, ${V2.nightPlus} 70%, #131838 100%);
  display:flex; flex-direction:column; align-items:center; justify-content:center;
  padding:110px;
}
.slide::after {
  content:''; position:absolute; inset:0; pointer-events:none;
  background-image:${GRAIN}; opacity:0.05;
}
.emo-row { display:flex; align-items:center; gap:14px; margin-bottom:26px; }
.dot { width:9px; height:9px; border-radius:50%; }
.colecao {
  font-family:'Instrument Sans', sans-serif;
  font-size:14px; font-weight:500;
  letter-spacing:4px; text-transform:uppercase;
  color:${V2.text};
}
.tagline {
  font-family:'Cormorant', serif;
  font-size:26px; font-weight:300; font-style:italic;
  color:${V2.muted};
  margin-bottom:64px; text-align:center;
}
.verse {
  font-family:'Cormorant', serif;
  font-weight:300; font-style:italic;
  color:${V2.cream}; line-height:1.45;
  text-align:center;
}
.ref {
  font-family:'Instrument Sans', sans-serif;
  font-size:15px; font-weight:300;
  color:${V2.gold};
  margin-top:56px; letter-spacing:2px;
}
.num {
  font-family:'Playfair Display', serif;
  font-size:300px; font-weight:400;
  position:absolute; top:-30px; right:30px;
  line-height:1; opacity:0.05;
}
.brand {
  position:absolute; bottom:56px; left:0; right:0;
  text-align:center;
  font-family:'Instrument Sans', sans-serif;
  font-size:13px; font-weight:300;
  color:${V2.cream}; opacity:0.32;
  letter-spacing:2px;
}
.brand .salmo { font-family:'Playfair Display', serif; font-style:italic; font-weight:500; letter-spacing:1px; }
${extra}
</style></head><body>${content}</body></html>`;
}

// Card padrão: post único de salmo
function salmoCard({ emo, colecao, num, verse, ref, verseSize = 46 }) {
  const e = EMO[emo];
  return base(`
<div class="slide">
  <div class="num" style="color:${e.dot}">${num}</div>
  <div class="emo-row"><span class="dot" style="background:${e.dot}"></span><span class="colecao">${colecao}</span></div>
  <div class="tagline">${e.tagline}</div>
  <div class="verse" style="font-size:${verseSize}px">${verse}</div>
  <div class="ref">${ref}</div>
  <div class="brand">O meu <span class="salmo">Salmo</span></div>
</div>`);
}

// ─── SEMANA 1 — posts únicos (salmos-âncora da LP) ───
const semana1 = [
  { name: 'dia-01-dom-esperanca', emo: 'esperanca', colecao: 'Esperança', num: '62',
    verse: '"Descansa só em Deus,<br>ó minha alma, porque<br>d\'Ele vem a minha<br>esperança."', ref: 'Salmo 62 · 5' },
  { name: 'dia-02-seg-gratidao', emo: 'gratidao', colecao: 'Gratidão', num: '100',
    verse: '"Servi ao Senhor<br>com alegria; entrai<br>diante dele com canto."', ref: 'Salmo 100 · 2' },
  { name: 'dia-03-ter-ansiedade', emo: 'ansiedade', colecao: 'Ansiedade', num: '94',
    verse: '"Quando os meus pensamentos<br>se multiplicam dentro de mim,<br>os teus consolos alegram<br>a minha alma."', ref: 'Salmo 94 · 19', verseSize: 42 },
  { name: 'dia-04-qua-perdao', emo: 'perdao', colecao: 'Perdão', num: '32',
    verse: '"Bem-aventurado aquele<br>cuja transgressão é perdoada,<br>e cujo pecado é coberto."', ref: 'Salmo 32 · 1', verseSize: 42 },
  { name: 'dia-05-qui-sono', emo: 'sono', colecao: 'Sono', num: '4',
    verse: '"Em paz me deito<br>e logo adormeço, pois só tu,<br>Senhor, me fazes habitar<br>em segurança."', ref: 'Salmo 4 · 8', verseSize: 42 },
  { name: 'dia-06-sex-louvor', emo: 'louvor', colecao: 'Louvor', num: '150',
    verse: '"Louvai ao Senhor.<br>Louvai a Deus<br>no seu santuário."', ref: 'Salmo 150 · 1' },
  { name: 'dia-07-sab-protecao', emo: 'protecao', colecao: 'Proteção', num: '91',
    verse: '"Aquele que habita<br>no esconderijo do Altíssimo,<br>à sombra do Onipotente<br>descansará."', ref: 'Salmo 91 · 1', verseSize: 42 },
];

// ─── CARROSSEL ANSIEDADE v2 ───
const e = EMO.ansiedade;

const carrosselHook = base(`
<div class="slide">
  <div class="emo-row"><span class="dot" style="background:${e.dot}"></span><span class="colecao">Coleção Ansiedade</span></div>
  <div class="verse" style="font-size:60px; margin-top:30px;">Para a mente<br>que não para<br>de pensar.</div>
  <div class="ref" style="color:${V2.muted}; margin-top:64px; font-style:italic; font-family:'Cormorant',serif; font-size:24px; letter-spacing:0;">cinco salmos para hoje</div>
  <div class="swipe">deslize →</div>
  <div class="brand">O meu <span class="salmo">Salmo</span></div>
</div>`, `
.swipe {
  position:absolute; bottom:110px;
  font-family:'Instrument Sans', sans-serif;
  font-size:14px; font-weight:300;
  color:${V2.cream}; opacity:0.3; letter-spacing:3px;
}`);

const carrosselVersos = [
  { name: 'slide-02-salmo-94', num: '94',
    verse: '"Quando os meus pensamentos<br>se multiplicam dentro de mim,<br>os teus consolos alegram<br>a minha alma."', ref: 'Salmo 94 · 19', verseSize: 42 },
  { name: 'slide-03-salmo-46', num: '46',
    verse: '"Deus é o nosso refúgio<br>e fortaleza, socorro<br>bem presente nas<br>tribulações."', ref: 'Salmo 46 · 1', verseSize: 44 },
  { name: 'slide-04-salmo-55', num: '55',
    verse: '"Lança o teu peso<br>sobre o Senhor,<br>e ele te sustentará."', ref: 'Salmo 55 · 22', verseSize: 48 },
  { name: 'slide-05-salmo-121', num: '121',
    verse: '"O meu socorro vem<br>do Senhor, que fez<br>o céu e a terra."', ref: 'Salmo 121 · 2', verseSize: 46 },
  { name: 'slide-06-salmo-62', num: '62',
    verse: '"Descansa só em Deus,<br>ó minha alma, porque<br>d\'Ele vem a minha<br>esperança."', ref: 'Salmo 62 · 5', verseSize: 44 },
];

function carrosselVerso({ num, verse, ref, verseSize }) {
  return base(`
<div class="slide">
  <div class="num" style="color:${e.dot}">${num}</div>
  <div class="emo-row"><span class="dot" style="background:${e.dot}"></span><span class="colecao">Ansiedade</span></div>
  <div class="verse" style="font-size:${verseSize}px; margin-top:30px;">${verse}</div>
  <div class="ref">${ref}</div>
  <div class="brand">O meu <span class="salmo">Salmo</span></div>
</div>`);
}

const carrosselCTA = base(`
<div class="slide">
  <div class="emo-row"><span class="dot" style="background:${e.dot}"></span><span class="colecao">O meu Salmo</span></div>
  <div class="verse" style="font-size:54px; margin-top:24px;">Há um Salmo<br>esperando por você.</div>
  <div class="feats">150 Salmos completos · 8 coleções por emoção<br>áudio narrado sem pressa · reflexão por Salmo</div>
  <div class="url">omeusalmo.com.br</div>
  <div class="meta">Gratuito · Android · Offline</div>
</div>`, `
.feats {
  margin-top:64px;
  font-family:'Instrument Sans', sans-serif;
  font-size:17px; font-weight:300;
  color:${V2.text}; line-height:2; text-align:center;
  letter-spacing:0.5px;
}
.url {
  margin-top:56px;
  font-family:'Instrument Sans', sans-serif;
  font-size:16px; font-weight:400;
  color:${V2.gold}; letter-spacing:2px;
}
.meta {
  margin-top:14px;
  font-family:'Instrument Sans', sans-serif;
  font-size:12px; font-weight:300;
  color:${V2.cream}; opacity:0.3; letter-spacing:3px; text-transform:uppercase;
}`);

// ─── GERAÇÃO ───
const jobs = [];
const dirS1 = path.join(__dirname, 'semana-1');
const dirCar = path.join(__dirname, 'carrossel-ansiedade');
fs.mkdirSync(dirS1, { recursive: true });
fs.mkdirSync(dirCar, { recursive: true });

semana1.forEach(s => jobs.push({ dir: dirS1, name: s.name, html: salmoCard(s) }));
jobs.push({ dir: dirCar, name: 'slide-01-hook', html: carrosselHook });
carrosselVersos.forEach(s => jobs.push({ dir: dirCar, name: s.name, html: carrosselVerso(s) }));
jobs.push({ dir: dirCar, name: 'slide-07-cta', html: carrosselCTA });

jobs.forEach(({ dir, name, html }) => {
  const htmlPath = path.join(dir, `${name}.html`);
  const pngPath = path.join(dir, `${name}.png`);
  fs.writeFileSync(htmlPath, html);
  try {
    execSync(`"${CHROME}" --headless=new --disable-gpu --virtual-time-budget=6000 --screenshot="${pngPath}" --window-size=1080,1080 --hide-scrollbars "file://${htmlPath}" 2>/dev/null`, { timeout: 40000 });
    console.log(`✓ ${path.basename(dir)}/${name}.png`);
  } catch (err) {
    console.error(`✗ ${name}: ${err.message}`);
  }
});
console.log('\nConcluído.');
