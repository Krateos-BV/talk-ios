#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2021 Nextcloud GmbH and Nextcloud contributors
# SPDX-License-Identifier: GPL-3.0-or-later

# generate-localizable-strings-file.sh

echo 'Generating Localizable.strings file...'

CURRENT_BRANCH=$(git branch --show-current)
STABLE_BRANCH=$(<.tx/backport)

if [[ "$CURRENT_BRANCH" != $STABLE_BRANCH && ! "$CURRENT_BRANCH" =~ ^backport/[[:digit:]]+/"$STABLE_BRANCH"$ ]]; then
  REMOTE_URL=$(git config --get remote.origin.url)
  if [ -z "$REMOTE_URL" ]; then
  	echo "No remote URL found. Please check your git config."
  	exit 1
  fi

  # The clone below exists so that genstrings (which scans ../, i.e. the repo root)
  # also picks up strings that live only on the stable branch. That assumes the
  # origin remote carries $STABLE_BRANCH. This fork does not: it keeps a single
  # branch, so the clone failed outright and took the whole check down with it —
  #   fatal: Remote branch stable23 not found in upstream origin
  # leaving main red from 2026-09-25T15:47Z and, worse, skipping the plural and
  # spell checks behind it. (XNT-226)
  #
  # Deliberately NOT repointed at upstream. Upstream's stable23 does carry the
  # branch, but cloning it here would fold UPSTREAM's strings — including
  # un-rebranded ones — into our generated Localizable.strings, which is worse
  # than having no stable coverage at all.
  #
  # Guarded rather than deleted, so this stays a no-op diff against upstream and
  # starts working again by itself if a stable branch is ever created here.
  if git ls-remote --exit-code --heads "$REMOTE_URL" "$STABLE_BRANCH" >/dev/null 2>&1; then
    echo "Not on $STABLE_BRANCH branch, cloning $STABLE_BRANCH branch"
    git clone --branch $STABLE_BRANCH --single-branch --depth 1 $REMOTE_URL $STABLE_BRANCH
    cd $STABLE_BRANCH
    git submodule update --init
    cd ..
  else
    echo "Branch '$STABLE_BRANCH' is not present in $REMOTE_URL - skipping it."
    echo "Generated strings will cover this branch only, which is correct for a"
    echo "fork that maintains no stable branch. Not an error; see XNT-226."
  fi

else
  echo "On $STABLE_BRANCH branch"
fi

cd NextcloudTalk
find ../ -name "*.swift" -print0 -or -name "*.m" -not -path "../Pods/*" -print0 | xargs -0 genstrings -o en.lproj -SwiftUI
iconv -f UTF-16 -t UTF-8 en.lproj/Localizable.strings > en.lproj/Localizable-utf8.strings
mv en.lproj/Localizable-utf8.strings en.lproj/Localizable.strings
cd ..
rm -rf "$STABLE_BRANCH"
echo 'Localizable.strings file generated!'
