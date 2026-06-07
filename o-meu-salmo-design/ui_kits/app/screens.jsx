/* Screens — Emoções, Coleção, Leitura */

function EmotionsScreen({ theme, onPick }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%', padding: '8px 22px 0' }}>
      <div style={{ marginTop: 18 }}>
        <EyebrowLabel>O meu Salmo</EyebrowLabel>
      </div>
      <h1 style={{ fontFamily: 'var(--font-display)', fontWeight: 400, fontSize: 38, lineHeight: 1.02, letterSpacing: '-.02em', color: 'var(--text-strong)', margin: '40px 0 8px' }}>
        Como você está<br />chegando hoje?
      </h1>
      <p style={{ fontFamily: 'var(--font-verse)', fontStyle: 'italic', fontSize: 17, color: 'var(--text-muted)', lineHeight: 1.5, marginBottom: 34 }}>
        Escolha um sentimento — eu encontro as palavras.
      </p>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 11 }}>
        {EMOTIONS.map(e => <EmotionChip key={e.id} emotion={e} large onClick={() => onPick(e)} />)}
      </div>
      <div style={{ flex: 1 }} />
      <div style={{ display: 'flex', justifyContent: 'center', paddingBottom: 22, opacity: .6 }}>
        <Logotype size={22} theme={theme} />
      </div>
    </div>
  );
}

const PSALMS = [
  { num: 46, title: 'Deus é o nosso refúgio', snippet: 'Aquietai-vos e sabei que eu sou Deus.' },
  { num: 23, title: 'O Senhor é o meu pastor', snippet: 'Nada me faltará; em verdes pastos me faz repousar.' },
  { num: 91, title: 'Aquele que habita', snippet: 'À sombra do Altíssimo descansarei.' },
  { num: 4, title: 'Em paz me deito', snippet: 'Em paz me deito e logo pego no sono.' },
];

function CollectionScreen({ emotion, onBack, onOpen, theme }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '6px 20px 14px' }}>
        <IconButton onClick={onBack}><span style={{ color: 'var(--text-muted)', fontSize: 16, marginTop: -2 }}>‹</span></IconButton>
        <EyebrowLabel color="var(--accent)">Para a {emotion.name.toLowerCase()}</EyebrowLabel>
      </div>
      <div style={{ padding: '0 22px' }}>
        <h2 style={{ fontFamily: 'var(--font-display)', fontWeight: 400, fontSize: 40, lineHeight: .95, letterSpacing: '-.02em', color: 'var(--text-strong)', margin: '4px 0 20px' }}>
          {PSALMS.length} Salmos<br />para esse momento
        </h2>
      </div>
      <div style={{ flex: 1, overflowY: 'auto', padding: '0 22px 22px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        {PSALMS.map(p => <PsalmCard key={p.num} num={p.num} title={p.title} snippet={p.snippet} onClick={() => onOpen(p)} />)}
      </div>
    </div>
  );
}

const VERSES = [
  'Deus é o nosso refúgio e fortaleza, socorro bem presente na angústia.',
  'Portanto não temeremos, ainda que a terra se mude.',
  'Há um rio cujas correntes alegram a cidade de Deus.',
  'Aquietai-vos e sabei que eu sou Deus.',
];

function ReadingScreen({ psalm, emotion, onBack, playing, onToggle }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '6px 20px 14px', borderBottom: '.5px solid var(--border)' }}>
        <IconButton onClick={onBack}><span style={{ color: 'var(--text-muted)', fontSize: 16, marginTop: -2 }}>‹</span></IconButton>
        <IconButton><span style={{ color: 'var(--text-muted)', fontSize: 13 }}>♡</span></IconButton>
      </div>
      <div style={{ flex: 1, overflowY: 'auto', padding: '18px 22px 8px' }}>
        <EyebrowLabel color="var(--accent)">Para a {emotion.name.toLowerCase()}</EyebrowLabel>
        <h1 style={{ fontFamily: 'var(--font-display)', fontWeight: 400, fontSize: 52, lineHeight: .88, letterSpacing: '-.025em', color: 'var(--text-strong)', margin: '6px 0 22px' }}>
          Salmo <span style={{ fontStyle: 'italic', color: 'var(--accent)' }}>{psalm.num}</span>
        </h1>
        {VERSES.map((v, i) => <VerseLine key={i} n={i + 1} active={i === 3}>{v}</VerseLine>)}
      </div>
      <AudioPlayer playing={playing} onToggle={onToggle} />
    </div>
  );
}

Object.assign(window, { EmotionsScreen, CollectionScreen, ReadingScreen, PSALMS, VERSES });
