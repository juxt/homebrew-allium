#!/usr/bin/env bash
#
# Reproduction harness for juxt/allium#42
# ---------------------------------------
# "homebrew MacOS upgrade to 3.3.0 fails:
#   Permission denied @ rb_check_realpath_internal - /Users/<you>/Documents"
#
# Root cause (from the reporter's --verbose --debug stack trace):
#   The allium formula ships NO bottle, so `brew install/upgrade` runs the
#   formula's `install` from source inside Homebrew's build sandbox
#   (FormulaInstaller#build). On macOS Tahoe the sandbox's
#   Sandbox#deny_read_home enumerates the user's home subfolders and calls
#   Pathname#realpath on each to build deny-read rules. `~/Documents` is
#   TCC-protected; if the terminal lacks access, realpath returns EPERM and the
#   whole upgrade aborts. Independent of cwd and of HOMEBREW_* dir overrides.
#
# Fix: ship bottles so Homebrew POURS a prebuilt package (#pour_bottle) instead
# of running #build — the sandbox / deny_read_home / realpath path is never
# entered.
#
# This script has two tiers:
#   tier1  Deterministic, no TCC changes. Proves un-bottled => build (enters the
#          sandbox) and bottled => pour (skips it). This verifies the FIX.
#   tier2  The literal rb_check_realpath_internal error. Requires a one-time
#          manual TCC denial (GUI), since only TCC produces the
#          "exist? == true but realpath == EPERM" state. Run on a terminal you
#          are willing to deny Documents access to.
#
# Usage:  ./repro-homebrew-sandbox.sh tier1
#         ./repro-homebrew-sandbox.sh tier2
set -uo pipefail

TAP="local/sbxrepro"
FORMULA="reprotool"
WORK="$(mktemp -d)"

cleanup() {
  brew uninstall --force "$FORMULA" >/dev/null 2>&1 || true
  brew untap "$TAP" >/dev/null 2>&1 || true
  rm -rf ~/Library/Logs/Homebrew/"$FORMULA" "$WORK"
}
trap cleanup EXIT

preflight() {
  [[ "$(uname)" == "Darwin" ]] || { echo "macOS only"; exit 2; }
  command -v brew >/dev/null || { echo "Homebrew required"; exit 2; }
  echo "macOS $(sw_vers -productVersion) | $(brew --version | head -1) | sandbox-exec: $([[ -x /usr/bin/sandbox-exec ]] && echo present || echo MISSING)"
}

write_formula() {
  local with_bottle="$1" sha="${2:-}"
  local dir; dir="$(brew --repo "$TAP")/Formula"; mkdir -p "$dir"
  {
    echo "class Reprotool < Formula"
    echo "  desc \"Scratch formula for the Homebrew build-sandbox repro\""
    echo "  homepage \"https://example.invalid/reprotool\""
    echo "  url \"file:///dev/null\""
    echo "  version \"1.0\""
    if [[ "$with_bottle" == "yes" ]]; then
      echo "  bottle do"
      echo "    root_url \"file://$WORK\""
      echo "    sha256 cellar: :any_skip_relocation, arm64_tahoe: \"$sha\""
      echo "  end"
    fi
    echo "  def install"
    echo "    (bin/\"reprotool\").write \"#!/bin/sh\\necho reprotool ok\\n\""
    echo "    chmod 0755, bin/\"reprotool\""
    echo "  end"
    echo "end"
  } > "$dir/$FORMULA.rb"
}

# A build (def install in the sandbox) writes 00.options.out into the formula's
# log dir; a pour never runs def install, so the log dir stays empty/absent.
built_from_source() { [[ -f ~/Library/Logs/Homebrew/"$FORMULA"/00.options.out ]]; }

tier1() {
  preflight
  brew tap-new "$TAP" >/dev/null 2>&1 || true

  echo; echo "## A. Un-bottled  -> expect BUILD (enters sandbox / deny_read_home)"
  write_formula no
  brew uninstall --force "$FORMULA" >/dev/null 2>&1; rm -rf ~/Library/Logs/Homebrew/"$FORMULA"
  brew install --formula "$TAP/$FORMULA" 2>&1 | grep -E "Installing|Pouring|built in" || true
  built_from_source && echo "PASS: ran #build (00.options.out present) -> deny_read_home path" \
                    || { echo "UNEXPECTED: no build artifact"; exit 1; }

  echo; echo "## Bottle the formula"
  brew uninstall --force "$FORMULA" >/dev/null 2>&1
  brew install --build-bottle --formula "$TAP/$FORMULA" >/dev/null 2>&1
  ( cd "$WORK" && brew bottle --json --no-rebuild "$TAP/$FORMULA" >/dev/null 2>&1 )
  local sha; sha="$(shasum -a 256 "$WORK"/${FORMULA}--1.0.*.bottle.tar.gz | awk '{print $1}')"
  # Homebrew fetches the single-dash remote name from root_url:
  cp "$WORK"/${FORMULA}--1.0.arm64_tahoe.bottle.tar.gz "$WORK"/${FORMULA}-1.0.arm64_tahoe.bottle.tar.gz

  echo; echo "## B. Bottled  -> expect POUR (skips #build entirely)"
  write_formula yes "$sha"
  brew uninstall --force "$FORMULA" >/dev/null 2>&1; rm -rf ~/Library/Logs/Homebrew/"$FORMULA"
  brew install --formula "$TAP/$FORMULA" 2>&1 | grep -E "Installing|Pouring|built in" || true
  built_from_source && { echo "UNEXPECTED: bottled install still built"; exit 1; } \
                    || echo "PASS: poured, #build never ran -> deny_read_home never reached"

  echo; echo "RESULT: bottling moves the install off the source-build sandbox path. Fix verified."
}

probe_denied() {
  ruby -e 'require "pathname"; begin; Pathname.new(File.expand_path("~/Documents")).realpath; exit 1; rescue Errno::EPERM; exit 0; rescue; exit 1; end'
}

tier2() {
  preflight
  if ! probe_denied; then
    cat <<'EOS'

Documents access is NOT currently denied for this terminal, so the literal
error cannot be reproduced yet. To set up the denial (do this in a terminal you
are willing to restrict; TCC is keyed to the GUI app, so fully Cmd-Q + relaunch):

  tccutil reset SystemPolicyDocumentsFolder <terminal-bundle-id>
    # Terminal.app -> com.apple.Terminal ; iTerm2 -> com.googlecode.iterm2

Then quit and relaunch that terminal; at the "would like to access files in
your Documents folder" prompt click "Don't Allow". Re-run: tier2

To revert afterwards:
  tccutil reset SystemPolicyDocumentsFolder <terminal-bundle-id>
  # relaunch and click Allow (or grant Full Disk Access in System Settings)
EOS
    exit 0
  fi

  echo "Documents denial is ACTIVE (realpath ~/Documents -> EPERM). Reproducing..."
  brew tap-new "$TAP" >/dev/null 2>&1 || true
  write_formula no
  brew uninstall --force "$FORMULA" >/dev/null 2>&1
  if brew install --formula "$TAP/$FORMULA" 2>&1 | tee "$WORK/out.log" | grep -q "rb_check_realpath_internal"; then
    echo "PASS: reproduced -> $(grep rb_check_realpath_internal "$WORK/out.log" | head -1)"
  else
    echo "Did not reproduce (see $WORK/out.log) — denial may not cover the iterated dirs."
  fi
}

case "${1:-tier1}" in
  tier1) tier1 ;;
  tier2) tier2 ;;
  *) echo "usage: $0 [tier1|tier2]"; exit 2 ;;
esac
