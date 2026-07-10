# Assinatura & Fingerprints — O meu Salmo

Referência dos certificados do app. **Não são segredo** (fingerprints públicos) — o segredo é o keystore (`~/keystores/omeusalmo.jks`, gitignored) e as senhas (`android/key.properties`, gitignored).

- **Package / applicationId:** `com.omeusalmo.salmos`
- **Play App Signing:** ativo — o app distribuído é re-assinado pelo Google (cert de assinatura), enquanto `omeusalmo.jks` é a chave de **upload**.
- Fonte dos fingerprints: Play Console → Configuração → Integridade do app → Assinatura de apps.

## Fingerprints

| Certificado | SHA-1 | SHA-256 |
|---|---|---|
| **Assinatura do app** (Google) | `36:7D:FE:8C:58:A9:18:D2:D6:2F:3A:87:48:47:79:8B:B4:54:CC:6F` | `72:7E:9D:6B:54:BA:AD:4A:2C:5D:92:8F:62:5F:26:53:CF:AE:4F:6E:B0:13:B6:06:1F:1A:72:99:16:BC:A8:58` |
| **Upload** (omeusalmo.jks) | `59:F9:6B:39:05:CB:87:A9:83:05:2A:CC:F8:73:86:35:D3:41:C3:0F` | `64:9B:65:EE:71:E2:E1:6D:BB:A2:B4:4B:1B:0D:03:85:BD:EF:C6:C2:AC:6E:E4:6A:36:F3:AE:22:B5:49:39:7E` |

## Onde cada um é usado

| Uso | Fingerprint | Estado |
|---|---|---|
| **App Links** (`docs/.well-known/assetlinks.json`) | SHA-256 de **ambos** os certs | ✅ configurado (2026-07-09) |
| **Restrição API key Firebase** (Cloud Console → o-meu-salmo → Credenciais) | SHA-1 de **ambos** os certs + package | ✅ configurado (2026-07-09) |
| **Firebase SHA fingerprints** (Console → apps → Android) | SHA-1/SHA-256 de ambos | registrar se Analytics/Crashlytics falhar |

> Regra: onde pedir fingerprint pro app da loja, use o do **cert de assinatura do app** (Google). Inclua o de **upload** também pra builds locais/teste funcionarem.
