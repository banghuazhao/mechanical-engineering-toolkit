package com.appsbay.mechanical_engineering_toolkit

import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.os.Build

/**
 * The shortcuts a long press on the launcher icon offers: the static Unit
 * Converter (declared in `res/xml/shortcuts.xml`), then the user's
 * favourites and, while they have none, their recent tools.
 *
 * Launchers show only a handful — four or five in all — so the list is cut
 * to what fits beside the static one rather than handed over in full for
 * the launcher to truncate unpredictably.
 */
object LauncherShortcuts {
    /** Dynamic shortcuts on top of the one static shortcut. */
    private const val MAX_DYNAMIC = 3

    fun update(context: Context, snapshot: ToolSnapshot) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) return
        val manager = context.getSystemService(ShortcutManager::class.java) ?: return

        val favorites = snapshot.favoriteIds.isNotEmpty()
        val tools = (if (favorites) snapshot.favoriteTools else snapshot.recentTools)
            // The Unit Converter already has its static shortcut.
            .filter { it.id != UNIT_CONVERTER_ID }
        val limit = minOf(MAX_DYNAMIC, manager.maxShortcutCountPerActivity - 1)
        val icon = Icon.createWithResource(
            context,
            if (favorites) R.drawable.ic_shortcut_star else R.drawable.ic_shortcut_history,
        )

        val shortcuts = tools.take(limit.coerceAtLeast(0)).mapIndexed { rank, tool ->
            ShortcutInfo.Builder(context, "tool-${tool.id}")
                .setShortLabel(tool.title.take(SHORT_LABEL_LIMIT))
                .setLongLabel(tool.title)
                .setIcon(icon)
                .setRank(rank)
                .setIntent(
                    Intent(Intent.ACTION_VIEW, toolDeepLink(tool.id))
                        .setClass(context, MainActivity::class.java),
                )
                .build()
        }

        try {
            manager.dynamicShortcuts = shortcuts
        } catch (error: IllegalStateException) {
            // Rate-limited while the app is in the background; the next
            // publish, which comes with the next calculation, tries again.
        }

        // A tool pinned to the home screen that is no longer a favourite
        // keeps working — it is the user's — but its label follows a
        // language change.
        val pinned = manager.pinnedShortcuts.mapNotNull { pinned ->
            val id = pinned.id.removePrefix("tool-").toIntOrNull() ?: return@mapNotNull null
            val tool = snapshot.tools.firstOrNull { it.id == id } ?: return@mapNotNull null
            ShortcutInfo.Builder(context, pinned.id)
                .setShortLabel(tool.title.take(SHORT_LABEL_LIMIT))
                .setLongLabel(tool.title)
                .build()
        }
        if (pinned.isNotEmpty()) {
            try {
                manager.updateShortcuts(pinned)
            } catch (error: IllegalStateException) {
            }
        }
    }

    private const val UNIT_CONVERTER_ID = 500

    /**
     * Launchers show the short label under the icon and cut it short there;
     * the long label, shown in the long-press menu, carries the full title.
     */
    private const val SHORT_LABEL_LIMIT = 25
}
