import Flutter
import FronteggSwift
import ObjectiveC
import UIKit
import XCTest

@testable import Runner

private enum DeepLinkTrace {
  static let install: Void = {
    traceSceneFallback()
    traceHandleDeeplink()
    traceSendDeepLink()
  }()

  private static func lookUpMethod(_ className: String, _ selectorName: String) -> Method? {
    guard let cls = NSClassFromString(className),
          let method = class_getInstanceMethod(cls, NSSelectorFromString(selectorName)) else {
      NSLog("%@", "DIAG trace: \(className) \(selectorName) not found")
      return nil
    }
    return method
  }

  private static func traceSceneFallback() {
    let selector = NSSelectorFromString("sceneFallbackContinueUserActivity:")
    guard let method = lookUpMethod("FlutterPluginAppLifeCycleDelegate", "sceneFallbackContinueUserActivity:") else { return }
    typealias Original = @convention(c) (AnyObject, Selector, AnyObject) -> Bool
    let original = unsafeBitCast(method_getImplementation(method), to: Original.self)
    let replacement: @convention(block) (AnyObject, AnyObject) -> Bool = { receiver, activity in
      let handled = original(receiver, selector, activity)
      NSLog("%@", "DIAG sceneFallbackContinueUserActivity -> \(handled)")
      return handled
    }
    method_setImplementation(method, imp_implementationWithBlock(replacement))
  }

  private static func traceHandleDeeplink() {
    let selectorName = "handleDeeplink:flutterEngine:relayToSystemIfUnhandled:"
    let selector = NSSelectorFromString(selectorName)
    guard let method = lookUpMethod("FlutterPluginSceneLifeCycleDelegate", selectorName) else { return }
    typealias Original = @convention(c) (AnyObject, Selector, AnyObject?, AnyObject, Bool) -> Bool
    let original = unsafeBitCast(method_getImplementation(method), to: Original.self)
    let replacement: @convention(block) (AnyObject, AnyObject?, AnyObject, Bool) -> Bool = { receiver, url, engine, relay in
      let handled = original(receiver, selector, url, engine, relay)
      NSLog("%@", "DIAG handleDeeplink \(String(describing: url)) -> \(handled)")
      return handled
    }
    method_setImplementation(method, imp_implementationWithBlock(replacement))
  }

  private static func traceSendDeepLink() {
    typealias Completion = @convention(block) (Bool) -> Void
    let selector = NSSelectorFromString("sendDeepLinkToFramework:completionHandler:")
    guard let method = lookUpMethod("FlutterEngine", "sendDeepLinkToFramework:completionHandler:") else { return }
    typealias Original = @convention(c) (AnyObject, Selector, AnyObject, @escaping Completion) -> Void
    let original = unsafeBitCast(method_getImplementation(method), to: Original.self)
    let replacement: @convention(block) (AnyObject, AnyObject, @escaping Completion) -> Void = { engine, url, completion in
      NSLog("%@", "DIAG sendDeepLinkToFramework \(url)")
      original(engine, selector, url) { success in
        NSLog("%@", "DIAG sendDeepLinkToFramework completion success=\(success)")
        completion(success)
      }
    }
    method_setImplementation(method, imp_implementationWithBlock(replacement))
  }
}

