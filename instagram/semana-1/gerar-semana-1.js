const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const DIR = __dirname;

const slides = [
  'dia-01-domingo-esperanca',
  'dia-02-segunda-gratidao',
  'dia-03-terca-ansiedade',
  'dia-04-quarta-perdao',
  'dia-05-quinta-sono',
  'dia-06-sexta-louvor',
  'dia-07-sabado-protecao',
];

slides.forEach((name) => {
  const htmlPath = path.join(DIR, `${name}.html`);
  const pngPath  = path.join(DIR, `${name}.png`);
  try {
    execSync(
      `"${CHROME}" --headless=new --disable-gpu --screenshot="${pngPath}" --window-size=1080,1080 --hide-scrollbars "file://${htmlPath}" 2>/dev/null`,
      { timeout: 15000 }
    );
    console.log(`✓ ${name}.png`);
  } catch (e) {
    console.error(`✗ ${name}: ${e.message}`);
  }
});

console.log(`\nSalvo em: ${DIR}`);
