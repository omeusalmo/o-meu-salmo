# Upload da versão 1.0.2 (código 5)

**TL;DR:** AAB pronto em `app/build/app/outputs/bundle/release/app-release.aab`, 119,2 MB. Subir com lançamento gradual em 20%, porque o teste em aparelho físico foi pulado. Notas da versão prontas no item 3.

- Gerado em: 2026-08-18
- Versão: `1.0.2`, código `5` (a produção é 1.0.1 código 4, de 13/08)
- Assinado com `~/keystores/omeusalmo.jks`

---

## 1. O que vai nesta versão

Correções que o usuário sente:

- O app não baixa mais as fontes da internet. Quem instala sem rede vê a tipografia certa já na primeira abertura.
- A notificação do Salmo do dia passa a chegar no horário escolhido. Antes chegava três horas antes, porque o agendamento usava UTC.
- O número do Salmo deixa de aparecer cortado para quem aumentou a fonte do celular. Atingia 51 dos 150 Salmos.
- O app passa a respeitar o aumento de fonte do sistema até o dobro. Antes travava em 1,3x e ignorava o resto.
- A tela de Ajustes foi refeita: o seletor de tema deixa de quebrar a palavra "Sistema", o card do Salmo do dia explica o que faz e responde ao toque em qualquer ponto, e os botões pequenos demais foram corrigidos.
- Contraste corrigido no tema escuro, onde textos azuis pequenos ficavam ilegíveis.
- "Salmo diário" passa a se chamar "Salmo do dia", igual à loja e ao site.

---

## 2. Passo a passo do upload

Um passo por vez.

1. Abra https://play.google.com/console e entre com a conta do app.
2. Clique em **O meu Salmo**.
3. No menu da esquerda, clique em **Testar e lançar** e depois em **Produção**.
4. Clique no botão **Criar nova versão**, no canto superior direito.
5. Na caixa **App bundles**, clique em **Fazer upload** e escolha o arquivo:
   `/Users/jeffsilva/Dropbox/Claude/o-meu-salmo/app/build/app/outputs/bundle/release/app-release.aab`
6. Espere o processamento. Confira que aparece **Versão 5 (1.0.2)**. Se aparecer versão 4, o arquivo é o antigo, pare e me avise.
7. No campo **Nome da versão**, escreva `1.0.2`.
8. No campo **Notas da versão**, cole o texto do item 3 abaixo, dentro das marcações `pt-BR` que já estiverem lá.
9. Clique em **Próxima**.
10. Na tela seguinte, procure **Lançamento gradual**. Marque e coloque **20%**. Motivo no item 4.
11. Clique em **Salvar** e depois em **Enviar para revisão**.

A revisão do Google costuma levar de algumas horas a alguns dias. A 1.0.1 continua no ar até a nova ser aprovada.

---

## 3. Notas da versão (colar no Console)

```
O aplicativo agora funciona sem internet desde a primeira abertura, com a letra do jeito certo.

A notificação do Salmo do dia chega no horário que você escolheu.

Quem aumenta a letra no celular agora vê o aplicativo inteiro maior, e o número do Salmo não aparece mais cortado.

A tela de Ajustes ficou mais fácil de ler e de tocar, com melhor contraste no modo escuro.
```

---

## 4. Por que lançamento gradual em 20%

O teste em aparelho físico foi pulado. Duas coisas não puderam ser verificadas em emulador, porque emulador é sempre instalação limpa:

- **Renomear o canal de notificação.** Quem já ativou a notificação na 1.0.1 tem um canal chamado "Salmo diário" registrado no Android. A versão nova manda o sistema renomear para "Salmo do dia". Se falhar, essa pessoa vê o nome antigo nas configurações do Android enquanto o app diz o nome novo. É inconsistência visual, não quebra nada.
- **Sobrevivência das configurações.** As chaves de armazenamento não mudaram e isso foi conferido no código, então tema, favoritos, consentimento e horário devem sobreviver à atualização. Mas ninguém viu acontecer num aparelho que já tinha a versão antiga.

Com 20%, se algo aparecer nos relatórios de falha ou nas avaliações, dá para interromper o lançamento antes de atingir todo mundo.

**Como acompanhar:** Play Console → **Qualidade** → **Android vitals**, olhando a taxa de falhas nos primeiros dias. E as avaliações novas na aba **Avaliações**.

**Como subir para 100%:** depois de dois ou três dias sem falha nova, volte em **Produção**, abra a versão e clique em **Aumentar lançamento**.

---

## 5. Pendências separadas desta build

- **Corrigir "um minuto" na descrição da loja.** A descrição longa ainda diz "Respirar: um minuto de pausa guiada", e o app não tem timer de um minuto. Passo a passo no item 4c de `marketing/facebook-post-e-um-app-FINAL.md`. É edição de texto da ficha, independente da build.
- **Teste no aparelho da mãe do Jeff**, quando der: instalar por cima da versão antiga e conferir se o canal aparece como "Salmo do dia" em Configurações do Android, Apps, O meu Salmo, Notificações.
