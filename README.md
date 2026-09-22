<!--
  - SPDX-FileCopyrightText: 2017 Nextcloud GmbH and Nextcloud contributors
  - SPDX-FileCopyrightText: 2026 XeniaCloud
  - SPDX-License-Identifier: GPL-3.0-or-later
-->
# Xenia Talk

[![REUSE status](https://api.reuse.software/badge/github.com/Krateos-BV/talk-ios)](https://api.reuse.software/info/github.com/Krateos-BV/talk-ios)

> Independently maintained iOS client for Xenia Talk, based on the [Nextcloud Talk iOS app](https://github.com/nextcloud/talk-ios) (GPLv3, with the Apple App Store exception below). Not affiliated with or endorsed by Nextcloud GmbH.

**Video & audio calls and chat through XeniaCloud on iOS**

Xenia Talk is a fully on-premises audio/video and chat communication service. It features web and mobile apps and is designed to offer the highest degree of security while being easy to use.

Xenia Talk lowers the barrier for communication and lets your team connect any time, any where, on any device, with each other, customers or partners.

## Getting help

This is an independently maintained fork — the upstream Nextcloud Talk community channels, forum, and issue tracker are for the Nextcloud app, not Xenia Talk, and won't be able to help with anything specific to this fork or to a XeniaCloud account. For support with Xenia Talk or your XeniaCloud account, contact XeniaCloud support directly.

Keep in mind that this repository only manages the iOS app. Server/backend issues should go through XeniaCloud support, not the Nextcloud project.

## Development version

This fork is not currently distributed via the App Store, TestFlight, or GitHub Releases. Builds are produced by this repository's own CI as unsigned artifacts.

## Development setup

After cloning this repository, you can use `pod install` to install all dependencies. After that, open the project with `open NextcloudTalk.xcworkspace`.

## Running tests locally

The tests included in this repository require a running Nextcloud instance. To run this locally, make sure you have a working docker environment and run the file `start-instance-for-tests.sh` - this will install a Nextcloud instance, install Nextcloud Talk and wait for everything to be up and running.
After that you can run the tests directly from Xcode or alternatively from the command line you can use:

```
xcodebuild test -workspace NextcloudTalk.xcworkspace \
    -scheme "NextcloudTalk" \
    -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5" \
    -test-iterations 3 \
    -retry-tests-on-failure
```

## Push notifications

If you are experiencing problems with push notifications, please check this [document](docs/notifications.md) to detect possible issues.

## Upstream & license

Xenia Talk is a rebrand of [nextcloud/talk-ios](https://github.com/nextcloud/talk-ios), forked under its [GPLv3 license, with an Apple App Store exception](https://github.com/nextcloud/talk-ios/blob/main/COPYING.iOS), which permits forking provided Nextcloud's own trademarks and branding are not carried over — the app name, icon, and accent colors here have been changed accordingly; the underlying code and functionality are otherwise unchanged from upstream unless noted in this fork's own commit history.

## WebRTC library

We are using our own builds of the WebRTC library, produced by upstream Nextcloud. They can be found in [this repository](https://github.com/nextcloud-releases/talk-clients-webrtc).

## Credits

### Ringtones

- [Telefon-Freiton in Deutschland nach DTAG 1 TR 110-1, Kap. 8.3](https://commons.wikimedia.org/wiki/File:1TR110-1_Kap8.3_Freiton1.ogg)
  author: arvedkrynil
