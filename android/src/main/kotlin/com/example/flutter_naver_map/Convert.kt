package com.example.flutter_naver_map

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Point
import com.naver.maps.geometry.LatLng
import com.naver.maps.geometry.LatLngBounds
import com.naver.maps.map.CameraPosition
import com.naver.maps.map.CameraUpdate
import io.flutter.view.FlutterMain
import java.util.ArrayList
import java.util.Arrays
import java.util.HashMap

/** Conversions between JSON-like values and GoogleMaps data types.  */
internal object Convert {


    private fun toDouble(o: Any): Double {
        return (o as Number).toDouble()
    }

    private fun toFloat(o: Any): Float {
        return (o as Number).toFloat()
    }

    private fun toFloatWrapper(o: Any?): Float? {
        return if (o == null) null else toFloat(o)
    }

    private fun toInt(o: Any): Int {
        return (o as Number).toInt()
    }

    fun cameraPositionToJson(position: CameraPosition?): Any? {
        if (position == null) {
            return null
        }
        val data = HashMap<String, Any>()
        data["bearing"] = position!!.bearing
        data["target"] = latLngToJson(position!!.target)
        data["tilt"] = position!!.tilt
        data["zoom"] = position!!.zoom
        return data
    }

    fun latlngBoundsToJson(latLngBounds: LatLngBounds): Any {
        val arguments = HashMap<String, Any>(2)
        arguments["southwest"] = latLngToJson(latLngBounds.southWest)
        arguments["northeast"] = latLngToJson(latLngBounds.northEast)
        return arguments
    }

    fun markerIdToJson(markerId: String?): Any? {
        if (markerId == null) {
            return null
        }
        val data = HashMap<String, Any>(1)
        data["markerId"] = markerId
        return data
    }

    fun polygonIdToJson(polygonId: String?): Any? {
        if (polygonId == null) {
            return null
        }
        val data = HashMap<String, Any>(1)
        data["polygonId"] = polygonId
        return data
    }

    fun polylineIdToJson(polylineId: String?): Any? {
        if (polylineId == null) {
            return null
        }
        val data = HashMap<String, Any>(1)
        data["polylineId"] = polylineId
        return data
    }

    fun circleIdToJson(circleId: String?): Any? {
        if (circleId == null) {
            return null
        }
        val data = HashMap<String, Any>(1)
        data["circleId"] = circleId
        return data
    }

    fun latLngToJson(latLng: LatLng): Any {
        return Arrays.asList<Any>(latLng.latitude, latLng.longitude)
    }

    fun toLatLng(o: Any): LatLng {
        val data = toList(o)
        return LatLng(toDouble(data[0]!!), toDouble(data[1]!!))
    }

    fun toPoint(o: Any): Point {
        val screenCoordinate = o as Map<String, Int>
        return Point(screenCoordinate["x"]!!, screenCoordinate["y"]!!)
    }

    fun pointToJson(point: Point): Map<String, Int> {
        val data = HashMap<String, Int>(2)
        data["x"] = point.x
        data["y"] = point.y
        return data
    }

    private fun toLatLngBounds(o: Any?): LatLngBounds? {
        if (o == null) {
            return null
        }
        val data = toList(o)
        return LatLngBounds(toLatLng(data[0]!!), toLatLng(data[1]!!))
    }

    private fun toList(o: Any): List<*> {
        return o as List<*>
    }

    private fun toMap(o: Any): Map<*, *> {
        return o as Map<*, *>
    }

    private fun toFractionalPixels(o: Any, density: Float): Float {
        return toFloat(o) * density
    }

    private fun toPixels(o: Any, density: Float): Int {
        return toFractionalPixels(o, density).toInt()
    }

    private fun toBitmap(o: Any): Bitmap {
        val bmpData = o as ByteArray
        val bitmap = BitmapFactory.decodeByteArray(bmpData, 0, bmpData.size)
        return bitmap ?: throw IllegalArgumentException("Unable to decode bytes as a valid bitmap.")
    }

    private fun toPoint(o: Any, density: Float): Point {
        val data = toList(o)
        return Point(toPixels(data[0]!!, density), toPixels(data[1]!!, density))
    }

