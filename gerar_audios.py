#!/usr/bin/env python3
"""
Gera os 150 MP3 dos Salmos com a voz pt-BR-Chirp3-HD-Zubenelgenubi.
Retomável: pula arquivos já existentes.

Uso: python3 gerar_audios.py
"""

import json
import os
import time
import warnings
from datetime import datetime
from pathlib import Path

warnings.filterwarnings("ignore")

# ── Caminhos ──────────────────────────────────────────────────────────────────

ROOT        = Path(__file__).parent
CREDENTIALS = ROOT / "app" / "google-credentials.json"
SALMOS_JSON = ROOT / "app" / "assets" / "salmos.json"
AUDIO_DIR   = ROOT / "app" / "assets" / "audios"
LOG_FILE    = ROOT / "audio_testes" / "geracao.log"

VOZ         = "pt-BR-Chirp3-HD-Zubenelgenubi"
LANG        = "pt-BR"
RATE        = 0.92
DELAY       = 0.5  # segundos entre chamadas
TIMEOUT     = 90   # segundos por chamada à API
MAX_CHARS   = 1500 # limite por chunk — conservador pra evitar "sentence too long"
MAX_RETRIES = 3    # tentativas por chunk em caso de erro transiente
DELAY       = 2.0  # delay maior pra evitar rate limit após muitas chamadas

# ── Helpers ───────────────────────────────────────────────────────────────────

def nome_arquivo(numero: int) -> Path:
    return AUDIO_DIR / f"salmo_{numero:03d}.mp3"


def texto_salmo(salmo: dict) -> str:
    versiculos = []
    for v in salmo["versiculos"]:
        v = v.rstrip()
        # normaliza fim de versículo: ; → . para o TTS reconhecer como frase
        if v.endswith(";") or v.endswith(","):
            v = v[:-1] + "."
        elif v and v[-1] not in ".!?":
            v = v + "."
        versiculos.append(v)
    return "\n".join(versiculos)


def dividir_em_chunks(texto: str, max_chars: int = MAX_CHARS) -> list[str]:
    """Divide texto em chunks por versículo sem exceder max_chars."""
    if len(texto) <= max_chars:
        return [texto]
    versiculos = texto.split("\n")
    chunks, atual = [], ""
    for v in versiculos:
        candidato = f"{atual}\n{v}" if atual else v
        if len(candidato) <= max_chars:
            atual = candidato
        else:
            if atual:
                chunks.append(atual)
            atual = v
    if atual:
        chunks.append(atual)
    return chunks


