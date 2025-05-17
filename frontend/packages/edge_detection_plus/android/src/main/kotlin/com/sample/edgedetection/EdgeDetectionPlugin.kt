package com.sample.edgedetection

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Build
import com.sample.edgedetection.scan.ScanActivity
import com.sample.edgedetection.scan.ScanPresenter
import com.sample.edgedetection.scan.IScanView
import com.sample.edgedetection.view.PaperRectangle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import android.content.Context
import android.view.SurfaceView
import android.view.View
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import org.opencv.android.OpenCVLoader
import android.widget.FrameLayout
import io.flutter.plugin.common.EventChannel
import org.opencv.core.Point
import org.opencv.core.Point as CvPoint
import android.os.Looper
import android.os.Handler
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

const val REQUEST_CAMERA_PERMISSION = 100

class EdgeDetectionPlugin : FlutterPlugin, ActivityAware {
    private var handler: EdgeDetectionHandler? = null

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
      handler = EdgeDetectionHandler()
      val channel = MethodChannel(binding.binaryMessenger, "edge_detection")
      channel.setMethodCallHandler(handler)
      
      binding.platformViewRegistry.registerViewFactory(
          "scanner_view", 
          ScannerViewFactory(binding.binaryMessenger)
      )

      startEventChannel(binding.binaryMessenger)
  }

  private fun startEventChannel(messenger: BinaryMessenger) {
    val eventChannel = EventChannel(messenger, "scanner_events_0")
    eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            ScannerView.eventSink = events
            Log.d("EdgeDetectionPlugin", "EventChannel listener set")
        }

        override fun onCancel(arguments: Any?) {
            ScannerView.eventSink = null
            Log.d("EdgeDetectionPlugin", "EventChannel listener cancelled")
        }
    })
}

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {}

    override fun onAttachedToActivity(activityPluginBinding: ActivityPluginBinding) {
        handler?.setActivityPluginBinding(activityPluginBinding)
    }

    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
    override fun onDetachedFromActivity() {}
}

class ScannerViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
  override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
      return ScannerView(context, viewId, messenger)
  }
}

class ScannerView(
    private val context: Context,
    private val id: Int,
    private val messenger: BinaryMessenger
) : PlatformView {
    private val containerView: FrameLayout = FrameLayout(context)
    private val surfaceView: SurfaceView = SurfaceView(context)
    private val paperRect: PaperRectangle = PaperRectangle(context)
    private lateinit var presenter: ScanPresenter
    private val eventChannel = EventChannel(messenger, "scanner_events_$id")
    private val methodChannel = MethodChannel(messenger, "scanner_view_$id")
    private val initialBundle = Bundle()

    private fun checkCameraPermission(context: Context): Boolean {
      return ContextCompat.checkSelfPermission(
          context, 
          Manifest.permission.CAMERA
      ) == PackageManager.PERMISSION_GRANTED
  }

    private fun requestCameraPermission(activity: Activity?) {
        activity?.let {
            ActivityCompat.requestPermissions(
                it,
                arrayOf(Manifest.permission.CAMERA),
                REQUEST_CAMERA_PERMISSION
            )
        }
    }

    init {
      eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            eventSink = events
            Log.d("ScannerView", "EventChannel listener set") 
        }

        override fun onCancel(arguments: Any?) {
            eventSink = null
            Log.d("ScannerView", "EventChannel listener cancelled")
        }
    })

    methodChannel.setMethodCallHandler { call, result ->
        when (call.method) {
            "start_scan" -> {
                  presenter.start()
            }
            "dispose_scanner" -> {
                dispose()
                result.success(null)
            }
            "set_flash" -> {
                val on = call.argument<Boolean>("on") ?: false
                presenter.setFlash(on)
                result.success(null)
            }
            "detect_edge" -> {
                try {
                    val imagePath = call.argument<String>("imagePath")
                    if (imagePath == null) {
                        result.error("NULL_PATH", "Image path cannot be null", null)
                        return@setMethodCallHandler
                    }
                    initialBundle.putString(EdgeDetectionHandler.SAVE_TO, imagePath)
                    val edgeData = detectEdge(initialBundle, crop = false)
                    result.success(edgeData)
                } catch (e: Exception) {
                  result.error("EDGE_DETECTION_ERROR", e.message, null)
                }
            }
            "detect_edge_with_crop" -> {
                try {
                    val imagePath = call.argument<String>("imagePath")
                    if (imagePath == null) {
                        result.error("NULL_PATH", "Image path cannot be null", null)
                        return@setMethodCallHandler
                    }
                    initialBundle.putString(EdgeDetectionHandler.SAVE_TO, imagePath)
                    val edgeData = detectEdge(initialBundle, crop = true)
                    result.success(edgeData)
                } catch (e: Exception) {
                    result.error("EDGE_DETECTION_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

        if (!OpenCVLoader.initDebug()) {
            Log.e("OpenCV", "OpenCV initialization failed")
        }

        containerView.addView(surfaceView, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        ))
        
        containerView.addView(paperRect, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        ))

        presenter = ScanPresenter(
          context,
          object : IScanView.Proxy {
              override fun getSurfaceView() = surfaceView
              override fun getCurrentDisplay() = if (context is Activity) {
                  if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                      context.display
                  } else {
                      context.windowManager.defaultDisplay
                  }
              } else null
              override fun getPaperRect() = paperRect
              override fun exit() {}
              override fun onDocumentDetected(corners: List<CvPoint>, width: Double, height: Double) {}
          },
          initialBundle
      )
    }

    override fun getView(): View = containerView

    override fun dispose() {
        presenter.stop()
    }

    fun detectEdge(initialBundle: Bundle, crop: Boolean = false): Map<String, Any?> {
      return presenter.detectEdge(null, initialBundle, crop)
  }

    companion object {
      var eventSink: EventChannel.EventSink? = null
    }
}

