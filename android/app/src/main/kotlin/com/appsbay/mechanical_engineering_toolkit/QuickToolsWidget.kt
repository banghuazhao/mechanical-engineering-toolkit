package com.appsbay.mechanical_engineering_toolkit

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService

/**
 * Which list a Quick Tools widget draws.
 *
 * Two widgets rather than one configurable one, as on iOS: the choice is
 * "favourites or recents", made once when the widget is placed, and two
 * entries in the widget picker say that more plainly than a configuration
 * screen would.
 */
enum class QuickToolsKind(
    val headerText: Int,
    val headerIcon: Int,
    val emptyText: Int,
) {
    FAVORITES(
        R.string.widget_favorites_header,
        R.drawable.ic_widget_star,
        R.string.widget_favorites_empty,
    ),
    RECENTS(
        R.string.widget_recents_header,
        R.drawable.ic_widget_history,
        R.string.widget_recents_empty,
    );

    fun tools(snapshot: ToolSnapshot): List<ToolSummary> = when (this) {
        FAVORITES -> snapshot.favoriteTools
        RECENTS -> snapshot.recentTools
    }

    val providerClass: Class<out QuickToolsWidget>
        get() = when (this) {
            FAVORITES -> FavoriteToolsWidget::class.java
            RECENTS -> RecentToolsWidget::class.java
        }
}

/**
 * A Home Screen widget listing tools, each row opening its calculator.
 *
 * Nothing here changes with time, so there is no update period: the app
 * calls [refreshAll] whenever favourites or history move, which is the only
 * thing that can change what the widget should show.
 */
abstract class QuickToolsWidget(private val kind: QuickToolsKind) : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (id in appWidgetIds) {
            manager.updateAppWidget(id, buildViews(context, kind, id))
        }
        manager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.widget_list)
    }

    companion object {
        /** Redraws every placed Quick Tools widget from the stored snapshot. */
        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            for (kind in QuickToolsKind.values()) {
                val ids = manager.getAppWidgetIds(ComponentName(context, kind.providerClass))
                if (ids.isEmpty()) continue
                for (id in ids) manager.updateAppWidget(id, buildViews(context, kind, id))
                manager.notifyAppWidgetViewDataChanged(ids, R.id.widget_list)
            }
        }

        private fun buildViews(context: Context, kind: QuickToolsKind, widgetId: Int): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.widget_quick_tools)
            views.setTextViewText(R.id.widget_header_title, context.getString(kind.headerText))
            views.setImageViewResource(R.id.widget_header_icon, kind.headerIcon)
            views.setTextViewText(R.id.widget_empty, context.getString(kind.emptyText))

            // The header opens the app at its library.
            views.setOnClickPendingIntent(
                R.id.widget_header,
                PendingIntent.getActivity(
                    context,
                    kind.ordinal,
                    Intent(Intent.ACTION_VIEW, Uri.parse("$DEEP_LINK_SCHEME://library"))
                        .setClass(context, MainActivity::class.java),
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                ),
            )

            // Distinct data per widget, or every placed widget would share one
            // cached factory and draw the same list.
            val service = Intent(context, QuickToolsWidgetService::class.java).apply {
                putExtra(QuickToolsWidgetService.EXTRA_KIND, kind.name)
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                data = Uri.parse("metoolkit-widget://${kind.name}/$widgetId")
            }
            views.setRemoteAdapter(R.id.widget_list, service)
            views.setEmptyView(R.id.widget_list, R.id.widget_empty)

            // Rows fill in their own deep link; the template only names the
            // activity, and has to be mutable for the fill-in to reach it.
            val mutable = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.FLAG_MUTABLE
            } else {
                0
            }
            views.setPendingIntentTemplate(
                R.id.widget_list,
                PendingIntent.getActivity(
                    context,
                    100 + kind.ordinal,
                    Intent(Intent.ACTION_VIEW).setClass(context, MainActivity::class.java),
                    PendingIntent.FLAG_UPDATE_CURRENT or mutable,
                ),
            )
            return views
        }
    }
}

class FavoriteToolsWidget : QuickToolsWidget(QuickToolsKind.FAVORITES)

class RecentToolsWidget : QuickToolsWidget(QuickToolsKind.RECENTS)

/** Supplies a Quick Tools widget's rows. */
class QuickToolsWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        val kind = runCatching {
            QuickToolsKind.valueOf(intent.getStringExtra(EXTRA_KIND) ?: "")
        }.getOrDefault(QuickToolsKind.FAVORITES)
        return Factory(applicationContext, kind)
    }

    private class Factory(
        private val context: Context,
        private val kind: QuickToolsKind,
    ) : RemoteViewsFactory {
        private var tools: List<ToolSummary> = emptyList()

        override fun onCreate() = load()

        override fun onDataSetChanged() = load()

        private fun load() {
            tools = kind.tools(ToolSnapshot.read(context)).take(MAX_ROWS)
        }

        override fun onDestroy() {}

        override fun getCount(): Int = tools.size

        override fun getViewAt(position: Int): RemoteViews {
            val tool = tools[position]
            return RemoteViews(context.packageName, R.layout.widget_tool_row).apply {
                setTextViewText(R.id.widget_row_title, tool.title)
                setTextViewText(R.id.widget_row_category, tool.category)
                setInt(R.id.widget_row_dot, "setColorFilter", categoryColor(tool.categoryId))
                // A locked tool still opens — the app answers with its own
                // upgrade sheet — but saying so up front keeps the tap honest.
                setViewVisibility(
                    R.id.widget_row_lock,
                    if (tool.locked) View.VISIBLE else View.GONE,
                )
                setOnClickFillInIntent(
                    R.id.widget_row,
                    Intent().setData(toolDeepLink(tool.id)),
                )
            }
        }

        override fun getLoadingView(): RemoteViews? = null

        override fun getViewTypeCount(): Int = 1

        override fun getItemId(position: Int): Long = tools[position].id.toLong()

        override fun hasStableIds(): Boolean = true
    }

    companion object {
        const val EXTRA_KIND = "kind"

        /** Enough to fill the tallest widget; the list scrolls past it. */
        private const val MAX_ROWS = 12

        /**
         * A colour per category, so the kind of tool reads at a glance. The
         * Flutter illustrations live in the app bundle and a widget cannot
         * draw them; a category mark is the honest stand-in, as on iOS. An
         * unknown category — one added in a newer app — gets the brand colour.
         */
        fun categoryColor(categoryId: String): Int = when (categoryId) {
            "mechanicsOfMaterial" -> 0xFF8B654B.toInt()
            "beamEngineering" -> 0xFF526A83.toInt()
            "theoryOfElasticity" -> 0xFF7B5EA7.toInt()
            "composite" -> 0xFF2E8B57.toInt()
            "statics" -> 0xFFB8860B.toInt()
            "utilities" -> 0xFF53665A.toInt()
            "machineDesign" -> 0xFF1E6FA8.toInt()
            "fluidsThermal" -> 0xFF0E8C9A.toInt()
            "thermodynamics" -> 0xFFC0502F.toInt()
            else -> 0xFF8B654B.toInt()
        }
    }
}
