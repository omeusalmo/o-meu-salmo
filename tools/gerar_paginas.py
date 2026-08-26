#!/usr/bin/env python3
"""Gera as páginas de salmo e o hub em docs/, a partir de app/assets/salmos.json.

Determinismo é o mecanismo de sincronia: o script sobrescreve tudo, então se o
JSON não mudou o `git status` fica limpo. Rode e faça commit do que mudar:

    python3 tools/gerar_paginas.py && git add -A docs && git commit -m "..."

`--check` gera em memória e falha se o disco divergir (gancho de CI).
"""
import argparse, html, json, pathlib, re, subprocess, sys

RAIZ = pathlib.Path(__file__).resolve().parent.parent
JSON = RAIZ / "app/assets/salmos.json"
DART = RAIZ / "app/lib/shared/widgets/tema_chip.dart"
LP   = RAIZ / "docs/index.html"
TPL  = RAIZ / "tools/templates"
SAIDA = RAIZ / "docs"

SITE = "https://omeusalmo.com.br"
PKG  = "com.omeusalmo.salmos"
LOJA = f"https://play.google.com/store/apps/details?id={PKG}"

# Escopo publicado. Os 20 de maior busca cruzados com as 8 coleções.
# Crescer daqui é só acrescentar números: tudo o mais se ajusta sozinho.
ESCOPO = [3, 4, 23, 27, 34, 37, 40, 42, 46, 51, 62, 77, 91, 100, 116, 121, 130, 133, 139, 143]

# Coleções que justificam o aviso do CVV na página.
SENSIVEIS = {"ansiedade", "luto"}

# O versículo em destaque é o mais conhecido de cada salmo, escolhido a
# dedo lendo o texto da Almeida 1911 (a numeração dela nem sempre bate
# com a das traduções modernas).
#
# Quando o verso mais famoso é o próprio 1, ele leva o dourado mesmo
# assim: a fama manda. Nesses casos o CSS desliga a capitular, senão
# seriam dois destaques na mesma linha (ver .psalm li:first-child.v-gold
# em salmo.css).
DOURADO = {
    3:   5,   # "Eu me deito e durmo; acordo, pois o Senhor me sustenta"
    4:   8,   # "Em paz me deitarei e dormirei"
    23: 1,   # "O Senhor é o meu pastor; nada me faltará"
    27: 10,   # "Se meu pai e minha mãe me abandonarem"
    34: 18,   # "Perto está o Senhor dos que têm o coração quebrantado"
    37:  5,   # "Entrega o teu caminho ao Senhor"
    40:  2,   # "dum charco de lodo; pôs os meus pés sobre uma rocha"
    42: 1,   # "Como o cervo anseia pelas correntes das águas"
    46: 10,   # "Aquietai-vos, e sabei que eu sou Deus"
    51: 10,   # "Cria em mim, ó Deus, um coração puro"
    62:  8,   # "derramai perante ele o vosso coração"
    77: 11,   # "Recordarei os feitos do Senhor"
    91: 11,   # "Porque aos seus anjos dará ordem a teu respeito"
    100: 4,   # "Entrai pelas suas portas com ação de graças"
    116: 12,  # "Que darei eu ao Senhor por todos os benefícios?"
    121: 1,  # "Elevo os meus olhos para os montes"
    130: 1,  # "Das profundezas clamo a ti, ó Senhor"
    139: 14,  # "de um modo tão admirável e maravilhoso fui formado"
    143: 8,   # "Faze-me ouvir da tua benignidade pela manhã"
}
# Abaixo disso o destaque não separa nada: o Salmo 133 tem 3 versículos.
MIN_VERSOS_DOURADO = 5


def verso_dourado(numero, qtd):
    if qtd < MIN_VERSOS_DOURADO:
        return None
    escolhido = DOURADO.get(numero)
    if escolhido and 1 <= escolhido <= qtd:
        return escolhido
    return None

EXTENSO = {1:"um",2:"dois",3:"três",4:"quatro",5:"cinco",6:"seis",7:"sete",8:"oito",
           9:"nove",10:"dez",11:"onze",12:"doze",13:"treze",14:"catorze",15:"quinze",
           16:"dezesseis",17:"dezessete",18:"dezoito",19:"dezenove",20:"vinte"}


def esc(t):
    return html.escape(str(t), quote=True)


