// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_naver_map/src/types/types.dart';
import 'package:flutter_naver_map/naver_maps_flutter_platform_interface.dart';
import 'package:flutter_naver_map/src/method_channel/method_channel_naver_maps_flutter.dart';

/// Callback method for when the map is ready to be used.
///
/// Pass to [NaverMap.onMapCreated] to receive a [NaverMapController] when the
/// map is created.
typedef void MapCreatedCallback(NaverMapController controller);

/// A widget which displays a map with data obtained from the Google Maps service.
class NaverMap extends StatefulWidget {
  /// Creates a widget displaying data from Google Maps services.
  ///
  /// [AssertionError] will be thrown if [initialCameraPosition] is null;
  const NaverMap({
    Key key,
    @required this.initialCameraPosition,
    this.onMapCreated,
    this.gestureRecognizers,
    this.compassEnabled = true,
    this.mapToolbarEnabled = true,
    this.cameraTargetBounds = CameraTargetBounds.unbounded,
    this.mapType = MapType.normal,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomControlsEnabled = true,
    this.zoomGesturesEnabled = true,
    this.tiltGesturesEnabled = true,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = true,

    /// If no padding is specified default padding will be 0.
    this.padding = const EdgeInsets.all(0),
    this.indoorViewEnabled = false,
    this.trafficEnabled = false,
    this.buildingsEnabled = true,
    this.markers,
    this.polygons,
    this.polylines,
    this.circles,
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
  })  : assert(initialCameraPosition != null),
        super(key: key);

  /// Callback method for when the map is ready to be used.
  ///
  /// Used to receive a [NaverMapController] for this [NaverMap].
  final MapCreatedCallback onMapCreated;

  /// The initial position of the map's camera.
  final CameraPosition initialCameraPosition;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// True if the map should show a toolbar when you interact with the map. Android only.
  final bool mapToolbarEnabled;

  /// Geographical bounding box for the camera target.
  final CameraTargetBounds cameraTargetBounds;

  /// Type of map tiles to be rendered.
  final MapType mapType;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should show zoom controls. This includes two buttons
  /// to zoom in and zoom out. The default value is to show zoom controls.
  ///
  /// This is only supported on Android. And this field is silently ignored on iOS.
  final bool zoomControlsEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool tiltGesturesEnabled;

  /// Padding to be set on map. See https://developers.google.com/maps/documentation/android-sdk/map#map_padding for more details.
  final EdgeInsets padding;

  /// Markers to be placed on the map.
  final Set<Marker> markers;

  /// Polygons to be placed on the map.
  final Set<Polygon> polygons;

  /// Polylines to be placed on the map.
  final Set<Polyline> polylines;

  /// Circles to be placed on the map.
  final Set<Circle> circles;

  /// Called when the camera starts moving.
  ///
  /// This can be initiated by the following:
  /// 1. Non-gesture animation initiated in response to user actions.
  ///    For example: zoom buttons, my location button, or marker clicks.
  /// 2. Programmatically initiated animation.
  /// 3. Camera motion initiated in response to user gestures on the map.
  ///    For example: pan, tilt, pinch to zoom, or rotate.
  final VoidCallback onCameraMoveStarted;

  /// Called repeatedly as the camera continues to move after an
  /// onCameraMoveStarted call.
  ///
  /// This may be called as often as once every frame and should
  /// not perform expensive operations.
  final CameraPositionCallback onCameraMove;

  /// Called when camera movement has ended, there are no pending
  /// animations and the user has stopped interacting with the map.
  final VoidCallback onCameraIdle;

  /// Called every time a [NaverMap] is tapped.
  final ArgumentCallback<LatLng> onTap;

  /// Called every time a [NaverMap] is long pressed.
  final ArgumentCallback<LatLng> onLongPress;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  /// if the user's location is currently known.
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On Android add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. `ACCESS_COARSE_LOCATION` returns a
  /// location with an accuracy approximately equivalent to a city block, while
  /// `ACCESS_FINE_LOCATION` returns as precise a location as possible, although
  /// it consumes more battery power. You will also need to request these
  /// permissions during run-time. If they are not granted, the My Location
  /// feature will fail silently.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.
  final bool myLocationEnabled;

  /// Enables or disables the my-location button.
  ///
  /// The my-location button causes the camera to move such that the user's
  /// location is in the center of the map. If the button is enabled, it is
  /// only shown when the my-location layer is enabled.
  ///
  /// By default, the my-location button is enabled (and hence shown when the
  /// my-location layer is enabled).
  ///
  /// See also:
  ///   * [myLocationEnabled] parameter.
  final bool myLocationButtonEnabled;

