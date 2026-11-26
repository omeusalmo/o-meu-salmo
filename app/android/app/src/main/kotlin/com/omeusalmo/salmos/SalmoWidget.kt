package com.omeusalmo.salmos

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Salmo do dia na tela inicial. Não escolhe salmo: lê a agenda que o Dart
 * grava (WidgetSalmo.publicar, a mesma de Home e notificação) e mostra a
 * entrada da data local de hoje.
 *
 * ponytail: troca de dia só via updatePeriodMillis (30 min). Teto: até ~30 min
 * de salmo de ontem após a meia-noite (mais se o aparelho estiver em Doze).
 * Se incomodar, alarme inexato na meia-noite chamando atualizarTodos.
 */
class SalmoWidget : AppWidgetProvider() {

    override fun onUpdate(ctx: Context, mgr: AppWidgetManager, ids: IntArray) {
        val views = montar(ctx)
        ids.forEach { mgr.updateAppWidget(it, views) }
    }

    companion object {
        const val EXTRA_ROTA = "omeusalmo.rota"

        fun atualizarTodos(ctx: Context) {
            val mgr = AppWidgetManager.getInstance(ctx)
            val ids = mgr.getAppWidgetIds(ComponentName(ctx, SalmoWidget::class.java))
            if (ids.isNotEmpty()) mgr.updateAppWidget(ids, montar(ctx))
        }

        private fun hoje(ctx: Context): JSONObject? = try {
            val json = ctx.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                .getString("flutter.widget_agenda", null) ?: return null
            JSONObject(json).optJSONObject(
                SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
            )
        } catch (_: Exception) {
            null
        }

        private fun montar(ctx: Context): RemoteViews {
            val v = RemoteViews(ctx.packageName, R.layout.widget_salmo)
            val dia = hoje(ctx)
            val rota: String
            if (dia != null) {
                val n = dia.getInt("numero")
                rota = "/salmos/$n"
                v.setTextViewText(R.id.widget_numero, "Salmo $n")
                v.setTextViewText(R.id.widget_titulo, dia.optString("titulo"))
                v.setTextViewText(R.id.widget_versiculo, dia.optString("versiculo"))
                v.setViewVisibility(R.id.widget_titulo, View.VISIBLE)
                v.setViewVisibility(R.id.widget_versiculo, View.VISIBLE)
                v.setViewVisibility(R.id.widget_fallback, View.GONE)
            } else {
                // Sem entrada para hoje (app não aberto há mais de 14 dias).
                rota = "/home"
                v.setTextViewText(R.id.widget_numero, ctx.getString(R.string.app_nome))
                v.setViewVisibility(R.id.widget_titulo, View.GONE)
                v.setViewVisibility(R.id.widget_versiculo, View.GONE)
                v.setViewVisibility(R.id.widget_fallback, View.VISIBLE)
            }
            // Fonte do sistema grande: 4x2 tem ~110dp de altura. Sem título e
            // com 1 linha de versículo, 2.0x ainda cabe (~122dp, no limite).
            if (ctx.resources.configuration.fontScale >= 1.3f) {
                v.setViewVisibility(R.id.widget_titulo, View.GONE)
                v.setInt(R.id.widget_versiculo, "setMaxLines", 1)
                v.setInt(R.id.widget_fallback, "setMaxLines", 1)
            }
            val abrir = Intent(ctx, MainActivity::class.java)
                .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                .putExtra(EXTRA_ROTA, rota)
            v.setOnClickPendingIntent(
                R.id.widget_raiz,
                PendingIntent.getActivity(
                    ctx, 0, abrir,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                ),
            )
            return v
        }
    }
}