def carregar():
    d = json.loads(JSON.read_text(encoding="utf-8"))
    salmos = {s["numero"]: s for s in d["salmos"]}
    colecoes = d["colecoes"]
    # o mapa de tema em português já existe no app; ler de lá evita duas fontes
    mapa = dict(re.findall(r"'([a-z_]+)'\s*:\s*'([^']+)'", DART.read_text(encoding="utf-8")))
    return salmos, colecoes, mapa


def data_do_conteudo():
    """lastmod vem do commit do JSON, não de agora: com datetime.now() as 21 datas
    mudariam a cada execução e o Google passaria a ignorar o sinal."""
    try:
        out = subprocess.run(["git", "log", "-1", "--format=%cs", "--", str(JSON)],
                             cwd=RAIZ, capture_output=True, text=True, timeout=10)
        if out.returncode == 0 and out.stdout.strip():
            return out.stdout.strip()
    except Exception:
        pass
    import datetime
    return datetime.date.fromtimestamp(JSON.stat().st_mtime).isoformat()


def por_extenso(data_iso):
    meses = ["janeiro","fevereiro","março","abril","maio","junho","julho",
             "agosto","setembro","outubro","novembro","dezembro"]
    a, m, dia = data_iso.split("-")
    return f"{int(dia)} de {meses[int(m)-1]} de {a}"


def css_compartilhado():
    """Tokens saem do index.html, que segue sendo a fonte da verdade: o arquivo
    é regenerado a cada execução, então não existe divergência possível."""
    lp = LP.read_text(encoding="utf-8")
    tokens = re.search(r'(/\* ── TOKENS.*?)\n/\* ── BASE', lp, re.S)
    if not tokens:
        sys.exit("ERRO: bloco de TOKENS não encontrado em docs/index.html")
    base = (TPL / "salmo.css").read_text(encoding="utf-8")
    return base


def colecoes_do(numero, colecoes):
    return [c for c in colecoes if numero in c["salmos"]]


def relacionados(numero, salmos, colecoes, limite=6):
    """Por sobreposição de tema, restrito ao escopo publicado: linkar para uma
    página que ainda não existe seria 404 e link interno quebrado."""
    alvo = set(salmos[numero].get("temas", []))
    pontuados = []
    for n in ESCOPO:
        if n == numero:
            continue
        comum = len(alvo & set(salmos[n].get("temas", [])))
        if comum:
            pontuados.append((-comum, len(salmos[n]["versiculos"]), n))
    pontuados.sort()
    return [n for _, _, n in pontuados[:limite]]


def vizinhos(numero):
    """Anterior e próximo caminham dentro do escopo, não pelo número absoluto:
    o Salmo 91 vizinha o 77 e o 100 enquanto o 90 e o 92 não existirem."""
    i = ESCOPO.index(numero)
    ant = ESCOPO[i - 1] if i > 0 else None
    prox = ESCOPO[i + 1] if i < len(ESCOPO) - 1 else None
    return ant, prox


def resumo(texto, limite=155):
    t = " ".join(texto.split())
    if len(t) <= limite:
        return t
    return t[:limite].rsplit(" ", 1)[0].rstrip(",;:.") + "…"


CABECA = """<!DOCTYPE html>
<html lang="pt-BR" data-theme="dark">
<head>
<meta charset="UTF-8">
<script>(function(){{var t=localStorage.getItem('theme')||(window.matchMedia('(prefers-color-scheme:light)').matches?'light':'dark');document.documentElement.dataset.theme=t;var r=localStorage.getItem('read');if(r&&r!=='m')document.documentElement.dataset.read=r;}})();</script>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{titulo}</title>
<meta name="description" content="{descricao}">
<meta name="robots" content="index, follow">
<link rel="canonical" href="{url}">
<link rel="icon" href="/favicon.png" type="image/png">
<link rel="apple-touch-icon" href="/apple-touch-icon.png">

<meta property="og:type" content="{og_tipo}">
<meta property="og:site_name" content="O meu Salmo">
<meta property="og:locale" content="pt_BR">
<meta property="og:title" content="{titulo}">
<meta property="og:description" content="{descricao}">
<meta property="og:url" content="{url}">
<meta property="og:image" content="{site}/og-image.png">
<meta name="twitter:card" content="summary_large_image">
<meta name="theme-color" content="#080B1C">

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,500;1,400;1,500&family=Cormorant:ital,wght@1,300;1,400&family=Instrument+Sans:wght@300;400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/assets/salmo.css">

<script type="application/ld+json">
{jsonld}
</script>
</head>
<body>

<a class="skip-link" href="#conteudo">{skip}</a>

<nav aria-label="Navegação principal">
  <div class="wrap inner">
    <a class="logo" href="/" aria-label="O meu Salmo, página inicial">
      <span class="om">O meu</span>
      <span class="sa">Salmo</span>
    </a>
    <div class="nav-tools">
      <button id="theme-btn" class="icon-btn" aria-label="Alternar tema claro e escuro">
        <svg class="icon-sun" width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" aria-hidden="true"><circle cx="12" cy="12" r="4.2"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/></svg>
        <svg class="icon-moon" width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" aria-hidden="true"><path d="M20 14.5A8.5 8.5 0 1 1 9.5 4a6.8 6.8 0 0 0 10.5 10.5z"/></svg>
      </button>
    </div>
  </div>
</nav>
"""

