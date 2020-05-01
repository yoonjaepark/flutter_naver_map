package com.example.flutter_naver_map

import android.app.Activity
import android.app.Application
import android.os.Bundle
import androidx.annotation.NonNull;
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.concurrent.atomic.AtomicInteger

/** FlutterNaverMapPlugin */
public class FlutterNaverMapPlugin: Application.ActivityLifecycleCallbacks, FlutterPlugin, ActivityAware, DefaultLifecycleObserver {
  private val registrarActivityHashCode: Int = 0
  private val state = AtomicInteger(0)
  internal val CREATED = 1
  internal val STARTED = 2
  internal val RESUMED = 3
  internal val PAUSED = 4
  internal val STOPPED = 5
  internal val DESTROYED = 6
  private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null

  override fun onActivityPaused(activity: Activity?) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return
    }
    state.set(PAUSED)
  }

  override fun onActivityResumed(activity: Activity?) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return
    }
    state.set(RESUMED)
  }

  override fun onActivityStarted(activity: Activity?) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return
    }
    state.set(STARTED)
  }

  override fun onActivityDestroyed(activity: Activity?) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return
    }
    activity?.getApplication()?.unregisterActivityLifecycleCallbacks(this)
    state.set(DESTROYED)
  }

  override fun onActivitySaveInstanceState(p0: Activity?, p1: Bundle?) {
  }

  override fun onActivityStopped(activity: Activity?) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return
    }
    state.set(STOPPED)
  }

  override fun onActivityCreated(activity: Activity?, p1: Bundle?) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return
    }
    state.set(CREATED)
  }

  override fun onDetachedFromActivity() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
//    binding
//            .getPlatformViewsController()
//            .getRegistry()
//            .registerViewFactory(
//                    "flutter_naver_map", FlutterNaverMapViewFactory(messenger, /*containerView=*/ null))
    pluginBinding
            ?.getPlatformViewRegistry()
            ?.registerViewFactory(
                    "flutter_naver_map",
                    FlutterNaverMapViewFactory(pluginBinding!!.binaryMessenger, /*containerView=*/ null))
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
  }


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
//    val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_naver_map")
//    channel.setMethodCallHandler(FlutterNaverMapPlugin());
    pluginBinding = flutterPluginBinding
    val messenger = flutterPluginBinding.getBinaryMessenger()
    pluginBinding!!
            .getFlutterEngine()
            .getPlatformViewsController()
            .getRegistry()
            .registerViewFactory(
                    "flutter_naver_map", FlutterNaverMapViewFactory(messenger, /*containerView=*/ null))
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
//      val channel = MethodChannel(registrar.messenger(), "flutter_naver_map")
//      channel.setMethodCallHandler(FlutterNaverMapPlugin())
      registrar
              .platformViewRegistry()
              .registerViewFactory(
                      "flutter_naver_map",
                      FlutterNaverMapViewFactory(registrar.messenger(), registrar.view()))
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    pluginBinding = null
  }
}
