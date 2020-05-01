// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'page.dart';
import 'package:flutter_naver_map/naver_maps_flutter_platform_interface.dart';

const CameraPosition _kInitialPosition = CameraPosition(target: LatLng(-33.852, 151.211), zoom: 11.0);

class MapCoordinatesPage extends NaverMapExampleAppPage {
  MapCoordinatesPage() : super(const Icon(Icons.map), 'Map coordinates');

  @override
  Widget build(BuildContext context) {
    return const _MapCoordinatesBody();
  }
}

class _MapCoordinatesBody extends StatefulWidget {
  const _MapCoordinatesBody();

  @override
  State<StatefulWidget> createState() => _MapCoordinatesBodyState();
}

class _MapCoordinatesBodyState extends State<_MapCoordinatesBody> {
  _MapCoordinatesBodyState();
  final Completer<NaverMapController> _controller = Completer<NaverMapController>();
  NaverMapController mapController;
  LatLngBounds _visibleRegion = LatLngBounds(
    southwest: const LatLng(0, 0),
    northeast: const LatLng(0, 0),
  );

  void onMapCreated(NaverMapController webViewController) async {
    _controller.complete(webViewController);
  }

  @override
  Widget build(BuildContext context) {
    final NaverMap googleMap =  NaverMap(onMapCreated: onMapCreated, initialCameraPosition: _kInitialPosition);

    final List<Widget> columnChildren = <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: SizedBox(
            width: 300.0,
            height: 200.0,
            child: googleMap,
          ),
        ),
      ),
    ];

//    if (mapController != null) {
//      final String currentVisibleRegion = 'VisibleRegion:'
//          '\nnortheast: ${_visibleRegion.northeast},'
//          '\nsouthwest: ${_visibleRegion.southwest}';
//      columnChildren.add(Center(child: Text(currentVisibleRegion)));
//      columnChildren.add(_getVisibleRegionButton());
//    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columnChildren,
    );
  }



//  void onMapCreated(GoogleMapController controller) async {
//    final LatLngBounds visibleRegion = await controller.getVisibleRegion();
//    setState(() {
//      mapController = controller;
//      _visibleRegion = visibleRegion;
//    });
//  }

  Widget _getVisibleRegionButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RaisedButton(
        child: const Text('Get Visible Region Bounds'),
        onPressed: () async {
//          final LatLngBounds visibleRegion =
//          await mapController.getVisibleRegion();
//          setState(() {
//            _visibleRegion = visibleRegion;
//          });
        },
      ),
    );
  }
}