RODAPE = """
<footer>
  <div class="wrap">
    <div class="ft-inner">
      <a class="logo" href="/" aria-label="O meu Salmo">
        <span class="om">O meu</span>
        <span class="sa">Salmo</span>
      </a>
      <div class="ft-links">
        <a href="/salmos/">Todos os salmos</a>
        <a href="/#faq">Perguntas frequentes</a>
        <a href="/privacy_policy.html">Privacidade</a>
        <a href="mailto:omeusalmo@gmail.com">Suporte</a>
      </div>
      <div class="ft-copy">&copy; 2026 O meu Salmo</div>
    </div>
  </div>
</footer>

<div class="appbar">
  <div class="ab-txt">
    <div class="ab-t">{barra_t}</div>
    <div class="ab-s">Grátis, offline, sem anúncio</div>
  </div>
  <a class="btn" href="{loja}" data-intent="{intent}">Abrir</a>
</div>

<script src="/assets/salmo.js"></script>
</body>
</html>
"""

CTL = """    <div class="reader-ctl" role="group" aria-labelledby="rc-lbl">
      <span class="rc-lbl" id="rc-lbl">Tamanho da letra</span>
      <div class="rc-opts">
        <button type="button" data-size="m" aria-pressed="true"><span class="rc-a" aria-hidden="true">A</span><span class="rc-w">Normal</span></button>
        <button type="button" data-size="g" aria-pressed="false"><span class="rc-a" aria-hidden="true">A</span><span class="rc-w">Grande</span></button>
        <button type="button" data-size="gg" aria-pressed="false"><span class="rc-a" aria-hidden="true">A</span><span class="rc-w">Maior</span></button>
      </div>
    </div>
"""


def intent(rota):
    """Três barras: o manifest declara o esquema sem host, então omeusalmo://salmos/23
    faz o go_router receber /23 e cair no errorBuilder."""
    fallback = LOJA.replace(":", "%3A").replace("/", "%2F").replace("?", "%3F").replace("=", "%3D")
    return f"intent:///{rota}#Intent;scheme=omeusalmo;package={PKG};S.browser_fallback_url={fallback};end"


