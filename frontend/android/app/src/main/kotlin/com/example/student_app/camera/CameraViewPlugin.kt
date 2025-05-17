package com.example.student_app.camera

import android.content.Context
import androidx.annotation.NonNull
import androidx.camera.view.CameraController
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

class CameraViewPlugin : FlutterPlugin {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var cameraController: CameraController

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "camera_view_android")
        channel.setMethodCallHandler { call, result ->
            if (call.method == "someMethod") {
                result.success("Result from Android")
            } else {
                result.notImplemented()
            }
        }
        context = flutterPluginBinding.applicationContext

        flutterPluginBinding
            .platformViewRegistry
            .registerViewFactory("@views/native-view", NativeViewFactory())
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}