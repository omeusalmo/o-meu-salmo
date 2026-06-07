# Roadmap Gerente — O meu Salmo
_Atualizado: 2026-06-07. Versão pós-construção do MVP, pré-lançamento._

---

## Estado atual do produto

**App Flutter:** MVP completo e funcional.

| Feature | Status |
|---|---|
| 150 salmos com reflexão + reflexao_pergunta | ✅ |
| 8 coleções emocionais | ✅ |
| Favoritos (offline, SharedPreferences) | ✅ |
| Salmo do dia (Home) | ✅ |
| Notificações locais (ciclo por dia do ano) | ✅ |
| Compositor de imagem + compartilhamento | ✅ |
| Firebase Analytics (6 eventos) | ✅ |
| Seção Apoie (Pix + bottom sheet) | ✅ |
| Sugestões via mailto | ✅ |
| WCAG 2.1 AA (contraste acessível) | ✅ |
| Release signing configurado (key.properties) | ✅ |
| Política de privacidade (HTML local) | ✅ |
| Landing Page | ✅ |

**Áudio narrado:** não implementado (fora do MVP).

---

## Bloqueadores de lançamento (Fase 2 crítica)

Estes itens **bloqueiam** a publicação no Google Play:

| # | Bloqueador | Responsável | Ação |
|---|---|---|---|
| B1 | Conta Google Play Console (US$ 25) | Jeff | Criar em play.google.com/console |
| B2 | Política de privacidade em URL pública | tech-lead-lp | Publicar `privacy_policy.html` na LP ou GitHub Pages |
| B3 | Screenshots do app (mín. 2, ideal 8) | Jeff + design | Capturar no emulador/device real |
| B4 | Feature Graphic (1024×500 px) | design | Criar com identidade visual |
| B5 | Closed testing: 12 testadores por 14 dias | Jeff | Convidar testers no Play Console |

---

## Sprint A — Lançamento (prioridade máxima)

_Meta: app publicado no Google Play._

### A1 · Publicação da política de privacidade
- Fazer deploy da `privacy_policy.html` em URL pública (GitHub Pages ou subdomínio da LP)
- Registrar URL no Play Console e no app (Ajustes > Política)

### A2 · ASO (App Store Optimization)
- **Título:** ≤30 chars, inclui "salmos" e emoção principal
- **Descrição curta:** ≤80 chars, benefício emocional + CTA
- **Descrição longa:** ≤4000 chars, palavras-chave: salmos, ansiedade, oração, dormir, gratidão, reflexão
- **Tags/categorias:** Lifestyle + Books & Reference

### A3 · Materiais visuais da loja
- 8 screenshots no formato portrait 9:16 (Phone)
- 1 Feature Graphic 1024×500 px
- Ícone já existe no app — exportar em 512×512 PNG

### A4 · Closed testing
- Criar track de testes interno no Play Console
- 12 testers × 14 dias (exigência atual do Google)
- Coletar feedback: bugs, UX, clareza do onboarding

### A5 · Validação final pre-store
- `flutter build appbundle --release` sem erros
- Testar install do .aab num device físico Android
- Verificar Analytics disparando (Firebase DebugView)

---

## Sprint B — Pós-lançamento imediato (semanas 1-4)

_Meta: primeiros 100 usuários, retenção D7 > 30%._

### B1 · Monitoramento
- Firebase Analytics: DAU, salmo_read, share_card, collection_opened
- Crashes: Firebase Crashlytics (adicionar ao app)
- Reviews: responder todas no Play Console na primeira semana

### B2 · Crescimento orgânico
- Compartilhamento via compositor de imagem (já implementado) — é o motor principal
- Divulgação em grupos de WhatsApp/Telegram de cristãos brasileiros
- Posts no Instagram com versículos usando visual do app

### B3 · Quick wins de UX
- Onboarding de 1 slide (mostrar as coleções na primeira abertura)
- Rating prompt na sessão 3 (após salmo lido)
- Deep link para salmo específico (para campanhas de divulgação)

---

## Sprint C — Crescimento (meses 2-3)

_Só iniciar com sinal de retenção D30 > 20%._

### C1 · Monetização: anúncios
- Integrar AdMob (banner na loja, não no conteúdo espiritual)
- Posicionamento: banner abaixo do compositor, não na leitura do salmo
- Meta: cobrir custos de infra antes de freemium

### C2 · Monetização: freemium
- Camada premium: áudio narrado, sem anúncios, widget na tela inicial
- Entitlements já têm base no app — ativar com produto IAP no Play Console
- Preço sugerido: R$ 9,90/mês ou R$ 69,90/ano

### C3 · Conteúdo premium
- Áudio TTS narrado para salmos das coleções (começar pelas 8 coleções)
- Novas coleções: Casamento, Família, Trabalho, Doença
- Reflexões expandidas (versão longa) como conteúdo premium

### C4 · Expansão de plataforma
- Widget Android (salmo do dia na home screen)
- iOS: só após Android estável e com receita

---

## Decisões fixadas (não renegociar sem motivo)

| Decisão | Razão |
|---|---|
| Sem Google Play Billing no MVP | Sem mecanismo de monetização ainda |
| Ads + freemium no futuro (não IAP de compra) | Menor fricção de entrada, público católico/evangélico sensível a paywall |
| Android-first | 80%+ dos cristãos brasileiros usam Android |
| Offline-first (JSON local) | Usuários em zonas rurais, sem dados |
| Sem servidor backend no MVP | Zero custo operacional até ter retenção |

---

## KPIs de saúde do produto

| Métrica | Meta D30 | Crítico |
|---|---|---|
| Retenção D7 | >30% | <15% = revisar onboarding |
| Retenção D30 | >20% | <10% = pivotar conteúdo |
| Salmos lidos/sessão | >2 | <1 = problema de navegação |
| Taxa de compartilhamento | >5% das sessões | <1% = revisar compositor |
| Rating médio | >4.3 | <4.0 = atuar em reviews |

---

## Time de agentes

| Agente | Frente | Sprint atual |
|---|---|---|
| `gerente` | Estratégia, coordenação, ASO | Sprint A (A2) |
| `tech-lead-app` | Flutter, bugs, features | Sprint A (A5) + B3 |
| `tech-lead-lp` | Landing page, privacidade pública | Sprint A (A1) |
| `tech-lead-loja` | Play Console, screenshots, ASO copy | Sprint A (A2, A3) |