  /// Enables or disables the indoor view from the map
  final bool indoorViewEnabled;

  /// Enables or disables the traffic layer of the map
  final bool trafficEnabled;

  /// Enables or disables showing 3D buildings where available
  final bool buildingsEnabled;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// Creates a [State] for this [NaverMap].
  @override
  State createState() => _NaverMapState();
}

/// Configuration options for the NaverMaps user interface.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration option".
class _NaverMapOptions {
  _NaverMapOptions({
    this.compassEnabled,
    this.mapToolbarEnabled,
    this.cameraTargetBounds,
    this.mapType,
    this.minMaxZoomPreference,
    this.rotateGesturesEnabled,
    this.scrollGesturesEnabled,
    this.tiltGesturesEnabled,
    this.trackCameraPosition,
    this.zoomControlsEnabled,
    this.zoomGesturesEnabled,
    this.myLocationEnabled,
    this.myLocationButtonEnabled,
    this.padding,
    this.indoorViewEnabled,
    this.trafficEnabled,
    this.buildingsEnabled,
  });

  static _NaverMapOptions fromWidget(NaverMap map) {
    return _NaverMapOptions(
      compassEnabled: map.compassEnabled,
      mapToolbarEnabled: map.mapToolbarEnabled,
      cameraTargetBounds: map.cameraTargetBounds,
      mapType: map.mapType,
      minMaxZoomPreference: map.minMaxZoomPreference,
      rotateGesturesEnabled: map.rotateGesturesEnabled,
      scrollGesturesEnabled: map.scrollGesturesEnabled,
      tiltGesturesEnabled: map.tiltGesturesEnabled,
      trackCameraPosition: map.onCameraMove != null,
      zoomControlsEnabled: map.zoomControlsEnabled,
      zoomGesturesEnabled: map.zoomGesturesEnabled,
      myLocationEnabled: map.myLocationEnabled,
      myLocationButtonEnabled: map.myLocationButtonEnabled,
      padding: map.padding,
      indoorViewEnabled: map.indoorViewEnabled,
      trafficEnabled: map.trafficEnabled,
      buildingsEnabled: map.buildingsEnabled,
    );
  }

  final bool compassEnabled;

  final bool mapToolbarEnabled;

  final CameraTargetBounds cameraTargetBounds;

  final MapType mapType;

  final MinMaxZoomPreference minMaxZoomPreference;

  final bool rotateGesturesEnabled;

  final bool scrollGesturesEnabled;

  final bool tiltGesturesEnabled;

  final bool trackCameraPosition;

  final bool zoomControlsEnabled;

  final bool zoomGesturesEnabled;

  final bool myLocationEnabled;

  final bool myLocationButtonEnabled;

  final EdgeInsets padding;

  final bool indoorViewEnabled;

  final bool trafficEnabled;

  final bool buildingsEnabled;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> optionsMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        optionsMap[fieldName] = value;
      }
    }

    addIfNonNull('compassEnabled', compassEnabled);
    addIfNonNull('mapToolbarEnabled', mapToolbarEnabled);
    addIfNonNull('cameraTargetBounds', cameraTargetBounds?.toJson());
    addIfNonNull('mapType', mapType?.index);
    addIfNonNull('minMaxZoomPreference', minMaxZoomPreference?.toJson());
    addIfNonNull('rotateGesturesEnabled', rotateGesturesEnabled);
    addIfNonNull('scrollGesturesEnabled', scrollGesturesEnabled);
    addIfNonNull('tiltGesturesEnabled', tiltGesturesEnabled);
    addIfNonNull('zoomControlsEnabled', zoomControlsEnabled);
    addIfNonNull('zoomGesturesEnabled', zoomGesturesEnabled);
    addIfNonNull('trackCameraPosition', trackCameraPosition);
    addIfNonNull('myLocationEnabled', myLocationEnabled);
    addIfNonNull('myLocationButtonEnabled', myLocationButtonEnabled);
    addIfNonNull('padding', <double>[
      padding?.top,
      padding?.left,
      padding?.bottom,
      padding?.right,
    ]);
    addIfNonNull('indoorEnabled', indoorViewEnabled);
    addIfNonNull('trafficEnabled', trafficEnabled);
    addIfNonNull('buildingsEnabled', buildingsEnabled);
    return optionsMap;
  }

  Map<String, dynamic> updatesMap(_NaverMapOptions newOptions) {
    final Map<String, dynamic> prevOptionsMap = toMap();

    return newOptions.toMap()
      ..removeWhere(
              (String key, dynamic value) => prevOptionsMap[key] == value);
  }
}




