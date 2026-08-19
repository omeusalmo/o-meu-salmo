# Upload da versão 1.0.2 (código 5)

**TL;DR:** AAB pronto em `app/build/app/outputs/bundle/release/app-release.aab`, 119,2 MB. Subir direto em **100%**, sem lançamento gradual. Notas da versão prontas no item 3.

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
10. Deixe o lançamento em **100%**, sem lançamento gradual. Motivo no item 4.
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

## 4. Por que 100% e não lançamento gradual

Decisão do Jeff em 18/08, e a base de usuários justifica.

Números do Play Console em 17/08 (últimos 28 dias): **113 impressões**, **37 aquisições**, **13 dispositivos ativos por mês**. Retenção de 7 dias ainda aparece como "dados indisponíveis", ou seja, não há volume suficiente nem para o Google calcular.

Com 13 dispositivos ativos, um lançamento em 20% atinge cerca de 2 ou 3 aparelhos. Isso não é amostra estatística, é anedota: um problema real teria grande chance de não aparecer, e o gradual só atrasaria a correção chegar em quem precisa. Lançamento gradual existe para proteger uma base grande de um defeito não detectado; aqui a base inteira já é do tamanho de uma amostra.

Além disso, esta versão corrige dois defeitos que atingem quem já usa o app hoje: a notificação chegando três horas antes e o número do Salmo cortado. Segurar a correção em 80% da base para proteger contra um risco cosmético não compensa.

### O que continua sem verificação em aparelho

Duas coisas não puderam ser testadas em emulador, porque emulador é sempre instalação limpa:

- **Renomear o canal de notificação.** Quem ativou a notificação na 1.0.1 tem um canal "Salmo diário" registrado no Android. A versão nova manda o sistema renomear. Se falhar, a pessoa vê o nome antigo nas configurações do Android enquanto o app diz o novo. Inconsistência visual, não quebra nada.
- **Sobrevivência das configurações.** As 15 chaves de armazenamento foram conferidas no código e nenhuma mudou, então tema, favoritos, consentimento e horário devem passar. Mas ninguém viu acontecer num aparelho que já tinha a versão antiga.

### Como acompanhar depois de publicar

- Play Console → **Qualidade** → **Android vitals**, taxa de falhas nos primeiros dias
- Aba **Avaliações**, comentários novos
- Se aparecer falha nova, dá para **interromper o lançamento** na própria tela de Produção, o que reverte para a 1.0.1 em quem ainda não atualizou

---

## 5. Pendências separadas desta build

- **Corrigir "um minuto" na descrição da loja.** A descrição longa ainda diz "Respirar: um minuto de pausa guiada", e o app não tem timer de um minuto. Passo a passo no item 4c de `marketing/facebook-post-e-um-app-FINAL.md`. É edição de texto da ficha, independente da build.
- **Teste no aparelho da mãe do Jeff**, quando der: instalar por cima da versão antiga e conferir se o canal aparece como "Salmo do dia" em Configurações do Android, Apps, O meu Salmo, Notificações.
