import UIKit
import Flutter
import SwiftUI

import FronteggSwift

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
#if DEBUG
        // E2EBootstrap.m's +load already set frontegg-testing=true before main()
        // — verify it's visible to ProcessInfo (which the SDK reads).
        let viaC = String(cString: getenv("frontegg-testing") ?? "<nil>")
        let viaProcessInfo = ProcessInfo.processInfo.environment["frontegg-testing"] ?? "<nil>"
        NSLog("[E2E] AppDelegate env: getenv=%@, ProcessInfo=%@", viaC, viaProcessInfo)
#endif

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
        NSLog("[E2E] e2e channel registered via FlutterPluginRegistry")

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
            NSLog("[E2E] initializeForE2E: baseUrl=%@, resetState=%d", baseUrl, resetState ? 1 : 0)
            Task { @MainActor in
#if DEBUG
                NSLog("[E2E] DEBUG block active")
                if resetState {
                    await FronteggApp.shared.resetForTesting(baseUrlOverride: baseUrl)
                    NSLog("[E2E] resetForTesting done")
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
                NSLog("[E2E] DEBUG block NOT active")
#endif
                FronteggApp.shared.shouldPromptSocialLoginConsent = false
                NSLog("[E2E] pre-manualInit embeddedMode=%d, baseUrl=%@", FronteggApp.shared.auth.embeddedMode ? 1 : 0, FronteggApp.shared.baseUrl)
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
                NSLog("[E2E] manualInit done, baseUrl=%@, embeddedMode=%d", FronteggApp.shared.baseUrl, FronteggApp.shared.auth.embeddedMode ? 1 : 0)
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

