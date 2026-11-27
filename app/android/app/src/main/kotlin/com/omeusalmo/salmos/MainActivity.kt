package com.omeusalmo.salmos

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var canal: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        canal = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "omeusalmo/widget").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "atualizar" -> { SalmoWidget.atualizarTodos(this@MainActivity); result.success(null) }
                    "rotaInicial" -> result.success(consumirRota(intent))
                    else -> result.notImplemented()
                }
            }
        }
    }

    // Recriada depois de o sistema matar o processo: o getIntent() é o do
    // toque antigo no widget (o removeExtra anterior só limpou uma cópia).
    // Sem isso, abrir pelo ícone dias depois levaria ao salmo velho.
    override fun onCreate(savedInstanceState: Bundle?) {
        if (savedInstanceState != null) intent?.removeExtra(SalmoWidget.EXTRA_ROTA)
        super.onCreate(savedInstanceState)
    }

    // singleTop: toque no widget com o app vivo chega aqui.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        consumirRota(intent)?.let { canal?.invokeMethod("abrir", it) }
    }

    /** Uma vez só; reabrir pelos recentes reentrega o intent original. */
    private fun consumirRota(i: Intent?): String? {
        if (i == null || i.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) return null
        return i.getStringExtra(SalmoWidget.EXTRA_ROTA)?.also { i.removeExtra(SalmoWidget.EXTRA_ROTA) }
    }
}
