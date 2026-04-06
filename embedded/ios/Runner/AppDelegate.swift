import UIKit
import Flutter
import SwiftUI
import os.log

import FronteggSwift

private let e2eLog = OSLog(subsystem: "com.frontegg.demo.e2e", category: "E2E")

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        DefaultLoader.customLoaderView = AnyView(Text("Loading..."))

        // Register the E2E method channel.  Use the FlutterPluginRegistry API
        // so it works even when window.rootViewController is not yet available
        // (UIScene lifecycle / Xcode 16.4).
        let registrar = self.registrar(forPlugin: "FronteggE2E")!
        let e2eChannel = FlutterMethodChannel(
            name: "frontegg_e2e",
            binaryMessenger: registrar.messenger()
        )
        e2eChannel.setMethodCallHandler(handleE2EMethodCall)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /*
     * Called when the app was launched with a url. Feel free to add additional processing here,
     * but if you want the App API to support tracking app url opens, make sure to keep this call
     */
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        if(FronteggAuth.shared.handleOpenUrl(url, true)){
            return true
        }else {
            showToast(message: "Opened link: \(url.absoluteString)")
        }
        return false
    }
    
    /*
     * Called when the app was launched with an activity, including Universal Links.
     * Feel free to add additional processing here, but if you want the App API to support
     * tracking app url opens, make sure to keep this call
     */
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if let url = userActivity.webpageURL {
            if(FronteggAuth.shared.handleOpenUrl(url, true)){
                return true
            }else {
                
                showToast(message: "Opened link: \(url.absoluteString)")
            }
        }
        
        
        
        return false
    }
    
    private func handleE2EMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initializeForE2E":
            guard let args = call.arguments as? [String: Any],
                  let baseUrl = args["baseUrl"] as? String,
                  let clientId = args["clientId"] as? String else {
                result(FlutterError(code: "MISSING_PARAM", message: "baseUrl and clientId required", details: nil))
                return
            }
            let resetState = args["resetState"] as? Bool ?? true
            let forceNetworkPathOffline = args["forceNetworkPathOffline"] as? Bool ?? false
            os_log("[E2E] initializeForE2E: baseUrl=%{public}@, clientId=%{public}@, resetState=%d", log: e2eLog, type: .info, baseUrl, clientId, resetState ? 1 : 0)
            Task { @MainActor in
#if DEBUG
                os_log("[E2E] DEBUG block active", log: e2eLog, type: .info)
                if resetState {
                    await FronteggApp.shared.resetForTesting(baseUrlOverride: baseUrl)
                    os_log("[E2E] resetForTesting done", log: e2eLog, type: .info)
                }
                FronteggApp.shared.configureTestingNetworkPathAvailability(
                    forceNetworkPathOffline ? false : nil
                )
                if let offline = args["enableOfflineMode"] as? Bool {
                    FronteggApp.shared.configureTestingOfflineMode(offline)
                } else if let offline = args["enableOfflineMode"] as? NSNumber {
                    FronteggApp.shared.configureTestingOfflineMode(offline.boolValue)
                }
#else
                os_log("[E2E] DEBUG block NOT active — #if DEBUG is false", log: e2eLog, type: .error)
#endif
                FronteggApp.shared.shouldPromptSocialLoginConsent = false
                os_log("[E2E] calling manualInit embeddedMode=%d", log: e2eLog, type: .info, FronteggApp.shared.auth.embeddedMode ? 1 : 0)
                FronteggApp.shared.manualInit(
                    baseUrl: baseUrl,
                    cliendId: clientId,
                    handleLoginWithSocialLogin: true,
                    handleLoginWithSSO: true,
                    handleLoginWithCustomSSO: true,
                    handleLoginWithCustomSocialLoginProvider: true,
                    handleLoginWithSocialProvider: true,
                    entitlementsEnabled: false
                )
                os_log("[E2E] manualInit done, baseUrl=%{public}@, embeddedMode=%d", log: e2eLog, type: .info, FronteggApp.shared.baseUrl, FronteggApp.shared.auth.embeddedMode ? 1 : 0)
                result(nil)
            }

        case "resetForTesting":
            FronteggApp.shared.auth.logout { _ in
                result(nil)
            }

        case "writeBootstrap", "consumeBootstrap":
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func showToast(message: String) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textAlignment = .center
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.numberOfLines = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.alpha = 1.0

        let maxWidth = window.frame.width - 40
        let labelSize = toastLabel.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        toastLabel.frame = CGRect(x: 20,
                                  y: window.frame.height - labelSize.height - 100,
                                  width: maxWidth,
                                  height: labelSize.height + 20)

        // 👇 Force above FlutterViewController
        toastLabel.layer.zPosition = 9999
        window.addSubview(toastLabel)

        UIView.animate(withDuration: 0.5, delay: 2.5, options: .curveEaseOut, animations: {
          toastLabel.alpha = 0
        }) { _ in
          toastLabel.removeFromSuperview()
        }
      }
    }

