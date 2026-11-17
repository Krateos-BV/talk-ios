//
// SPDX-FileCopyrightText: 2026 Krateos B.V.
// SPDX-License-Identifier: GPL-3.0-or-later
//

import Foundation
import WebKit

///
/// Decides which pages an in-app web view may show.
///
/// The privacy statement and the sign-in pages link to the public website, whose header and footer
/// lead to plans, pricing and sign-up. App Review (Guideline 3.1.1) treats such links as a call to action
/// for purchase, so these web views must not leave the pages they exist for (XEN-381, same as Notes XEN-369).
///
/// New windows (`target="_blank"`, `window.open`) are never opened. Embedded frames may load,
/// because anything they open in the main frame is checked again.
///
@objcMembers
final class XeniaWebNavigationPolicy: NSObject {

    enum Rule: Equatable {
        /// Only the page at this host and path over HTTPS. Query and fragment are ignored.
        case singlePage(host: String, path: String)
        /// Any page on these hosts over HTTPS (plus `insecureHost` over HTTP), except paths containing a blocked fragment.
        case hosts(Set<String>, insecureHost: String?, blockedPathFragments: [String])
    }

    /// Hosts the sign-in flow uses: the Nextcloud portal and the identity provider.
    static let loginAllowedHosts: Set<String> = ["portal.xeniacloud.eu", "auth.xeniacloud.eu"]

    /// The sign-up flow, which links to plans, is never shown.
    static let loginBlockedPathFragments: [String] = ["enrollment"]

    let rule: Rule

    init(rule: Rule) {
        self.rule = rule
    }

    ///
    /// Only the page at `url` may be shown.
    ///
    static func singlePage(url: URL) -> XeniaWebNavigationPolicy {
        XeniaWebNavigationPolicy(rule: .singlePage(host: (url.host ?? "").lowercased(), path: normalized(path: url.path)))
    }

    ///
    /// The sign-in pages: ``loginAllowedHosts`` over HTTPS, never a path containing ``loginBlockedPathFragments``.
    ///
    /// The host of `serverURL` is allowed as well, so the UI tests can sign in to their local test server
    /// (the server field is locked to the portal in shipped builds). It may use HTTP only if `serverURL` does.
    ///
    static func login(serverURL: URL?) -> XeniaWebNavigationPolicy {
        var hosts = loginAllowedHosts
        var insecureHost: String?

        if let serverURL, let serverHost = serverURL.host?.lowercased() {
            hosts.insert(serverHost)

            if serverURL.scheme?.lowercased() == "http" {
                insecureHost = serverHost
            }
        }

        return XeniaWebNavigationPolicy(rule: .hosts(hosts, insecureHost: insecureHost, blockedPathFragments: loginBlockedPathFragments.map { $0.lowercased() }))
    }

    ///
    /// Whether the web view may perform `navigationAction`.
    ///
    @MainActor
    func allows(navigationAction: WKNavigationAction) -> Bool {
        allows(navigationAction.request.url, isMainFrame: navigationAction.targetFrame?.isMainFrame)
    }

    ///
    /// - Parameters:
    ///     - url: The navigation target.
    ///     - isMainFrame: `true` for the main frame, `false` for a subframe, `nil` when the target is a new window.
    ///
    @nonobjc
    func allows(_ url: URL?, isMainFrame: Bool?) -> Bool {
        switch isMainFrame {
        case .none:
            return false
        case .some(false):
            return true
        case .some(true):
            guard let url else {
                return false
            }

            return allowsMainFrame(url)
        }
    }

    @nonobjc
    func allowsMainFrame(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased(), let urlHost = url.host?.lowercased() else {
            return false
        }

        switch rule {
        case let .singlePage(host, path):
            return scheme == "https" && urlHost == host && Self.normalized(path: url.path) == path

        case let .hosts(hosts, insecureHost, blockedPathFragments):
            guard hosts.contains(urlHost) else {
                return false
            }

            guard scheme == "https" || (scheme == "http" && urlHost == insecureHost) else {
                return false
            }

            let urlPath = url.path.lowercased()
            return blockedPathFragments.allSatisfy { !urlPath.contains($0) }
        }
    }

    private static func normalized(path: String) -> String {
        var path = path

        while path.count > 1, path.hasSuffix("/") {
            path.removeLast()
        }

        return path.isEmpty ? "/" : path
    }
}
