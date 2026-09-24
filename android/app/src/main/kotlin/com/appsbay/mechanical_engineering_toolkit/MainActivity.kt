package com.appsbay.mechanical_engineering_toolkit

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var shortcuts: ShortcutBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val bridge = ShortcutBridge(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
        shortcuts = bridge
        // A cold start from a widget row or a launcher shortcut: the link is
        // on the intent that created the activity. The bridge holds it until
        // Dart says it is ready.
        bridge.open(intent?.data)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        shortcuts?.detach()
        shortcuts = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    /** A tap while the app is already running (the activity is singleTop). */
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        shortcuts?.open(intent.data)
    }
}
