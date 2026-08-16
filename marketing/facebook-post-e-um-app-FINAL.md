# Post Facebook "é um aplicativo" — pronto para publicar

**TL;DR:** imagem em `instagram/fila-de-postagem/21-fb-e-um-app/post.png`. Legenda focada no conteúdo do app, escrita para o público mais velho do Facebook. Link limpo no corpo do post. Publicar quarta 19h30 (Brasília), fixar 14 dias. Variante de Instagram no fim, com "link na bio".

- Data: 2026-08-16
- Objetivo: os seguidores da Página não sabem que existe um aplicativo. Este post resolve isso mostrando o produto, sem explicar que é um app.
- Decisões do Jeff (16/08): imagem vira anúncio direto ("Baixe o app" + mockup + benefícios), sem manchete explicando que é aplicativo. Legenda foca no que tem dentro do app, não no problema do sono. Público-alvo: os mais velhos, que são quem usa o Facebook. Link no corpo do post no Facebook, link na bio no Instagram.
- As 3 legendas anteriores (A direta, B fundador, C situacional) ficam arquivadas em `facebook-copy-e-um-app.md`. Nenhuma foi usada.

---

## 1. Imagem

`instagram/fila-de-postagem/21-fb-e-um-app/post.png` (1080x1350, 4:5)

Fonte editável: `instagram/fontes/facebook-app/post-e-um-app.html`
Regerar: `cd instagram/fontes && ./gerar-tudo.sh`

Manchete gravada na imagem: **Baixe o app / O meu Salmo** (com "Salmo" em itálico cobalt, seguindo o padrão dos outros cards)

Benefícios listados na imagem: os 150 Salmos completos · áudio narrado, ouça sem ler · escolha pelo que você sente · funciona sem internet · sem anúncios e sem cadastro. Mais o selo do Google Play e o rótulo "grátis para Android".

Tela usada: `02-colecoes.png`. Foi escolhida em cima da home porque mostra app bar, lista de cards e a barra de abas inferior. Lê como software num relance. A home mostra um Salmo grande em serifa, ou seja, exatamente o que o seguidor já acha que a Página é.

Sobrevive ao corte quadrado (busca e grade da Página): manchete, celular inteiro e selo do Google Play ficam dentro da faixa central. Só o marcador do topo e a URL do rodapé ficam de fora, e são reforço.

---

## 2. Legenda (colar no Facebook)

```
O meu Salmo é um aplicativo gratuito com os 150 Salmos, do 23 ao 91, para você ler ou ouvir em voz alta.

O áudio lê o Salmo inteiro para você, para quando a vista cansa.

Você escolhe pelo que está sentindo: sono, ansiedade, luto, proteção, gratidão, esperança, perdão e louvor.

Dá para mandar um versículo como imagem para os filhos no WhatsApp.

Funciona sem internet depois de instalado. Não pede cadastro, não pede senha e não tem propaganda.

Para instalar: abra a Play Store no seu celular Android e escreva O meu Salmo na busca.

https://play.google.com/store/apps/details?id=com.omeusalmo.salmos
```

A primeira linha tem 104 caracteres (contados no shell, não no olho) e é o que aparece antes do "Ver mais", que corta perto de 125. A palavra "aplicativo" fecha no caractere 27.

### Por que cada escolha, depois da revisão dos três agentes

- **"em voz alta" no lugar de "narração em áudio".** "Narração" é palavra de documentário, não de conversa. E cuidado: a voz é sintetizada (`gerar_audios.py`), então nunca escrever "alguém lê para você", que promete narrador humano.
- **"você escolhe pelo que está sentindo" no lugar de "8 coleções".** Para quem tem 70 anos, coleção é selo e moeda. A lista começa em sono e luto de propósito: insônia e perda são as duas realidades dominantes dessa faixa, e as duas primeiras palavras decidem se ela continua lendo.
- **A reflexão NÃO explica o Salmo.** As reflexões são 2 a 3 frases íntimas que terminam em pergunta aberta (`assets/reflexoes-salmos.md`). Escrever "explicando" prometeria comentário bíblico, que é justamente o que o posicionamento nega.
- **"Depois de instalado, funciona sem internet".** Sem o "depois de instalado", a pessoa entende que não precisa de internet nem para baixar, e o download tem 119 MB por causa dos áudios.
- **Sumiu "não custa nada".** É a frase exata dos golpes que esse público recebe no WhatsApp todo dia. Reasseguramento genérico aumenta a suspeita. Trocado pela lista do que o app não pede, que ela confere em dez segundos.
- **"propaganda" no lugar de "anúncio".** Palavra nativa dessa geração.
- **O caminho de instalar por busca vem antes do link.** Ela não precisa confiar em URL nenhuma, só digitar o nome. O link fica como alternativa.
- **"Ainda não tem para iPhone"** evita o comentário raivoso que queima o post.
- **Saiu o "Respirar".** Ver o alerta de precisão abaixo.

