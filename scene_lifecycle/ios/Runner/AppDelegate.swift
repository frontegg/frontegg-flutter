import Flutter
import UIKit
import FronteggSwift

enum RouterLog {
  static var pageNotFoundLocations: [String] = []
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NotificationCenter.default.addObserver(forName: UIScene.didActivateNotification, object: nil, queue: .main) { note in
      if let scene = note.object as? UIWindowScene { self.showLinkStateOverlay(in: scene) }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SceneLifecycleRouterLog")!
    FlutterMethodChannel(name: "scene_lifecycle/router", binaryMessenger: registrar.messenger())
      .setMethodCallHandler { call, result in
        if call.method == "pageNotFound", let location = call.arguments as? String {
          RouterLog.pageNotFoundLocations.append(location)
        }
        result(nil)
      }
  }

  private var stateWindow: UIWindow?

  func showLinkStateOverlay(in scene: UIWindowScene) {
    guard stateWindow == nil else { return }
    let window = UIWindow(windowScene: scene)
    window.windowLevel = .alert + 1
    window.isUserInteractionEnabled = false
    let label = UILabel(frame: CGRect(x: 0, y: 60, width: 400, height: 20))
    label.accessibilityIdentifier = "linkState"
    label.font = .systemFont(ofSize: 6)
    window.addSubview(label)
    window.isHidden = false
    stateWindow = window
    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
      let presented = scene.windows.first?.rootViewController?.presentedViewController.map { String(describing: type(of: $0)) } ?? "none"
      label.text = "fronteggLink=\(FronteggAuth.shared.pendingAppLink?.path ?? "none") presented=\(presented.contains("EmbeddedLoginModal") ? "frontegg" : presented) pageNotFound=\(RouterLog.pageNotFoundLocations.count)"
      label.accessibilityLabel = label.text
    }
  }

  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    if let url = userActivity.webpageURL, FronteggAuth.shared.handleOpenUrl(url, true) {
      return true
    }
    return false
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    if FronteggAuth.shared.handleOpenUrl(url, true) {
      return true
    }
    return false
  }
}
