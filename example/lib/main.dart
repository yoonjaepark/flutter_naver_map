// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_naver_map_example/move_camera.dart';
import 'map_ui.dart';
import 'page.dart';
import 'map_coordinates.dart';

final List<NaverMapExampleAppPage> _allPages = <NaverMapExampleAppPage>[
  MapUiPage(),
  MapCoordinatesPage(),
//  MapClickPage(),
//  AnimateCameraPage(),
  MoveCameraPage(),
//  PlaceMarkerPage(),
//  MarkerIconsPage(),
//  ScrollingMapPage(),
//  PlacePolylinePage(),
//  PlacePolygonPage(),
//  PlaceCirclePage(),
//  PaddingPage(),
//  SnapshotPage(),
];

class MapsDemo extends StatelessWidget {
  void _pushPage(BuildContext context, NaverMapExampleAppPage page) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(page.title)),
          body: page,
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NaverMapExample examples')),
      body: ListView.builder(
        itemCount: _allPages.length,
        itemBuilder: (_, int index) => ListTile(
          leading: _allPages[index].leading,
          title: Text(_allPages[index].title),
          onTap: () => _pushPage(context, _allPages[index]),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: MapsDemo()));
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<NaverMapController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NaverMapController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<NaverMapController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final NaverMapController controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
//                if (await controller.canGoBack()) {
//                  await controller.goBack();
//                } else {
//                  Scaffold.of(context).showSnackBar(
//                    const SnackBar(content: Text("No back history item")),
//                  );
//                  return;
//                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
//                if (await controller.canGoForward()) {
//                  await controller.goForward();
//                } else {
//                  Scaffold.of(context).showSnackBar(
//                    const SnackBar(
//                        content: Text("No forward history item")),
//                  );
//                  return;
//                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady
                  ? null
                  : () {
//                controller.reload();
              },
            ),
          ],
        );
      },
    );
  }
}