// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'page.dart';
import 'map_coordinates.dart';

final List<NaverMapExampleAppPage> _allPages = <NaverMapExampleAppPage>[
//  MapUiPage(),
  MapCoordinatesPage(),
//  MapClickPage(),
//  AnimateCameraPage(),
//  MoveCameraPage(),
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


//void main() => runApp(MaterialApp(home: WebViewExample()));
//
//class WebViewExample extends StatefulWidget {
//  @override
//  _WebViewExampleState createState() => _WebViewExampleState();
//}
//
//class _WebViewExampleState extends State<WebViewExample> {
//  final Completer<WebViewController> _controller =
//  Completer<WebViewController>();
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//        appBar: AppBar(
//          title: const Text('Flutter WebView example'),
//          actions: <Widget>[
//            NavigationControls(_controller.future),
//            SampleMenu(_controller.future),
//          ],
//        ),
//        body: Column(children: [
//          Center(
//              child: Container(
//                  width: MediaQuery.of(context).size.width,
//                  height: 300.0,
//                  child:   WebView(
//                    onWebViewCreated: (WebViewController webViewController) {
//                      _controller.complete(webViewController);
//                    },
//                  ))),
//          Expanded(
//              flex: 3,
//              child: Container(
//                  color: Colors.blue[100],
//                  child: Center(child: Text("Hello from Flutter!"))))
//        ])
//    );
//  }
//
//  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
//    return JavascriptChannel(
//        name: 'Toaster',
//        onMessageReceived: (JavascriptMessage message) {
//          Scaffold.of(context).showSnackBar(
//            SnackBar(content: Text(message.message)),
//          );
//        });
//  }
//
//  Widget favoriteButton() {
//    return FutureBuilder<WebViewController>(
//        future: _controller.future,
//        builder: (BuildContext context,
//            AsyncSnapshot<WebViewController> controller) {
//          if (controller.hasData) {
//            return FloatingActionButton(
//              onPressed: () async {
////                final String url = await controller.data.currentUrl();
//                Scaffold.of(context).showSnackBar(
//                  SnackBar(content: Text('Favorited')),
//                );
//              },
//              child: const Icon(Icons.favorite),
//            );
//          }
//          return Container();
//        });
//  }
//}
//
//enum MenuOptions {
//  showUserAgent,
//  listCookies,
//  clearCookies,
//  addToCache,
//  listCache,
//  clearCache,
//  navigationDelegate,
//}
//
//class SampleMenu extends StatelessWidget {
//  SampleMenu(this.controller);
//
//  final Future<WebViewController> controller;
//
//  @override
//  Widget build(BuildContext context) {
//    return FutureBuilder<WebViewController>(
//      future: controller,
//      builder:
//          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
//        return PopupMenuButton<MenuOptions>(
//          onSelected: (MenuOptions value) {
//            switch (value) {
//              case MenuOptions.showUserAgent:
//                break;
//              case MenuOptions.listCookies:
//                break;
//              case MenuOptions.clearCookies:
//                break;
//              case MenuOptions.addToCache:
//                break;
//              case MenuOptions.listCache:
//                break;
//              case MenuOptions.clearCache:
//                break;
//              case MenuOptions.navigationDelegate:
//                break;
//            }
//          },
//          itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
//            PopupMenuItem<MenuOptions>(
//              value: MenuOptions.showUserAgent,
//              child: const Text('Show user agent'),
//              enabled: controller.hasData,
//            ),
//            const PopupMenuItem<MenuOptions>(
//              value: MenuOptions.listCookies,
//              child: Text('List cookies'),
//            ),
//            const PopupMenuItem<MenuOptions>(
//              value: MenuOptions.clearCookies,
//              child: Text('Clear cookies'),
//            ),
//            const PopupMenuItem<MenuOptions>(
//              value: MenuOptions.addToCache,
//              child: Text('Add to cache'),
//            ),
//            const PopupMenuItem<MenuOptions>(
//              value: MenuOptions.listCache,
//              child: Text('List cache'),
//            ),
//            const PopupMenuItem<MenuOptions>(
//              value: MenuOptions.clearCache,
//              child: Text('Clear cache'),
//            ),
//            const PopupMenuItem<MenuOptions>(
//              value: MenuOptions.navigationDelegate,
//              child: Text('Navigation Delegate example'),
//            ),
//          ],
//        );
//      },
//    );
//  }
//}

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