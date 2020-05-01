// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'platform_interface.dart';
import 'src/webview_android.dart';
import 'src/webview_cupertino.dart';

typedef void WebViewCreatedCallback(WebViewController controller);


class JavascriptMessage {
  const JavascriptMessage(this.message) : assert(message != null);
  final String message;
}

typedef void JavascriptMessageHandler(JavascriptMessage message);

class NavigationRequest {
  NavigationRequest._({this.url, this.isForMainFrame});
  final String url;
  final bool isForMainFrame;

  @override
  String toString() {
    return '$runtimeType(url: $url, isForMainFrame: $isForMainFrame)';
  }
}

enum NavigationDecision {
  prevent,
  navigate,
}

typedef FutureOr<NavigationDecision> NavigationDelegate(
    NavigationRequest navigation);

typedef void PageStartedCallback(String url);

typedef void PageFinishedCallback(String url);

typedef void WebResourceErrorCallback(WebResourceError error);

enum AutoMediaPlaybackPolicy {
  require_user_action_for_all_media_types,
  always_allow,
}

final RegExp _validChannelNames = RegExp('^[a-zA-Z_][a-zA-Z0-9_]*\$');

class JavascriptChannel {
  JavascriptChannel({
    @required this.name,
    @required this.onMessageReceived,
  })  : assert(name != null),
        assert(onMessageReceived != null),
        assert(_validChannelNames.hasMatch(name));
  final String name;
  final JavascriptMessageHandler onMessageReceived;
}

class WebView extends StatefulWidget {
  const WebView({
    Key key,
    this.onWebViewCreated,
    this.initialUrl,
    this.javascriptChannels,
    this.navigationDelegate,
    this.gestureRecognizers,
    this.onPageStarted,
    this.onPageFinished,
    this.onWebResourceError,
    this.debuggingEnabled = false,
    this.gestureNavigationEnabled = false,
    this.userAgent,
    this.initialMediaPlaybackPolicy =
        AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
  })  :assert(initialMediaPlaybackPolicy != null),
        super(key: key);

  static WebViewPlatform _platform;

  static set platform(WebViewPlatform platform) {
    _platform = platform;
  }

