package com.appsbay.mechanical_engineering_toolkit

import android.content.Context
import android.net.Uri
import org.json.JSONArray
import org.json.JSONObject

/** The scheme `lib/util/deep_links.dart` routes; registered in the manifest. */
const val DEEP_LINK_SCHEME = "metoolkit"

/** `metoolkit://tool/703` — opens that calculator. */
fun toolDeepLink(id: Int): Uri = Uri.parse("$DEEP_LINK_SCHEME://tool/$id")

/**
 * One tool as the app published it: already localized, with its category
 * and whether this build holds it behind Premium. Mirrors
 * `ShortcutToolSummary` in `lib/util/shortcut_bridge.dart`.
 */
data class ToolSummary(
    val id: Int,
    val title: String,
    val categoryId: String,
    val category: String,
    val locked: Boolean,
)

/**
 * What the widgets and launcher shortcuts show: every tool, and which of
 * them are favourites and recent. The Android counterpart of
 * `apple/METoolkitShared/SharedStore.swift`, stored in the app's own
 * preferences — on Android a widget runs in the app's process, so there is
 * no container to share.
 */
data class ToolSnapshot(
    val tools: List<ToolSummary>,
    val favoriteIds: List<Int>,
    val recentIds: List<Int>,
) {
    private val byId: Map<Int, ToolSummary> by lazy { tools.associateBy { it.id } }

    /**
     * Favourites in the order they were starred, falling back to [recentTools]
     * while there are none, so a freshly placed widget is never blank.
     */
    val favoriteTools: List<ToolSummary>
        get() {
            val starred = favoriteIds.mapNotNull { byId[it] }
            return starred.ifEmpty { recentTools }
        }

    /** Most recent first, each tool once. */
    val recentTools: List<ToolSummary>
        get() = recentIds.distinct().mapNotNull { byId[it] }

    fun toJson(): String = JSONObject().apply {
        put("tools", JSONArray().apply {
            for (tool in tools) {
                put(JSONObject().apply {
                    put("id", tool.id)
                    put("title", tool.title)
                    put("categoryId", tool.categoryId)
                    put("category", tool.category)
                    put("locked", tool.locked)
                })
            }
        })
        put("favoriteIds", JSONArray(favoriteIds))
        put("recentIds", JSONArray(recentIds))
    }.toString()

    companion object {
        private const val PREFS = "me_toolkit_quick_tools"
        private const val KEY = "snapshot"

        val EMPTY = ToolSnapshot(emptyList(), emptyList(), emptyList())

        fun read(context: Context): ToolSnapshot {
            val raw = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .getString(KEY, null) ?: return EMPTY
            return try {
                parse(JSONObject(raw))
            } catch (error: Exception) {
                EMPTY
            }
        }

        fun write(context: Context, snapshot: ToolSnapshot) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .edit()
                .putString(KEY, snapshot.toJson())
                .apply()
        }

        /** Decodes the `publishSnapshot` channel arguments. */
        fun fromChannel(arguments: Map<*, *>): ToolSnapshot {
            val tools = (arguments["tools"] as? List<*>).orEmpty().mapNotNull { entry ->
                val map = entry as? Map<*, *> ?: return@mapNotNull null
                val id = (map["id"] as? Number)?.toInt() ?: return@mapNotNull null
                val title = map["title"] as? String ?: return@mapNotNull null
                ToolSummary(
                    id = id,
                    title = title,
                    categoryId = map["categoryId"] as? String ?: "",
                    category = map["category"] as? String ?: "",
                    locked = map["locked"] as? Boolean ?: false,
                )
            }
            fun ids(key: String) =
                (arguments[key] as? List<*>).orEmpty().mapNotNull { (it as? Number)?.toInt() }
            return ToolSnapshot(tools, ids("favoriteIds"), ids("recentIds"))
        }

        private fun parse(json: JSONObject): ToolSnapshot {
            val toolsJson = json.optJSONArray("tools") ?: JSONArray()
            val tools = (0 until toolsJson.length()).mapNotNull { i ->
                val t = toolsJson.optJSONObject(i) ?: return@mapNotNull null
                ToolSummary(
                    id = t.optInt("id"),
                    title = t.optString("title"),
                    categoryId = t.optString("categoryId"),
                    category = t.optString("category"),
                    locked = t.optBoolean("locked"),
                )
            }
            fun ids(key: String): List<Int> {
                val array = json.optJSONArray(key) ?: return emptyList()
                return (0 until array.length()).map { array.optInt(it) }
            }
            return ToolSnapshot(tools, ids("favoriteIds"), ids("recentIds"))
        }
    }
}
