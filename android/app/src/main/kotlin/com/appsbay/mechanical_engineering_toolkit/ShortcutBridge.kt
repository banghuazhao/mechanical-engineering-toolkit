package com.appsbay.mechanical_engineering_toolkit

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * The Android end of `lib/util/shortcut_bridge.dart`, on the same channel as
 * `apple/METoolkitShared/ShortcutBridge.swift` and speaking the same three
 * methods: `publishSnapshot` stores what the widgets and launcher shortcuts
 * show, `ready` says Dart is listening, and `openDeepLink` hands Dart a link
 * from a widget row or a shortcut.
 */
class ShortcutBridge(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, CHANNEL)

    /**
     * Links that arrived before Dart had a router to take them. A cold start
     * from a widget row delivers its link in `onCreate`, long before `runApp`
     * has built a navigator, and dropping it would make the widget fail on
     * exactly the tap it exists for.
     */
    private val pending = mutableListOf<String>()
    private var dartIsReady = false

    private val main = Handler(Looper.getMainLooper())

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "publishSnapshot" -> {
                val arguments = call.arguments as? Map<*, *>
                if (arguments == null) {
                    result.error("bad_arguments", "publishSnapshot expects a map", null)
                    return
                }
                val snapshot = ToolSnapshot.fromChannel(arguments)
                // Off the platform thread: writing preferences and asking the
                // widget host to redraw should not hold up a frame.
                Thread {
                    ToolSnapshot.write(context, snapshot)
                    QuickToolsWidget.refreshAll(context)
                    LauncherShortcuts.update(context, snapshot)
                    main.post { result.success(true) }
                }.start()
            }
            "ready" -> {
                dartIsReady = true
                val queued = pending.toList()
                pending.clear()
                for (link in queued) channel.invokeMethod("openDeepLink", link)
                result.success(null)
            }
            // An Apple App Group; Android has no equivalent to report.
            "appGroupIdentifier" -> result.success(null)
            else -> result.notImplemented()
        }
    }

    /**
     * Routes [link] to Dart, or queues it until Dart is listening. Returns
     * whether it was one of ours.
     */
    fun open(link: Uri?): Boolean {
        if (link?.scheme != DEEP_LINK_SCHEME) return false
        val text = link.toString()
        if (dartIsReady) {
            channel.invokeMethod("openDeepLink", text)
        } else {
            pending.add(text)
        }
        return true
    }

    fun detach() {
        channel.setMethodCallHandler(null)
    }

    companion object {
        const val CHANNEL = "com.appsbay.mechanicalEngineeringToolkit/shortcuts"
    }
}