def pagina_salmo(n, salmos, colecoes, mapa, data):
    s = salmos[n]
    url = f"{SITE}/salmos/{n}"
    cols = colecoes_do(n, colecoes)
    versos = s["versiculos"]
    qtd = len(versos)
    sensivel = any(c["id"] in SENSIVEIS for c in cols)

    titulo_pg = f"Salmo {n} completo · {s['titulo']}"
    descricao = (f"Salmo {n} completo, {qtd} versículos em letras grandes e sem anúncio: "
                 f"“{resumo(versos[0], 90)}”")

    ld = {
        "@context": "https://schema.org",
        "@graph": [
            {"@type": "WebSite", "@id": f"{SITE}/#website", "url": f"{SITE}/",
             "name": "O meu Salmo", "inLanguage": "pt-BR"},
            {"@type": "Organization", "@id": f"{SITE}/#org", "name": "O meu Salmo", "url": f"{SITE}/"},
            {"@type": "WebPage", "@id": f"{url}#webpage", "url": url, "name": titulo_pg,
             "inLanguage": "pt-BR", "isPartOf": {"@id": f"{SITE}/#website"},
             "datePublished": data, "dateModified": data},
            {"@type": "BreadcrumbList", "itemListElement": [
                {"@type": "ListItem", "position": 1, "name": "Início", "item": f"{SITE}/"},
                {"@type": "ListItem", "position": 2, "name": "Salmos", "item": f"{SITE}/salmos/"},
                {"@type": "ListItem", "position": 3, "name": f"Salmo {n}"}]},
            {"@type": "CreativeWork", "@id": f"{url}#texto", "name": f"Salmo {n}",
             "alternateName": s["titulo"], "inLanguage": "pt-BR",
             "citation": "João Ferreira de Almeida, edição de 1911",
             "license": "https://creativecommons.org/publicdomain/mark/1.0/",
             "isPartOf": {"@type": "Book", "name": "Livro dos Salmos"}},
            {"@type": "Article", "@id": f"{url}#reflexao",
             "headline": f"Quando ler o Salmo {n}",
             "articleBody": s["reflexao"], "inLanguage": "pt-BR",
             "datePublished": data, "author": {"@id": f"{SITE}/#org"},
             "publisher": {"@id": f"{SITE}/#org"},
             "mainEntityOfPage": {"@id": f"{url}#webpage"}},
        ],
    }

    tags = "".join(
        f'\n        <span class="tag" data-emo="{c["id"]}"><span class="dot" aria-hidden="true"></span>{esc(c["titulo"].replace("Para a ","").replace("Para ","").replace("No ","").split(" e ")[0])}</span>'
        for c in cols)
    if not cols:
        for t in s.get("temas", [])[:3]:
            tags += f'\n        <span class="tag"><span class="dot" aria-hidden="true"></span>{esc(mapa.get(t, t.capitalize()))}</span>'

    ouro = verso_dourado(n, qtd)

    def linha(i, v):
        cls = ' class="v-gold"' if i == ouro else ""
        return f'      <li id="v{i}"{cls}><span class="n">{i}</span><span class="t">{esc(v)}</span></li>'

    linhas = "\n".join(linha(i, v) for i, v in enumerate(versos, 1))

    care = ""
    if sensivel:
        care = """
    <aside class="care" aria-label="Aviso de saúde">
      <p><b>Se a ansiedade está pesada, procure ajuda.</b> Um salmo acalma, mas não substitui acompanhamento de saúde. O CVV atende de graça, 24 horas por dia.</p>
      <a class="care-tel" href="tel:188">Ligar para o CVV: 188</a>
    </aside>
"""

    rel = relacionados(n, salmos, colecoes)
    rel_html = ""
    if rel:
        itens = "\n".join(
            f'        <a class="rel-item" href="/salmos/{r}"><span class="rn">Salmo {r}</span><span class="rt">{esc(salmos[r]["titulo"])}</span></a>'
            for r in rel)
        rel_html = f"""
    <section class="rel" aria-labelledby="rel-t">
      <h2 id="rel-t">Salmos que conversam com este</h2>
      <div class="rel-grid">
{itens}
      </div>
    </section>
"""

    ant, prox = vizinhos(n)
    pag = ""
    if ant or prox:
        partes = []
        if ant:
            partes.append(f'      <a href="/salmos/{ant}">\n        <span class="lbl">Anterior</span>\n        <span class="nm">Salmo {ant}</span>\n      </a>')
        if prox:
            partes.append(f'      <a class="next" href="/salmos/{prox}">\n        <span class="lbl">Próximo</span>\n        <span class="nm">Salmo {prox}</span>\n      </a>')
        pag = '\n    <nav class="pager" aria-label="Navegar entre salmos">\n' + "\n".join(partes) + "\n    </nav>\n"

    corpo = f"""
<div class="wrap-read">
  <nav class="crumb" aria-label="Trilha de navegação">
    <ol>
      <li><a href="/">Início</a></li>
      <li><span class="sep" aria-hidden="true">&rsaquo;</span><a href="/salmos/">Salmos</a></li>
      <li><span class="sep" aria-hidden="true">&rsaquo;</span><span aria-current="page">Salmo {n}</span></li>
    </ol>
  </nav>
</div>

<main id="conteudo" tabindex="-1">
  <div class="wrap-read page">

    <header class="ph">
      <span class="hd-ghost" aria-hidden="true">{n}</span>
      <h1>
        <span class="ph-num">Salmo {n}</span>
        <span class="ph-title">{esc(s["titulo"])}</span>
      </h1>
      <div class="ph-meta">
        <span class="sr-only">Coleções deste salmo:</span>{tags}
        <span>{qtd} versículos</span>
      </div>
    </header>

{CTL}
    <ol class="psalm" role="list" aria-label="Salmo {n}, {EXTENSO.get(qtd, qtd)} versículos">
{linhas}
    </ol>

    <p class="attrib">Tradução de João Ferreira de Almeida, edição de 1911, em domínio público. <a href="/#faq">Por que soa diferente?</a></p>

    <section class="reflect" aria-labelledby="reflexao">
      <span class="eye">Quando ler</span>
      <h2 id="reflexao">Quando ler o Salmo {n}</h2>
      <p>{esc(s["reflexao"])}</p>
      <p class="ask">{esc(s["reflexao_pergunta"])}</p>

      <div class="byline">
        <span>Publicado em <time datetime="{data}">{por_extenso(data)}</time></span>
      </div>
    </section>
{care}
    <section class="cta" aria-labelledby="cta-t">
      <div class="cta-ghost" aria-hidden="true">Salmo</div>
      <span class="eye">O aplicativo</span>
      <h2 id="cta-t">Este salmo também tem <em>voz</em></h2>
      <p>No aplicativo o Salmo {n} é narrado inteiro, sem pressa. São 150 salmos organizados por como você está se sentindo. Funciona sem internet, e não tem anúncio nenhum.</p>
      <a class="btn" href="{LOJA}" rel="noopener">Baixar grátis no Android</a>
      <p class="proof"><span>Sem cadastro</span> <span>· Sem anúncio</span> <span>· Funciona offline</span></p>
    </section>
{rel_html}{pag}
  </div>
</main>
"""

    cabeca = CABECA.format(titulo=esc(titulo_pg), descricao=esc(descricao), url=url,
                           og_tipo="article", site=SITE, skip="Ir para o salmo",
                           jsonld=json.dumps(ld, ensure_ascii=False, indent=2).replace("</", "<\\/"))
    rodape = RODAPE.format(barra_t=f"Ouça o Salmo {n} narrado", loja=LOJA, intent=intent(f"salmos/{n}"))
    return cabeca + corpo + rodape


