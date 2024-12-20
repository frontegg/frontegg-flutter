import Foundation
import FronteggSwift
import Flutter

class FronteggMethodCallHandler {
    private var fronteggApp: FronteggApp
    private let ERROR_CODE: String = "frontegg.error"
    
    init(fronteggApp: FronteggApp) {
        self.fronteggApp = fronteggApp
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "login":
            login(call: call,result:result)
        case "loginWithPasskeys":
            loginWithPasskeys(result: result)
        case "registerPasskeys":
            registerPasskeys(result: result)
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
    
    private func login(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let arguments = call.arguments as? [String: Any?]
        
        let loginHint = arguments?["loginHint"] as? String
        // Never get success. Should be fixed on SDK before implemented here
       let completion: FronteggAuth.CompletionHandler = { res in
           switch (res) {
           case .success(_):
               result(nil)
           case .failure(let error):
               result(FlutterError(code: "LOGIN_ERROR", message: error.failureReason ?? "", details: nil))
           }

       }
       fronteggApp.auth.login(completion, loginHint: loginHint)
    }
    
    private func loginWithPasskeys(result: @escaping FlutterResult) -> Void {
        let completion: FronteggAuth.CompletionHandler = { res in
            switch(res) {
            case .success(_):
                result(nil)
            case .failure(let error):
                result(FlutterError(
                    code: self.ERROR_CODE,
                    message: error.localizedDescription,
                    details: nil
                ))
            }
        }
        fronteggApp.auth.loginWithPasskeys(completion)
    }
    
    private func registerPasskeys(result: @escaping FlutterResult) -> Void {
        let completion: FronteggAuth.ConditionCompletionHandler = { error in
            if let fronteggError = error {
                result(FlutterError(
                    code: self.ERROR_CODE,
                    message: fronteggError.localizedDescription,
                    details: nil
                ))
            } else {
                result(nil)
            }
        }
        fronteggApp.auth.registerPasskeys(completion)
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
        fronteggApp.auth.logout() { _ in
            result(nil)
        }
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


        // Retrieve the 'ephemeral' parameter or use the default value of true
        let ephemeralSession = arguments["ephemeral"] as? Bool ?? true

        fronteggApp.auth.directLoginAction(window: nil, type: type, data: data, ephemeralSession: ephemeralSession) { _ in
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
