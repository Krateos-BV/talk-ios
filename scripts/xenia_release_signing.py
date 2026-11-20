#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Krateos B.V.
# SPDX-License-Identifier: GPL-3.0-or-later
"""Switch the Release configs of the shipping targets to manual App Store signing.

Used by xenia-release.yml right before Archive, on the runner's checkout only:
the committed project keeps automatic signing for Debug and local builds.

Why: automatic signing makes Xcode create an Apple Development certificate on every
fresh runner, and the team hit Apple's certificate limit (XEN-381, run 44792903681).
Manual signing with the Distribution certificate and the App Store profiles that
Export already uses needs no new certificate.
"""
import re
import sys

PROFILES = {
    "NextcloudTalk": "Xenia Talk App Store",
    "TalkIntents": "Xenia Talk Intents App Store",
    "BroadcastUploadExtension": "Xenia Talk BroadcastUploadExtension App Store",
    "ShareExtension": "Xenia Talk ShareExtension App Store",
    "NotificationServiceExtension": "Xenia Talk NotificationServiceExtension App Store",
}

SIGNING_KEYS = re.compile(
    r'^\s*("?CODE_SIGN_STYLE"?|"?CODE_SIGN_IDENTITY(\[sdk=[^\]]*\])?"?|"?PROVISIONING_PROFILE_SPECIFIER(\[sdk=[^\]]*\])?"?|"?PROVISIONING_PROFILE"?)\s*=.*;\s*$'
)


def release_config_ids(project: str) -> dict:
    ids = {}
    pattern = re.compile(
        r'/\* Build configuration list for PBXNativeTarget "([^"]+)" \*/ = \{\s*isa = XCConfigurationList;\s*buildConfigurations = \(([^)]*)\)'
    )
    for match in pattern.finditer(project):
        release = re.search(r'(\w{24}) /\* Release \*/', match.group(2))
        if release:
            ids[match.group(1)] = release.group(1)
    return ids


def patch(project: str) -> str:
    ids = release_config_ids(project)
    for target, profile in PROFILES.items():
        config_id = ids.get(target)
        if not config_id:
            sys.exit(f"Release configuration for target {target} not found")

        start = project.find(f"{config_id} /* Release */ = {{")
        settings_start = project.find("buildSettings = {", start)
        settings_end = project.find("\n\t\t\t};", settings_start)
        if start < 0 or settings_start < 0 or settings_end < 0:
            sys.exit(f"buildSettings for target {target} not found")

        body = project[settings_start:settings_end].split("\n")
        body = [line for line in body if not SIGNING_KEYS.match(line)]
        body += [
            "\t\t\t\tCODE_SIGN_STYLE = Manual;",
            '\t\t\t\tCODE_SIGN_IDENTITY = "Apple Distribution";',
            '\t\t\t\t"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "Apple Distribution";',
            f'\t\t\t\tPROVISIONING_PROFILE_SPECIFIER = "{profile}";',
        ]
        project = project[:settings_start] + "\n".join(body) + project[settings_end:]
    return project


if __name__ == "__main__":
    path = sys.argv[1] if len(sys.argv) > 1 else "NextcloudTalk.xcodeproj/project.pbxproj"
    with open(path, encoding="utf-8") as handle:
        original = handle.read()
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(patch(original))
    print(f"Manual App Store signing set for {', '.join(PROFILES)}")