    private fun toString(o: Any): String {
        return o as String
    }
//
//    fun interpretGoogleMapOptions(o: Any, sink: GoogleMapOptionsSink) {
//        val data = toMap(o)
//        val cameraTargetBounds = data["cameraTargetBounds"]
//        if (cameraTargetBounds != null) {
//            val targetData = toList(cameraTargetBounds)
//            sink.setCameraTargetBounds(toLatLngBounds(targetData[0]))
//        }
//        val compassEnabled = data["compassEnabled"]
//        if (compassEnabled != null) {
//            sink.setCompassEnabled(toBoolean(compassEnabled))
//        }
//        val mapToolbarEnabled = data["mapToolbarEnabled"]
//        if (mapToolbarEnabled != null) {
//            sink.setMapToolbarEnabled(toBoolean(mapToolbarEnabled))
//        }
//        val mapType = data["mapType"]
//        if (mapType != null) {
//            sink.setMapType(toInt(mapType))
//        }
//        val minMaxZoomPreference = data["minMaxZoomPreference"]
//        if (minMaxZoomPreference != null) {
//            val zoomPreferenceData = toList(minMaxZoomPreference)
//            sink.setMinMaxZoomPreference( //
//                    toFloatWrapper(zoomPreferenceData[0]), //
//                    toFloatWrapper(zoomPreferenceData[1]))
//        }
//        val padding = data["padding"]
//        if (padding != null) {
//            val paddingData = toList(padding)
//            sink.setPadding(
//                    toFloat(paddingData[0]),
//                    toFloat(paddingData[1]),
//                    toFloat(paddingData[2]),
//                    toFloat(paddingData[3]))
//        }
//        val rotateGesturesEnabled = data["rotateGesturesEnabled"]
//        if (rotateGesturesEnabled != null) {
//            sink.setRotateGesturesEnabled(toBoolean(rotateGesturesEnabled))
//        }
//        val scrollGesturesEnabled = data["scrollGesturesEnabled"]
//        if (scrollGesturesEnabled != null) {
//            sink.setScrollGesturesEnabled(toBoolean(scrollGesturesEnabled))
//        }
//        val tiltGesturesEnabled = data["tiltGesturesEnabled"]
//        if (tiltGesturesEnabled != null) {
//            sink.setTiltGesturesEnabled(toBoolean(tiltGesturesEnabled))
//        }
//        val trackCameraPosition = data["trackCameraPosition"]
//        if (trackCameraPosition != null) {
//            sink.setTrackCameraPosition(toBoolean(trackCameraPosition))
//        }
//        val zoomGesturesEnabled = data["zoomGesturesEnabled"]
//        if (zoomGesturesEnabled != null) {
//            sink.setZoomGesturesEnabled(toBoolean(zoomGesturesEnabled))
//        }
//        val myLocationEnabled = data["myLocationEnabled"]
//        if (myLocationEnabled != null) {
//            sink.setMyLocationEnabled(toBoolean(myLocationEnabled))
//        }
//        val zoomControlsEnabled = data["zoomControlsEnabled"]
//        if (zoomControlsEnabled != null) {
//            sink.setZoomControlsEnabled(toBoolean(zoomControlsEnabled))
//        }
//        val myLocationButtonEnabled = data["myLocationButtonEnabled"]
//        if (myLocationButtonEnabled != null) {
//            sink.setMyLocationButtonEnabled(toBoolean(myLocationButtonEnabled))
//        }
//        val indoorEnabled = data["indoorEnabled"]
//        if (indoorEnabled != null) {
//            sink.setIndoorEnabled(toBoolean(indoorEnabled))
//        }
//        val trafficEnabled = data["trafficEnabled"]
//        if (trafficEnabled != null) {
//            sink.setTrafficEnabled(toBoolean(trafficEnabled))
//        }
//        val buildingsEnabled = data["buildingsEnabled"]
//        if (buildingsEnabled != null) {
//            sink.setBuildingsEnabled(toBoolean(buildingsEnabled))
//        }
//    }
//
//    /** Returns the dartMarkerId of the interpreted marker.  */
//    fun interpretMarkerOptions(o: Any, sink: MarkerOptionsSink): String {
//        val data = toMap(o)
//        val alpha = data["alpha"]
//        if (alpha != null) {
//            sink.setAlpha(toFloat(alpha))
//        }
//        val anchor = data["anchor"]
//        if (anchor != null) {
//            val anchorData = toList(anchor)
//            sink.setAnchor(toFloat(anchorData[0]), toFloat(anchorData[1]))
//        }
//        val consumeTapEvents = data["consumeTapEvents"]
//        if (consumeTapEvents != null) {
//            sink.setConsumeTapEvents(toBoolean(consumeTapEvents))
//        }
//        val draggable = data["draggable"]
//        if (draggable != null) {
//            sink.setDraggable(toBoolean(draggable))
//        }
//        val flat = data["flat"]
//        if (flat != null) {
//            sink.setFlat(toBoolean(flat))
//        }
//        val icon = data["icon"]
//        if (icon != null) {
//            sink.setIcon(toBitmapDescriptor(icon))
//        }
//
//        val infoWindow = data["infoWindow"]
//        if (infoWindow != null) {
//            interpretInfoWindowOptions(sink, (infoWindow as Map<String, Any>?)!!)
//        }
//        val position = data["position"]
//        if (position != null) {
//            sink.setPosition(toLatLng(position))
//        }
//        val rotation = data["rotation"]
//        if (rotation != null) {
//            sink.setRotation(toFloat(rotation))
//        }
//        val visible = data["visible"]
//        if (visible != null) {
//            sink.setVisible(toBoolean(visible))
//        }
//        val zIndex = data["zIndex"]
//        if (zIndex != null) {
//            sink.setZIndex(toFloat(zIndex))
//        }
//        val markerId = data["markerId"] as String
//        return markerId ?: throw IllegalArgumentException("markerId was null")
//    }
//
//    private fun interpretInfoWindowOptions(
//            sink: MarkerOptionsSink, infoWindow: Map<String, Any>) {
//        val title = infoWindow["title"] as String
//        val snippet = infoWindow["snippet"] as String
//        // snippet is nullable.
//        if (title != null) {
//            sink.setInfoWindowText(title, snippet)
//        }
//        val infoWindowAnchor = infoWindow["anchor"]
//        if (infoWindowAnchor != null) {
//            val anchorData = toList(infoWindowAnchor)
//            sink.setInfoWindowAnchor(toFloat(anchorData[0]), toFloat(anchorData[1]))
//        }
//    }
//
//    fun interpretPolygonOptions(o: Any, sink: PolygonOptionsSink): String {
//        val data = toMap(o)
//        val consumeTapEvents = data["consumeTapEvents"]
//        if (consumeTapEvents != null) {
//            sink.setConsumeTapEvents(toBoolean(consumeTapEvents))
//        }
//        val geodesic = data["geodesic"]
//        if (geodesic != null) {
//            sink.setGeodesic(toBoolean(geodesic))
//        }
//        val visible = data["visible"]
//        if (visible != null) {
//            sink.setVisible(toBoolean(visible))
//        }
//        val fillColor = data["fillColor"]
//        if (fillColor != null) {
//            sink.setFillColor(toInt(fillColor))
//        }
//        val strokeColor = data["strokeColor"]
//        if (strokeColor != null) {
//            sink.setStrokeColor(toInt(strokeColor))
//        }
//        val strokeWidth = data["strokeWidth"]
//        if (strokeWidth != null) {
//            sink.setStrokeWidth(toInt(strokeWidth))
//        }
//        val zIndex = data["zIndex"]
//        if (zIndex != null) {
//            sink.setZIndex(toFloat(zIndex))
//        }
//        val points = data["points"]
//        if (points != null) {
//            sink.setPoints(toPoints(points))
//        }
//        val polygonId = data["polygonId"] as String
//        return polygonId ?: throw IllegalArgumentException("polygonId was null")
//    }
//
//    fun interpretPolylineOptions(o: Any, sink: PolylineOptionsSink): String {
//        val data = toMap(o)
//        val consumeTapEvents = data["consumeTapEvents"]
//        if (consumeTapEvents != null) {
//            sink.setConsumeTapEvents(toBoolean(consumeTapEvents))
//        }
//        val color = data["color"]
//        if (color != null) {
//            sink.setColor(toInt(color))
//        }
//        val endCap = data["endCap"]
//        if (endCap != null) {
//            sink.setEndCap(toCap(endCap))
//        }
//        val geodesic = data["geodesic"]
//        if (geodesic != null) {
//            sink.setGeodesic(toBoolean(geodesic))
//        }
//        val jointType = data["jointType"]
//        if (jointType != null) {
//            sink.setJointType(toInt(jointType))
//        }
//        val startCap = data["startCap"]
//        if (startCap != null) {
//            sink.setStartCap(toCap(startCap))
//        }
//        val visible = data["visible"]
//        if (visible != null) {
//            sink.setVisible(toBoolean(visible))
//        }
//        val width = data["width"]
//        if (width != null) {
//            sink.setWidth(toInt(width))
//        }
//        val zIndex = data["zIndex"]
//        if (zIndex != null) {
//            sink.setZIndex(toFloat(zIndex))
//        }
//        val points = data["points"]
//        if (points != null) {
//            sink.setPoints(toPoints(points))
//        }
//        val pattern = data["pattern"]
//        if (pattern != null) {
//            sink.setPattern(toPattern(pattern))
//        }
//        val polylineId = data["polylineId"] as String
//        return polylineId ?: throw IllegalArgumentException("polylineId was null")
//    }

//    fun interpretCircleOptions(o: Any, sink: CircleOptionsSink): String {
//        val data = toMap(o)
//        val consumeTapEvents = data["consumeTapEvents"]
//        if (consumeTapEvents != null) {
//            sink.setConsumeTapEvents(toBoolean(consumeTapEvents))
//        }
//        val fillColor = data["fillColor"]
//        if (fillColor != null) {
//            sink.setFillColor(toInt(fillColor))
//        }
//        val strokeColor = data["strokeColor"]
//        if (strokeColor != null) {
//            sink.setStrokeColor(toInt(strokeColor))
//        }
//        val visible = data["visible"]
//        if (visible != null) {
//            sink.setVisible(toBoolean(visible))
//        }
//        val strokeWidth = data["strokeWidth"]
//        if (strokeWidth != null) {
//            sink.setStrokeWidth(toInt(strokeWidth))
//        }
//        val zIndex = data["zIndex"]
//        if (zIndex != null) {
//            sink.setZIndex(toFloat(zIndex))
//        }
//        val center = data["center"]
//        if (center != null) {
//            sink.setCenter(toLatLng(center))
//        }
//        val radius = data["radius"]
//        if (radius != null) {
//            sink.setRadius(toDouble(radius))
//        }
//        val circleId = data["circleId"] as String
//        return circleId ?: throw IllegalArgumentException("circleId was null")
//    }

