/* O meu Salmo — UI Kit components (React + Babel inline)
   Exports to window at the end so index.html can use them. */

const PHONE = { width: 320, height: 660 };

/* ── Status bar ── */
function StatusBar({ theme }) {
  const c = theme === 'day' ? '#0C1230' : '#EEF0FC';
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 22px 4px', fontFamily: 'var(--font-ui)', fontSize: 12, fontWeight: 500, color: c }}>
      <span>9:41</span>
      <span style={{ display: 'flex', gap: 5, alignItems: 'center', opacity: .85 }}>
        <span style={{ fontSize: 10 }}>5G</span>
        <span style={{ width: 22, height: 11, border: `1px solid ${c}`, borderRadius: 3, display: 'inline-block', position: 'relative' }}>
          <span style={{ position: 'absolute', inset: 1.5, background: c, borderRadius: 1, width: '70%' }} />
        </span>
      </span>
    </div>
  );
}

/* ── Eyebrow (versalete) ── */
function EyebrowLabel({ children, color }) {
  return <div style={{ fontFamily: 'var(--font-ui)', fontSize: 11, fontWeight: 400, letterSpacing: '.16em', textTransform: 'uppercase', color: color || 'var(--text-muted)' }}>{children}</div>;
}

/* ── Logotype (stacked, left-aligned) ── */
function Logotype({ size = 30, theme }) {
  const word = theme === 'day' ? 'var(--cobalt-500)' : 'var(--cobalt-400)';
  const eye = theme === 'day' ? '#2E3A86' : '#8C97D4';
  return (
    <div style={{ display: 'inline-flex', flexDirection: 'column', alignItems: 'flex-start', lineHeight: 1 }}>
      <span style={{ fontFamily: 'var(--font-ui)', fontSize: size * 0.26, fontWeight: 400, letterSpacing: '.34em', textTransform: 'uppercase', paddingLeft: '.34em', marginBottom: size * 0.14, color: eye, whiteSpace: 'nowrap' }}>O meu</span>
      <span style={{ fontFamily: 'var(--font-display)', fontStyle: 'italic', fontWeight: 500, fontSize: size, letterSpacing: '-.015em', lineHeight: .86, color: word }}>Salmo</span>
    </div>
  );
}

/* ── Emotion chip ── */
const EMOTIONS = [
  { id: 'ansiedade', name: 'Ansiedade', bg: '#EEEDF8', fg: '#3D3889', dot: '#5567EA' },
  { id: 'paz', name: 'Paz', bg: '#EAF1E6', fg: '#4E7A52', dot: '#6A9A62' },
  { id: 'gratidao', name: 'Gratidão', bg: '#FAF2E0', fg: '#9A7320', dot: '#C99A38' },
  { id: 'luto', name: 'Luto', bg: '#F1EBEF', fg: '#7A4A66', dot: '#9A6A86' },
  { id: 'duvida', name: 'Dúvida', bg: '#ECECF2', fg: '#5E5A82', dot: '#8480AA' },
];

function EmotionChip({ emotion, onClick, large }) {
  return (
    <button onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 9, border: 'none', cursor: 'pointer',
      background: emotion.bg, color: emotion.fg, borderRadius: 999,
      padding: large ? '15px 22px' : '10px 16px', fontFamily: 'var(--font-ui)',
      fontSize: large ? 16 : 14, fontWeight: 500, transition: 'transform var(--dur-fast) var(--ease)',
    }}
      onMouseDown={e => e.currentTarget.style.transform = 'scale(.97)'}
      onMouseUp={e => e.currentTarget.style.transform = 'scale(1)'}
      onMouseLeave={e => e.currentTarget.style.transform = 'scale(1)'}>
      <span style={{ width: large ? 10 : 8, height: large ? 10 : 8, borderRadius: '50%', background: emotion.dot }} />
      {emotion.name}
    </button>
  );
}

