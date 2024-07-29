import Foundation
import FronteggSwift
import Flutter

class FronteggMethodCallHandler {
    private var fronteggApp: FronteggApp
    
    init(fronteggApp: FronteggApp) {
        self.fronteggApp = fronteggApp
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "login":
            login(result:result)
        case "switchTenant":
            switchTenant(call: call, result: result)
        case "directLoginAction":
            directLoginAction(call: call, result: result)
        case "refreshToken":
            refreshToken(result: result)
        case "logout":
            logout(result: result)
        case "getConstants":
            result(constantsToExport())
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func login(result: @escaping FlutterResult) {
        fronteggApp.auth.login()
        result(nil)
    }
    
    private func constantsToExport() -> [AnyHashable : Any?]! {
        return [
            "baseUrl": fronteggApp.baseUrl,
            "clientId": fronteggApp.clientId,
            "applicationId": fronteggApp.applicationId,
            "bundleId": Bundle.main.bundleIdentifier as Any
        ]
    }
    
    private func logout(result: @escaping FlutterResult) {
        fronteggApp.auth.logout()
        result(nil)
    }
    
    private func switchTenant(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing argumants", details: nil))
        }
        
        guard let tenantId = arguments["tenantId"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'tenantId' argumant", details: nil))
        }
        
        fronteggApp.auth.switchTenant(tenantId: tenantId) { _ in
            result(nil)
        }
    }
    
    private func directLoginAction(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing argumants", details: nil))
        }
        
        guard let type = arguments["type"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'type' argumant", details: nil))
        }
        
        guard let data = arguments["data"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'data' argumant", details: nil))
        }
        
        fronteggApp.auth.directLoginAction(window: nil, type: type, data: data) { _ in
            result(nil)
        }
    }
    
    private func refreshToken(result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInteractive).async {
            Task {
                let success = await self.fronteggApp.auth.refreshTokenIfNeeded()
                result(success)
            }
        }
    }
}