Todas as funcionalidades foram conferidas contra `play-store/listing/aso-copy.md` e contra o código em `app/lib/`.

**Por que o link vai limpo, sem UTM:** a URL aparece como texto no corpo do post. Uma URL com `utm_source` e `utm_campaign` colada no meio de um texto sobre madrugada sem sono quebra o tom. O link rastreável fica reservado pros lugares onde a URL não aparece na tela: botão "Baixar" da Página e sticker de Story.

Link rastreável (só para botão e sticker):
```
https://play.google.com/store/apps/details?id=com.omeusalmo.salmos&referrer=utm_source%3Dfacebook%26utm_medium%3Dsocial%26utm_campaign%3Dpost_e_um_app
```

---

## 3. Passo a passo da publicação

1. Abrir a Página do Facebook no computador (mais fácil de formatar que no celular).
2. Clicar em "Criar publicação".
3. Colar a legenda do item 2. Conferir se as quebras de linha ficaram iguais.
4. Anexar a imagem `post.png`.
5. Publicar quarta-feira, entre 19h30 e 20h30 (horário de Brasília). Se quiser agendar: clicar na seta ao lado de "Publicar" e escolher "Agendar".
6. Depois de publicado, abrir o post, clicar nos três pontinhos e escolher "Fixar no topo da Página".
7. Deixar fixado por **14 dias**. Depois trocar pelo vídeo de reforço (item 6 do plano de distribuição) e fixar ele por mais 5 a 7 dias.
8. No menu da Página, trocar o botão de ação para **"Baixar"**, apontando pro link rastreável acima.

**Hashtags:** nenhuma. Facebook não tem cultura de descoberta por hashtag e um bloco delas destoaria do tom.

**Não mexer no campo "Site" da Página.** Ele continua apontando pro `omeusalmo.com.br`. A landing page é asset de SEO e já converte pra loja. O botão "Baixar" cobre a Play Store, não precisa abrir mão de um pelo outro.

---

## 4. Respostas prontas para os comentários

**"é pago?"**
Não. É gratuito, sem propaganda e sem plano pago. Dentro de Ajustes existe só uma opção de doação voluntária, para quem quiser ajudar. Ninguém precisa pagar nada para usar tudo.

> Por que citar a doação: existe uma chave Pix em "Apoie o app" (`app/lib/features/ajustes/ajustes_screen.dart`). Se um senhor desconfiado instala, encontra o Pix lá dentro e sente que foi enganado, você perde a pessoa e ganha um comentário ruim. Na legenda não se fala nisso, porque criaria a suspeita que estamos evitando. Na resposta, sim.

**"tem para iphone?"**
Por enquanto só Android, na Play Store. iPhone está nos planos, ainda sem data.

**"como baixo?"**
Abra a Play Store no seu celular Android, escreva O meu Salmo na busca e toque em Instalar. Baixe conectado no Wi-Fi, porque os áudios dos 150 Salmos vêm junto e o arquivo é grande.

---

## 4b. Alerta de precisão (resolver antes de publicar)

**RESOLVIDO em 16/08/2026: o Jeff decidiu tirar a duração do texto.**

O problema: `app/lib/shared/widgets/breathing_circle.dart` roda `_ctrl.repeat()` num ciclo de 9 segundos indefinidamente. Não existe timer de 60 segundos nem contagem regressiva, a tela só fecha quando o usuário toca no X. A frase "um minuto de pausa guiada" prometia uma duração que o app não cumpre.

Corrigido nos arquivos para `Respirar: uma pausa guiada com o Salmo 46`, em:
- `play-store/listing/aso-copy.md` linha 31
- `play-store/GUIA-PLAY-CONSOLE.html` linha 70

> ⚠️ **Falta aplicar no Google Play Console.** Corrigir o arquivo não muda o que está publicado na loja. A descrição longa que está no ar ainda diz "um minuto". Passo a passo no item 4c abaixo.

### 4c. Passo a passo para corrigir a descrição no Google Play Console

Um comando por vez. A descrição longa da loja é editada só por lá, o arquivo do repositório é a nossa cópia de trabalho.

1. Abra https://play.google.com/console e entre com a conta do app.
2. Na lista de apps, clique em **O meu Salmo**.
3. No menu da esquerda, clique em **Crescimento** e depois em **Presença na loja**.
4. Clique em **Ficha principal da Play Store**.
5. Role até o campo **Descrição completa**.
6. Ache a linha `— Respirar: um minuto de pausa guiada com o Salmo 46`.
7. Apague as palavras `um minuto de` e deixe a linha assim: `— Respirar: uma pausa guiada com o Salmo 46`.
8. Role até o fim da página e clique em **Salvar**.
9. Vai aparecer um aviso de alterações pendentes no topo. Clique em **Enviar para revisão**.
10. A mudança entra em revisão do Google. Texto costuma sair rápido, mas pode levar alguns dias. Não some da loja enquanto isso, a versão antiga continua no ar até aprovar.