class EdgeDetectionHandler : MethodCallHandler, PluginRegistry.ActivityResultListener {
    private var activityPluginBinding: ActivityPluginBinding? = null
    private var result: Result? = null
    private var methodCall: MethodCall? = null

    companion object {
        const val INITIAL_BUNDLE = "initial_bundle"
        const val SAVE_TO = "save_to"
        const val FROM_GALLERY = "from_gallery"
        const val CAN_USE_GALLERY = "can_use_gallery"
        const val SCAN_TITLE = "scan_title"
        var instance: EdgeDetectionHandler? = null
    }

    init {
        instance = this
    }

    fun setActivityPluginBinding(activityPluginBinding: ActivityPluginBinding) {
        activityPluginBinding.addActivityResultListener(this)
        this.activityPluginBinding = activityPluginBinding
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when {
            getActivity() == null -> {
                result.error(
                    "no_activity",
                    "edge_detection plugin requires a foreground activity.",
                    null
                )
                return
            }
            call.method.equals("edge_detect") -> {
                openCameraActivity(call, result)
            }
            call.method.equals("edge_detect_gallery") -> {
                openGalleryActivity(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getActivity(): Activity? {
        return activityPluginBinding?.activity
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == REQUEST_CODE) {
            when (resultCode) {
                Activity.RESULT_OK -> {
                    finishWithSuccess(true, data)
                }
                Activity.RESULT_CANCELED -> {
                    finishWithSuccess(false, data)
                }
                ERROR_CODE -> {
                    finishWithError(ERROR_CODE.toString(), data?.getStringExtra("RESULT") ?: "ERROR")
                }
            }
            return true
        }
        return false
    }

    private fun openCameraActivity(call: MethodCall, result: Result) {
        if (!setPendingMethodCallAndResult(call, result)) {
            finishWithAlreadyActiveError()
            return
        }

        val initialIntent =Intent(Intent(getActivity()?.applicationContext, ScanActivity::class.java))

        val bundle = Bundle()
        bundle.putString(SAVE_TO, call.argument<String>(SAVE_TO) as String)
        bundle.putString(FROM_GALLERY, call.argument<String>(FROM_GALLERY) as String)
        bundle.putString(SCAN_TITLE, call.argument<String>(SCAN_TITLE) as String)
        bundle.putBoolean(CAN_USE_GALLERY, call.argument<Boolean>(CAN_USE_GALLERY) as Boolean)

        initialIntent.putExtra(INITIAL_BUNDLE, bundle)

        getActivity()?.startActivityForResult(initialIntent, REQUEST_CODE)
    }

    private fun openGalleryActivity(call: MethodCall, result: Result) {
        if (!setPendingMethodCallAndResult(call, result)) {
            finishWithAlreadyActiveError()
            return
        }
        val initialIntent = Intent(Intent(getActivity()?.applicationContext, ScanActivity::class.java))

        val bundle = Bundle()
        bundle.putString(SAVE_TO, call.argument<String>(SAVE_TO) as String)
        bundle.putString(FROM_GALLERY, call.argument<String>(FROM_GALLERY) as String)
        bundle.putString(SCAN_TITLE, call.argument<String>(SCAN_TITLE) as String)
        bundle.putBoolean(CAN_USE_GALLERY, call.argument<Boolean>(CAN_USE_GALLERY) as Boolean)

        initialIntent.putExtra(INITIAL_BUNDLE, bundle)

        getActivity()?.startActivityForResult(initialIntent, REQUEST_CODE)
    }

    private fun setPendingMethodCallAndResult(
        methodCall: MethodCall,
        result: Result
    ): Boolean {
        if (this.result != null) {
            return false
        }
        this.methodCall = methodCall
        this.result = result
        return true
    }

    private fun finishWithAlreadyActiveError() {
        finishWithError("already_active", "Edge detection is already active")
    }

    private fun finishWithError(errorCode: String, errorMessage: String) {
        result?.error(errorCode, errorMessage, null)
        clearMethodCallAndResult()
    }

    private fun bundleToMap(bundle: Bundle): Map<String, Any?> {
      val map = HashMap<String, Any?>()
      for (key in bundle.keySet()) {
          val value = bundle.get(key)
          map[key] = if (value is Bundle) {
              bundleToMap(value)
          } else {
              value
          }
      }
      return map
  }
  
  private fun finishWithSuccess(res: Boolean, data: Intent?) {
    println("finishWithSuccess")
    val extras = data?.extras?.let { bundleToMap(it) } ?: emptyMap<String, Any?>()
    val resultMap = HashMap<String, Any?>()
    resultMap["success"] = res
    resultMap.putAll(extras)
    result?.success(resultMap)
    clearMethodCallAndResult()
}

    private fun clearMethodCallAndResult() {
        methodCall = null
        result = null
    }
}
