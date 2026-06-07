#!/usr/bin/env python3
"""
Testa vozes Chirp 3 HD do Google TTS para o app Meu Salmo.
Gera um MP3 do Salmo 23 para cada voz, salvo em audio_testes/.

Pré-requisito: pip install google-cloud-texttospeech
"""

import os
import sys
from pathlib import Path

# ── Configuração ──────────────────────────────────────────────────────────────

CREDENTIALS_FILE = Path(__file__).parent / "app" / "google-credentials.json"
OUTPUT_DIR = Path(__file__).parent / "audio_testes"

SALMO_23 = """O Senhor é o meu pastor; nada me faltará.
Deitar-me faz em pastos verdejantes; guia-me mansamente a águas tranquilas.
Refrigera a minha alma; guia-me nas veredas da justiça por amor do seu nome.
Ainda que eu ande pelo vale da sombra da morte, não temerei mal algum, porque tu estás comigo; a tua vara e o teu cajado me consolam.
Preparas uma mesa perante mim na presença dos meus inimigos; unges com óleo a minha cabeça, o meu cálice transborda.
Certamente que a bondade e a misericórdia me seguirão todos os dias da minha vida, e habitarei na casa do Senhor por longos dias."""

VOZES = [
    # femininas
    {"name": "pt-BR-Chirp3-HD-Achernar",      "lang": "pt-BR", "genero": "feminina"},
    {"name": "pt-BR-Chirp3-HD-Aoede",         "lang": "pt-BR", "genero": "feminina"},
    {"name": "pt-BR-Chirp3-HD-Autonoe",       "lang": "pt-BR", "genero": "feminina"},
    {"name": "pt-BR-Chirp3-HD-Callirrhoe",    "lang": "pt-BR", "genero": "feminina"},
    {"name": "pt-BR-Chirp3-HD-Despina",       "lang": "pt-BR", "genero": "feminina"},
    {"name": "pt-BR-Chirp3-HD-Erinome",       "lang": "pt-BR", "genero": "feminina"},
    {"name": "pt-BR-Chirp3-HD-Gacrux",        "lang": "pt-BR", "genero": "feminina"},
    {"name": "pt-BR-Chirp3-HD-Kore",          "lang": "pt-BR", "genero": "feminina"},
    {"name": "pt-BR-Chirp3-HD-Laomedeia",     "lang": "pt-BR", "genero": "feminina"},
    {"name": "pt-BR-Chirp3-HD-Leda",          "lang": "pt-BR", "genero": "feminina"},
    {"name": "pt-BR-Chirp3-HD-Pulcherrima",   "lang": "pt-BR", "genero": "feminina"},
    {"name": "pt-BR-Chirp3-HD-Sulafat",       "lang": "pt-BR", "genero": "feminina"},
    {"name": "pt-BR-Chirp3-HD-Vindemiatrix",  "lang": "pt-BR", "genero": "feminina"},
    {"name": "pt-BR-Chirp3-HD-Zephyr",        "lang": "pt-BR", "genero": "feminina"},
    # masculinas
    {"name": "pt-BR-Chirp3-HD-Achird",        "lang": "pt-BR", "genero": "masculina"},
    {"name": "pt-BR-Chirp3-HD-Algenib",       "lang": "pt-BR", "genero": "masculina"},
    {"name": "pt-BR-Chirp3-HD-Algieba",       "lang": "pt-BR", "genero": "masculina"},
    {"name": "pt-BR-Chirp3-HD-Alnilam",       "lang": "pt-BR", "genero": "masculina"},
    {"name": "pt-BR-Chirp3-HD-Charon",        "lang": "pt-BR", "genero": "masculina"},
    {"name": "pt-BR-Chirp3-HD-Enceladus",     "lang": "pt-BR", "genero": "masculina"},
    {"name": "pt-BR-Chirp3-HD-Fenrir",        "lang": "pt-BR", "genero": "masculina"},
    {"name": "pt-BR-Chirp3-HD-Iapetus",       "lang": "pt-BR", "genero": "masculina"},
    {"name": "pt-BR-Chirp3-HD-Orus",          "lang": "pt-BR", "genero": "masculina"},
    {"name": "pt-BR-Chirp3-HD-Puck",          "lang": "pt-BR", "genero": "masculina"},
    {"name": "pt-BR-Chirp3-HD-Rasalgethi",    "lang": "pt-BR", "genero": "masculina"},
    {"name": "pt-BR-Chirp3-HD-Sadachbia",     "lang": "pt-BR", "genero": "masculina"},
    {"name": "pt-BR-Chirp3-HD-Sadaltager",    "lang": "pt-BR", "genero": "masculina"},
    {"name": "pt-BR-Chirp3-HD-Schedar",       "lang": "pt-BR", "genero": "masculina"},
    {"name": "pt-BR-Chirp3-HD-Umbriel",       "lang": "pt-BR", "genero": "masculina"},
    {"name": "pt-BR-Chirp3-HD-Zubenelgenubi", "lang": "pt-BR", "genero": "masculina"},
]

# ── Verificações iniciais ─────────────────────────────────────────────────────

