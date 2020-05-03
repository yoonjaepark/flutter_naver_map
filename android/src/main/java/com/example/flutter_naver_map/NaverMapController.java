package com.example.flutter_naver_map;
// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.graphics.PointF;
import android.location.Location;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;

import com.naver.maps.geometry.LatLng;
import com.naver.maps.geometry.LatLngBounds;
import com.naver.maps.map.CameraPosition;
import com.naver.maps.map.CameraUpdate;
import com.naver.maps.map.MapView;
import com.naver.maps.map.NaverMap;
import com.naver.maps.map.NaverMapOptions;
import com.naver.maps.map.NaverMapSdk;
import com.naver.maps.map.OnMapReadyCallback;
import com.naver.maps.map.Symbol;
import com.naver.maps.map.indoor.IndoorSelection;
import com.naver.maps.map.overlay.Marker;

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.platform.PlatformView;
import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import static com.example.flutter_naver_map.FlutterNaverMapPlugin.CREATED;
import static com.example.flutter_naver_map.FlutterNaverMapPlugin.DESTROYED;
import static com.example.flutter_naver_map.FlutterNaverMapPlugin.PAUSED;
import static com.example.flutter_naver_map.FlutterNaverMapPlugin.RESUMED;
import static com.example.flutter_naver_map.FlutterNaverMapPlugin.STARTED;
import static com.example.flutter_naver_map.FlutterNaverMapPlugin.STOPPED;