  ///
  /// The default value is [AndroidWebView] on Android and [CupertinoWebView] on iOS.
  static WebViewPlatform get platform {
    if (_platform == null) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          _platform = AndroidWebView();
          break;
        case TargetPlatform.iOS:
          _platform = CupertinoWebView();
          break;
        default:
          throw UnsupportedError(
              "Trying to use the default webview implementation for $defaultTargetPlatform but there isn't a default one");
      }
    }
    return _platform;
  }

  /// If not null invoked once the web view is created.
  final WebViewCreatedCallback onWebViewCreated;

  /// Which gestures should be consumed by the web view.
  ///
  /// It is possible for other gesture recognizers to be competing with the web view on pointer
  /// events, e.g if the web view is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The web view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the web view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// The initial URL to load.
  final String initialUrl;

  /// Whether Javascript execution is enabled.

  /// The set of [JavascriptChannel]s available to JavaScript code running in the web view.
  ///
  /// For each [JavascriptChannel] in the set, a channel object is made available for the
  /// JavaScript code in a window property named [JavascriptChannel.name].
  /// The JavaScript code can then call `postMessage` on that object to send a message that will be
  /// passed to [JavascriptChannel.onMessageReceived].
  ///
  /// For example for the following JavascriptChannel:
  ///
  /// ```dart
  /// JavascriptChannel(name: 'Print', onMessageReceived: (JavascriptMessage message) { print(message.message); });
  /// ```
  ///
  /// JavaScript code can call:
  ///
  /// ```javascript
  /// Print.postMessage('Hello');
  /// ```
  ///
  /// To asynchronously invoke the message handler which will print the message to standard output.
  ///
  /// Adding a new JavaScript channel only takes affect after the next page is loaded.
  ///
  /// Set values must not be null. A [JavascriptChannel.name] cannot be the same for multiple
  /// channels in the list.
  ///
  /// A null value is equivalent to an empty set.
  final Set<JavascriptChannel> javascriptChannels;

  /// A delegate function that decides how to handle navigation actions.
  ///
  /// When a navigation is initiated by the WebView (e.g when a user clicks a link)
  /// this delegate is called and has to decide how to proceed with the navigation.
  ///
  /// See [NavigationDecision] for possible decisions the delegate can take.
  ///
  /// When null all navigation actions are allowed.
  ///
  /// Caveats on Android:
  ///
  ///   * Navigation actions targeted to the main frame can be intercepted,
  ///     navigation actions targeted to subframes are allowed regardless of the value
  ///     returned by this delegate.
  ///   * Setting a navigationDelegate makes the WebView treat all navigations as if they were
  ///     triggered by a user gesture, this disables some of Chromium's security mechanisms.
  ///     A navigationDelegate should only be set when loading trusted content.
  ///   * On Android WebView versions earlier than 67(most devices running at least Android L+ should have
  ///     a later version):
  ///     * When a navigationDelegate is set pages with frames are not properly handled by the
  ///       webview, and frames will be opened in the main frame.
  ///     * When a navigationDelegate is set HTTP requests do not include the HTTP referer header.
  final NavigationDelegate navigationDelegate;

  /// Invoked when a page starts loading.
  final PageStartedCallback onPageStarted;

  /// Invoked when a page has finished loading.
  ///
  /// This is invoked only for the main frame.
  ///
  /// When [onPageFinished] is invoked on Android, the page being rendered may
  /// not be updated yet.
  ///
  /// When invoked on iOS or Android, any Javascript code that is embedded
  /// directly in the HTML has been loaded and code injected with
  /// [WebViewController.evaluateJavascript] can assume this.
  final PageFinishedCallback onPageFinished;

  /// Invoked when a web resource has failed to load.
  ///
  /// This can be called for any resource (iframe, image, etc.), not just for
  /// the main page.
  final WebResourceErrorCallback onWebResourceError;

  /// Controls whether WebView debugging is enabled.
  ///
  /// Setting this to true enables [WebView debugging on Android](https://developers.google.com/web/tools/chrome-devtools/remote-debugging/).
  ///
  /// WebView debugging is enabled by default in dev builds on iOS.
  ///
  /// To debug WebViews on iOS:
  /// - Enable developer options (Open Safari, go to Preferences -> Advanced and make sure "Show Develop Menu in Menubar" is on.)
  /// - From the Menu-bar (of Safari) select Develop -> iPhone Simulator -> <your webview page>
  ///
  /// By default `debuggingEnabled` is false.
  final bool debuggingEnabled;

  /// A Boolean value indicating whether horizontal swipe gestures will trigger back-forward list navigations.
  ///
  /// This only works on iOS.
  ///
  /// By default `gestureNavigationEnabled` is false.
  final bool gestureNavigationEnabled;

  /// The value used for the HTTP User-Agent: request header.
  ///
  /// When null the platform's webview default is used for the User-Agent header.
  ///
  /// When the [WebView] is rebuilt with a different `userAgent`, the page reloads and the request uses the new User Agent.
  ///
  /// When [WebViewController.goBack] is called after changing `userAgent` the previous `userAgent` value is used until the page is reloaded.
  ///
  /// This field is ignored on iOS versions prior to 9 as the platform does not support a custom
  /// user agent.
  ///
  /// By default `userAgent` is null.
  final String userAgent;

  /// Which restrictions apply on automatic media playback.
  ///
  /// This initial value is applied to the platform's webview upon creation. Any following
  /// changes to this parameter are ignored (as long as the state of the [WebView] is preserved).
  ///
  /// The default policy is [AutoMediaPlaybackPolicy.require_user_action_for_all_media_types].
  final AutoMediaPlaybackPolicy initialMediaPlaybackPolicy;

  @override
  State<StatefulWidget> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  _PlatformCallbacksHandler _platformCallbacksHandler;

  @override
  Widget build(BuildContext context) {
    return WebView.platform.build(
      context: context,
      onWebViewPlatformCreated: _onWebViewPlatformCreated,
      webViewPlatformCallbacksHandler: _platformCallbacksHandler,
      gestureRecognizers: widget.gestureRecognizers,
      creationParams: _creationParamsfromWidget(widget),
    );
  }

  @override
  void initState() {
    super.initState();
    _assertJavascriptChannelNamesAreUnique();
    _platformCallbacksHandler = _PlatformCallbacksHandler(widget);
  }

  @override
  void didUpdateWidget(WebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _assertJavascriptChannelNamesAreUnique();
    _controller.future.then((WebViewController controller) {
      _platformCallbacksHandler._widget = widget;
      controller._updateWidget(widget);
    });
  }

  void _onWebViewPlatformCreated(WebViewPlatformController webViewPlatform) {
    final WebViewController controller =
        WebViewController._(widget, webViewPlatform, _platformCallbacksHandler);
    _controller.complete(controller);
    if (widget.onWebViewCreated != null) {
      widget.onWebViewCreated(controller);
    }
  }

  void _assertJavascriptChannelNamesAreUnique() {
    if (widget.javascriptChannels == null ||
        widget.javascriptChannels.isEmpty) {
      return;
    }
    assert(_extractChannelNames(widget.javascriptChannels).length ==
        widget.javascriptChannels.length);
  }
}

