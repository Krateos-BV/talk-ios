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

<<<<<<< HEAD
=======
Pull Requests will be checked with [SwiftLint](https://github.com/realm/SwiftLint). We strongly encourage the installation of SwiftLint to detect issues as early as possible.

## Run the project

Depending on how you try to run the project, you'll notice that it's not running "as-is". There are a few steps to make it work with your developer account:

1. The project contains multiple targets (currently `NextcloudTalk`, `ShareExtension` and `NotificationServiceExtension`). The bundle ids of those targets start with `com.nextcloud.Talk` which can't be used outside of Nextcloud GmbH. To run the project, change all bundle ids to something that's allowed for your developer account: `com.<yourname>.Talk`.
2. To communicate between the main app and its extensions, app groups are used. The group identifier for NextcloudTalk is set to `group.com.nextcloud.Talk`, with the same restriction as above. Change the group identifier of all targets to `group.com.<yourname>.Talk`.
3. Open the file `NCAppBranding.m` (can be found in XCode under NextcloudTalk -> Settings) and change `bundleIdentifier` and `groupIdentifier` to the same values you used in 1. and 2.
4. Run the project

## Contributing to Source Code

Thanks for wanting to contribute source code to the Talk iOS app. That's great! 🎉

Please read the [Code of Conduct](https://nextcloud.com/community/code-of-conduct/). This document offers some guidance to ensure Nextcloud participants can cooperate effectively in a positive and inspiring atmosphere, and to explain how together we can strengthen and support each other.

For more information please review the [guidelines for contributing](https://github.com/nextcloud/server/blob/main/.github/CONTRIBUTING.md) to this repository.

## How to contribute

1. 🐛 [Pick a good first issue](https://github.com/nextcloud/talk-ios/labels/good%20first%20issue) or any issue/feature you like to work on
2. 👩‍🔧 Create a branch and make your changes. Remember to sign off your commits using `git commit -sm "Your commit message"`
3. ⬆ Create a [pull request](https://opensource.guide/how-to-contribute/#opening-a-pull-request) and `@mention` the people from the issue to review
4. 👍 Fix things that come up during a review
5. 🎉 Wait for it to get merged!

You got stuck while working on a issue or need some pointers? Feel free to ask in the corresponding issue or in [our public Talk team conversation](https://cloud.nextcloud.com/call/c7fz9qpr), we're happy to help.

## WebRTC library

We are using our own builds of the WebRTC library. They can be found in this [repository](https://github.com/nextcloud-releases/talk-clients-webrtc).

Current version: [155.8059.0](https://github.com/nextcloud-releases/talk-clients-webrtc/releases/tag/155.8059.0).

>>>>>>> upstream/main
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
