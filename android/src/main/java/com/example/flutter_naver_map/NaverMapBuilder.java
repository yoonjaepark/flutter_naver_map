package com.example.flutter_naver_map;

import android.app.Application;
import android.content.Context;
import android.graphics.Rect;

import androidx.lifecycle.Lifecycle;

import com.naver.maps.geometry.LatLngBounds;
import com.naver.maps.map.CameraPosition;
import com.naver.maps.map.NaverMap;
import com.naver.maps.map.NaverMapOptions;
import com.naver.maps.map.NaverMapSdk;

import java.util.concurrent.atomic.AtomicInteger;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry;

class NaverMapBuilder {
    private final NaverMapOptions options = new NaverMapOptions();
    private boolean trackCameraPosition = false;
    private boolean myLocationEnabled = false;
    private boolean myLocationButtonEnabled = false;
    private boolean indoorEnabled = true;
    private boolean trafficEnabled = false;
    private boolean buildingsEnabled = true;
    private Object initialMarkers;
    private Object initialPolygons;
    private Object initialPolylines;
    private Object initialCircles;
    private Rect padding = new Rect(0, 0, 0, 0);

    NaverMapController build(
            int id,
            Context context,
            AtomicInteger state,
            BinaryMessenger binaryMessenger,
            Application application,
            Lifecycle lifecycle,
            PluginRegistry.Registrar registrar,
            int activityHashCode) {
        final NaverMapController controller =
                new NaverMapController(
                        id,
                        context,
                        state,
                        binaryMessenger,
                        application,
                        lifecycle,
                        registrar,
                        activityHashCode,
                        options);
        controller.init();
//        controller.setMyLocationEnabled(myLocationEnabled);
//        controller.setMyLocationButtonEnabled(myLocationButtonEnabled);
        controller.setIndoorEnabled(indoorEnabled);
        controller.setTrafficEnabled(trafficEnabled);
        controller.setBuildingsEnabled(buildingsEnabled);
//        controller.setTrackCameraPosition(trackCameraPosition);
//        controller.setInitialMarkers(initialMarkers);
//        controller.setInitialPolygons(initialPolygons);
//        controller.setInitialPolylines(initialPolylines);
//        controller.setInitialCircles(initialCircles);
//        controller.setPadding(padding.top, padding.left, padding.bottom, padding.right);
        return controller;
    }

    void setInitialCameraPosition(CameraPosition position) {
        options.camera(position);
    }

    public void setCompassEnabled(boolean compassEnabled) {
        options.compassEnabled(compassEnabled);
    }

    public void setMapToolbarEnabled(boolean setMapToolbarEnabled) {
//        options.mapToolbarEnabled(setMapToolbarEnabled);
    }

    public void setCameraTargetBounds(LatLngBounds bounds) {
//        options.latLngBoundsForCameraTarget(bounds);
    }

    public void setMapType(int mapType) {
        switch (mapType) {
            case 1:
                options.mapType(NaverMap.MapType.Basic);
                break;
            case 2:
                options.mapType(NaverMap.MapType.Hybrid);
                break;
            case 3:
                options.mapType(NaverMap.MapType.Navi);
                break;
            case 4:
                options.mapType(NaverMap.MapType.None);
                break;
        }

    }

    public void setMinMaxZoomPreference(Float min, Float max) {
        if (min != null) {
            options.minZoom(min);
        }
        if (max != null) {
            options.maxZoom(max);
        }
    }

    public void setPadding(float top, float left, float bottom, float right) {
        this.padding = new Rect((int) left, (int) top, (int) right, (int) bottom);
    }

    public void setTrackCameraPosition(boolean trackCameraPosition) {
        this.trackCameraPosition = trackCameraPosition;
    }

    public void setRotateGesturesEnabled(boolean rotateGesturesEnabled) {
        options.rotateGesturesEnabled(rotateGesturesEnabled);
    }

    public void setScrollGesturesEnabled(boolean scrollGesturesEnabled) {
        options.scrollGesturesEnabled(scrollGesturesEnabled);
    }

    public void setTiltGesturesEnabled(boolean tiltGesturesEnabled) {
        options.tiltGesturesEnabled(tiltGesturesEnabled);
    }

    public void setZoomGesturesEnabled(boolean zoomGesturesEnabled) {
        options.zoomGesturesEnabled(zoomGesturesEnabled);
    }

    public void setIndoorEnabled(boolean indoorEnabled) {
        this.indoorEnabled = indoorEnabled;
    }

    public void setTrafficEnabled(boolean trafficEnabled) {
        this.trafficEnabled = trafficEnabled;
    }

    public void setBuildingsEnabled(boolean buildingsEnabled) {
        this.buildingsEnabled = buildingsEnabled;
    }

    public void setMyLocationEnabled(boolean myLocationEnabled) {
        this.myLocationEnabled = myLocationEnabled;
    }

    public void setZoomControlsEnabled(boolean zoomControlsEnabled) {
        options.zoomControlEnabled(zoomControlsEnabled);
    }

    public void setMyLocationButtonEnabled(boolean myLocationButtonEnabled) {
        this.myLocationButtonEnabled = myLocationButtonEnabled;
    }

    public void setInitialMarkers(Object initialMarkers) {
        this.initialMarkers = initialMarkers;
    }

    public void setInitialPolygons(Object initialPolygons) {
        this.initialPolygons = initialPolygons;
    }

    public void setInitialPolylines(Object initialPolylines) {
        this.initialPolylines = initialPolylines;
    }

    public void setInitialCircles(Object initialCircles) {
        this.initialCircles = initialCircles;
    }
}
