package com.example.student_app.camera

import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import androidx.core.content.ContextCompat
import com.otaliastudios.cameraview.controls.Facing
import com.otaliastudios.cameraview.gesture.Gesture
import com.otaliastudios.cameraview.gesture.GestureAction
import io.flutter.plugin.platform.PlatformView
import android.Manifest

internal class NativeCameraView(context: Context, id: Int, creationParams: Map<String?, Any?>?,) :
    PlatformView {
    private lateinit var cameraView: com.otaliastudios.cameraview.CameraView

    override fun getView(): View {
        return cameraView;
    }

    override fun dispose() {
        cameraView.destroy()
    }

    init {
        cameraView = com.otaliastudios.cameraview.CameraView(context)
        cameraView.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )

        if (ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
            setupCamera()
        } else {
            Log.e("NativeCameraView", "Camera permission not granted")
        }
    }

    private fun setupCamera() {
        cameraView.keepScreenOn = true
        cameraView.open()
        cameraView.mapGesture(Gesture.PINCH, GestureAction.ZOOM)
        cameraView.mapGesture(Gesture.TAP, GestureAction.AUTO_FOCUS)
        cameraView.mapGesture(Gesture.LONG_TAP, GestureAction.TAKE_PICTURE)
        cameraView.facing = Facing.BACK
    }
}