def log(msg: str, fp):
    print(msg)
    fp.write(msg + "\n")
    fp.flush()


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    # Validações
    if not CREDENTIALS.exists():
        print(f"❌ Credencial não encontrada: {CREDENTIALS}")
        return
    if not SALMOS_JSON.exists():
        print(f"❌ JSON não encontrado: {SALMOS_JSON}")
        return

    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = str(CREDENTIALS)

    try:
        from google.cloud import texttospeech
    except ImportError:
        print("❌ Execute: pip install google-cloud-texttospeech")
        return

    AUDIO_DIR.mkdir(parents=True, exist_ok=True)
    LOG_FILE.parent.mkdir(parents=True, exist_ok=True)

    data     = json.loads(SALMOS_JSON.read_text(encoding="utf-8"))
    salmos   = data["salmos"]
    total    = len(salmos)
    inicio   = datetime.now()

    client = texttospeech.TextToSpeechClient()

    voice = texttospeech.VoiceSelectionParams(
        language_code=LANG,
        name=VOZ,
    )
    audio_config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.MP3,
        speaking_rate=RATE,
        pitch=0.0,
    )

    gerados  = []
    pulados  = []
    erros    = []

    with open(LOG_FILE, "w", encoding="utf-8") as fp:
        log(f"=== Geração de Áudio — Meu Salmo ===", fp)
        # pausa inicial para resetar possível rate limit
        faltantes = [s for s in salmos if not nome_arquivo(s["numero"]).exists()]
        if faltantes and len(faltantes) < 20:
            log(f"Aguardando 15s antes de iniciar (rate limit reset)...", fp)
            time.sleep(15)
        log(f"Início: {inicio.strftime('%Y-%m-%d %H:%M:%S')}", fp)
        log(f"Voz: {VOZ}  |  Rate: {RATE}  |  Total: {total}", fp)
        log("", fp)

        for salmo in salmos:
            num     = salmo["numero"]
            arquivo = nome_arquivo(num)
            idx     = f"[{num:3d}/{total}]"

            if arquivo.exists():
                msg = f"{idx} ⏭️  Salmo {num:<3} → já existe, pulando"
                log(msg, fp)
                pulados.append(num)
                continue

            texto = texto_salmo(salmo)

            try:
                chunks = dividir_em_chunks(texto)
                audio_total = b""
                for i, chunk in enumerate(chunks):
                    synthesis_input = texttospeech.SynthesisInput(text=chunk)
                    # retry com backoff exponencial
                    for tentativa in range(MAX_RETRIES):
                        try:
                            response = client.synthesize_speech(
                                input=synthesis_input,
                                voice=voice,
                                audio_config=audio_config,
                                timeout=TIMEOUT,
                            )
                            audio_total += response.audio_content
                            break
                        except Exception as chunk_err:
                            if tentativa < MAX_RETRIES - 1:
                                espera = 5 * (2 ** tentativa)  # 5s, 10s, 20s
                                log(f"         ⚠️  chunk {i+1}/{len(chunks)} erro (tentativa {tentativa+1}): {chunk_err} — aguardando {espera}s", fp)
                                time.sleep(espera)
                            else:
                                raise chunk_err
                    if len(chunks) > 1:
                        time.sleep(0.5)
                arquivo.write_bytes(audio_total)
                kb  = len(audio_total) / 1024
                chunks_info = f" [{len(chunks)} chunks]" if len(chunks) > 1 else ""
                msg = f"{idx} ✅ Salmo {num:<3} → {arquivo.name} ({kb:.1f} KB){chunks_info}"
                log(msg, fp)
                gerados.append(num)

            except Exception as e:
                msg = f"{idx} ❌ Salmo {num:<3} → erro: {e}"
                log(msg, fp)
                erros.append({"salmo": num, "erro": str(e)})

            time.sleep(DELAY)

        # ── Resumo ────────────────────────────────────────────────────────────
        fim      = datetime.now()
        duracao  = fim - inicio
        mins     = int(duracao.total_seconds() // 60)
        segs     = int(duracao.total_seconds() % 60)

        log("", fp)
        log("─" * 45, fp)
        log(f"✅ Gerados:  {len(gerados)}", fp)
        log(f"⏭️  Pulados:  {len(pulados)} (já existiam)", fp)
        log(f"❌ Erros:    {len(erros)}", fp)
        log(f"Tempo total: {mins}m {segs}s", fp)
        log("─" * 45, fp)

        if erros:
            log("", fp)
            log("Salmos com erro (rode novamente para retentar):", fp)
            for e in erros:
                log(f"  • Salmo {e['salmo']}: {e['erro'][:100]}", fp)

        # ── Verificação final ─────────────────────────────────────────────────
        log("", fp)
        log("─" * 45, fp)
        log("Verificação final:", fp)

        mp3s    = sorted(AUDIO_DIR.glob("salmo_*.mp3"))
        qtd     = len(mp3s)
        tamanhos = [f.stat().st_size for f in mp3s]
        media_kb = (sum(tamanhos) / len(tamanhos) / 1024) if tamanhos else 0
        suspeitos = [f.name for f in mp3s if f.stat().st_size < 5 * 1024]

        log(f"📁 Arquivos em assets/audios/: {qtd}/150", fp)
        log(f"📊 Tamanho médio: {media_kb:.1f} KB", fp)

        if suspeitos:
            log(f"⚠️  Arquivos suspeitos (< 5 KB): {', '.join(suspeitos)}", fp)
        else:
            log("⚠️  Arquivos suspeitos (< 5 KB): nenhum", fp)

        if qtd == 150 and not suspeitos:
            log("✅ Tudo pronto para embutir no app.", fp)
        else:
            log("⚠️  Execute novamente para completar os arquivos faltantes.", fp)

        log("─" * 45, fp)
        log(f"Log salvo em: {LOG_FILE}", fp)


if __name__ == "__main__":
    main()