/** Controller of a single NaverMaps MapView instance. */
final class NaverMapController
        implements Application.ActivityLifecycleCallbacks,
        DefaultLifecycleObserver,
        ActivityPluginBinding.OnSaveInstanceStateListener,
        MethodChannel.MethodCallHandler,
        OnMapReadyCallback,
        NaverMapListener,
        PlatformView {

    private static final String TAG = "NaverMapController";
    private final int id;
    private final AtomicInteger activityState;
    private final MethodChannel methodChannel;
    private final MapView mapView;
    private NaverMap naverMap;
    private boolean trackCameraPosition = false;
    private boolean myLocationEnabled = false;
    private boolean myLocationButtonEnabled = false;
    private boolean zoomControlsEnabled = true;
    private boolean indoorEnabled = true;
    private boolean trafficEnabled = false;
    private boolean buildingsEnabled = true;
    private boolean disposed = false;
    private final float density;
    private MethodChannel.Result mapReadyResult;
    private final int activityHashCode; // Do not use directly, use getActivityHashCode() instead to get correct hashCode for both v1 and v2 embedding.
    private final Lifecycle lifecycle;
    private final Context context;
    private final Application mApplication; // Do not use direclty, use getApplication() instead to get correct application object for both v1 and v2 embedding.
    private final PluginRegistry.Registrar registrar; // For v1 embedding only.
//    private final MarkersController markersController;
//    private final PolygonsController polygonsController;
//    private final PolylinesController polylinesController;
//    private final CirclesController circlesController;
    private List<Object> initialMarkers;
    private List<Object> initialPolygons;
    private List<Object> initialPolylines;
    private List<Object> initialCircles;

    NaverMapController(
            int id,
            Context context,
            AtomicInteger activityState,
            BinaryMessenger binaryMessenger,
            Application application,
            Lifecycle lifecycle,
            PluginRegistry.Registrar registrar,
            int registrarActivityHashCode,
            NaverMapOptions options) {
        this.id = id;
        this.context = context;
        this.activityState = activityState;
        this.mapView = new MapView(context, options);
        this.density = context.getResources().getDisplayMetrics().density;
        methodChannel = new MethodChannel(binaryMessenger, "flutter_naver_map_" + id);
        methodChannel.setMethodCallHandler(this);
        mApplication = application;
        this.lifecycle = lifecycle;
        this.registrar = registrar;
        this.activityHashCode = registrarActivityHashCode;
//        this.markersController = new MarkersController(methodChannel);
//        this.polygonsController = new PolygonsController(methodChannel, density);
//        this.polylinesController = new PolylinesController(methodChannel, density);
//        this.circlesController = new CirclesController(methodChannel, density);
    }

    @Override
    public View getView() {
        return mapView;
    }

    void init() {
        NaverMapSdk.getInstance(context).setClient(
                new NaverMapSdk.NaverCloudPlatformClient("ddfe2dimwb"));

        Log.i("activityState.get()", activityState.get() + "");
        switch (activityState.get()) {
            case STOPPED:
                mapView.onCreate(null);
                mapView.onStart();
                mapView.onResume();
                mapView.onPause();
                mapView.onStop();
                break;
            case PAUSED:
                mapView.onCreate(null);
                mapView.onStart();
                mapView.onResume();
                mapView.onPause();
                break;
            case RESUMED:
                mapView.onCreate(null);
                mapView.onStart();
                mapView.onResume();
                break;
            case STARTED:
                mapView.onCreate(null);
                mapView.onStart();
                break;
            case CREATED:
                mapView.onCreate(null);
                break;
            case DESTROYED:
                mapView.onDestroy();
                // Nothing to do, the activity has been completely destroyed.
                break;
            default:
                throw new IllegalArgumentException(
                        "Cannot interpret " + activityState.get() + " as an activity state");
        }
        if (lifecycle != null) {
            lifecycle.addObserver(this);
        } else {
            getApplication().registerActivityLifecycleCallbacks(this);
        }
        mapView.getMapAsync(this);
    }

    private void moveCamera(CameraUpdate cameraUpdate) {
        naverMap.moveCamera(cameraUpdate);
    }

    private void animateCamera(CameraUpdate cameraUpdate) {
//        naverMap.animateCamera(cameraUpdate);
    }

    private CameraPosition getCameraPosition() {
        return trackCameraPosition ? naverMap.getCameraPosition() : null;
    }

    @Override
    public void onMapReady(NaverMap naverMap) {
        Log.i(TAG, "onMapReady");
        this.naverMap = naverMap;
        LatLng initialPosition = new LatLng(37.506855, 127.066242);
        CameraUpdate cameraUpdate = CameraUpdate.scrollTo(initialPosition);
        naverMap.moveCamera(cameraUpdate);
        this.naverMap.setIndoorEnabled(this.indoorEnabled);
//        this.naverMap.setTrafficEnabled(this.trafficEnabled);
//        this.naverMap.setBuildingsEnabled(this.buildingsEnabled);
//        naverMap.setOnInfoWindowClickListener(this);
        if (mapReadyResult != null) {
            mapReadyResult.success(null);
            mapReadyResult = null;
        }
        setNaverMapListener(this);
        updateMyLocationSettings();
//        markersController.setNaverMap(naverMap);
//        polygonsController.setNaverMap(naverMap);
//        polylinesController.setNaverMap(naverMap);
//        circlesController.setNaverMap(naverMap);
        updateInitialMarkers();
        updateInitialPolygons();
        updateInitialPolylines();
        updateInitialCircles();
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        Log.i("call.method", call.method);
        switch (call.method) {
            case "map#waitForMap":
                if (naverMap != null) {
                    result.success(null);
                    return;
                }
                mapReadyResult = result;
                break;
            case "map#update":
            {
                result.success(null);
//                Convert.interpretNaverMapOptions(call.argument("options"), this);
//                result.success(Convert.cameraPositionToJson(getCameraPosition()));
                break;
            }
            case "map#getVisibleRegion":
            {
                if (naverMap != null) {

                    LatLngBounds latLngBounds = naverMap.getContentBounds();
                    Log.i(TAG, latLngBounds.toString());
                    Log.i(TAG, Convert.latlngBoundsToJson(latLngBounds).toString());
                    result.success(Convert.latlngBoundsToJson(latLngBounds));
                } else {
                    result.error(
                            "NaverMap uninitialized",
                            "getVisibleRegion called prior to map initialization",
                            null);
                }
                break;
            }
            case "map#getScreenCoordinate":
            {
                if (naverMap != null) {
                    LatLng latLng = Convert.toLatLng(call.arguments);
//                    Point screenLocation = naverMap.getProjection().toScreenLocation(latLng);
//                    result.success(Convert.pointToJson(screenLocation));
                    result.success(null);

                } else {
                    result.error(
                            "NaverMap uninitialized",
                            "getScreenCoordinate called prior to map initialization",
                            null);
                }
                break;
            }
            case "map#getLatLng":
            {
                if (naverMap != null) {
                    result.success(null);

//                    Point point = Convert.toPoint(call.arguments);
//                    LatLng latLng = naverMap.getProjection().fromScreenLocation(point);
//                    result.success(Convert.latLngToJson(latLng));
                } else {
                    result.error(
                            "NaverMap uninitialized", "getLatLng called prior to map initialization", null);
                }
                break;
            }
            case "map#takeSnapshot":
            {
                if (naverMap != null) {
                    final MethodChannel.Result _result = result;
                    naverMap.takeSnapshot(
                            new NaverMap.SnapshotReadyCallback() {
                                @Override
                                public void onSnapshotReady(Bitmap bitmap) {
                                    ByteArrayOutputStream stream = new ByteArrayOutputStream();
//                                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
                                    byte[] byteArray = stream.toByteArray();
                                    bitmap.recycle();
                                    _result.success(byteArray);
                                }
                            });
                } else {
                    result.error("NaverMap uninitialized", "takeSnapshot", null);
                }
                break;
            }
            case "camera#move":
            {
                final CameraUpdate cameraUpdate =
                        Convert.toCameraUpdate(call.argument("cameraUpdate"), density);
                moveCamera(cameraUpdate);
                result.success(null);
                break;
            }
            case "camera#animate":
            {
//                final CameraUpdate cameraUpdate =
//                        Convert.toCameraUpdate(call.argument("cameraUpdate"), density);
//                animateCamera(cameraUpdate);
                result.success(null);
                break;
            }
            case "markers#update":
            {
//                Object markersToAdd = call.argument("markersToAdd");
//                markersController.addMarkers((List<Object>) markersToAdd);
//                Object markersToChange = call.argument("markersToChange");
//                markersController.changeMarkers((List<Object>) markersToChange);
//                Object markerIdsToRemove = call.argument("markerIdsToRemove");
//                markersController.removeMarkers((List<Object>) markerIdsToRemove);
                result.success(null);
                break;
            }
            case "markers#showInfoWindow":
            {
//                Object markerId = call.argument("markerId");
//                markersController.showMarkerInfoWindow((String) markerId, result);
                break;
            }
            case "markers#hideInfoWindow":
            {
//                Object markerId = call.argument("markerId");
//                markersController.hideMarkerInfoWindow((String) markerId, result);
                break;
            }
            case "markers#isInfoWindowShown":
            {
//                Object markerId = call.argument("markerId");
//                markersController.isInfoWindowShown((String) markerId, result);
                break;
            }
            case "polygons#update":
            {
//                Object polygonsToAdd = call.argument("polygonsToAdd");
//                polygonsController.addPolygons((List<Object>) polygonsToAdd);
//                Object polygonsToChange = call.argument("polygonsToChange");
//                polygonsController.changePolygons((List<Object>) polygonsToChange);
//                Object polygonIdsToRemove = call.argument("polygonIdsToRemove");
//                polygonsController.removePolygons((List<Object>) polygonIdsToRemove);
                result.success(null);
                break;
            }
            case "polylines#update":
            {
//                Object polylinesToAdd = call.argument("polylinesToAdd");
//                polylinesController.addPolylines((List<Object>) polylinesToAdd);
//                Object polylinesToChange = call.argument("polylinesToChange");
//                polylinesController.changePolylines((List<Object>) polylinesToChange);
//                Object polylineIdsToRemove = call.argument("polylineIdsToRemove");
//                polylinesController.removePolylines((List<Object>) polylineIdsToRemove);
                result.success(null);
                break;
            }
            case "circles#update":
            {
//                Object circlesToAdd = call.argument("circlesToAdd");
//                circlesController.addCircles((List<Object>) circlesToAdd);
//                Object circlesToChange = call.argument("circlesToChange");
//                circlesController.changeCircles((List<Object>) circlesToChange);
//                Object circleIdsToRemove = call.argument("circleIdsToRemove");
//                circlesController.removeCircles((List<Object>) circleIdsToRemove);
                result.success(null);
                break;
            }
            case "map#isCompassEnabled":
            {
                result.success(naverMap.getUiSettings().isCompassEnabled());
                break;
            }
            case "map#isMapToolbarEnabled":
            {
                result.success(null);
//                result.success(naverMap.getUiSettings().isMapToolbarEnabled());
                break;
            }
            case "map#getMinMaxZoomLevels":
            {
                List<Float> zoomLevels = new ArrayList<>(2);
//                zoomLevels.add(naverMap.getMinZoom());
//                zoomLevels.add(naverMap.getMaxZoom());
                result.success(zoomLevels);
                break;
            }
            case "map#isZoomGesturesEnabled":
            {
                result.success(naverMap.getUiSettings().isZoomGesturesEnabled());
                break;
            }
            case "map#isZoomControlsEnabled":
            {
                result.success(naverMap.getUiSettings().isZoomControlEnabled());
                break;
            }
            case "map#isScrollGesturesEnabled":
            {
                result.success(naverMap.getUiSettings().isScrollGesturesEnabled());
                break;
            }
            case "map#isTiltGesturesEnabled":
            {
                result.success(naverMap.getUiSettings().isTiltGesturesEnabled());
                break;
            }
            case "map#isRotateGesturesEnabled":
            {
                result.success(naverMap.getUiSettings().isRotateGesturesEnabled());
                break;
            }
            case "map#isMyLocationButtonEnabled":
            {
                result.success(naverMap.getUiSettings().isLocationButtonEnabled());
                break;
            }
            case "map#isTrafficEnabled":
            {
//                result.success(naverMap.isTrafficEnabled());
                break;
            }
            case "map#isBuildingsEnabled":
            {
//                result.success(naverMap.isBuildingsEnabled());
                break;
            }
            case "map#getZoomLevel":
            {
                result.success(naverMap.getCameraPosition().zoom);
                break;
            }
            case "map#setStyle":
            {
                String mapStyle = (String) call.arguments;
                boolean mapStyleSet;
                if (mapStyle == null) {
//                    mapStyleSet = naverMap.setMapStyle(null);
                } else {
//                    mapStyleSet = naverMap.setMapStyle(new MapStyleOptions(mapStyle));
                }
                ArrayList<Object> mapStyleResult = new ArrayList<>(2);
//                mapStyleResult.add(mapStyleSet);
//                if (!mapStyleSet) {
//                    mapStyleResult.add(
//                            "Unable to set the map style. Please check console logs for errors.");
//                }
                result.success(mapStyleResult);
                break;
            }
            default:
                result.notImplemented();
        }
    }

//    @Override
//    public void onMapClick(LatLng latLng) {
//        final Map<String, Object> arguments = new HashMap<>(2);
//        arguments.put("position", Convert.latLngToJson(latLng));
//        methodChannel.invokeMethod("map#onTap", arguments);
//    }
//
//    @Override
//    public void onMapLongClick(LatLng latLng) {
//        final Map<String, Object> arguments = new HashMap<>(2);
//        arguments.put("position", Convert.latLngToJson(latLng));
//        methodChannel.invokeMethod("map#onLongPress", arguments);
//    }
//
//    @Override
//    public void onCameraMoveStarted(int reason) {
//        final Map<String, Object> arguments = new HashMap<>(2);
////        boolean isGesture = reason == NaverMap.OnCameraMoveStartedListener.REASON_GESTURE;
////        arguments.put("isGesture", isGesture);
//        methodChannel.invokeMethod("camera#onMoveStarted", arguments);
//    }
//
//    @Override
//    public void onInfoWindowClick(Marker marker) {
////        markersController.onInfoWindowTap(marker.getId());
//    }
//
//    @Override
//    public void onCameraMove() {
//        if (!trackCameraPosition) {
//            return;
//        }
//        final Map<String, Object> arguments = new HashMap<>(2);
//        arguments.put("position", Convert.cameraPositionToJson(naverMap.getCameraPosition()));
//        methodChannel.invokeMethod("camera#onMove", arguments);
//    }
//
//    @Override
//    public void onCameraIdle() {
//        methodChannel.invokeMethod("camera#onIdle", Collections.singletonMap("map", id));
//    }
//
//    @Override
//    public boolean onMarkerClick(Marker marker) {
////        return markersController.onMarkerTap(marker.getId());
//    }

//    @Override
//    public void onMarkerDragStart(Marker marker) {}
//
//    @Override
//    public void onMarkerDrag(Marker marker) {}
//
//    @Override
//    public void onMarkerDragEnd(Marker marker) {
//        markersController.onMarkerDragEnd(marker.getId(), marker.getPosition());
//    }
//
//    @Override
//    public void onPolygonClick(Polygon polygon) {
//        polygonsController.onPolygonTap(polygon.getId());
//    }
//
//    @Override
//    public void onPolylineClick(Polyline polyline) {
//        polylinesController.onPolylineTap(polyline.getId());
//    }
//
//    @Override
//    public void onCircleClick(Circle circle) {
//        circlesController.onCircleTap(circle.getId());
//    }

    @Override
    public void dispose() {
        if (disposed) {
            return;
        }
        disposed = true;
        methodChannel.setMethodCallHandler(null);
        setNaverMapListener(null);
        getApplication().unregisterActivityLifecycleCallbacks(this);
    }

    private void setNaverMapListener(@Nullable NaverMapListener listener) {
//        naverMap.setOnCameraMoveStartedListener(listener);
//        naverMap.setOnCameraMoveListener(listener);
//        naverMap.setOnCameraIdleListener(listener);
//        naverMap.setOnMarkerClickListener(listener);
//        naverMap.setOnMarkerDragListener(listener);
//        naverMap.setOnPolygonClickListener(listener);
//        naverMap.setOnPolylineClickListener(listener);
//        naverMap.setOnCircleClickListener(listener);
        naverMap.setOnMapClickListener(listener);
        naverMap.setOnMapLongClickListener(listener);
    }

    // @Override
    // The minimum supported version of Flutter doesn't have this method on the PlatformView interface, but the maximum
    // does. This will override it when available even with the annotation commented out.
    public void onInputConnectionLocked() {
        // TODO(mklim): Remove this empty override once https://github.com/flutter/flutter/issues/40126 is fixed in stable.
    };

    // @Override
    // The minimum supported version of Flutter doesn't have this method on the PlatformView interface, but the maximum
    // does. This will override it when available even with the annotation commented out.
    public void onInputConnectionUnlocked() {
        // TODO(mklim): Remove this empty override once https://github.com/flutter/flutter/issues/40126 is fixed in stable.
    };

    // Application.ActivityLifecycleCallbacks methods
    @Override
    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
        if (disposed || activity.hashCode() != getActivityHashCode()) {
            return;
        }
        mapView.onCreate(savedInstanceState);
    }

    @Override
    public void onActivityStarted(Activity activity) {
        if (disposed || activity.hashCode() != getActivityHashCode()) {
            return;
        }
        mapView.onStart();
    }

    @Override
    public void onActivityResumed(Activity activity) {
        if (disposed || activity.hashCode() != getActivityHashCode()) {
            return;
        }
        mapView.onResume();
    }

    @Override
    public void onActivityPaused(Activity activity) {
        if (disposed || activity.hashCode() != getActivityHashCode()) {
            return;
        }
        mapView.onPause();
    }

    @Override
    public void onActivityStopped(Activity activity) {
        if (disposed || activity.hashCode() != getActivityHashCode()) {
            return;
        }
        mapView.onStop();
    }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
        if (disposed || activity.hashCode() != getActivityHashCode()) {
            return;
        }
        mapView.onSaveInstanceState(outState);
    }

    @Override
    public void onActivityDestroyed(Activity activity) {
        if (disposed || activity.hashCode() != getActivityHashCode()) {
            return;
        }
        mapView.onDestroy();
    }

    // DefaultLifecycleObserver and OnSaveInstanceStateListener

    @Override
    public void onCreate(@NonNull LifecycleOwner owner) {
        if (disposed) {
            return;
        }
        mapView.onCreate(null);
    }

    @Override
    public void onStart(@NonNull LifecycleOwner owner) {
        if (disposed) {
            return;
        }
        mapView.onStart();
    }

    @Override
    public void onResume(@NonNull LifecycleOwner owner) {
        if (disposed) {
            return;
        }
        mapView.onResume();
    }

    @Override
    public void onPause(@NonNull LifecycleOwner owner) {
        if (disposed) {
            return;
        }
        mapView.onResume();
    }

    @Override
    public void onStop(@NonNull LifecycleOwner owner) {
        if (disposed) {
            return;
        }
        mapView.onStop();
    }

    @Override
    public void onDestroy(@NonNull LifecycleOwner owner) {
        if (disposed) {
            return;
        }
        mapView.onDestroy();
    }

    @Override
    public void onRestoreInstanceState(Bundle bundle) {
        if (disposed) {
            return;
        }
        mapView.onCreate(bundle);
    }

    @Override
    public void onSaveInstanceState(Bundle bundle) {
        if (disposed) {
            return;
        }
        mapView.onSaveInstanceState(bundle);
    }

    // NaverMapOptionsSink methods

