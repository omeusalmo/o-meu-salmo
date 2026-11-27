package com.omeusalmo.salmos

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.os.Bundle
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
        ids.forEach { mgr.updateAppWidget(it, montar(ctx, mgr, it)) }
    }

    override fun onReceive(ctx: Context, intent: Intent) {
        super.onReceive(ctx, intent)
        when (intent.action) {
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> atualizarTodos(ctx)
        }
    }

    // Launcher mudou o tamanho da célula (grade, rotação): recalcula o corte.
    override fun onAppWidgetOptionsChanged(
        ctx: Context, mgr: AppWidgetManager, id: Int, opcoes: Bundle,
    ) = mgr.updateAppWidget(id, montar(ctx, mgr, id))

    companion object {
        const val EXTRA_ROTA = "omeusalmo.rota"

        fun atualizarTodos(ctx: Context) {
            val mgr = AppWidgetManager.getInstance(ctx)
            val ids = mgr.getAppWidgetIds(ComponentName(ctx, SalmoWidget::class.java))
            ids.forEach { mgr.updateAppWidget(it, montar(ctx, mgr, it)) }
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

        private fun montar(ctx: Context, mgr: AppWidgetManager, id: Int): RemoteViews {
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
            // Corta só o que não cabe na altura real da célula. Retrato usa
            // MAX_HEIGHT, paisagem MIN_HEIGHT (convenção dos launchers).
            // Alturas em sp (linha ~1.3x do textSize): número 26, título 18,
            // versículo 20/linha; fixo em dp: padding 24 + margem 8.
            val retrato = ctx.resources.configuration.orientation ==
                Configuration.ORIENTATION_PORTRAIT
            val altura = mgr.getAppWidgetOptions(id).getInt(
                if (retrato) AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT
                else AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT,
                110,
            ).takeIf { it > 0 } ?: 110
            val fonte = ctx.resources.configuration.fontScale
            fun cabe(sp: Int) = sp * fonte + 32 <= altura
            if (!cabe(26 + 18 + 40)) v.setViewVisibility(R.id.widget_titulo, View.GONE)
            if (!cabe(26 + 40)) {
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
