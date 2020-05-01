package com.example.flutter_naver_map

import android.annotation.TargetApi
import android.content.Context
import android.os.Build
import android.os.Handler
import android.view.View
import android.webkit.WebStorage
import com.naver.maps.map.MapView
import com.naver.maps.map.NaverMapSdk
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class FlutterNaverMapView @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
internal constructor(
        context: Context,
        messenger: BinaryMessenger,
        id: Int,
        params: Map<String, Any>,
        containerView: View?) : PlatformView, MethodChannel.MethodCallHandler {
    private val methodChannel: MethodChannel
    private val platformThreadHandler: Handler
    private val mapView: MapView

    init {
        NaverMapSdk.getInstance(context).setClient(
                NaverMapSdk.NaverCloudPlatformClient("ddfe2dimwb"))
        this.mapView = MapView(context)
        platformThreadHandler = Handler(context.mainLooper)
        methodChannel = MethodChannel(messenger, "flutter_naver_map_$id")
        methodChannel.setMethodCallHandler(this)
    }

    override fun getView(): View {
        return mapView
    }

    // @Override
    // This is overriding a method that hasn't rolled into stable Flutter yet. Including the
    // annotation would cause compile time failures in versions of Flutter too old to include the new
    // method. However leaving it raw like this means that the method will be ignored in old versions
    // of Flutter but used as an override anyway wherever it's actually defined.
    // TODO(mklim): Add the @Override annotation once flutter/engine#9727 rolls to stable.
    override fun onInputConnectionUnlocked() {
    }

    // @Override
    // This is overriding a method that hasn't rolled into stable Flutter yet. Including the
    // annotation would cause compile time failures in versions of Flutter too old to include the new
    // method. However leaving it raw like this means that the method will be ignored in old versions
    // of Flutter but used as an override anyway wherever it's actually defined.
    // TODO(mklim): Add the @Override annotation once flutter/engine#9727 rolls to stable.
    override fun onInputConnectionLocked() {
    }

    // @Override
    // This is overriding a method that hasn't rolled into stable Flutter yet. Including the
    // annotation would cause compile time failures in versions of Flutter too old to include the new
    // method. However leaving it raw like this means that the method will be ignored in old versions
    // of Flutter but used as an override anyway wherever it's actually defined.
    // TODO(mklim): Add the @Override annotation once stable passes v1.10.9.
    override fun onFlutterViewAttached(flutterView: View) {
    }

    // @Override
    // This is overriding a method that hasn't rolled into stable Flutter yet. Including the
    // annotation would cause compile time failures in versions of Flutter too old to include the new
    // method. However leaving it raw like this means that the method will be ignored in old versions
    // of Flutter but used as an override anyway wherever it's actually defined.
    // TODO(mklim): Add the @Override annotation once stable passes v1.10.9.
    override fun onFlutterViewDetached() {
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            else -> result.notImplemented()
        }
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }

//    companion object {
//        private val JS_CHANNEL_NAMES_FIELD = "javascriptChannelNames"
//    }
}
