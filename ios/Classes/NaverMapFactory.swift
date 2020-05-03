

import NMapsMap;
//
class NaverMapFactory: NSObject, FlutterPlatformViewFactory {
    private var registrar: FlutterPluginRegistrar

    init(registrar: (FlutterPluginRegistrar)) {
        NMFAuthManager.shared().clientId = "ddfe2dimwb"
        self.registrar = registrar
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        var builder: NaverMapBuilder = NaverMapBuilder();
        return NaverMapController(
        frame: frame,
        viewIdentifier: viewId,
        arguments: args,
        registrar: self.registrar)
    }
}

class NaverMapController: NSObject, FlutterPlatformView {
    private var registrar: FlutterPluginRegistrar
    private var frame: CGRect
    private var viewIdentifier: Int64
    private var args: Any?
    private var mapView: NMFMapView
    static var channel: FlutterMethodChannel?

    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        self.frame = frame
        self.viewIdentifier = viewId
        self.args = args
        self.mapView = NMFMapView(frame: frame)
//        let orientationInstance = OrientationStreamHandler()
        print("#########################");
        print(String(viewId));

//        let channel = FlutterMethodChannel(name: "flutter_naver_map_" + String(viewId) , binaryMessenger: registrar.messenger())
        NaverMapController.channel  = FlutterMethodChannel(name: "flutter_naver_map_" + String(viewId), binaryMessenger: registrar.messenger())

          let instance = SwiftMethodChannelPlugin()
        if let channel = NaverMapController.channel {
            registrar.addMethodCallDelegate(instance, channel: channel)
          }
//        let ch = FlutterEventChannel(name: "flutter_naver_map", binaryMessenger: registrar.messenger())
//        ch.setStreamHandler(orientationInstance)
    }

    func view() -> UIView {
        return mapView
    }
    
    

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("dasda")
      if(call.method == "getPackageVersion"){
        result("1.0.0")
      }else{
        result("")
      }
    }
}


//
//public class OrientationStreamHandler: NSObject, FlutterStreamHandler {
//
//    private var eventSink: FlutterEventSink?
//
//    // dart 코드에서 이 StreamHandler가 달린 EventChannel에 처음 접근했을 때 호출됩니다.
//    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
//        self.eventSink = events
//          registerOrientationObserver()
//        return nil
//    }
//
//    // dart 코드에서 EventChannel을 더이상 사용하지 않을 때 호출됩니다.
//    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
//        //더 이상 사용하지 않을 eventSink를 nil로 만들어줍니다.
//        self.eventSink = nil
//          removeOrientationObserver()
//        return nil
//    }
//
//    // Observer를 등록하는 함수
//    private func registerOrientationObserver() {
//      // eventSink?(0)코드를 작성해 dart 코드의 EventChannel로 결과를 전송합니다.
//      eventSink?(0)
//    }
//
//    // Observer를 해제시켜주는 함수
//    private func removeOrientationObserver() {
//    }
//}
//






public class SwiftMethodChannelPlugin: NSObject, FlutterPlugin {
  static var channel: FlutterMethodChannel?
  static let METHOD_CHANNEL_NAME = "flutter_naver_map"

  public static func register(with registrar: FlutterPluginRegistrar) {
    channel  = FlutterMethodChannel(name: METHOD_CHANNEL_NAME, binaryMessenger: registrar.messenger())

    let instance = SwiftMethodChannelPlugin()
    if let channel = channel {
      registrar.addMethodCallDelegate(instance, channel: channel)
    }
  }
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("dasda")

      if(call.method == "getPackageVersion"){
        result("1.0.0")
      }else{
        result("")
      }
    }

  //iOS 내부에서 어떤 이벤트가 발현되었을때 실행되는 함수입니다.
  public func somethingEventFired(){
    //옵셔널 변수를 벗겨줍니다.
    if let channel = SwiftMethodChannelPlugin.channel {
      //flutter의 handleCallback 함수를 실행시켜줍니다.
      channel.invokeMethod("handleCallback", arguments: nil)
    }
  }
}
