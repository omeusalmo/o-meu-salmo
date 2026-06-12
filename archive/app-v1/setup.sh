#!/bin/bash
# Executa UMA vez para gerar os diretórios de plataforma (android/, ios/ etc.)
# e instalar as dependências. Não sobrescreve nada que já existe em lib/.
set -e

echo "Inicializando Salmos App..."

# flutter create em diretório existente com pubspec.yaml gera as pastas
# de plataforma sem tocar em arquivos já presentes — mas para main.dart
# o comportamento varia pela versão; salvamos como precaução.
if [ -f lib/main.dart ]; then
  cp lib/main.dart lib/main.dart.bak
fi

flutter create \
  --project-name salmos_app \
  --description "Salmos — Leitura e Meditação" \
  --org com.jeffsilva \
  --platforms android \
  .

# Restaura nosso main.dart caso o flutter create tenha substituído
if [ -f lib/main.dart.bak ]; then
  mv lib/main.dart.bak lib/main.dart
fi

flutter pub get

echo ""
echo "Projeto pronto!"
echo ""
echo "Para rodar:"
echo "  flutter run"
