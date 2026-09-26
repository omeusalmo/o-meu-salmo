import 'package:flutter/material.dart';

import '../../core/apoio/apoio_service.dart';
import '../../core/apoio/compra_service.dart';
import '../../core/apoio/elegibilidade.dart';
import 'apoio_sheet.dart';

/// Ouve o retorno à Home e dispara o que [Elegibilidade] permitir.
///
/// Envolve o conteúdo da Home. Não desenha nada — existe para ter o
/// `BuildContext` de uma tela viva na hora de abrir o sheet.
///
/// Por que "voltar à Home" e não "sair da leitura": o pedido antigo vivia num
/// `Future.delayed(10s)` dentro da tela de leitura e aparecia no meio do Salmo,
/// inclusive na coleção de Luto. Interromper a leitura é o oposto do que o app
/// se propõe a fazer.
///
/// As duas guardas de visibilidade importam:
/// • `TickerMode` está desligado no ramo inativo do `StatefulShellRoute` — sem
///   isto, ler um Salmo pela aba Salmos abriria o sheet numa Home que a pessoa
///   não está vendo;
/// • `ModalRoute.isCurrent` garante que nada está empilhado em cima.
class ApoioGatilho extends StatefulWidget {
  final Widget child;

  /// Injetável em teste. Em produção é o Google Play Billing.
  final CompraApoio Function()? criarCompra;

  const ApoioGatilho({super.key, required this.child, this.criarCompra});

  @override
  State<ApoioGatilho> createState() => _ApoioGatilhoState();
}

class _ApoioGatilhoState extends State<ApoioGatilho> {
  /// Respiro entre a Home reaparecer e o pedido chegar. Sem ele o sheet nasce
  /// junto com a tela e parece que estava esperando atrás da porta.
  static const _respiro = Duration(milliseconds: 500);

  bool _avaliando = false;

  @override
  void initState() {
    super.initState();
    ApoioService.instance.volta.addListener(_agendar);
    // Uma leitura pode ter terminado antes deste widget existir.
    _agendar();
  }

  @override
  void dispose() {
    ApoioService.instance.volta.removeListener(_agendar);
    super.dispose();
  }

  void _agendar() {
    // Nada esperando: não agenda timer nenhum. Sem esta linha, toda abertura da
    // Home deixaria um Future de meio segundo pendurado à toa — e todo teste de
    // widget da Home teria de drená-lo.
    if (!ApoioService.instance.temPendente) return;
    if (_avaliando) return;
    _avaliando = true;
    Future.delayed(_respiro, () async {
      _avaliando = false;
      if (!mounted) return;
      if (!TickerMode.valuesOf(context).enabled) return;
      if (ModalRoute.of(context)?.isCurrent == false) return;

      final gatilho = await ApoioService.instance.aoVoltarParaHome();
      if (gatilho != Gatilho.apoio) return;
      if (!mounted) return;

      await mostrarApoioSheet(
        context,
        comPergunta: true,
        compra: (widget.criarCompra ?? CompraApoioPlay.new)(),
        origem: 'gatilho',
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