CreationParams _creationParamsfromWidget(WebView widget) {
  return CreationParams(
    initialUrl: widget.initialUrl,
    webSettings: _webSettingsFromWidget(widget),
    javascriptChannelNames: _extractChannelNames(widget.javascriptChannels),
    userAgent: widget.userAgent,
    autoMediaPlaybackPolicy: widget.initialMediaPlaybackPolicy,
  );
}

WebSettings _webSettingsFromWidget(WebView widget) {
  return WebSettings(
    hasNavigationDelegate: widget.navigationDelegate != null,
    debuggingEnabled: widget.debuggingEnabled,
    gestureNavigationEnabled: widget.gestureNavigationEnabled,
    userAgent: WebSetting<String>.of(widget.userAgent),
  );
}

// This method assumes that no fields in `currentValue` are null.
WebSettings _clearUnchangedWebSettings(
    WebSettings currentValue, WebSettings newValue) {
  assert(currentValue.hasNavigationDelegate != null);
  assert(currentValue.debuggingEnabled != null);
  assert(currentValue.userAgent.isPresent);
  assert(newValue.hasNavigationDelegate != null);
  assert(newValue.debuggingEnabled != null);
  assert(newValue.userAgent.isPresent);

  bool hasNavigationDelegate;
  bool debuggingEnabled;
  WebSetting<String> userAgent = WebSetting<String>.absent();
  if (currentValue.hasNavigationDelegate != newValue.hasNavigationDelegate) {
    hasNavigationDelegate = newValue.hasNavigationDelegate;
  }
  if (currentValue.debuggingEnabled != newValue.debuggingEnabled) {
    debuggingEnabled = newValue.debuggingEnabled;
  }
  if (currentValue.userAgent != newValue.userAgent) {
    userAgent = newValue.userAgent;
  }

  return WebSettings(
    hasNavigationDelegate: hasNavigationDelegate,
    debuggingEnabled: debuggingEnabled,
    userAgent: userAgent,
  );
}

Set<String> _extractChannelNames(Set<JavascriptChannel> channels) {
  final Set<String> channelNames = channels == null
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // ignore: prefer_collection_literals
      ? Set<String>()
      : channels.map((JavascriptChannel channel) => channel.name).toSet();
  return channelNames;
}

class _PlatformCallbacksHandler implements WebViewPlatformCallbacksHandler {
  _PlatformCallbacksHandler(this._widget) {
    _updateJavascriptChannelsFromSet(_widget.javascriptChannels);
  }

  WebView _widget;