def verificar_gitignore():
    gitignore = Path(__file__).parent / ".gitignore"
    entrada = "google-credentials.json"

    if gitignore.exists():
        conteudo = gitignore.read_text(encoding="utf-8")
        if entrada not in conteudo:
            with open(gitignore, "a") as f:
                f.write(f"\n{entrada}\n")
            print(f"✅ google-credentials.json adicionado ao .gitignore existente")
        else:
            print(f"✅ google-credentials.json protegido no .gitignore")
    else:
        gitignore.write_text(f"{entrada}\n", encoding="utf-8")
        print(f"✅ .gitignore criado com google-credentials.json protegido")


def verificar_credenciais():
    if not CREDENTIALS_FILE.exists():
        print(f"\n❌ Arquivo não encontrado: {CREDENTIALS_FILE}")
        print("   Baixe as credenciais da Service Account no Google Cloud Console")
        print("   e salve como 'google-credentials.json' na raiz do projeto.")
        sys.exit(1)
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = str(CREDENTIALS_FILE)
    print(f"✅ Credenciais carregadas: {CREDENTIALS_FILE.name}")


# ── Geração de áudio ──────────────────────────────────────────────────────────

def gerar_audio(client, voz_name: str, lang_code: str, texto: str) -> bytes:
    from google.cloud import texttospeech

    synthesis_input = texttospeech.SynthesisInput(text=texto)

    voice = texttospeech.VoiceSelectionParams(
        language_code=lang_code,
        name=voz_name,
    )

    audio_config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.MP3,
        speaking_rate=0.95,  # levemente mais lento — melhor para narração sacra
    )

    response = client.synthesize_speech(
        input=synthesis_input,
        voice=voice,
        audio_config=audio_config,
    )
    return response.audio_content


def nome_arquivo(voz_name: str) -> str:
    # pt-BR-Chirp3-HD-Aoede → salmo23_Aoede.mp3
    sufixo = voz_name.split("-")[-1]
    return f"salmo23_{sufixo}.mp3"


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    print("\n=== Teste de Vozes — Meu Salmo (Salmo 23) ===\n")

    verificar_gitignore()
    verificar_credenciais()

    try:
        from google.cloud import texttospeech
    except ImportError:
        print("\n❌ Biblioteca não instalada.")
        print("   Execute: pip install google-cloud-texttospeech")
        sys.exit(1)

    OUTPUT_DIR.mkdir(exist_ok=True)
    print(f"✅ Pasta de saída: {OUTPUT_DIR}\n")

    client = texttospeech.TextToSpeechClient()

    sucesso = []
    falha = []

    for voz in VOZES:
        voz_name = voz["name"]
        lang = voz["lang"]
        genero = voz["genero"]
        arquivo = OUTPUT_DIR / nome_arquivo(voz_name)

        print(f"🔊 Gerando {voz_name} ({genero}, {lang})...")

        try:
            audio = gerar_audio(client, voz_name, lang, SALMO_23)
            arquivo.write_bytes(audio)
            tamanho_kb = len(audio) / 1024
            print(f"   ✅ {voz_name} → {arquivo.name} ({tamanho_kb:.1f} KB)")
            sucesso.append({"voz": voz_name, "arquivo": arquivo.name, "kb": tamanho_kb})

        except Exception as e:
            erro_msg = str(e)
            print(f"   ❌ {voz_name} ({lang}) → erro: {erro_msg}")

            # Tenta en-US para confirmar que a API funciona
            if lang == "pt-BR":
                voz_en = voz_name.replace("pt-BR", "en-US")
                lang_en = "en-US"
                arquivo_en = OUTPUT_DIR / f"salmo23_{voz_name.split('-')[-1]}_en_fallback.mp3"
                print(f"   🔄 Tentando fallback en-US: {voz_en}...")
                try:
                    audio = gerar_audio(client, voz_en, lang_en, "The Lord is my shepherd; I shall not want.")
                    arquivo_en.write_bytes(audio)
                    print(f"   ⚠️  {voz_en} (en-US) funcionou — voz existe mas pt-BR indisponível")
                    print(f"       Salvo como: {arquivo_en.name}")
                except Exception as e2:
                    print(f"   ❌ Fallback en-US também falhou: {e2}")

            falha.append({"voz": voz_name, "erro": erro_msg})

    # ── Resumo ────────────────────────────────────────────────────────────────
    print("\n" + "=" * 52)
    print("RESUMO")
    print("=" * 52)

    if sucesso:
        print(f"\n✅ Vozes geradas ({len(sucesso)}):")
        for v in sucesso:
            print(f"   • {v['voz']} → {v['arquivo']} ({v['kb']:.1f} KB)")

    if falha:
        print(f"\n❌ Vozes com falha ({len(falha)}):")
        for v in falha:
            print(f"   • {v['voz']}: {v['erro'][:80]}...")

    print(f"\nArquivos em: {OUTPUT_DIR.resolve()}")
    print("\nPróximo passo: ouvir os MP3s e escolher a voz para os 150 salmos.\n")


if __name__ == "__main__":
    main()