def pagina_hub(salmos, colecoes, mapa, data):
    url = f"{SITE}/salmos/"
    titulo_pg = "Salmos completos em letras grandes, sem anúncio"
    descricao = ("Os salmos mais procurados, com o texto completo em letras grandes e sem "
                 "propaganda no meio. Escolha pelo número ou pelo que você está sentindo.")

    ld = {
        "@context": "https://schema.org",
        "@graph": [
            {"@type": "WebSite", "@id": f"{SITE}/#website", "url": f"{SITE}/",
             "name": "O meu Salmo", "inLanguage": "pt-BR"},
            {"@type": "Organization", "@id": f"{SITE}/#org", "name": "O meu Salmo", "url": f"{SITE}/"},
            {"@type": "CollectionPage", "@id": f"{url}#webpage", "url": url, "name": titulo_pg,
             "inLanguage": "pt-BR", "isPartOf": {"@id": f"{SITE}/#website"},
             "datePublished": data, "dateModified": data},
            {"@type": "BreadcrumbList", "itemListElement": [
                {"@type": "ListItem", "position": 1, "name": "Início", "item": f"{SITE}/"},
                {"@type": "ListItem", "position": 2, "name": "Salmos"}]},
            {"@type": "ItemList", "numberOfItems": len(ESCOPO), "itemListElement": [
                {"@type": "ListItem", "position": i, "name": f"Salmo {n}",
                 "url": f"{SITE}/salmos/{n}"} for i, n in enumerate(ESCOPO, 1)]},
        ],
    }

    linhas = []
    for n in ESCOPO:
        s = salmos[n]
        cols = colecoes_do(n, colecoes)
        if cols:
            apoio = f'<span class="ls" data-emo="{cols[0]["id"]}"><span class="ls-dot" aria-hidden="true"></span>{esc(cols[0]["titulo"])}</span>'
        else:
            t = s.get("temas", [""])[0]
            apoio = f'<span class="ls">{esc(mapa.get(t, t.capitalize()))}</span>'
        linhas.append(f"""      <a href="/salmos/{n}">
        <span class="ln">{n}</span>
        <span>
          <span class="lt">{esc(s["titulo"])}</span>
          {apoio}
        </span>
        <span class="lv">{len(s["versiculos"])} versículos</span>
      </a>""")

    corpo = f"""
<div class="wrap-read">
  <nav class="crumb" aria-label="Trilha de navegação">
    <ol>
      <li><a href="/">Início</a></li>
      <li><span class="sep" aria-hidden="true">&rsaquo;</span><span aria-current="page">Salmos</span></li>
    </ol>
  </nav>
</div>

<main id="conteudo" tabindex="-1">
  <div class="wrap-read page">

    <header class="ph">
      <span class="hd-ghost" aria-hidden="true">150</span>
      <h1><span class="ph-num">Os salmos, inteiros</span></h1>
      <p class="sub">Sem propaganda no meio da oração.</p>
      <p class="lead">Cada salmo aqui está completo, com o texto em letras grandes e um botão para aumentar ainda mais. Nenhuma página tem anúncio. Cada um traz as marcas do momento a que serve.</p>
    </header>

    <div class="list">
{chr(10).join(linhas)}
    </div>

    <p class="attrib">Estamos publicando aos poucos, começando pelos mais procurados. Os 150 estão completos no aplicativo, com narração em áudio. <a href="/#faq">Sobre a tradução usada</a>.</p>

    <section class="cta" aria-labelledby="cta-t">
      <div class="cta-ghost" aria-hidden="true">Salmo</div>
      <span class="eye">O aplicativo</span>
      <h2 id="cta-t">Os 150, <em>narrados</em>, sem internet</h2>
      <p>No aplicativo estão todos os salmos, organizados por como você está se sentindo, cada um lido em voz alta e sem pressa. Funciona offline, e não tem anúncio nenhum.</p>
      <a class="btn" href="{LOJA}" rel="noopener">Baixar grátis no Android</a>
      <p class="proof"><span>Sem cadastro</span> <span>· Sem anúncio</span> <span>· Funciona offline</span></p>
    </section>

  </div>
</main>
"""
    cabeca = CABECA.format(titulo=esc(titulo_pg), descricao=esc(descricao), url=url,
                           og_tipo="website", site=SITE, skip="Ir para a lista",
                           jsonld=json.dumps(ld, ensure_ascii=False, indent=2).replace("</", "<\\/"))
    rodape = RODAPE.format(barra_t="Todos os 150, narrados", loja=LOJA, intent=intent("salmos"))
    return cabeca + corpo + rodape


