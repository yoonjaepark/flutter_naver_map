package com.example.flutter_naver_map
import android.content.Context
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class FlutterNaverMapViewFactory internal constructor(private val messenger: BinaryMessenger, private val containerView: View?) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as Map<String, Any>
        return FlutterNaverMapView(context, messenger, viewId, params, containerView)
    }
}
