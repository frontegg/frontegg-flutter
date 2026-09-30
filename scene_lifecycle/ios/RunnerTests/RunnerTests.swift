import Flutter
import FronteggSwift
import UIKit
import XCTest

@testable import Runner

final class RunnerTests: XCTestCase {
  private let resetPasswordLink = URL(string: "https://auth.scene-lifecycle.example/oauth/account/reset-password?userId=u1&token=t1&redirectUrl=https%3A%2F%2Fauth.scene-lifecycle.example%2Foauth%2Faccount%2Flogin")!
  private let hostAppLink = URL(string: "https://www.scene-lifecycle.example/promo")!

  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    waitForFlutterUI()
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
    deliverUniversalLink(hostAppLink)

    waitUntil("the app router receives the host app's link") {
      !RouterLog.pageNotFoundLocations.isEmpty
    }
    XCTAssertEqual(RouterLog.pageNotFoundLocations, [hostAppLink.absoluteString])
    XCTAssertNil(FronteggAuth.shared.pendingAppLink)
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

  private func presentedControllerName() -> String? {
    let root = (windowScene.delegate as? UIWindowSceneDelegate)?.window??.rootViewController
    return root?.presentedViewController.map { String(describing: type(of: $0)) }
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