//    @Override
//    public void setCameraTargetBounds(LatLngBounds bounds) {
////        naverMap.setLatLngBoundsForCameraTarget(bounds);
//    }
//
//    @Override
//    public void setCompassEnabled(boolean compassEnabled) {
//        naverMap.getUiSettings().setCompassEnabled(compassEnabled);
//    }
//
//    @Override
//    public void setMapToolbarEnabled(boolean mapToolbarEnabled) {
////        naverMap.getUiSettings().setMapToolbarEnabled(mapToolbarEnabled);
//    }
//
//    @Override
//    public void setMapType(int mapType) {
////        naverMap.setMapType(mapType);
//    }

//    @Override
//    public void setTrackCameraPosition(boolean trackCameraPosition) {
//        this.trackCameraPosition = trackCameraPosition;
//    }
//
//    @Override
//    public void setRotateGesturesEnabled(boolean rotateGesturesEnabled) {
//        naverMap.getUiSettings().setRotateGesturesEnabled(rotateGesturesEnabled);
//    }
//
//    @Override
//    public void setScrollGesturesEnabled(boolean scrollGesturesEnabled) {
//        naverMap.getUiSettings().setScrollGesturesEnabled(scrollGesturesEnabled);
//    }
//
//    @Override
//    public void setTiltGesturesEnabled(boolean tiltGesturesEnabled) {
//        naverMap.getUiSettings().setTiltGesturesEnabled(tiltGesturesEnabled);
//    }