final NaverMapsFlutterPlatform _naverMapsFlutterPlatform =
    NaverMapsFlutterPlatform.instance;
//final GoogleMapsFlutterPlatform _googleMapsFlutterPlatform =
//    GoogleMapsFlutterPlatform.instance;
/// Controller for a single NaverMap instance running on the host platform.
class NaverMapController {
  /// The mapId for this controller
  final int mapId;

  NaverMapController._(
      CameraPosition initialCameraPosition,
      this._naverMapState, {
        @required this.mapId,
      }) : assert(_naverMapsFlutterPlatform != null) {
    _connectStreams(mapId);
  }

  /// Initialize control of a [NaverMap] with [id].
  ///
  /// Mainly for internal use when instantiating a [NaverMapController] passed
  /// in [NaverMap.onMapCreated] callback.
  static Future<NaverMapController> init(
      int id,
      CameraPosition initialCameraPosition,
      _NaverMapState naverMapState,
      ) async {
    assert(id != null);
    await _naverMapsFlutterPlatform.init(id);
    return NaverMapController._(
      initialCameraPosition,
      naverMapState,
      mapId: id,
    );
  }

  /// Used to communicate with the native platform.
  ///
  /// Accessible only for testing.
  // TODO(dit) https://github.com/flutter/flutter/issues/55504 Remove this getter.
  @visibleForTesting
  MethodChannel get channel {
    if (_naverMapsFlutterPlatform is MethodChannelNaverMapsFlutter) {
      return (_naverMapsFlutterPlatform as MethodChannelNaverMapsFlutter)
          .channel(mapId);
    }
    return null;
  }

  final _NaverMapState _naverMapState;

  void _connectStreams(int mapId) {
    if (_naverMapState.widget.onCameraMoveStarted != null) {
      _naverMapsFlutterPlatform
          .onCameraMoveStarted(mapId: mapId)
          .listen((_) => _naverMapState.widget.onCameraMoveStarted());
    }
    if (_naverMapState.widget.onCameraMove != null) {
      _naverMapsFlutterPlatform.onCameraMove(mapId: mapId).listen(
              (CameraMoveEvent e) => _naverMapState.widget.onCameraMove(e.value));
    }
    if (_naverMapState.widget.onCameraIdle != null) {
      _naverMapsFlutterPlatform
          .onCameraIdle(mapId: mapId)
          .listen((_) => _naverMapState.widget.onCameraIdle());
    }
    _naverMapsFlutterPlatform
        .onMarkerTap(mapId: mapId)
        .listen((MarkerTapEvent e) => _naverMapState.onMarkerTap(e.value));
    _naverMapsFlutterPlatform.onMarkerDragEnd(mapId: mapId).listen(
            (MarkerDragEndEvent e) =>
                _naverMapState.onMarkerDragEnd(e.value, e.position));
    _naverMapsFlutterPlatform.onInfoWindowTap(mapId: mapId).listen(
            (InfoWindowTapEvent e) => _naverMapState.onInfoWindowTap(e.value));
    _naverMapsFlutterPlatform
        .onPolylineTap(mapId: mapId)
        .listen((PolylineTapEvent e) => _naverMapState.onPolylineTap(e.value));
    _naverMapsFlutterPlatform
        .onPolygonTap(mapId: mapId)
        .listen((PolygonTapEvent e) => _naverMapState.onPolygonTap(e.value));
    _naverMapsFlutterPlatform
        .onCircleTap(mapId: mapId)
        .listen((CircleTapEvent e) => _naverMapState.onCircleTap(e.value));
    _naverMapsFlutterPlatform
        .onTap(mapId: mapId)
        .listen((MapTapEvent e) => _naverMapState.onTap(e.position));
    _naverMapsFlutterPlatform.onLongPress(mapId: mapId).listen(
            (MapLongPressEvent e) => _naverMapState.onLongPress(e.position));
  }