/* ── Psalm list card ── */
function PsalmCard({ num, title, snippet, onClick }) {
  return (
    <button onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 16, width: '100%', textAlign: 'left',
      background: 'var(--surface)', border: '.5px solid var(--border)', borderRadius: 'var(--radius-md)',
      padding: '16px 18px', cursor: 'pointer', fontFamily: 'var(--font-ui)',
    }}>
      <span style={{ fontFamily: 'var(--font-display)', fontSize: 34, fontWeight: 400, color: 'var(--accent)', lineHeight: 1, minWidth: 44 }}>{num}</span>
      <span style={{ flex: 1 }}>
        <span style={{ display: 'block', fontFamily: 'var(--font-display)', fontSize: 18, color: 'var(--text-strong)', marginBottom: 3 }}>{title}</span>
        <span style={{ display: 'block', fontFamily: 'var(--font-verse)', fontStyle: 'italic', fontSize: 14, color: 'var(--text-muted)', lineHeight: 1.4, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{snippet}</span>
      </span>
    </button>
  );
}

/* ── Verse line (scripture body) ── */
function VerseLine({ n, children, active }) {
  return (
    <div style={{ display: 'flex', gap: 12, marginBottom: 14 }}>
      <span style={{ fontFamily: 'var(--font-ui)', fontSize: 10, color: 'var(--accent)', marginTop: 6, minWidth: 14 }}>{n}</span>
      <span style={{ fontFamily: 'var(--font-verse)', fontStyle: 'italic', fontSize: 19, lineHeight: 1.6,
        color: active ? 'var(--scripture)' : 'var(--text)' }}>{children}</span>
    </div>
  );
}

/* ── Play triangle ── */
function Tri({ size = 8, color = 'var(--accent-on)' }) {
  return <span style={{ width: 0, height: 0, borderTop: `${size * 0.625}px solid transparent`, borderBottom: `${size * 0.625}px solid transparent`, borderLeft: `${size}px solid ${color}`, marginLeft: size * 0.25 }} />;
}

/* ── Icon button (round) ── */
function IconButton({ onClick, children, size = 38, filled }) {
  return (
    <button onClick={onClick} style={{
      width: size, height: size, borderRadius: '50%', flexShrink: 0, cursor: 'pointer',
      background: filled ? 'var(--accent)' : 'transparent',
      border: filled ? 'none' : '.5px solid var(--border)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      boxShadow: filled ? 'var(--shadow-cobalt)' : 'none',
    }}>{children}</button>
  );
}

/* ── Audio player (fixed bar) ── */
function AudioPlayer({ playing, onToggle, progress = 0.38 }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 20px', borderTop: '.5px solid var(--border)', background: 'var(--bg)' }}>
      <IconButton filled onClick={onToggle}>
        {playing
          ? <span style={{ display: 'flex', gap: 3 }}><span style={{ width: 3, height: 12, background: 'var(--accent-on)' }} /><span style={{ width: 3, height: 12, background: 'var(--accent-on)' }} /></span>
          : <Tri size={9} />}
      </IconButton>
      <span style={{ fontFamily: 'var(--font-ui)', fontSize: 10, color: 'var(--text)', fontVariantNumeric: 'tabular-nums' }}>1:24</span>
      <span style={{ flex: 1, height: 3, background: 'var(--border)', borderRadius: 2, position: 'relative' }}>
        <span style={{ position: 'absolute', left: 0, top: 0, height: '100%', width: `${progress * 100}%`, background: 'var(--accent)', borderRadius: 2 }}>
          <span style={{ position: 'absolute', right: -4, top: '50%', transform: 'translateY(-50%)', width: 9, height: 9, borderRadius: '50%', background: 'var(--cobalt-400)' }} />
        </span>
      </span>
      <span style={{ fontFamily: 'var(--font-ui)', fontSize: 10, color: 'var(--text-muted)', fontVariantNumeric: 'tabular-nums' }}>3:40</span>
    </div>
  );
}

Object.assign(window, { StatusBar, EyebrowLabel, Logotype, EmotionChip, EMOTIONS, PsalmCard, VerseLine, Tri, IconButton, AudioPlayer, PHONE });