//    @Override
//    public void setMinMaxZoomPreference(Float min, Float max) {
//        naverMap.resetMinMaxZoomPreference();
//        if (min != null) {
//            naverMap.setMinZoomPreference(min);
//        }
//        if (max != null) {
//            naverMap.setMaxZoomPreference(max);
//        }
//    }

//    @Override
//    public void setPadding(float top, float left, float bottom, float right) {
//        if (naverMap != null) {
//            naverMap.setContentPadding(
//                    (int) (left * density),
//                    (int) (top * density),
//                    (int) (right * density),
//                    (int) (bottom * density));
//        }
//    }

//    @Override
//    public void setZoomGesturesEnabled(boolean zoomGesturesEnabled) {
//        naverMap.getUiSettings().setZoomGesturesEnabled(zoomGesturesEnabled);
//    }

//    @Override
//    public void setMyLocationEnabled(boolean myLocationEnabled) {
//        if (this.myLocationEnabled == myLocationEnabled) {
//            return;
//        }
//        this.myLocationEnabled = myLocationEnabled;
//        if (naverMap != null) {
//            updateMyLocationSettings();
//        }
//    }

//    @Override
//    public void setMyLocationButtonEnabled(boolean myLocationButtonEnabled) {
//        if (this.myLocationButtonEnabled == myLocationButtonEnabled) {
//            return;
//        }
//        this.myLocationButtonEnabled = myLocationButtonEnabled;
//        if (naverMap != null) {
//            updateMyLocationSettings();
//        }
//    }