  /// Updates configuration options of the map user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMapOptions(Map<String, dynamic> optionsUpdate) {
    assert(optionsUpdate != null);
    return _naverMapsFlutterPlatform.updateMapOptions(optionsUpdate,
        mapId: mapId);
  }

  /// Updates marker configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMarkers(MarkerUpdates markerUpdates) {
    assert(markerUpdates != null);
    return _naverMapsFlutterPlatform.updateMarkers(markerUpdates,
        mapId: mapId);
  }

  /// Updates polygon configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolygons(PolygonUpdates polygonUpdates) {
    assert(polygonUpdates != null);
    return _naverMapsFlutterPlatform.updatePolygons(polygonUpdates,
        mapId: mapId);
  }

  /// Updates polyline configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolylines(PolylineUpdates polylineUpdates) {
    assert(polylineUpdates != null);
    return _naverMapsFlutterPlatform.updatePolylines(polylineUpdates,
        mapId: mapId);
  }

  /// Updates circle configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateCircles(CircleUpdates circleUpdates) {
    assert(circleUpdates != null);
    return _naverMapsFlutterPlatform.updateCircles(circleUpdates,
        mapId: mapId);
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  Future<void> animateCamera(CameraUpdate cameraUpdate) {
    return _naverMapsFlutterPlatform.animateCamera(cameraUpdate, mapId: mapId);
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(CameraUpdate cameraUpdate) {
    return _naverMapsFlutterPlatform.moveCamera(cameraUpdate, mapId: mapId);
  }

  /// Sets the styling of the base map.
  ///
  /// Set to `null` to clear any previous custom styling.
  ///
  /// If problems were detected with the [mapStyle], including un-parsable
  /// styling JSON, unrecognized feature type, unrecognized element type, or
  /// invalid styler keys: [MapStyleException] is thrown and the current
  /// style is left unchanged.
  ///
  /// The style string can be generated using [map style tool](https://mapstyle.withgoogle.com/).
  /// Also, refer [iOS](https://developers.google.com/maps/documentation/ios-sdk/style-reference)
  /// and [Android](https://developers.google.com/maps/documentation/android-sdk/style-reference)
  /// style reference for more information regarding the supported styles.
  Future<void> setMapStyle(String mapStyle) {
    return _naverMapsFlutterPlatform.setMapStyle(mapStyle, mapId: mapId);
  }

  /// Return [LatLngBounds] defining the region that is visible in a map.
  Future<LatLngBounds> getVisibleRegion() {
    return _naverMapsFlutterPlatform.getVisibleRegion(mapId: mapId);
  }

  /// Return [ScreenCoordinate] of the [LatLng] in the current map view.
  ///
  /// A projection is used to translate between on screen location and geographic coordinates.
  /// Screen location is in screen pixels (not display pixels) with respect to the top left corner
  /// of the map, not necessarily of the whole screen.
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) {
    return _naverMapsFlutterPlatform.getScreenCoordinate(latLng, mapId: mapId);
  }

  /// Returns [LatLng] corresponding to the [ScreenCoordinate] in the current map view.
  ///
  /// Returned [LatLng] corresponds to a screen location. The screen location is specified in screen
  /// pixels (not display pixels) relative to the top left of the map, not top left of the whole screen.
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) {
    return _naverMapsFlutterPlatform.getLatLng(screenCoordinate, mapId: mapId);
  }

  /// Programmatically show the Info Window for a [Marker].
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [hideMarkerInfoWindow] to hide the Info Window.
  ///   * [isMarkerInfoWindowShown] to check if the Info Window is showing.
  Future<void> showMarkerInfoWindow(MarkerId markerId) {
    assert(markerId != null);
    return _naverMapsFlutterPlatform.showMarkerInfoWindow(markerId,
        mapId: mapId);
  }

  /// Programmatically hide the Info Window for a [Marker].
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [showMarkerInfoWindow] to show the Info Window.
  ///   * [isMarkerInfoWindowShown] to check if the Info Window is showing.
  Future<void> hideMarkerInfoWindow(MarkerId markerId) {
    assert(markerId != null);
    return _naverMapsFlutterPlatform.hideMarkerInfoWindow(markerId,
        mapId: mapId);
  }

  /// Returns `true` when the [InfoWindow] is showing, `false` otherwise.
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [showMarkerInfoWindow] to show the Info Window.
  ///   * [hideMarkerInfoWindow] to hide the Info Window.
  Future<bool> isMarkerInfoWindowShown(MarkerId markerId) {
    assert(markerId != null);
    return _naverMapsFlutterPlatform.isMarkerInfoWindowShown(markerId,
        mapId: mapId);
  }

  /// Returns the current zoom level of the map
  Future<double> getZoomLevel() {
    return _naverMapsFlutterPlatform.getZoomLevel(mapId: mapId);
  }

  /// Returns the image bytes of the map
  Future<Uint8List> takeSnapshot() {
    return _naverMapsFlutterPlatform.takeSnapshot(mapId: mapId);
  }
}


