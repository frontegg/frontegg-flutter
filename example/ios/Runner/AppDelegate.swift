import UIKit
import Flutter

import FronteggSwift

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /*
     * Called when the app was launched with a url. Feel free to add additional processing here,
     * but if you want the App API to support tracking app url opens, make sure to keep this call
     */
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        if(FronteggAuth.shared.handleOpenUrl(url, true)){
            return true
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
            }
        }
        
        return false
    }
}