//    @Override
//    public void setZoomControlsEnabled(boolean zoomControlsEnabled) {
//        if (this.zoomControlsEnabled == zoomControlsEnabled) {
//            return;
//        }
//        this.zoomControlsEnabled = zoomControlsEnabled;
//        if (naverMap != null) {
////            naverMap.getUiSettings().setZoomControlsEnabled(zoomControlsEnabled);
//        }
//    }

//    @Override
//    public void setInitialMarkers(Object initialMarkers) {
//        this.initialMarkers = (List<Object>) initialMarkers;
//        if (naverMap != null) {
//            updateInitialMarkers();
//        }
//    }

    private void updateInitialMarkers() {
//        markersController.addMarkers(initialMarkers);
    }

//    @Override
//    public void setInitialPolygons(Object initialPolygons) {
//        this.initialPolygons = (List<Object>) initialPolygons;
//        if (naverMap != null) {
//            updateInitialPolygons();
//        }
//    }

    private void updateInitialPolygons() {
//        polygonsController.addPolygons(initialPolygons);
    }

//    @Override
//    public void setInitialPolylines(Object initialPolylines) {
//        this.initialPolylines = (List<Object>) initialPolylines;
//        if (naverMap != null) {
//            updateInitialPolylines();
//        }
//    }

    private void updateInitialPolylines() {
//        polylinesController.addPolylines(initialPolylines);
    }

