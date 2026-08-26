/* salmo.js · tema, tamanho de leitura e barra "abrir no app".
   Gerado por tools/gerar_paginas.py. Editado na auditoria de design
   de 2026-08-24: propagar as mudanças para o gerador. */
(function(){
  'use strict';

  var root = document.documentElement;

  /* ── TEMA ── espelha a chave 'theme' que a home já usa ── */
  var btn  = document.getElementById('theme-btn');
  var meta = document.querySelector('meta[name="theme-color"]');

  function syncTheme(t){
    /* a barra de endereço do Chrome no Android acompanha o tema */
    if (meta) meta.setAttribute('content', t === 'dark' ? '#080B1C' : '#F5F7FE');
    /* o rótulo diz o que o botão FAZ, não em que tema você está */
    if (btn) btn.setAttribute('aria-label', t === 'dark' ? 'Mudar para o tema claro' : 'Mudar para o tema escuro');
  }
  syncTheme(root.dataset.theme);

  if (btn) {
    btn.addEventListener('click', function(){
      var next = root.dataset.theme === 'dark' ? 'light' : 'dark';
      root.dataset.theme = next;
      syncTheme(next);
      try { localStorage.setItem('theme', next); } catch(e){}
      if (typeof gtag === 'function') gtag('event','theme_toggle',{theme:next});
    });
  }

  /* ── TAMANHO DE LEITURA ──
     Três degraus: 21px / 25px / 30px. O padrão já fica no topo da faixa
     recomendada para leitura longa acima dos 55 anos. */
  var ctl = document.querySelector('.reader-ctl');
  if (ctl) {
    var apply = function(size, persist){
      if (size === 'm') delete root.dataset.read;
      else root.dataset.read = size;
      ctl.querySelectorAll('button').forEach(function(b){
        b.setAttribute('aria-pressed', String(b.dataset.size === size));
      });
      if (persist) { try { localStorage.setItem('read', size); } catch(e){} }
    };
    var saved = 'm';
    try { saved = localStorage.getItem('read') || 'm'; } catch(e){}
    apply(saved, false);
    ctl.addEventListener('click', function(e){
      var b = e.target.closest('button');
      if (!b) return;
      apply(b.dataset.size, true);
      if (typeof gtag === 'function') gtag('event','read_size',{size:b.dataset.size});
    });
  }

  /* ── BARRA "ABRIR NO APP" ──
     Só em Android, e só depois que o salmo termina: durante a leitura
     nada cobre o texto. O href de fábrica é o da Play Store, que funciona
     em qualquer navegador; no Chrome e no Samsung Internet ele é trocado
     pelo intent://, que abre o app direto no salmo quando ele existe. */
  var bar = document.querySelector('.appbar');
  var ua  = navigator.userAgent;

  if (bar && /Android/i.test(ua)) {
    document.body.classList.add('has-appbar');

    var link = bar.querySelector('a[data-intent]');
    if (link && /Chrome|SamsungBrowser/i.test(ua)) link.href = link.dataset.intent;

    var show = function(){ document.body.classList.add('appbar-on'); };
    var mark = document.querySelector('.attrib') || document.querySelector('footer');

    if (mark && 'IntersectionObserver' in window) {
      var io = new IntersectionObserver(function(entries){
        if (!entries[0].isIntersecting) return;
        show();
        io.disconnect();
      });
      io.observe(mark);
    } else {
      show();
    }
  }

  /* ── BOTÃO MAGNÉTICO (só o CTA principal) ──
     Microinteração pontual, não um efeito espalhado pela página: puxa
     sutilmente o botão de "Baixar grátis" em direção ao cursor. Só em
     desktop com mouse (hover:hover) e só se a pessoa não pediu menos
     movimento. O link do CVV (care-tel) fica de fora de propósito:
     não é lugar pra brincadeira. */
  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var hasHover = window.matchMedia('(hover: hover)').matches;
  if (!reduceMotion && hasHover) {
    document.querySelectorAll('.cta .btn').forEach(function (el) {
      el.addEventListener('mousemove', function (e) {
        var r = el.getBoundingClientRect();
        var dx = e.clientX - (r.left + r.width / 2);
        var dy = e.clientY - (r.top + r.height / 2);
        el.style.transform = 'translate(' + dx * 0.12 + 'px,' + dy * 0.12 + 'px)';
      });
      el.addEventListener('mouseleave', function () {
        el.style.transform = '';
      });
    });
  }
})();
