//// Copyright 2019 The Chromium Authors. All rights reserved.
//// Use of this source code is governed by a BSD-style license that can be
//// found in the LICENSE file.
//
//import 'dart:async';
//
//import 'package:flutter/services.dart';
//
//import '../platform_interface.dart';
//
//class MethodChannelWebViewPlatform implements WebViewPlatformController {
//  /// Constructs an instance that will listen for webviews broadcasting to the
//  /// given [id], using the given [WebViewPlatformCallbacksHandler].
//  MethodChannelWebViewPlatform(int id, this._platformCallbacksHandler)
//      : assert(_platformCallbacksHandler != null),
//        _channel = MethodChannel('plugins.flutter.io/webview_$id') {
//    _channel.setMethodCallHandler(_onMethodCall);
//  }
//
//  final WebViewPlatformCallbacksHandler _platformCallbacksHandler;
//
//  final MethodChannel _channel;
//
//  static const MethodChannel _cookieManagerChannel =
//      MethodChannel('plugins.flutter.io/cookie_manager');
//
//  Future<bool> _onMethodCall(MethodCall call) async {
//    switch (call.method) {
//      case 'javascriptChannelMessage':
//        final String channel = call.arguments['channel'];
//        final String message = call.arguments['message'];
//        _platformCallbacksHandler.onJavaScriptChannelMessage(channel, message);
//        return true;
//      case 'navigationRequest':
//        return await _platformCallbacksHandler.onNavigationRequest(
//          url: call.arguments['url'],
//          isForMainFrame: call.arguments['isForMainFrame'],
//        );
//      case 'onPageFinished':
////        _platformCallbacksHandler.onPageFinished(call.arguments['url']);
//        return null;
//      case 'onPageStarted':
////        _platformCallbacksHandler.onPageStarted(call.arguments['url']);
//        return null;
//      case 'onWebResourceError':
////        _platformCallbacksHandler.onWebResourceError(
////          WebResourceError(
////            errorCode: call.arguments['errorCode'],
////            description: call.arguments['description'],
////            domain: call.arguments['domain'],
////            errorType: call.arguments['errorType'] == null
////                ? null
////                : WebResourceErrorType.values.firstWhere(
////                    (WebResourceErrorType type) {
////                      return type.toString() ==
////                          '$WebResourceErrorType.${call.arguments['errorType']}';
////                    },
////                  ),
////          ),
////        );
//        return null;
//    }
//
//    throw MissingPluginException(
//      '${call.method} was invoked but has no handler',
//    );
//  }
//
//  @override
//  Future<void> loadUrl(
//    String url,
//    Map<String, String> headers,
//  ) async {
//    assert(url != null);
//    return _channel.invokeMethod<void>('loadUrl', <String, dynamic>{
//      'url': url,
//      'headers': headers,
//    });
//  }
//
//  @override
//  Future<void> reload() => _channel.invokeMethod<void>("reload");
//
//  /// Method channel implementation for [WebViewPlatform.clearCookies].
//  static Future<bool> clearCookies() {
//    return _cookieManagerChannel
//        .invokeMethod<bool>('clearCookies')
//        .then<bool>((dynamic result) => result);
//  }
//
//  static Map<String, dynamic> _webSettingsToMap(WebSettings settings) {
//    final Map<String, dynamic> map = <String, dynamic>{};
//    void _addIfNonNull(String key, dynamic value) {
//      if (value == null) {
//        return;
//      }
//      map[key] = value;
//    }
//
//    void _addSettingIfPresent<T>(String key, WebSetting<T> setting) {
//      if (!setting.isPresent) {
//        return;
//      }
//      map[key] = setting.value;
//    }
//
//    _addIfNonNull('hasNavigationDelegate', settings.hasNavigationDelegate);
//    _addIfNonNull('debuggingEnabled', settings.debuggingEnabled);
//    _addIfNonNull(
//        'gestureNavigationEnabled', settings.gestureNavigationEnabled);
//    _addSettingIfPresent('userAgent', settings.userAgent);
//    return map;
//  }
//
//  /// Converts a [CreationParams] object to a map as expected by `platform_views` channel.
//  ///
//  /// This is used for the `creationParams` argument of the platform views created by
//  /// [AndroidWebViewBuilder] and [CupertinoWebViewBuilder].
//  static Map<String, dynamic> creationParamsToMap(
//      CreationParams creationParams) {
//    return <String, dynamic>{
//      'initialUrl': creationParams.initialUrl,
//      'settings': _webSettingsToMap(creationParams.webSettings),
//      'javascriptChannelNames': creationParams.javascriptChannelNames.toList(),
//      'userAgent': creationParams.userAgent,
//      'autoMediaPlaybackPolicy': creationParams.autoMediaPlaybackPolicy.index,
//    };
//  }
//
//  @override
//  Future<void> addJavascriptChannels(Set<String> javascriptChannelNames) {
//    // TODO: implement addJavascriptChannels
//    return null;
//  }
//
//  @override
//  Future<bool> canGoBack() {
//    // TODO: implement canGoBack
//    return null;
//  }
//
//  @override
//  Future<bool> canGoForward() {
//    // TODO: implement canGoForward
//    return null;
//  }
//
//  @override
//  Future<void> clearCache() {
//    // TODO: implement clearCache
//    return null;
//  }
//
//  @override
//  Future<String> currentUrl() {
//    // TODO: implement currentUrl
//    return null;
//  }
//
//  @override
//  Future<String> evaluateJavascript(String javascriptString) {
//    // TODO: implement evaluateJavascript
//    return null;
//  }
//
//  @override
//  Future<int> getScrollX() {
//    // TODO: implement getScrollX
//    return null;
//  }
//
//  @override
//  Future<int> getScrollY() {
//    // TODO: implement getScrollY
//    return null;
//  }
//
//  @override
//  Future<String> getTitle() {
//    // TODO: implement getTitle
//    return null;
//  }
//
//  @override
//  Future<void> goBack() {
//    // TODO: implement goBack
//    return null;
//  }
//
//  @override
//  Future<void> goForward() {
//    // TODO: implement goForward
//    return null;
//  }
//
//  @override
//  Future<void> removeJavascriptChannels(Set<String> javascriptChannelNames) {
//    // TODO: implement removeJavascriptChannels
//    return null;
//  }
//
//  @override
//  Future<void> scrollBy(int x, int y) {
//    // TODO: implement scrollBy
//    return null;
//  }
//
//  @override
//  Future<void> scrollTo(int x, int y) {
//    // TODO: implement scrollTo
//    return null;
//  }
//
//  @override
//  Future<void> updateSettings(WebSettings setting) {
//    // TODO: implement updateSettings
//    return null;
//  }
//}
