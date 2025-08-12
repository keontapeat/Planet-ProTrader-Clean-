#!/usr/bin/env bash
set -euo pipefail

echo "=== Planet ProTrader (Clean) — Clean Build Locks ==="
echo "This will kill stray build processes, remove locked build DBs, and reset caches."

echo "1) Killing lingering build/index processes..."
pkill -9 -f "xcodebuild" || true
pkill -9 -f "SourceKitService" || true
pkill -9 -f "swift-frontend" || true
pkill -9 -f "swift-compile" || true
pkill -9 -f "swift-worker" || true
pkill -9 -f "clang" || true

DD=\"$HOME/Library/Developer/Xcode/DerivedData\"
APP_GLOB=\"Planet_ProTrader_(Clean)-*\"

echo "2) Removing locked build databases and intermediate build state..."
for P in \"$DD\"/$APP_GLOB; do
  if [ -d \"$P\" ]; then
    echo \"   - Cleaning: $P\"
    rm -rf \"$P/Build/Intermediates.noindex/XCBuildData\" || true
    rm -rf \"$P/Build/XCBuildData\" || true
    rm -f  \"$P/Build/Intermediates.noindex/XCBuildData\"/build.db* || true
    rm -rf \"$P/Index.noindex\" || true
    rm -rf \"$P/Logs\" || true

    echo \"   - Clearing SourcePackages artifacts/checkouts (forces a clean package resolve)\"
    rm -rf \"$P/SourcePackages/checkouts\" || true
    rm -rf \"$P/SourcePackages/repositories\" || true
    rm -rf \"$P/SourcePackages/artifacts\" || true
  fi
done

echo "3) Clearing global caches (SwiftPM + ModuleCache)..."
rm -rf \"$DD/ModuleCache.noindex\" || true
rm -rf \"$HOME/Library/Caches/org.swift.swiftpm\" || true
rm -rf \"$HOME/Library/org.swift.swiftpm\" || true
rm -rf \"$HOME/Library/Developer/Xcode/SourcePackages\" || true

echo "4) Clearing Simulator preview caches (harmless, helps with stale previews)..."
xcrun simctl --set previews delete all || true

echo "5) Optionally pre-resolve package dependencies if project is present..."
if [ -d \"./Planet ProTrader (Clean).xcodeproj\" ]; then
  echo \"   - Resolving packages for scheme 'Planet ProTrader (Clean)'\"
  xcodebuild -resolvePackageDependencies -project \"./Planet ProTrader (Clean).xcodeproj\" -scheme \"Planet ProTrader (Clean)\" >/dev/null || true
fi

echo \"\"
echo \"✅ Clean complete.\"
echo \"Next steps:\"
echo \"   1) Reopen Xcode\"
echo \"   2) File > Packages > Reset Package Caches\"
echo \"   3) Product > Clean Build Folder\"
echo \"   4) Build\"
echo \"If it still locks, reboot macOS to clear orphaned file handles.\"