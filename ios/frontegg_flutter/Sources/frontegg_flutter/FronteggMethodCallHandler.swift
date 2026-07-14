import Foundation
import FronteggSwift
import Flutter
import SwiftUI
import UIKit

class FronteggMethodCallHandler {
    private var fronteggApp: FronteggApp
    
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
        case "refreshToken":
            refreshToken(result: result)
        case "logout":
            logout(result: result)
        case "getConstants":
            result(constantsToExport())
        case "requestAuthorize":
            requestAuthorize(call: call, result: result)
            
        case "directLoginAction":
            directLoginAction(call: call, result: result)
        case "directLogin":
            directLogin(call: call, result: result)
        case "socialLogin":
            socialLogin(call: call, result: result)
        case "customSocialLogin":
            customSocialLogin(call: call, result: result)
            
        case "stepUp":
            stepUp(call: call, result: result)
        case "isSteppedUp":
            isSteppedUp(call: call, result: result)
        case "loadEntitlements":
            loadEntitlements(call: call, result: result)
        case "getFeatureEntitlement":
            getFeatureEntitlement(call: call, result: result)
        case "getPermissionEntitlement":
            getPermissionEntitlement(call: call, result: result)
        case "openAdminPortal":
            openAdminPortal(result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func isSteppedUp(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing argumants", details: nil))
        }
        
        let maxAge = arguments["maxAge"] as? TimeInterval
        
        let isSteppedUp = fronteggApp.auth.isSteppedUp(maxAge: maxAge)
        result(isSteppedUp)
    }
    
    private func stepUp(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    )  {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing argumants", details: nil))
        }
        let maxAge = arguments["maxAge"] as? TimeInterval
        
        let compelation: FronteggAuth.CompletionHandler = { res in
            switch (res) {
                case .success(_):
                    result(nil)
                case .failure(let error):
                result(FlutterError(code: error.failureReason ?? "unknown", message: error.localizedDescription, details: nil))
            }
        }
        
        Task {
            await fronteggApp.auth.stepUp(maxAge: maxAge, compelation)
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
        
        
        // Retrieve the 'ephemeralSession' parameter (must match Flutter key) or use the default value of true
        let ephemeralSession = arguments["ephemeralSession"] as? Bool ?? true
        
        let additionalQueryParams = arguments["additionalQueryParams"] as? [String: String] ?? [:]
        
        let compelation: FronteggAuth.CompletionHandler = { _ in
            result(nil)
        }
        
        fronteggApp.auth.directLoginAction(
            window: nil,
            type: type,
            data: data,
            ephemeralSession: ephemeralSession,
            _completion: compelation,
            additionalQueryParams: additionalQueryParams
        )
    }
    
    private func directLogin(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing argumants", details: nil))
        }
        
        guard let url = arguments["url"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'url' argumant", details: nil))
        }
        
        // Retrieve the 'ephemeralSession' parameter (must match Flutter key) or use the default value of true
        let ephemeralSession = arguments["ephemeralSession"] as? Bool ?? true
        
        let additionalQueryParams = arguments["additionalQueryParams"] as? [String: String] ?? [:]
        
        let compelation: FronteggAuth.CompletionHandler = { _ in
            result(nil)
        }
        
