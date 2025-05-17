package com.sample.edgedetection.scan

import android.view.Display
import android.view.SurfaceView
import com.sample.edgedetection.view.PaperRectangle
import org.opencv.core.Point as CvPoint

interface IScanView {
    interface Proxy {
        fun exit()
        fun getCurrentDisplay(): Display?
        fun getSurfaceView(): SurfaceView
        fun getPaperRect(): PaperRectangle
        fun onDocumentDetected(corners: List<CvPoint>, width: Double, height: Double)
    }
}