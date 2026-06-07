# Arquitetura da Informação — O meu Salmo (MVP)

Documento de referência estrutural do app. Define **navegação, hierarquia de
telas e fluxos** do usuário.

- **Fonte da verdade ESTRUTURAL:** este documento (o que existe, onde fica, como
  se navega).
- **Fonte da verdade VISUAL:** o Design System em `o-meu-salmo-design/`.
- Complementar ao Escopo Técnico (telas e ordem de build) e ao Roadmap.

---

## 1. Modelo de navegação

- **Barra de navegação inferior com 4 abas** (destinos de topo):
  **Início · Coleções · Salmos · Favoritos**.
- **Ajustes** é acessado por um ícone (engrenagem) na barra superior — não é aba.
- **Telas de detalhe** (Coleção, Leitura, Compositor) abrem empilhadas (push),
  não são abas.
- **Tema claro/escuro** segue o sistema do dispositivo, com alternância manual
  em Ajustes.
- A tela de **Leitura do Salmo** é o "hub" do app: quase todos os caminhos
  levam até ela.

---

## 2. Mapa de telas (hierarquia)

```
O meu Salmo
│
├── [Aba] Início / Salmo do dia
│      └── Salmo (Leitura)
│
├── [Aba] Coleções
│      └── Coleção (detalhe)
│             └── Salmo (Leitura)
│
├── [Aba] Salmos (Todos os 150 + busca)
│      └── Salmo (Leitura)
│
├── [Aba] Favoritos
│      └── Salmo (Leitura)
│
├── Salmo (Leitura)   ← hub central
│      └── Compositor de imagem
│             └── Compartilhar (share nativo do sistema)
│
└── [Barra superior] Ajustes
       └── Apoie o app
```

---

## 3. Telas — conteúdo e conexões

### 3.1 Início / Salmo do dia  *(aba)*
- **Objetivo:** ponto de entrada diário; criar hábito.
- **Conteúdo:** salmo do dia em destaque (número, tema/coleção, versículo-âncora),
  botão "Ouvir", atalho para Coleções.
- **Navega para:** Salmo (Leitura); aba Coleções.

### 3.2 Coleções  *(aba)*
- **Objetivo:** o coração do app — curadoria por emoção.
- **Conteúdo:** lista de curadorias temáticas (ansiedade, sono, gratidão, luto,
  etc.), cada card com título + subtítulo.
- **Navega para:** Coleção (detalhe).

### 3.3 Coleção (detalhe)
- **Objetivo:** mostrar os salmos de um tema.
- **Conteúdo:** título e subtítulo do tema + lista dos salmos daquela coleção.
- **Navega para:** Salmo (Leitura).

### 3.4 Salmos — Todos os 150  *(aba)*
- **Objetivo:** acesso direto a qualquer salmo.
- **Conteúdo:** lista dos 150 (número + título) e **busca** por número/palavra.
- **Navega para:** Salmo (Leitura).

### 3.5 Salmo (Leitura)  *(hub central)*
- **Objetivo:** a experiência principal de leitura.
- **Conteúdo:** título, rótulo da tradução, versículos com tipografia caprichada,
  controle de tamanho de fonte, player de áudio, botão favoritar, botão
  compartilhar, reflexão (quando houver).
- **Navega para:** Compositor de imagem (via compartilhar); volta para a origem.

### 3.6 Favoritos  *(aba)*
- **Objetivo:** salmos salvos pelo usuário.
- **Conteúdo:** lista dos salmos favoritados.
- **Navega para:** Salmo (Leitura).

### 3.7 Compositor de imagem
- **Objetivo:** o motor de crescimento — gerar imagem pra compartilhar.
- **Conteúdo:** seleção de versículo + escolha de fundo → preview da imagem.
- **Navega para:** compartilhamento nativo do sistema (WhatsApp status, stories, etc.).

### 3.8 Ajustes  *(barra superior)*
- **Objetivo:** configurações e apoio.
- **Conteúdo:** horário da notificação diária, alternância de tema, "Sobre",
  e o botão **Apoie o app** (compra única).

---

## 4. Estados de cada tela (para o ui-designer)

Cada tela precisa prever, quando aplicável:
- **Carregando** — enquanto o conteúdo monta.
- **Vazio** — ex.: Favoritos sem nada salvo; Busca sem resultado
  ("Não encontrei nada assim. Tente uma emoção?").
- **Offline** — o conteúdo é local, então deve funcionar offline; sinalizar com
  serenidade ("Você está offline — seus Salmos continuam aqui.").
- **Erro** — falha de áudio ou de geração de imagem, com recuperação suave.

---

## 5. Fluxos principais

1. **Hábito (retenção):**
   Notificação diária → Início (Salmo do dia) → Leitura → Ouvir áudio.

2. **Emocional (proposta central):**
   Coleções → escolhe a emoção (ex.: ansiedade) → Coleção (detalhe) → Leitura.

3. **Crescimento (compartilhamento — prioridade máxima):**
   Leitura → Compartilhar → Compositor de imagem (versículo + fundo) →
   share nativo (status do WhatsApp / stories).

4. **Salvar:**
   Leitura → Favoritar → aparece em Favoritos.

5. **Apoio (monetização discreta):**
   Ajustes → Apoie o app.

---

## 6. Notas para a squad

- Implementar a navegação com a abordagem já adotada no esqueleto (ex.:
  `go_router`), com a barra inferior de 4 abas e as telas de detalhe em push.
- A **Leitura** é o hub: garanta que o "voltar" sempre retorne à tela de origem
  correta (Início, Coleção, Salmos ou Favoritos).
- O **Compositor de imagem** é a única tela "de saída" (entrega ao share do SO);
  trate-a como prioridade de qualidade visual — é o que circula nas redes.
- Esta IA define a **estrutura**; o visual de cada tela vem do Design System em
  `o-meu-salmo-design/`. Em dúvida estrutural, este documento manda; em dúvida
  visual, o Design System manda.
- Mapeamento com o roadmap: as telas seguem a ordem de build já definida
  (Leitura → Salmos+busca → Coleções → Início/Salmo do dia → Favoritos →
  Áudio → Compositor/compartilhar → Analytics → Apoie).