        fronteggApp.auth.directLoginAction(
            window: nil,
            type: "direct",
            data: url,
            ephemeralSession: ephemeralSession,
            _completion: compelation,
            additionalQueryParams: additionalQueryParams
        )
    }
    
    
    private func socialLogin(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing argumants", details: nil))
        }
        
        guard let provider = arguments["provider"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'provider' argumant", details: nil))
        }
        
        // Retrieve the 'ephemeralSession' parameter (must match Flutter key) or use the default value of true
        let ephemeralSession = arguments["ephemeralSession"] as? Bool ?? true
        
        let additionalQueryParams = arguments["additionalQueryParams"] as? [String: String] ?? [:]
        
        let compelation: FronteggAuth.CompletionHandler = { _ in
            result(nil)
        }
        
        fronteggApp.auth.directLoginAction(
            window: nil,
            type: "social-login",
            data: provider,
            ephemeralSession: ephemeralSession,
            _completion: compelation,
            additionalQueryParams: additionalQueryParams
        )
    }
    
    
    private func customSocialLogin(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing argumants", details: nil))
        }
        
        guard let id = arguments["id"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'id' argumant", details: nil))
        }
        
        
        // Retrieve the 'ephemeralSession' parameter (must match Flutter key) or use the default value of true
        let ephemeralSession = arguments["ephemeralSession"] as? Bool ?? true
        
        let additionalQueryParams = arguments["additionalQueryParams"] as? [String: String] ?? [:]
        
        let compelation: FronteggAuth.CompletionHandler = { _ in
            result(nil)
        }
        
        fronteggApp.auth.directLoginAction(
            window: nil,
            type: "custom-social-login",
            data: id,
            ephemeralSession: ephemeralSession,
            _completion: compelation,
            additionalQueryParams: additionalQueryParams
        )
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
               result(FlutterError(code: error.failureReason ?? "unknown", message: error.localizedDescription, details: nil))
           }

       }
       fronteggApp.auth.login(completion, loginHint: loginHint)
    }
    
    private func requestAuthorize(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing argumants", details: nil))
        }
        
        guard let refreshToken = arguments["refreshToken"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'refreshToken' argumant", details: nil))
        }
        
        let deviceTokenCookie = arguments["deviceTokenCookie"] as? String
        
        let completion: FronteggAuth.CompletionHandler = { res in
            switch (res) {
            case .success(let user):
                var jsonUser: [String: Any]? = nil
                if let userData = try? JSONEncoder().encode(user) {
                    jsonUser = try? JSONSerialization.jsonObject(with: userData, options: .allowFragments) as? [String: Any]
                }
                result(jsonUser)
            case .failure(let error):
                result(FlutterError(code: error.failureReason ?? "unknown", message: error.localizedDescription, details: nil))
            }
        }
        
        fronteggApp.auth.requestAuthorize(refreshToken: refreshToken, deviceTokenCookie: deviceTokenCookie, completion)
    }
    
    private func loginWithPasskeys(result: @escaping FlutterResult) -> Void {
        let completion: FronteggAuth.CompletionHandler = { res in
            switch(res) {
            case .success(_):
                result(nil)
            case .failure(let error):
                result(FlutterError(code: error.failureReason ?? "unknown", message: error.localizedDescription, details: nil
                ))
            }
        }
        fronteggApp.auth.loginWithPasskeys(completion)
    }
    
    private func registerPasskeys(result: @escaping FlutterResult) -> Void {
        let completion: FronteggAuth.ConditionCompletionHandler = { error in
            if let fronteggError = error {
                result(FlutterError(
                    code: fronteggError.failureReason ?? "unknown", message: fronteggError.localizedDescription, details: nil
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
    
    private func refreshToken(result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInteractive).async {
            Task {
                let success = await self.fronteggApp.auth.refreshTokenIfNeeded()
                result(success)
            }
        }
    }

    private func loadEntitlements(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing arguments",
                    details: nil
                )
            )
        }

        let forceRefresh = arguments["forceRefresh"] as? Bool ?? false

        fronteggApp.auth.loadEntitlements(
            forceRefresh: forceRefresh
        ) { success in
            result(success)
        }
    }

    private func getFeatureEntitlement(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let arguments = call.arguments as? [String: Any?],
              let key = arguments["key"] as? String
        else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing feature key", details: nil))
        }
        result(Self.entitlementToDict(fronteggApp.auth.getFeatureEntitlements(featureKey: key)))
    }

    private func getPermissionEntitlement(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let arguments = call.arguments as? [String: Any?],
              let key = arguments["key"] as? String
        else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing permission key", details: nil))
        }
        result(Self.entitlementToDict(fronteggApp.auth.getPermissionEntitlements(permissionKey: key)))
    }

    private static func entitlementToDict(_ entitlement: Entitlement) -> [String: Any?] {
        [
            "isEntitled": entitlement.isEntitled,
            "justification": entitlement.justification,
        ]
    }

    private func openAdminPortal(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            guard let viewController = Self.topViewController() else {
                result(FlutterError(
                    code: "NO_VIEW_CONTROLLER",
                    message: "Cannot open Admin Portal without an active view controller",
                    details: nil
                ))
                return
            }

            if #available(iOS 14.0, *) {
                let host = UIHostingController(rootView: AdminPortalView())
                host.modalPresentationStyle = .pageSheet
                viewController.present(host, animated: true)
                result(nil)
            } else {
                result(FlutterError(
                    code: "UNSUPPORTED",
                    message: "Admin Portal requires iOS 14+",
                    details: nil
                ))
            }
        }
    }

    private static func topViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        var topController = keyWindow?.rootViewController
        while let presented = topController?.presentedViewController {
            topController = presented
        }
        return topController
    }
}