final class RunnerTests: XCTestCase {
  private let resetPasswordLink = URL(string: "https://auth.scene-lifecycle.example/oauth/account/reset-password?userId=u1&token=t1&redirectUrl=https%3A%2F%2Fauth.scene-lifecycle.example%2Foauth%2Faccount%2Flogin")!
  private let hostAppLink = URL(string: "https://www.scene-lifecycle.example/promo")!

  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    _ = DeepLinkTrace.install
    waitForFlutterUI()
    closePresentedWindow()
    RouterLog.pageNotFoundLocations = []
    FronteggAuth.shared.pendingAppLink = nil
  }

  func testResetPasswordUniversalLinkReachesFronteggInsteadOfTheAppRouter() {
    deliverUniversalLink(resetPasswordLink)

    waitUntil("the link is handled by Frontegg or by the app router") {
      FronteggAuth.shared.pendingAppLink != nil || !RouterLog.pageNotFoundLocations.isEmpty
    }
    XCTAssertEqual(RouterLog.pageNotFoundLocations, [], "The reset-password link reached the app's router")
    XCTAssertEqual(FronteggAuth.shared.pendingAppLink, resetPasswordLink)
    waitUntil("the Frontegg login window is presented") {
      self.presentedControllerName()?.contains("EmbeddedLoginModal") == true
    }
  }

  func testUniversalLinkOutsideFronteggStillReachesTheAppRouter() {
    logState("before deliver")
    deliverUniversalLink(hostAppLink)
    logState("after deliver")
    RunLoop.current.run(until: Date().addingTimeInterval(3))
    logState("3s after deliver")

    waitUntil("the app router receives the host app's link") {
      !RouterLog.pageNotFoundLocations.isEmpty
    }
    XCTAssertEqual(RouterLog.pageNotFoundLocations, [hostAppLink.absoluteString])
    XCTAssertNil(FronteggAuth.shared.pendingAppLink)
  }

  func testZDiagnosticDirectNavigationPushReachesTheAppRouter() {
    let root = (windowScene.delegate as? UIWindowSceneDelegate)?.window??.rootViewController
    guard let engine = (root as? FlutterViewController)?.engine else {
      XCTFail("No FlutterViewController engine")
      return
    }
    engine.navigationChannel.invokeMethod("pushRouteInformation", arguments: ["location": hostAppLink.absoluteString]) { result in
      NSLog("%@", "DIAG direct pushRouteInformation result=\(String(describing: result))")
    }
    waitUntil("the app router receives the directly pushed link") {
      !RouterLog.pageNotFoundLocations.isEmpty
    }
    NSLog("%@", "DIAG direct push pageNotFound=\(RouterLog.pageNotFoundLocations)")
  }

  private var windowScene: UIWindowScene {
    UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first!
  }

  private func deliverUniversalLink(_ url: URL) {
    let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
    activity.webpageURL = url
    let scene = windowScene
    XCTAssertEqual(String(describing: type(of: scene.delegate!)), "FlutterSceneDelegate")
    (scene.delegate as! UIWindowSceneDelegate).scene!(scene, continue: activity)
  }

  private func logState(_ label: String) {
    let root = (windowScene.delegate as? UIWindowSceneDelegate)?.window??.rootViewController
    let flutterViewController = root as? FlutterViewController
    let rootName: String = root.map { String(describing: type(of: $0)) } ?? "nil"
    let deepLinking = String(describing: Bundle.main.object(forInfoDictionaryKey: "FlutterDeepLinkingEnabled"))
    let parts: [String] = [
      "DIAG test \(label):",
      "appState=\(UIApplication.shared.applicationState.rawValue)",
      "sceneState=\(windowScene.activationState.rawValue)",
      "root=\(rootName)",
      "presented=\(presentedControllerName() ?? "none")",
      "displayingFlutterUI=\(flutterViewController?.isDisplayingFlutterUI ?? false)",
      "viewInWindow=\(flutterViewController?.viewIfLoaded?.window != nil)",
      "deepLinking=\(deepLinking)",
      "pageNotFound=\(RouterLog.pageNotFoundLocations)",
      "pendingAppLink=\(String(describing: FronteggAuth.shared.pendingAppLink))",
    ]
    NSLog("%@", parts.joined(separator: " "))
  }

  private func presentedControllerName() -> String? {
    let root = (windowScene.delegate as? UIWindowSceneDelegate)?.window??.rootViewController
    return root?.presentedViewController.map { String(describing: type(of: $0)) }
  }

  private func closePresentedWindow() {
    let root = (windowScene.delegate as? UIWindowSceneDelegate)?.window??.rootViewController
    guard root?.presentedViewController != nil else { return }
    root?.dismiss(animated: false)
    waitUntil("the presented window closes") { root?.presentedViewController == nil }
  }

  private func waitForFlutterUI() {
    waitUntil("Flutter renders its first frame") {
      let root = (self.windowScene.delegate as? UIWindowSceneDelegate)?.window??.rootViewController
      return (root as? FlutterViewController)?.isDisplayingFlutterUI == true
    }
  }

  private func waitUntil(_ description: String, timeout: TimeInterval = 15, _ condition: @escaping () -> Bool) {
    let deadline = Date().addingTimeInterval(timeout)
    while !condition() && Date() < deadline {
      RunLoop.current.run(until: Date().addingTimeInterval(0.1))
    }
    XCTAssertTrue(condition(), "Timed out waiting until \(description)")
  }
}
