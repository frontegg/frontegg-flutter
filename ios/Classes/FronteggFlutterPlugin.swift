import Flutter
import UIKit
import FronteggSwift

public class FronteggFlutterPlugin: NSObject, FlutterPlugin {
    public let fronteggApp = FronteggApp.shared
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "frontegg_flutter", binaryMessenger: registrar.messenger())
        let instance = FronteggFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "login":
            login(result:result)
        case "getConstants":
            result(constantsToExport())
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func login(result: @escaping FlutterResult) {
        print(fronteggApp.baseUrl)
        print(fronteggApp.clientId)
        fronteggApp.auth.login()
        result(nil)
    }
    
    func constantsToExport() -> [AnyHashable : Any]! {
          return [
            "baseUrl": fronteggApp.baseUrl,
            "clientId": fronteggApp.clientId,
            "bundleId": Bundle.main.bundleIdentifier as Any
          ]
        }
}
