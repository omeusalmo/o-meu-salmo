# Sessão Claude Code — Gerar os 150 Áudios dos Salmos

## O que preciso fazer nesta sessão

Gerar os 150 arquivos MP3 dos Salmos usando Google Cloud Text-to-Speech,
com a voz já escolhida, salvando direto em `assets/audios/` no formato
que o app Flutter espera. O script deve ser robusto: pausável, retomável,
e com controle de progresso para não regerar arquivos já prontos.

---

## Contexto

- **Voz escolhida:** `pt-BR-Chirp3-HD-Zubenelgenubi` (masculina, Chirp 3: HD)
- **Credencial:** `google-credentials.json` na raiz do projeto
- **Destino:** `assets/audios/` — já existe no projeto Flutter
- **Formato dos nomes:** `salmo_001.mp3`, `salmo_002.mp3`, ... `salmo_150.mp3`
- **Fonte do texto:** `assets/data/salmos.json` — já existe no projeto

---

## Tarefas desta sessão

### 1. Criar o script `gerar_audios.py` na raiz do projeto

O script deve:

1. Ler as credenciais de `google-credentials.json`
2. Ler todos os salmos de `assets/data/salmos.json`
3. Para cada salmo, montar o texto completo concatenando todos os versículos
   com quebra de linha entre eles
4. Chamar a API Google Cloud TTS com os parâmetros abaixo
5. Salvar o resultado em `assets/audios/salmo_NNN.mp3` (número com zero à esquerda)
6. **Pular arquivos que já existem** — para poder retomar se interrompido
7. Aguardar 0.5 segundo entre chamadas para não exceder rate limits

**Parâmetros da API:**
```python
voice = texttospeech.VoiceSelectionParams(
    language_code="pt-BR",
    name="pt-BR-Chirp3-HD-Zubenelgenubi"
)
audio_config = texttospeech.AudioConfig(
    audio_encoding=texttospeech.AudioEncoding.MP3,
    speaking_rate=0.92,  # ligeiramente mais lento que o padrão — mais solene
    pitch=0.0
)
```

**Output no console durante a execução:**
```
[  1/150] ✅ Salmo 1   → assets/audios/salmo_001.mp3 (32.4 KB)
[  2/150] ⏭️  Salmo 2   → já existe, pulando
[  3/150] ✅ Salmo 3   → assets/audios/salmo_003.mp3 (28.1 KB)
[  3/150] ❌ Salmo 3   → erro: [mensagem] — continuando...
```

**Ao final:**
```
─────────────────────────────────
✅ Gerados:  148
⏭️  Pulados:    2 (já existiam)
❌ Erros:      0
Tempo total: 4m 32s
─────────────────────────────────
Se houver erros, rode o script novamente — ele retoma de onde parou.
```

### 2. Tratar erros sem parar tudo

Se uma chamada falhar (timeout, rate limit, etc.), o script deve:
- Registrar o erro no console com `❌`
- Continuar para o próximo salmo
- Ao final, listar quais salmos falharam
- **Não** interromper a execução

### 3. Arquivo de log

Salvar um arquivo `audio_testes/geracao.log` com:
- Data/hora de início e fim
- Status de cada salmo (gerado, pulado, erro)
- Erros completos para debug

### 4. Verificação final

Ao concluir, o script deve verificar:
- Quantos arquivos existem em `assets/audios/`
- Se todos os 150 estão presentes
- Tamanho médio dos arquivos (para detectar arquivos vazios/corrompidos)

```
─────────────────────────────────
Verificação final:
📁 Arquivos em assets/audios/: 150/150
📊 Tamanho médio: 41.3 KB
⚠️  Arquivos suspeitos (< 5 KB): nenhum
✅ Tudo pronto para embutir no app.
─────────────────────────────────
```

---

## Dependências

```
google-cloud-texttospeech
```

Já deve estar instalado da sessão anterior. Se não:
`pip install google-cloud-texttospeech`

---

## O que NÃO fazer nesta sessão

- Não modificar o `salmos.json`
- Não mexer no código Flutter
- Não deletar arquivos já existentes em `assets/audios/`

---

## Definição de "sessão concluída"

- Script `gerar_audios.py` criado e rodando
- 150 arquivos MP3 em `assets/audios/`, todos com tamanho > 5 KB
- Log salvo em `audio_testes/geracao.log`
- Console mostra a verificação final com 150/150

---

## Observação sobre tamanho do app

150 arquivos MP3 de Salmos terão aproximadamente 5–7 MB no total.
Isso é aceitável para um app Android — não é necessário nenhum ajuste.