Enquanto não for aprovado, o post do Facebook pode ir ao ar normalmente: o item "Respirar" não aparece na legenda.

---

**Nomenclatura divergente entre app e loja (não bloqueia o post).** O app diz "Salmo diário" em `app/lib/features/ajustes/ajustes_screen.dart:155` e no canal de notificação em `app/lib/core/notifications/notification_service.dart:16`. A ASO e o guia de voz dizem "Salmo do dia". Quem ler o post e for procurar o ajuste encontra outro nome. Correção é no app.

**Lacuna de produto que apareceu na revisão.** Não existe controle de tamanho de fonte na leitura: o app respeita a config do sistema com teto de 1.3x (`app/lib/main.dart:88`) e o versículo está em 17px. Dado que o público-alvo declarado é 60+, um controle de tamanho de fonte é a próxima feature óbvia, e destravaria a promessa de "letra grande" em posts futuros. Não prometer isso agora.

**Prova social não usada.** Nenhum dos revisores tinha acesso ao número real de instalações. Se o Play Console já mostra 1.000+ instalações ou uma nota consolidada, isso vale mais que dois itens da lista para um público desconfiado. Só usar com número real.

---

## 5. Variante para o Instagram

Mesma imagem. Muda a legenda no fecho e entram hashtags.

Trocar as duas últimas linhas por:

```
Funciona sem internet, sem conta e sem cadastro. Não tem anúncio e não custa nada.

O link está na bio.
```

E colocar de 3 a 5 hashtags discretas no fim, seguindo o que já está em `marketing/estrategia-instagram.md`.

Antes de publicar, apontar a bio de `@omeusalmo` pro link rastreável durante a janela do post.

---

## 6. Como medir (7 dias)

- **Compartilhamentos.** Sinal mais forte. Curtir é fácil, compartilhar significa que alguém está avisando o próprio círculo que existe um app. Comparar com a média da Página, que hoje só posta devocional.
- **Comentários perguntando "como baixo" ou "é grátis".** Prova direta de que a pessoa não sabia do app. É esse o sinal de que a mensagem chegou.
- **Alcance de contas que não seguem a Página.** Mostra se saiu da bolha.
- **Instalações no Play Console** na semana do post contra a média móvel dos 7 dias anteriores.

Sem os comentários de instalação, mesmo com número bom de download, ainda dá pra suspeitar que quem instalou já conhecia o app por outro canal.

---

## 7. FAQ na landing page (feita, não publicada)

As respostas prontas dos comentários viraram uma seção de FAQ em `docs/index.html`, com 10 perguntas, posicionada depois do bloco de download e antes do rodapé. Cards sempre abertos, sem acordeão, porque para o público mais velho um clique a mais é um lugar a mais para se perder.

Junto foi adicionado um nó `FAQPage` ao `@graph` de JSON-LD que já existia no head. Isso é o que permite as perguntas aparecerem direto no resultado do Google e serem citadas por busca com IA.

**A mudança está só no arquivo local. Não foi feito commit nem push.** Publicar é decisão sua: o deploy é automático assim que `main /docs` recebe push.

Duas respostas dizem coisas que valem sua conferência antes de publicar:

- **"são mais de 60 MB"** na pergunta de como baixar. Usei um piso que é verdade em qualquer cenário: os áudios sozinhos pesam 62 MB, o APK release tem 89 MB e o AAB tem 119 MB. O que a pessoa realmente baixa é um split otimizado que não bate com nenhum desses números. O valor exato está no Play Console, em Tamanho do download. Se quiser precisão, pegue lá e troque.
- **"A tradução é a de João Ferreira de Almeida, edição de 1911"** na pergunta de quais Salmos existem. É verdade, está em `app/lib/features/ajustes/ajustes_screen.dart:362`. Mas Almeida é tradução protestante e o app atende católicos também. Numa FAQ, transparência ganha. Se preferir não destacar, a frase sai sem prejuízo do resto.

---

## Documentos relacionados

- `marketing/facebook-copy-e-um-app.md` — as 3 legendas completas (A direta, B fundador, C situacional). A e B ficam de reserva: B serve pra repostar como confidência, A serve de texto da seção "Sobre" da Página.
- `marketing/facebook-plano-post-e-um-app.md` — plano de distribuição completo, roteiro do vídeo de reforço, adaptação de Story.
