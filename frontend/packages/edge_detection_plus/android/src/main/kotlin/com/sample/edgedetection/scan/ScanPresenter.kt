package com.sample.edgedetection.scan

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.graphics.Point
import android.graphics.Rect
import android.graphics.YuvImage
import android.hardware.Camera
import android.hardware.camera2.CameraAccessException
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.hardware.camera2.params.StreamConfigurationMap
import android.os.Bundle
import android.os.Looper
import android.os.SystemClock
import android.os.Handler
import android.util.Log
import android.view.Display
import android.view.SurfaceHolder
import android.widget.Toast
import com.sample.edgedetection.EdgeDetectionHandler
import com.sample.edgedetection.REQUEST_CODE
import com.sample.edgedetection.SourceManager
import com.sample.edgedetection.processor.Corners
import com.sample.edgedetection.processor.processPicture
import io.reactivex.Observable
import io.reactivex.Scheduler
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import org.opencv.android.Utils
import org.opencv.core.Core
import org.opencv.core.Core.ROTATE_90_CLOCKWISE
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.Size
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import kotlin.math.max
import kotlin.math.min
import android.util.Size as SizeB
import android.graphics.Bitmap
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.common.InputImage
import android.graphics.Color
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.Text
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import java.io.File
import java.io.FileOutputStream
import android.view.SurfaceView
import org.opencv.core.Point as CvPoint
import org.opencv.core.MatOfPoint2f
import org.opencv.imgproc.Imgproc as CvImgproc
import kotlin.math.max
import kotlin.math.pow
import kotlin.math.sqrt
import android.net.Uri