  // Maps a channel name to a channel.
  final Map<String, JavascriptChannel> _javascriptChannels =
      <String, JavascriptChannel>{};

  @override
  void onJavaScriptChannelMessage(String channel, String message) {
    _javascriptChannels[channel].onMessageReceived(JavascriptMessage(message));
  }

  @override
  FutureOr<bool> onNavigationRequest({String url, bool isForMainFrame}) async {
    final NavigationRequest request =
        NavigationRequest._(url: url, isForMainFrame: isForMainFrame);
    final bool allowNavigation = _widget.navigationDelegate == null ||
        await _widget.navigationDelegate(request) ==
            NavigationDecision.navigate;
    return allowNavigation;
  }

  @override
  void onPageStarted(String url) {
    if (_widget.onPageStarted != null) {
      _widget.onPageStarted(url);
    }
  }

  @override
  void onPageFinished(String url) {
    if (_widget.onPageFinished != null) {
      _widget.onPageFinished(url);
    }
  }

  @override
  void onWebResourceError(WebResourceError error) {
    if (_widget.onWebResourceError != null) {
      _widget.onWebResourceError(error);
    }
  }

  void _updateJavascriptChannelsFromSet(Set<JavascriptChannel> channels) {
    _javascriptChannels.clear();
    if (channels == null) {
      return;
    }
    for (JavascriptChannel channel in channels) {
      _javascriptChannels[channel.name] = channel;
    }
  }
}

/// Controls a [WebView].
///
/// A [WebViewController] instance can be obtained by setting the [WebView.onWebViewCreated]
/// callback for a [WebView] widget.
class WebViewController {
  WebViewController._(
    this._widget,
    this._webViewPlatformController,
    this._platformCallbacksHandler,
  ) : assert(_webViewPlatformController != null) {
    _settings = _webSettingsFromWidget(_widget);
  }

  final WebViewPlatformController _webViewPlatformController;

  final _PlatformCallbacksHandler _platformCallbacksHandler;

  WebSettings _settings;

  WebView _widget;

  /// Loads the specified URL.
  ///
  /// If `headers` is not null and the URL is an HTTP URL, the key value paris in `headers` will
  /// be added as key value pairs of HTTP headers for the request.
  ///
  /// `url` must not be null.
  ///
  /// Throws an ArgumentError if `url` is not a valid URL string.
//  Future<void> loadUrl(
//    String url, {
//    Map<String, String> headers,
//  }) async {
//    assert(url != null);
//    _validateUrlString(url);
//    return _webViewPlatformController.loadUrl(url, headers);
//  }

  /// Accessor to the current URL that the WebView is displaying.
  ///
  /// If [WebView.initialUrl] was never specified, returns `null`.
  /// Note that this operation is asynchronous, and it is possible that the
  /// current URL changes again by the time this function returns (in other
  /// words, by the time this future completes, the WebView may be displaying a
  /// different URL).
//  Future<String> currentUrl() {
//    return _webViewPlatformController.currentUrl();
//  }

  /// Checks whether there's a back history item.
  ///
  /// Note that this operation is asynchronous, and it is possible that the "canGoBack" state has
  /// changed by the time the future completed.
//  Future<bool> canGoBack() {
//    return _webViewPlatformController.canGoBack();
//  }

  /// Checks whether there's a forward history item.
  ///
  /// Note that this operation is asynchronous, and it is possible that the "canGoForward" state has
  /// changed by the time the future completed.
//  Future<bool> canGoForward() {
//    return _webViewPlatformController.canGoForward();
//  }

  /// Goes back in the history of this WebView.
  ///
  /// If there is no back history item this is a no-op.
//  Future<void> goBack() {
//    return _webViewPlatformController.goBack();
//  }

  /// Goes forward in the history of this WebView.
  ///
  /// If there is no forward history item this is a no-op.
//  Future<void> goForward() {
//    return _webViewPlatformController.goForward();
//  }

