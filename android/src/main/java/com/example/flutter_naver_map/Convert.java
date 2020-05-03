package com.example.flutter_naver_map;

import com.naver.maps.geometry.LatLng;
import com.naver.maps.geometry.LatLngBounds;
import com.naver.maps.map.CameraPosition;
import com.naver.maps.map.CameraUpdate;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Convert {

//    static CameraPosition toCameraPosition(Object o) {
//        final Map<?, ?> data = toMap(o);
//        final CameraPosition builder = new CameraPosition(toLatLng(o), toFloat(data.get("zoom")));
//        return builder;
//    }

    static Object latlngBoundsToJson(LatLngBounds latLngBounds) {
        final Map<String, Object> arguments = new HashMap<>(2);
        arguments.put("southwest", latLngToJson(latLngBounds.getSouthWest()));
        arguments.put("northeast", latLngToJson(latLngBounds.getNorthEast()));
        return arguments;
    }

    static CameraUpdate toCameraUpdate(Object o, float density) {
        final List<?> data = toList(o);
        switch (toString(data.get(0))) {
//            case "newCameraPosition":
//                return CameraUpdateFactory.newCameraPosition(toCameraPosition(data.get(1)));
//            case "newLatLng":
//                return CameraUpdateFactory.newLatLng(toLatLng(data.get(1)));
//            case "newLatLngBounds":
//                return CameraUpdateFactory.newLatLngBounds(
//                        toLatLngBounds(data.get(1)), toPixels(data.get(2), density));
//            case "newLatLngZoom":
//                return CameraUpdateFactory.newLatLngZoom(toLatLng(data.get(1)), toFloat(data.get(2)));
//            case "scrollBy":
//                return CameraUpdateFactory.scrollBy( //
//                        toFractionalPixels(data.get(1), density), //
//                        toFractionalPixels(data.get(2), density));
//            case "zoomBy":
//                if (data.size() == 2) {
//                    return CameraUpdateFactory.zoomBy(toFloat(data.get(1)));
//                } else {
//                    return CameraUpdateFactory.zoomBy(toFloat(data.get(1)), toPoint(data.get(2), density));
//                }
//            case "zoomIn":
//                return CameraUpdateFactory.zoomIn();
//            case "zoomOut":
//                return CameraUpdateFactory.zoomOut();
//            case "zoomTo":
//                return CameraUpdateFactory.zoomTo(toFloat(data.get(1)));
            default:
                throw new IllegalArgumentException("Cannot interpret " + o + " as CameraUpdate");
        }
    }

    private static double toDouble(Object o) {
        return ((Number) o).doubleValue();
    }

    private static float toFloat(Object o) {
        return ((Number) o).floatValue();
    }

    private static Float toFloatWrapper(Object o) {
        return (o == null) ? null : toFloat(o);
    }

    private static int toInt(Object o) {
        return ((Number) o).intValue();
    }


    static Object latLngToJson(LatLng latLng) {
        return Arrays.asList(latLng.latitude, latLng.longitude);
    }

    static LatLng toLatLng(Object o) {
        final List<?> data = toList(o);
        return new LatLng(toDouble(data.get(0)), toDouble(data.get(1)));
    }

    private static String toString(Object o) {
        return (String) o;
    }

    private static List<?> toList(Object o) {
        return (List<?>) o;
    }

    private static Map<?, ?> toMap(Object o) {
        return (Map<?, ?>) o;
    }

}
