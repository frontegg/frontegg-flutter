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
        GeneratedPluginRegistrant.register(with: self)

        DefaultLoader.customLoaderView = AnyView(Text("Loading..."))
        
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