class _NaverMapState extends State<NaverMap> {
  final Completer<NaverMapController> _controller =
  Completer<NaverMapController>();

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Map<PolygonId, Polygon> _polygons = <PolygonId, Polygon>{};
  Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};
  Map<CircleId, Circle> _circles = <CircleId, Circle>{};
  _NaverMapOptions _naverMapOptions;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'initialCameraPosition': widget.initialCameraPosition?.toMap(),
      'options': _naverMapOptions.toMap(),
      'markersToAdd': serializeMarkerSet(widget.markers),
      'polygonsToAdd': serializePolygonSet(widget.polygons),
      'polylinesToAdd': serializePolylineSet(widget.polylines),
      'circlesToAdd': serializeCircleSet(widget.circles),
    };
    return _naverMapsFlutterPlatform.buildView(
      creationParams,
      widget.gestureRecognizers,
      onPlatformViewCreated,
    );
  }

  @override
  void initState() {
    super.initState();
    _naverMapOptions = _NaverMapOptions.fromWidget(widget);
    _markers = keyByMarkerId(widget.markers);
    _polygons = keyByPolygonId(widget.polygons);
    _polylines = keyByPolylineId(widget.polylines);
    _circles = keyByCircleId(widget.circles);
  }

  @override
  void didUpdateWidget(NaverMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateOptions();
    _updateMarkers();
    _updatePolygons();
    _updatePolylines();
    _updateCircles();
  }

  void _updateOptions() async {
    final _NaverMapOptions newOptions = _NaverMapOptions.fromWidget(widget);
    final Map<String, dynamic> updates =
    _naverMapOptions.updatesMap(newOptions);
    if (updates.isEmpty) {
      return;
    }
    final NaverMapController controller = await _controller.future;
    // ignore: unawaited_futures
    controller._updateMapOptions(updates);
    _naverMapOptions = newOptions;
  }

  void _updateMarkers() async {
    final NaverMapController controller = await _controller.future;
    // ignore: unawaited_futures
    controller._updateMarkers(
        MarkerUpdates.from(_markers.values.toSet(), widget.markers));
    _markers = keyByMarkerId(widget.markers);
  }

  void _updatePolygons() async {
    final NaverMapController controller = await _controller.future;
    // ignore: unawaited_futures
    controller._updatePolygons(
        PolygonUpdates.from(_polygons.values.toSet(), widget.polygons));
    _polygons = keyByPolygonId(widget.polygons);
  }

  void _updatePolylines() async {
    final NaverMapController controller = await _controller.future;
    // ignore: unawaited_futures
    controller._updatePolylines(
        PolylineUpdates.from(_polylines.values.toSet(), widget.polylines));
    _polylines = keyByPolylineId(widget.polylines);
  }

  void _updateCircles() async {
    final NaverMapController controller = await _controller.future;
    // ignore: unawaited_futures
    controller._updateCircles(
        CircleUpdates.from(_circles.values.toSet(), widget.circles));
    _circles = keyByCircleId(widget.circles);
  }

  Future<void> onPlatformViewCreated(int id) async {
    final NaverMapController controller = await NaverMapController.init(
      id,
      widget.initialCameraPosition,
      this,
    );
    _controller.complete(controller);
    if (widget.onMapCreated != null) {
      widget.onMapCreated(controller);
    }
  }

  void onMarkerTap(MarkerId markerId) {
    assert(markerId != null);
    if (_markers[markerId]?.onTap != null) {
      _markers[markerId].onTap();
    }
  }

  void onMarkerDragEnd(MarkerId markerId, LatLng position) {
    assert(markerId != null);
    if (_markers[markerId]?.onDragEnd != null) {
      _markers[markerId].onDragEnd(position);
    }
  }

  void onPolygonTap(PolygonId polygonId) {
    assert(polygonId != null);
    _polygons[polygonId].onTap();
  }

  void onPolylineTap(PolylineId polylineId) {
    assert(polylineId != null);
    if (_polylines[polylineId]?.onTap != null) {
      _polylines[polylineId].onTap();
    }
  }

  void onCircleTap(CircleId circleId) {
    assert(circleId != null);
    _circles[circleId].onTap();
  }

  void onInfoWindowTap(MarkerId markerId) {
    assert(markerId != null);
    if (_markers[markerId]?.infoWindow?.onTap != null) {
      _markers[markerId].infoWindow.onTap();
    }
  }

  void onTap(LatLng position) {
    assert(position != null);
    if (widget.onTap != null) {
      widget.onTap(position);
    }
  }

  void onLongPress(LatLng position) {
    assert(position != null);
    if (widget.onLongPress != null) {
      widget.onLongPress(position);
    }
  }
}
