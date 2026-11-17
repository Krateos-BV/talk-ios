//
// SPDX-FileCopyrightText: 2026 Krateos B.V.
// SPDX-License-Identifier: GPL-3.0-or-later
//

import UIKit
import WebKit

///
/// Shows the privacy statement in a web view that cannot leave that one page.
///
/// Replaces SFSafariViewController, which cannot restrict navigation: the statement is a page of the public
/// website, whose header and footer link to plans and sign-up (Guideline 3.1.1, XEN-381).
/// Anchors within the page keep working.
///
class PrivacyStatementViewController: UIViewController, WKNavigationDelegate {

    let url: URL
    let navigationPolicy: XeniaWebNavigationPolicy

    private(set) var webView: WKWebView?

    init(url: URL) {
        self.url = url
        self.navigationPolicy = XeniaWebNavigationPolicy.singlePage(url: url)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NCAppBranding.styleViewController(self)
        self.navigationItem.title = NSLocalizedString("Privacy", comment: "")
        self.view.backgroundColor = .systemBackground

        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()

        let webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        webView.navigationDelegate = self
        webView.allowsLinkPreview = false
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(webView)
        self.webView = webView

        webView.load(URLRequest(url: url))
    }

    // MARK: - WKNavigationDelegate

    // Explicit selector: a signature that only nearly matches the protocol would compile, but never be called.
    @objc(webView:decidePolicyForNavigationAction:decisionHandler:)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy) -> Void) {
        decisionHandler(navigationPolicy.allows(navigationAction: navigationAction) ? .allow : .cancel)
    }
}
