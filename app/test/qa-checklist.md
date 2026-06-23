# QA Manual — O meu Salmo (device físico)

> Rodar no celular Android **físico** (da mãe) antes de abrir o teste fechado.
> Emulador não pega bugs de áudio real, notificação agendada e comportamento offline.
> Marca ☑ o que passar, anota o que falhar.

**Build testado:** 1.0.0 (1) · **Device:** __________ · **Android:** ____ · **Data:** ____

---

## 1. Instalação e primeira abertura
- ☐ Instala pela Play Store (link de teste interno) sem erro
- ☐ Ícone na home = ícone cobalt "O meu Salmo" (não o robô padrão)
- ☐ Splash aparece (~3s) e some sozinha
- ☐ Primeira tela carrega sem crash, sem tela branca

## 2. Home / Salmo do dia
- ☐ Mostra Salmo do dia com número, título e versículo
- ☐ Data do dia correta
- ☐ Botão "Ler o salmo" abre a leitura certa
- ☐ Atalho "Respirar" visível e clicável

## 3. Coleções (8 emoções)
- ☐ As 8 aparecem: Ansiedade, Sono, Gratidão, Luto, Esperança, Perdão, Louvor, Proteção
- ☐ Abrir uma coleção lista os salmos dela
- ☐ Cada salmo da lista abre a leitura correta

## 4. Leitura + Áudio (crítico)
- ☐ Texto integral do salmo carrega
- ☐ Play inicia a narração em PT
- ☐ **Versículo ouvido acende/destaca na tela** (sincronia áudio↔texto)
- ☐ Pause/resume funciona
- ☐ Barra de progresso anda; arrastar reposiciona
- ☐ Áudio continua com a tela bloqueada / app em segundo plano
- ☐ Áudio para ao sair do salmo (não toca sobreposto)
- ☐ Testar salmo curto (117) e o mais longo (119)

## 5. Respirar (Salmo 46)
- ☐ Abre o modo Respirar
- ☐ Animação/ciclo de respiração roda suave (1 min)
- ☐ Texto/versículo do Salmo 46 aparece
- ☐ Sai limpo ao terminar ou ao fechar

## 6. Reflexão
- ☐ Reflexão do salmo aparece (texto da reflexão)
- ☐ Conteúdo coerente com o salmo aberto

## 7. Favoritos
- ☐ Marcar favorito (coração) num salmo
- ☐ Aparece na aba Favoritos
- ☐ Desmarcar remove da lista
- ☐ **Fechar e reabrir o app → favorito persiste** (storage local)

## 8. Compartilhar
- ☐ Compartilhar versículo gera **imagem** (não só texto)
- ☐ Imagem on-brand (cobalt, legível)
- ☐ Sheet de compartilhamento do Android abre (WhatsApp etc.)

## 9. Notificação "Salmo do dia" (crítico — só no físico)
- ☐ Toggle liga/desliga
- ☐ Editar horário salva o novo horário
- ☐ Ajustar pra ~2 min à frente → **notificação chega no horário**
- ☐ Tocar na notificação abre o app no salmo do dia
- ☐ Reiniciar o celular → notificação ainda dispara (sobrevive reboot)

## 10. Ajustes / Tema
- ☐ Tema Sistema / Claro / Escuro — troca aplica na hora
- ☐ Tema claro legível (contraste OK em todas as telas)
- ☐ Versão exibida = 1.0.0
- ☐ Fechar/reabrir mantém o tema escolhido

## 11. Offline (promessa da LP — crítico)
- ☐ Ativar modo avião
- ☐ Abrir salmos, ler texto → funciona
- ☐ **Tocar áudio → funciona offline** (áudio é bundle local)
- ☐ Coleções, favoritos, Respirar → funcionam sem rede
- ☐ Nenhuma tela trava esperando internet

## 12. Robustez
- ☐ Girar tela (se permitido) não quebra layout
- ☐ Fonte grande do sistema (Acessibilidade) não corta texto crítico
- ☐ Voltar (gesto/botão) navega correto, não fecha app à toa
- ☐ Uso de 5 min sem crash / sem travar / sem vazar áudio

---

## Bugs encontrados
| # | Tela | O que aconteceu | Severidade | Print? |
|---|------|-----------------|------------|--------|
| 1 | | | | |
| 2 | | | | |

> Severidade: **bloqueia** (não lança) / **alta** (lança mas corrige logo) / **baixa** (backlog).
> Bugs que bloqueiam → corrigir, rebuildar AAB, subir nova versão **antes** do teste fechado.
