import XCTest

final class RunnerUITests: XCTestCase {
  private let resetPasswordLink = URL(string: "https://auth.scene-lifecycle.example/oauth/account/reset-password?userId=u1&token=t1&redirectUrl=https%3A%2F%2Fauth.scene-lifecycle.example%2Foauth%2Faccount%2Flogin")!

  func testColdLaunchFromResetPasswordLinkOpensFronteggInsteadOfTheAppRouter() {
    let app = XCUIApplication()
    app.terminate()
    app.open(resetPasswordLink)

    let linkState = app.staticTexts["linkState"]
    XCTAssertTrue(linkState.waitForExistence(timeout: 30))
    let expected = "fronteggLink=/oauth/account/reset-password presented=frontegg pageNotFound=0"
    let deadline = Date().addingTimeInterval(15)
    while linkState.label != expected && Date() < deadline {
      if linkState.label.hasSuffix("pageNotFound=1") { break }
      Thread.sleep(forTimeInterval: 0.3)
    }
    XCTAssertEqual(linkState.label, expected)
  }
}
