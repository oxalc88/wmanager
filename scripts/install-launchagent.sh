#!/bin/zsh
set -euo pipefail

repo_root="$(cd "$(dirname "${0}")/.." && pwd)"
plist_path="${HOME}/Library/LaunchAgents/com.wmanager.plist"
log_dir="${HOME}/Library/Logs"
bin_path="${repo_root}/.build/release/WManager"

mkdir -p "${log_dir}"
swift build -c release

cat > "${plist_path}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.wmanager</string>
    <key>ProgramArguments</key>
    <array>
        <string>${bin_path}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${log_dir}/WManager.out.log</string>
    <key>StandardErrorPath</key>
    <string>${log_dir}/WManager.err.log</string>
</dict>
</plist>
EOF

launchctl unload "${plist_path}" >/dev/null 2>&1 || true
launchctl load "${plist_path}"
echo "Installed and loaded ${plist_path}"