    private fun toPoints(o: Any): List<LatLng> {
        val data = toList(o)
        val points = ArrayList<LatLng>(data.size)

        for (ob in data) {
            val point = toList(ob!!)
            points.add(LatLng(toDouble(point[0]!!), toDouble(point[1]!!)))
        }
        return points
    }

//    private fun toPattern(o: Any): List<PatternItem>? {
//        val data = toList(o)
//
//        if (data.isEmpty()) {
//            return null
//        }
//
//        val pattern = ArrayList<PatternItem>(data.size)
//
//        for (ob in data) {
//            val patternItem = toList(ob)
//            when (toString(patternItem[0])) {
//                "dot" -> pattern.add(Dot())
//                "dash" -> pattern.add(Dash(toFloat(patternItem[1])))
//                "gap" -> pattern.add(Gap(toFloat(patternItem[1])))
//                else -> throw IllegalArgumentException("Cannot interpret $pattern as PatternItem")
//            }
//        }
//
//        return pattern
//    }

//    private fun toCap(o: Any): Cap {
//        val data = toList(o)
//        when (toString(data[0])) {
//            "buttCap" -> return ButtCap()
//            "roundCap" -> return RoundCap()
//            "squareCap" -> return SquareCap()
//            "customCap" -> return if (data.size == 2) {
//                CustomCap(toBitmapDescriptor(data[1]))
//            } else {
//                CustomCap(toBitmapDescriptor(data[1]), toFloat(data[2]))
//            }
//            else -> throw IllegalArgumentException("Cannot interpret $o as Cap")
//        }
//    }
}
