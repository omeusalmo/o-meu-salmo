import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:salmos_app/core/constants/app_constants.dart';

/// A tela de Ajustes mostra a versão do app. Ler isso em tempo de execução
/// exigiria uma dependência nova (package_info_plus) e esta versão do Flutter
/// não gera `version.json` no bundle de assets, então o valor vive numa
/// constante. Este teste é o que impede a constante de envelhecer: se alguém
/// bumpar o pubspec e esquecer o AppConstants, a suíte falha.
void main() {
  test('AppConstants.appVersion bate com o pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match =
        RegExp(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)', multiLine: true)
            .firstMatch(pubspec);

    expect(match, isNotNull, reason: 'Não achei `version:` no pubspec.yaml.');

    expect(
      AppConstants.appVersion,
      match!.group(1),
      reason: 'O pubspec está em ${match.group(1)} e a tela de Ajustes mostra '
          '${AppConstants.appVersion}. Atualize AppConstants.appVersion.',
    );
  });
}
