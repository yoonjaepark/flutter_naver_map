// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Builds an Android webview.
///
/// This is used as the default implementation for [WebView.platform] on Android. It uses
/// an [AndroidView] to embed the webview in the widget hierarchy, and uses a method channel to
/// communicate with the platform code.
//class AndroidWebView implements WebViewPlatform {
//  @override
//  Widget build({
//    BuildContext context,
//    CreationParams creationParams,
//    @required WebViewPlatformCallbacksHandler webViewPlatformCallbacksHandler,
//    WebViewPlatformCreatedCallback onWebViewPlatformCreated,
//    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
//  }) {
//    assert(webViewPlatformCallbacksHandler != null);
//    return GestureDetector(
//      onLongPress: () {},
//      excludeFromSemantics: true,
//      child: AndroidView(
//        viewType: 'flutter_naver_map',
//        onPlatformViewCreated: (int id) {
//          if (onWebViewPlatformCreated == null) {
//            return;
//          }
//          onWebViewPlatformCreated(MethodChannelWebViewPlatform(
//              id, webViewPlatformCallbacksHandler));
//        },
//        gestureRecognizers: gestureRecognizers,
//        layoutDirection: TextDirection.rtl,
//        creationParams:
//            MethodChannelWebViewPlatform.creationParamsToMap(creationParams),
//        creationParamsCodec: const StandardMessageCodec(),
//      ),
//    );
//  }
//
//  @override
//  Future<bool> clearCookies() => MethodChannelWebViewPlatform.clearCookies();
//}
