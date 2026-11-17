//
// SPDX-FileCopyrightText: 2026 Krateos B.V.
// SPDX-License-Identifier: GPL-3.0-or-later
//

import XCTest
@testable import NextcloudTalk

/// App Review (Guideline 3.1.1, XEN-381) must not reach plans, pricing or sign-up from the privacy page or the login.
final class UnitXeniaWebNavigationPolicyTest: XCTestCase {

    private func url(_ string: String) throws -> URL {
        try XCTUnwrap(URL(string: string))
    }

    // MARK: - Privacy statement

    func testPrivacyURLIsHTTPS() throws {
        XCTAssertEqual(try url(privacyURL).scheme, "https")
    }

    func testPrivacyAllowsTheStatementItself() throws {
        let policy = XeniaWebNavigationPolicy.singlePage(url: try url(privacyURL))

        for string in [
            "https://xeniacloud.eu/privacy-policy/",
            "https://xeniacloud.eu/privacy-policy",
            "https://XeniaCloud.eu/privacy-policy/#cookies",
            "https://xeniacloud.eu/privacy-policy/?lang=en"
        ] {
            XCTAssertTrue(policy.allows(try url(string), isMainFrame: true), string)
        }
    }

    func testPrivacyBlocksEverythingElse() throws {
        let policy = XeniaWebNavigationPolicy.singlePage(url: try url(privacyURL))

        for string in [
            "https://xeniacloud.eu/",
            "https://xeniacloud.eu/#personal-pricing",
            "https://xeniacloud.eu/#business-pricing",
            "https://xeniacloud.eu/pricing-en/",
            "https://auth.xeniacloud.eu/if/flow/enrollment/",
            "https://portal.xeniacloud.eu/privacy-policy/",
            "http://xeniacloud.eu/privacy-policy/",
            "mailto:privacy@example.com"
        ] {
            XCTAssertFalse(policy.allows(try url(string), isMainFrame: true), string)
        }
    }

    func testPrivacyNeverOpensNewWindowsButLoadsFrames() throws {
        let policy = XeniaWebNavigationPolicy.singlePage(url: try url(privacyURL))

        XCTAssertFalse(policy.allows(try url(privacyURL), isMainFrame: nil))
        XCTAssertFalse(policy.allows(try url("https://xeniacloud.eu/pricing-en/"), isMainFrame: nil))
        XCTAssertTrue(policy.allows(try url("https://consent.example.com/widget"), isMainFrame: false))
        XCTAssertFalse(policy.allows(nil, isMainFrame: true))
    }

    // MARK: - Login

    func testLoginAllowsSignInPages() throws {
        let policy = XeniaWebNavigationPolicy.login(serverURL: try url(LoginViewController.xeniaCloudServerURL))

        for string in [
            "https://portal.xeniacloud.eu/index.php/login/flow",
            "https://portal.xeniacloud.eu/index.php/login?redirect_url=/index.php/login/flow",
            "https://portal.xeniacloud.eu/apps/user_oidc/login/1",
            "https://auth.xeniacloud.eu/application/o/authorize/?client_id=x",
            "https://auth.xeniacloud.eu/if/flow/default-authentication-flow/",
            "https://Auth.XeniaCloud.eu/if/flow/default-authentication-flow/"
        ] {
            XCTAssertTrue(policy.allows(try url(string), isMainFrame: true), string)
        }
    }

    func testLoginBlocksWebsiteAndSignUp() throws {
        let policy = XeniaWebNavigationPolicy.login(serverURL: try url(LoginViewController.xeniaCloudServerURL))

        for string in [
            "https://xeniacloud.eu/",
            "https://xeniacloud.eu/#personal-pricing",
            "https://xeniacloud.eu/pricing-en/",
            "https://auth.xeniacloud.eu/if/flow/enrollment/",
            "https://auth.xeniacloud.eu/if/flow/default-Enrollment-flow/",
            "http://portal.xeniacloud.eu/index.php/login/flow",
            "https://github.com/nextcloud/talk-ios",
            "https://portal.xeniacloud.eu.example.com/"
        ] {
            XCTAssertFalse(policy.allows(try url(string), isMainFrame: true), string)
        }
    }

    func testLoginNeverOpensNewWindows() throws {
        let policy = XeniaWebNavigationPolicy.login(serverURL: try url(LoginViewController.xeniaCloudServerURL))

        XCTAssertFalse(policy.allows(try url("https://xeniacloud.eu/pricing-en/"), isMainFrame: nil))
        XCTAssertFalse(policy.allows(try url("https://portal.xeniacloud.eu/index.php/login/flow"), isMainFrame: nil))
        XCTAssertTrue(policy.allows(try url("https://challenges.cloudflare.com/turnstile/v0/api.js"), isMainFrame: false))
    }

    func testLoginAllowsTheTestServerOnlyWithItsOwnScheme() throws {
        let policy = XeniaWebNavigationPolicy.login(serverURL: try url("http://localhost:8080"))

        XCTAssertTrue(policy.allows(try url("http://localhost:8080/index.php/login/flow"), isMainFrame: true))
        XCTAssertFalse(policy.allows(try url("http://portal.xeniacloud.eu/index.php/login/flow"), isMainFrame: true))
        XCTAssertFalse(policy.allows(try url("http://localhost:8080/index.php/apps/registration/enrollment"), isMainFrame: true))
        XCTAssertFalse(policy.allows(try url("https://xeniacloud.eu/pricing-en/"), isMainFrame: true))
    }

    // MARK: - Wiring

    @MainActor
    func testPrivacyViewControllerImplementsDelegateSelector() throws {
        let viewController = PrivacyStatementViewController(url: try url(privacyURL))

        XCTAssertTrue(viewController.responds(to: NSSelectorFromString("webView:decidePolicyForNavigationAction:decisionHandler:")))
        XCTAssertEqual(viewController.navigationPolicy.rule, XeniaWebNavigationPolicy.singlePage(url: try url(privacyURL)).rule)
    }
}