//    @Override
//    public void setInitialCircles(Object initialCircles) {
//        this.initialCircles = (List<Object>) initialCircles;
//        if (naverMap != null) {
//            updateInitialCircles();
//        }
//    }

    private void updateInitialCircles() {
//        circlesController.addCircles(initialCircles);
    }

    @SuppressLint("MissingPermission")
    private void updateMyLocationSettings() {
        if (hasLocationPermission()) {
            // The plugin doesn't add the location permission by default so that apps that don't need
            // the feature won't require the permission.
            // Gradle is doing a static check for missing permission and in some configurations will
            // fail the build if the permission is missing. The following disables the Gradle lint.
            //noinspection ResourceType
//            naverMap.setMyLocationEnabled(myLocationEnabled);
//            naverMap.getUiSettings().setMyLocationButtonEnabled(myLocationButtonEnabled);
        } else {
            // TODO(amirh): Make the options update fail.
            // https://github.com/flutter/flutter/issues/24327
            Log.e(TAG, "Cannot enable MyLocation layer as location permissions are not granted");
        }
    }

    private boolean hasLocationPermission() {
        return checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
                == PackageManager.PERMISSION_GRANTED
                || checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION)
                == PackageManager.PERMISSION_GRANTED;
    }

    private int checkSelfPermission(String permission) {
        if (permission == null) {
            throw new IllegalArgumentException("permission is null");
        }
        return context.checkPermission(
                permission, android.os.Process.myPid(), android.os.Process.myUid());
    }

    private int getActivityHashCode() {
        if (registrar != null && registrar.activity() != null) {
            return registrar.activity().hashCode();
        } else {
            return activityHashCode;
        }
    }

    private Application getApplication() {
        if (registrar != null && registrar.activity() != null) {
            return registrar.activity().getApplication();
        } else {
            return mApplication;
        }
    }

    public void setIndoorEnabled(boolean indoorEnabled) {
        this.indoorEnabled = indoorEnabled;
    }

    public void setTrafficEnabled(boolean trafficEnabled) {
        this.trafficEnabled = trafficEnabled;
        if (naverMap == null) {
            return;
        }
//        naverMap.setTrafficEnabled(trafficEnabled);
    }

    public void setBuildingsEnabled(boolean buildingsEnabled) {
        this.buildingsEnabled = buildingsEnabled;
    }

    @Override
    public void onCameraChange(int i, boolean b) {

    }

    @Override
    public void onIndoorSelectionChange(@Nullable IndoorSelection indoorSelection) {

    }

    @Override
    public void onLocationChange(@NonNull Location location) {

    }

    @Override
    public void onMapClick(@NonNull PointF pointF, @NonNull LatLng latLng) {

    }

    @Override
    public boolean onMapDoubleTap(@NonNull PointF pointF, @NonNull LatLng latLng) {
        return false;
    }

    @Override
    public void onMapLongClick(@NonNull PointF pointF, @NonNull LatLng latLng) {

    }

    @Override
    public boolean onMapTwoFingerTap(@NonNull PointF pointF, @NonNull LatLng latLng) {
        return false;
    }

    @Override
    public void onOptionChange() {

    }

    @Override
    public boolean onSymbolClick(@NonNull Symbol symbol) {
        return false;
    }

    @Override
    public void onCameraIdle() {

    }
}

interface NaverMapListener
        extends NaverMap.OnCameraIdleListener,
        NaverMap.OnLocationChangeListener,
        NaverMap.OnSymbolClickListener,
        NaverMap.OnOptionChangeListener,
        NaverMap.OnMapTwoFingerTapListener,
        NaverMap.OnMapDoubleTapListener,
        NaverMap.OnIndoorSelectionChangeListener,
        NaverMap.OnMapLongClickListener,
        NaverMap.OnMapClickListener,
        NaverMap.OnCameraChangeListener{}
