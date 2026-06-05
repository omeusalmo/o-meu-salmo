// ─────────────────────────────────────────────────────────────────────────────
// CONFIGURAÇÃO DO FIREBASE
//
// Para habilitar analytics:
// 1. Acesse console.firebase.google.com
// 2. Crie um projeto "o-meu-salmo"
// 3. Adicione um app Android (pacote: com.jeffsilva.salmos_app)
// 4. Clique em "Configurações do Projeto" → aba "Geral" → role até seu app
// 5. Copie os valores de apiKey, appId, etc. e substitua abaixo
//
// Alternativamente, use o FlutterFire CLI para gerar este arquivo automaticamente:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Firebase não configurado para esta plataforma: $defaultTargetPlatform',
        );
    }
  }

  // TODO: substitua com os valores reais do console.firebase.google.com
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );
}
