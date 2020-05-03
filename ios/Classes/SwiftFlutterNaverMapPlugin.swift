import Flutter
import UIKit

//public class SwiftFlutterNaverMapPlugin: NSObject, FlutterPlugin {
////  public static func register(with registrar: FlutterPluginRegistrar) {
////    let channel = FlutterMethodChannel(name: "flutter_naver_map", binaryMessenger: registrar.messenger())
////    let instance = SwiftFlutterNaverMapPlugin()
////    registrar.addMethodCallDelegate(instance, channel: channel)
////  }
//
//    public static func register(with registrar: FlutterPluginRegistrar) {
////        let channel = FlutterMethodChannel(name: "flutter_naver_map", binaryMessenger: registrar.messenger())
////        let naverMapFactory = NaverMapFactory(registrar: registrar)
//        registrar.register(NaverMapFactory(registrar: registrar), withId: "flutter_naver_map")
//    }
//}




public class SwiftFlutterNaverMapPlugin : NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let googleMapFactory:NaverMapFactory! = NaverMapFactory(registrar:registrar)
        registrar.register(googleMapFactory,
                                      withId:"flutter_naver_map")
    }
    
    private var _registrar:NSObject!
    private var _channel:FlutterMethodChannel!
    private var _mapControllers:NSMutableDictionary!


    class func registerWithRegistrar(registrar:NSObject!) {
    }

    func mapFromCall(call:FlutterMethodCall, error:FlutterError) -> NaverMapController! {
        let mapId:AnyObject! = call.arguments as AnyObject?
        let controller:NaverMapController! = _mapControllers?[mapId] as! NaverMapController
        if (controller == nil) && (error != nil) {
            let error = FlutterError(code: "unknown_map", message:nil, details:mapId)
      }
      return controller
    }
}