def sitemap(data):
    urls = [(f"{SITE}/", "1.0", "weekly"), (f"{SITE}/salmos/", "0.9", "weekly")]
    urls += [(f"{SITE}/salmos/{n}", "0.8", "monthly") for n in ESCOPO]
    itens = "\n".join(
        f"  <url>\n    <loc>{u}</loc>\n    <lastmod>{data}</lastmod>\n"
        f"    <changefreq>{cf}</changefreq>\n    <priority>{p}</priority>\n  </url>"
        for u, p, cf in urls)
    return ('<?xml version="1.0" encoding="UTF-8"?>\n'
            '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
            f"{itens}\n</urlset>\n")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true", help="falha se o disco divergir")
    ap.add_argument("--saida", help="diretório alternativo (para testar sem tocar docs/)")
    args = ap.parse_args()

    global SAIDA
    if args.saida:
        SAIDA = pathlib.Path(args.saida)

    salmos, colecoes, mapa = carregar()
    data = data_do_conteudo()

    faltando = [n for n in ESCOPO if n not in salmos]
    if faltando:
        sys.exit(f"ERRO: salmos do escopo ausentes no JSON: {faltando}")

    arquivos = {}
    for n in ESCOPO:
        arquivos[SAIDA / f"salmos/{n}.html"] = pagina_salmo(n, salmos, colecoes, mapa, data)
    arquivos[SAIDA / "salmos/index.html"] = pagina_hub(salmos, colecoes, mapa, data)
    arquivos[SAIDA / "assets/salmo.css"] = css_compartilhado()
    arquivos[SAIDA / "assets/salmo.js"] = (TPL / "salmo.js").read_text(encoding="utf-8")
    arquivos[SAIDA / "sitemap.xml"] = sitemap(data)

    if args.check:
        divergiu = [p for p, c in arquivos.items()
                    if not p.exists() or p.read_text(encoding="utf-8") != c]
        if divergiu:
            print("divergem do gerador:")
            for p in divergiu:
                print("  ", p.relative_to(RAIZ))
            sys.exit(1)
        print(f"ok: {len(arquivos)} arquivos em dia")
        return

    for p, c in arquivos.items():
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(c, encoding="utf-8")

    print(f"{len(ESCOPO)} salmos + hub + css + js + sitemap")
    print(f"lastmod: {data} (do commit de salmos.json)")


if __name__ == "__main__":
    main()