  /// Reloads the current URL.
//  Future<void> reload() {
//    return _webViewPlatformController.reload();
//  }

  /// Clears all caches used by the [WebView].
  ///
  /// The following caches are cleared:
  ///	1. Browser HTTP Cache.
  ///	2. [Cache API](https://developers.google.com/web/fundamentals/instant-and-offline/web-storage/cache-api) caches.
  ///    These are not yet supported in iOS WkWebView. Service workers tend to use this cache.
  ///	3. Application cache.
  ///	4. Local Storage.
  ///
  /// Note: Calling this method also triggers a reload.
//  Future<void> clearCache() async {
//    await _webViewPlatformController.clearCache();
//    return reload();
//  }

  Future<void> _updateWidget(WebView widget) async {
    _widget = widget;
//    await _updateSettings(_webSettingsFromWidget(widget));
    await _updateJavascriptChannels(widget.javascriptChannels);
  }

//  Future<void> _updateSettings(WebSettings newSettings) {
//    final WebSettings update =
//        _clearUnchangedWebSettings(_settings, newSettings);
//    _settings = newSettings;
//    return _webViewPlatformController.updateSettings(update);
//  }

  Future<void> _updateJavascriptChannels(
      Set<JavascriptChannel> newChannels) async {
    final Set<String> currentChannels =
        _platformCallbacksHandler._javascriptChannels.keys.toSet();
    final Set<String> newChannelNames = _extractChannelNames(newChannels);
    final Set<String> channelsToAdd =
        newChannelNames.difference(currentChannels);
    final Set<String> channelsToRemove =
        currentChannels.difference(newChannelNames);
//    if (channelsToRemove.isNotEmpty) {
//      await _webViewPlatformController
//          .removeJavascriptChannels(channelsToRemove);
//    }
//    if (channelsToAdd.isNotEmpty) {
//      await _webViewPlatformController.addJavascriptChannels(channelsToAdd);
//    }
    _platformCallbacksHandler._updateJavascriptChannelsFromSet(newChannels);
  }

  /// Returns the title of the currently loaded page.
//  Future<String> getTitle() {
//    return _webViewPlatformController.getTitle();
//  }

  /// Sets the WebView's content scroll position.
  ///
  /// The parameters `x` and `y` specify the scroll position in WebView pixels.
//  Future<void> scrollTo(int x, int y) {
//    return _webViewPlatformController.scrollTo(x, y);
//  }

  /// Move the scrolled position of this view.
  ///
  /// The parameters `x` and `y` specify the amount of WebView pixels to scroll by horizontally and vertically respectively.
//  Future<void> scrollBy(int x, int y) {
//    return _webViewPlatformController.scrollBy(x, y);
//  }

  /// Return the horizontal scroll position, in WebView pixels, of this view.
  ///
  /// Scroll position is measured from left.
//  Future<int> getScrollX() {
//    return _webViewPlatformController.getScrollX();
//  }

  /// Return the vertical scroll position, in WebView pixels, of this view.
  ///
  /// Scroll position is measured from top.
//  Future<int> getScrollY() {
//    return _webViewPlatformController.getScrollY();
//  }
}

/// Manages cookies pertaining to all [WebView]s.
class CookieManager {
  /// Creates a [CookieManager] -- returns the instance if it's already been called.
  factory CookieManager() {
    return _instance ??= CookieManager._();
  }

  CookieManager._();

  static CookieManager _instance;

  /// Clears all cookies for all [WebView] instances.
  ///
  /// This is a no op on iOS version smaller than 9.
  ///
  /// Returns true if cookies were present before clearing, else false.
  Future<bool> clearCookies() => WebView.platform.clearCookies();
}

// Throws an ArgumentError if `url` is not a valid URL string.
void _validateUrlString(String url) {
  try {
    final Uri uri = Uri.parse(url);
    if (uri.scheme.isEmpty) {
      throw ArgumentError('Missing scheme in URL string: "$url"');
    }
  } on FormatException catch (e) {
    throw ArgumentError(e);
  }
}