@Suppress("DEPRECATION")
class ScanPresenter constructor(
    private val context: Context,
    private val iView: IScanView.Proxy,
    private val initialBundle: Bundle
) :
    SurfaceHolder.Callback, Camera.PictureCallback, Camera.PreviewCallback {
    private val TAG: String = "ScanPresenter"
    private var mCamera: Camera? = null
    private val mSurfaceHolder: SurfaceHolder = iView.getSurfaceView().holder
    private val executor: ExecutorService
    private val proxySchedule: Scheduler
    private var busy: Boolean = false
    private var mCameraLensFacing: String? = null
    private var flashEnabled: Boolean = false

    private var mLastClickTime = 0L
    private var shutted: Boolean = true

    private var documentPoints: MatOfPoint2f? = null
    private var picture: Mat? = null;

    private var recognizedText: String = ""
    private var isProcessingText: Boolean = false

    init {
        mSurfaceHolder.addCallback(this)
        executor = Executors.newSingleThreadExecutor()
        proxySchedule = Schedulers.from(executor)
    }

    private fun isOpenRecently(): Boolean {
        if (SystemClock.elapsedRealtime() - mLastClickTime < 3000) {
            return true
        }
        mLastClickTime = SystemClock.elapsedRealtime()
        return false
    }

    fun start() {
        mCamera?.startPreview() ?: Log.i(TAG, "mCamera startPreview")
    }

    fun stop() {
        mCamera?.stopPreview() ?: Log.i(TAG, "mCamera stopPreview")
    }

    fun canShut(): Boolean {
        return shutted
    }

    fun shut(skipCrop: Boolean = false) {
        if (isOpenRecently()) {
            Log.i(TAG, "NOT Taking click")
            return
        }
        busy = true
        shutted = false
        Log.i(TAG, "Starting autofocus before capture")
        mCamera?.autoFocus { success, _ ->
            if (success) {
                mCamera?.takePicture(null, null, this)
            } else {
                busy = false
                shutted = true
            }
        }
    }

    fun toggleFlash() {
        try {
            flashEnabled = !flashEnabled
            val parameters = mCamera?.parameters
            parameters?.flashMode =
                if (flashEnabled) Camera.Parameters.FLASH_MODE_TORCH else Camera.Parameters.FLASH_MODE_OFF
            mCamera?.parameters = parameters
            mCamera?.startPreview()
        } catch (e: CameraAccessException) {
            e.printStackTrace()
        }
    }

    fun setFlash(on: Boolean) {
        try {
            flashEnabled = on
            val parameters = mCamera?.parameters
            parameters?.flashMode =
                if (on) Camera.Parameters.FLASH_MODE_TORCH else Camera.Parameters.FLASH_MODE_OFF
            mCamera?.parameters = parameters
            mCamera?.startPreview()
        } catch (e: CameraAccessException) {
            e.printStackTrace()
        }
    }

    public fun updateCamera() {
        if (null == mCamera) {
            return
        }
        mCamera?.stopPreview()
        try {
            mCamera?.setPreviewDisplay(mSurfaceHolder)
        } catch (e: IOException) {
            e.printStackTrace()
            return
        }
        mCamera?.setPreviewCallback(this)
        mCamera?.startPreview()
    }

    private val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager

    private fun getCameraCharacteristics(id: String): CameraCharacteristics {
        return cameraManager.getCameraCharacteristics(id)
    }

    private fun getBackFacingCameraId(): String? {
        for (camID in cameraManager.cameraIdList) {
            val lensFacing =
                getCameraCharacteristics(camID)?.get(CameraCharacteristics.LENS_FACING)!!
            if (lensFacing == CameraCharacteristics.LENS_FACING_BACK) {
                mCameraLensFacing = camID
                break
            }
        }
        return mCameraLensFacing
    }

    constructor(
        context: Context,
        iView: IScanView.Proxy,
        initialBundle: Bundle,
        embeddedSurfaceView: SurfaceView
    )
            : this(context, iView, initialBundle) {
        initEmbeddedCamera(embeddedSurfaceView.holder)
    }

    private fun initCamera(holder: SurfaceHolder) {
        try {
            mCamera = Camera.open(Camera.CameraInfo.CAMERA_FACING_BACK)
        } catch (e: RuntimeException) {
            e.printStackTrace()
            Toast.makeText(context, "cannot open camera, please grant camera", Toast.LENGTH_SHORT)
                .show()
        }
    }

    private fun initEmbeddedCamera(holder: SurfaceHolder) {
        mSurfaceHolder.removeCallback(this)
        mSurfaceHolder.addCallback(object : SurfaceHolder.Callback {
            override fun surfaceCreated(holder: SurfaceHolder) {
                initCamera(holder)
            }

            override fun surfaceChanged(
                holder: SurfaceHolder,
                format: Int,
                width: Int,
                height: Int
            ) {
                updateCamera()
            }

            override fun surfaceDestroyed(holder: SurfaceHolder) {
                mCamera?.stopPreview()
                mCamera?.release()
                mCamera = null
            }
        })
    }

    private fun initCamera() {

        try {
            mCamera = Camera.open(Camera.CameraInfo.CAMERA_FACING_BACK)
        } catch (e: RuntimeException) {
            e.stackTrace
            Toast.makeText(context, "cannot open camera, please grant camera", Toast.LENGTH_SHORT)
                .show()
            return
        }

        val cameraCharacteristics =
            cameraManager.getCameraCharacteristics(getBackFacingCameraId()!!)

        val size = iView.getCurrentDisplay()?.let {
            getPreviewOutputSize(
                it, cameraCharacteristics, SurfaceHolder::class.java
            )
        }

        Log.i(TAG, "Selected preview size: ${size?.width}${size?.height}")

        size?.width?.toString()?.let { Log.i(TAG, it) }
        val param = mCamera?.parameters
        param?.setPreviewSize(size?.width ?: 1920, size?.height ?: 1080)
        val display = iView.getCurrentDisplay()
        val point = Point()

        display?.getRealSize(point)

        val displayWidth = minOf(point.x, point.y)
        val displayHeight = maxOf(point.x, point.y)
        val displayRatio = displayWidth.div(displayHeight.toFloat())
        val previewRatio = size?.height?.toFloat()?.div(size.width.toFloat()) ?: displayRatio
        if (displayRatio > previewRatio) {
            val surfaceParams = iView.getSurfaceView().layoutParams
            surfaceParams.height = (displayHeight / displayRatio * previewRatio).toInt()
            iView.getSurfaceView().layoutParams = surfaceParams
        }

        val supportPicSize = mCamera?.parameters?.supportedPictureSizes
        supportPicSize?.sortByDescending { it.width.times(it.height) }
        var pictureSize = supportPicSize?.find {
            it.height.toFloat().div(it.width.toFloat()) - previewRatio < 0.01
        }

        if (null == pictureSize) {
            pictureSize = supportPicSize?.get(0)
        }

        if (null == pictureSize) {
            Log.e(TAG, "can not get picture size")
        } else {
            param?.setPictureSize(pictureSize.width, pictureSize.height)
        }
        val pm = context.packageManager
        if (pm.hasSystemFeature(PackageManager.FEATURE_CAMERA_AUTOFOCUS) && mCamera!!.parameters.supportedFocusModes.contains(
                Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE
            )
        ) {
            param?.focusMode = Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE
            Log.i(TAG, "enabling autofocus")
        } else {
            Log.i(TAG, "autofocus not available")
        }

        param?.flashMode = Camera.Parameters.FLASH_MODE_OFF

        mCamera?.parameters = param
        mCamera?.setDisplayOrientation(90)
        mCamera?.enableShutterSound(false)
    }

    private fun matrixResizer(sourceMatrix: Mat): Mat {
        val sourceSize: Size = sourceMatrix.size()
        var copied = Mat()
        if (sourceSize.height < sourceSize.width) {
            Core.rotate(sourceMatrix, copied, ROTATE_90_CLOCKWISE)
        } else {
            copied = sourceMatrix
        }
        val copiedSize: Size = copied.size()
        return if (copiedSize.width > ScanConstants.MAX_SIZE.width || copiedSize.height > ScanConstants.MAX_SIZE.height) {
            var useRatio = 0.0
            val widthRatio: Double = ScanConstants.MAX_SIZE.width / copiedSize.width
            val heightRatio: Double = ScanConstants.MAX_SIZE.height / copiedSize.height
            useRatio = if (widthRatio > heightRatio) widthRatio else heightRatio
            val resizedImage = Mat()
            val newSize = Size(copiedSize.width * useRatio, copiedSize.height * useRatio)
            Imgproc.resize(copied, resizedImage, newSize)
            resizedImage
        } else {
            copied
        }
    }

    fun deskewPicture(picture: Mat, pts: List<CvPoint>): Mat {
        val tl = pts[0]
        val tr = pts[1]
        val br = pts[2]
        val bl = pts[3]

        val widthA = sqrt((br.x - bl.x).pow(2.0) + (br.y - bl.y).pow(2.0))
        val widthB = sqrt((tr.x - tl.x).pow(2.0) + (tr.y - tl.y).pow(2.0))
        val dw = max(widthA, widthB)
        val maxWidth = dw.toInt()

        val heightA = sqrt((tr.x - br.x).pow(2.0) + (tr.y - br.y).pow(2.0))
        val heightB = sqrt((tl.x - bl.x).pow(2.0) + (tl.y - bl.y).pow(2.0))
        val dh = max(heightA, heightB)
        val maxHeight = dh.toInt()

        val centerX = (tl.x + tr.x + br.x + bl.x) / 4.0
        val centerY = (tl.y + tr.y + br.y + bl.y) / 4.0

        val dstPts = MatOfPoint2f(
            CvPoint(centerX - maxWidth / 2.0, centerY - maxHeight / 2.0),
            CvPoint(centerX + maxWidth / 2.0, centerY - maxHeight / 2.0),
            CvPoint(centerX + maxWidth / 2.0, centerY + maxHeight / 2.0),
            CvPoint(centerX - maxWidth / 2.0, centerY + maxHeight / 2.0)
        )

        val srcPts = MatOfPoint2f(tl, tr, br, bl)

        val m = CvImgproc.getPerspectiveTransform(srcPts, dstPts)

        val finalCorners = MatOfPoint2f()
        Core.perspectiveTransform(srcPts, finalCorners, m)
        documentPoints = finalCorners

        val warped = Mat()
        CvImgproc.warpPerspective(picture, warped, m, picture.size())
        m.release()

        return warped
    }

    fun cropDocument(mat: Mat, pts: List<CvPoint>): Mat {
        val tl = pts[0]
        val tr = pts[1]
        val br = pts[2]
        val bl = pts[3]

        val widthA = sqrt((br.x - bl.x).pow(2.0) + (br.y - bl.y).pow(2.0))
        val widthB = sqrt((tr.x - tl.x).pow(2.0) + (tr.y - tl.y).pow(2.0))
        val maxWidth = max(widthA, widthB).toInt()

        val heightA = sqrt((tr.x - br.x).pow(2.0) + (tr.y - br.y).pow(2.0))
        val heightB = sqrt((tl.x - bl.x).pow(2.0) + (tl.y - bl.y).pow(2.0))
        val maxHeight = max(heightA, heightB).toInt()

        val srcPts = MatOfPoint2f(tl, tr, br, bl)
        val dstPts = MatOfPoint2f(
            CvPoint(0.0, 0.0),
            CvPoint(maxWidth.toDouble(), 0.0),
            CvPoint(maxWidth.toDouble(), maxHeight.toDouble()),
            CvPoint(0.0, maxHeight.toDouble())
        )

        val m = CvImgproc.getPerspectiveTransform(srcPts, dstPts)
        val cropped = Mat()
        CvImgproc.warpPerspective(mat, cropped, m, Size(maxWidth.toDouble(), maxHeight.toDouble()))
        m.release()

        documentPoints = dstPts;

        return cropped
    }

    fun detectEdge(
        pict: Mat? = null,
        initialBundleParam: Bundle? = null,
        crop: Boolean = false
    ): Map<String, Any?> {
        SourceManager.pic = null
        SourceManager.corners = null
        if (pict != null) {
            picture = pict.clone()
        }
        val pic = picture ?: return emptyMap()
        val resizedMat = matrixResizer(pic)
        SourceManager.corners = processPicture(resizedMat)
        Imgproc.cvtColor(resizedMat, resizedMat, Imgproc.COLOR_RGB2BGRA)
        SourceManager.pic = resizedMat

        val fullPicPath =
            initialBundleParam?.getString(EdgeDetectionHandler.SAVE_TO) ?: initialBundle.getString(
                EdgeDetectionHandler.SAVE_TO
            )
        val file = File(fullPicPath ?: return emptyMap())
        if (file.exists()) {
            file.delete()
        }
        val mediaScanIntent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
        mediaScanIntent.data = Uri.fromFile(file)
        context.sendBroadcast(mediaScanIntent)

        val cornersList = SourceManager.corners?.corners?.filterNotNull() ?: return emptyMap()
        if (!crop && cornersList.size == 4) {
            documentPoints = MatOfPoint2f(
                cornersList[0],
                cornersList[1],
                cornersList[2],
                cornersList[3]
            )
        }
        val resultMat = if (crop) cropDocument(pic, cornersList) else pic
        val success = Imgcodecs.imwrite(file.absolutePath, resultMat)
        if (success) {
            val context = this.context
            val mediaScanIntent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
            mediaScanIntent.data = Uri.fromFile(file)
            context.sendBroadcast(mediaScanIntent)
        }

        val corners =
            documentPoints?.toList()?.map { listOf(it.x, it.y) } ?: emptyList<List<Double>>()
        val width = resultMat.size().width.toDouble()
        val height = resultMat.size().height.toDouble()

        return mapOf(
            "success" to true,
            "corners" to corners,
            "width" to width,
            "height" to height,
            "imagePath" to fullPicPath,
            "recognizedText" to recognizedText,
        )
    }

    fun releaseResources() {
        synchronized(this) {
            mCamera?.stopPreview()
            mCamera?.setPreviewCallback(null)
            mCamera?.release()
            mCamera = null
            picture?.release()
            picture = null
            documentPoints = null
        }
    }

    override fun surfaceCreated(p0: SurfaceHolder) {
        initCamera()
    }

    override fun surfaceChanged(p0: SurfaceHolder, p1: Int, p2: Int, p3: Int) {
        updateCamera()
    }

    override fun surfaceDestroyed(p0: SurfaceHolder) {
        synchronized(this) {
            mCamera?.stopPreview()
            mCamera?.setPreviewCallback(null)
            mCamera?.release()
            mCamera = null
        }
    }

    override fun onPictureTaken(p0: ByteArray?, p1: Camera?) {}

    private fun analyzeText(photo: Bitmap) {
        if (isProcessingText) {
            return
        }
        isProcessingText = true
        val image = InputImage.fromBitmap(photo, 0)
        val textRecognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
        textRecognizer.process(image)
            .addOnSuccessListener { textResult ->
                isProcessingText = false
                recognizedText = textResult.text
            }
            .addOnFailureListener { e ->
                isProcessingText = false
                println("Text recognition error: ${e.message}")
            }
    }

    override fun onPreviewFrame(p0: ByteArray?, p1: Camera?) {
        if (busy) {
            return
        }
        busy = true
        try {
            Observable.just(p0)
                .observeOn(proxySchedule)
                .doOnError {}
                .subscribe({
                    val parameters = p1?.parameters
                    val width = parameters?.previewSize?.width
                    val height = parameters?.previewSize?.height
                    val yuv = YuvImage(
                        p0, parameters?.previewFormat ?: 0, width ?: 1080, height
                            ?: 1920, null
                    )
                    val out = ByteArrayOutputStream()
                    yuv.compressToJpeg(Rect(0, 0, width ?: 1080, height ?: 1920), 100, out)
                    val bytes = out.toByteArray()
                    val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
                    val img = Mat()
                    Utils.bitmapToMat(bitmap, img)
                    bitmap.recycle()
                    Core.rotate(img, img, Core.ROTATE_90_CLOCKWISE)
                    println("setting a new picture to imagePath")
                    println(initialBundle.getString(EdgeDetectionHandler.SAVE_TO))
                    picture = img

                    val qrBitmap =
                        Bitmap.createBitmap(img.cols(), img.rows(), Bitmap.Config.ARGB_8888)
                    Utils.matToBitmap(img, qrBitmap)

                    analyzeText(qrBitmap)

                    val detectedCorners = processPicture(img)
                    // if (detectedCorners != null && canShut() && qrCodeDetected) {
                    //   println("Detected all, shutting donw!!!")
                    //   lastDetectedFrame = img.clone()
                    //   // iView.onQrCodeDetected()
                    //   Handler(Looper.getMainLooper()).post {
                    //     iView.onQrCodeDetected(lastDetectedQrCode)
                    // }
                    //     // shut(skipCrop = false)

                    //     // val corners = documentPoints?.toList()?.map { listOf(it.x, it.y) } ?: emptyList<List<Double>>()
                    //     // val points = corners["points"] as List<Double>
                    //     // iView.onDocumentDetected(
                    //     // corners,
                    //     // picture?.size()?.width!!.toDouble(),
                    //     // picture?.size()?.height!!.toDouble()
                    //     // )
                    // }

                    try {
                        out.close()
                    } catch (e: IOException) {
                        e.printStackTrace()
                    }

                    Observable.create<Corners> {
                        val corner = processPicture(img)
                        busy = false
                        if (null != corner && corner.corners.size == 4) {
                            it.onNext(corner)
                        } else {
                            it.onError(Throwable("paper not detected"))
                        }
                    }.observeOn(AndroidSchedulers.mainThread())
                        .subscribe({
                            iView.getPaperRect().onCornersDetected(it)

                        }, {
                            iView.getPaperRect().onCornersNotDetected()
                        })
                }, { throwable -> Log.e(TAG, throwable.message!!) })
        } catch (e: Exception) {
            print(e.message)
        }

    }

    class SmartSize(width: Int, height: Int) {
        var size = SizeB(width, height)
        var long = max(size.width, size.height)
        var short = min(size.width, size.height)
        override fun toString() = "SmartSize(${long}x${short})"
    }

    private val SIZE_1080P: SmartSize = SmartSize(1920, 1080)

    private fun getDisplaySmartSize(display: Display): SmartSize {
        val outPoint = Point()
        display.getRealSize(outPoint)
        return SmartSize(outPoint.x, outPoint.y)
    }

    /**
     * Returns the largest available PREVIEW size. For more information, see:
     * https://d.android.com/reference/android/hardware/camera2/CameraDevice and
     * https://developer.android.com/reference/android/hardware/camera2/params/StreamConfigurationMap
     */
    private fun <T> getPreviewOutputSize(
        display: Display,
        characteristics: CameraCharacteristics,
        targetClass: Class<T>,
        format: Int? = null
    ): SizeB {

        // Find which is smaller: screen or 1080p
        val screenSize = getDisplaySmartSize(display)
        val hdScreen = screenSize.long >= SIZE_1080P.long || screenSize.short >= SIZE_1080P.short
        val maxSize = if (hdScreen) SIZE_1080P else screenSize

        // If image format is provided, use it to determine supported sizes; else use target class
        val config = characteristics.get(
            CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP
        )!!
        if (format == null)
            assert(StreamConfigurationMap.isOutputSupportedFor(targetClass))
        else
            assert(config.isOutputSupportedFor(format))
        val allSizes = if (format == null)
            config.getOutputSizes(targetClass) else config.getOutputSizes(format)

        // Get available sizes and sort them by area from largest to smallest
        val validSizes = allSizes
            .sortedWith(compareBy { it.height * it.width })
            .map { SmartSize(it.width, it.height) }.reversed()

        // Then, get the largest output size that is smaller or equal than our max size
        return validSizes.first { it.long <= maxSize.long && it.short <= maxSize.short }.size
    }
}
