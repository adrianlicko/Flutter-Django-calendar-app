package com.example.student_app

import android.content.Intent
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val channel = "channel_name"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val method = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)

        method.setMethodCallHandler { call, result ->
            if (call.method == "method_name") {
                val userName = call.argument<String>("username")
                Toast.makeText(this, userName, Toast.LENGTH_LONG).show()
                result.success(userName)
            } else if (call.method == "method_scan") {
                startActivity(Intent(this, ScanActivity::class.java))
            } else {
                result.notImplemented()
            }
        }
    }
}
