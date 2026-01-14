#!/bin/zsh
set -euo pipefail

repo_root="$(cd "$(dirname "${0}")/.." && pwd)"
plist_path="${HOME}/Library/LaunchAgents/com.wmanager.app.plist"
log_dir="${HOME}/Library/Logs"
app_path="${APP_PATH:-/Applications/WManager.app}"
bin_path="${app_path}/Contents/MacOS/WManager"

if [[ ! -x "${bin_path}" ]]; then
    if [[ -x "${repo_root}/scripts/build-app.sh" ]]; then
        "${repo_root}/scripts/build-app.sh"
        app_path="${repo_root}/build/WManager.app"
        bin_path="${app_path}/Contents/MacOS/WManager"
    fi
fi

if [[ ! -x "${bin_path}" ]]; then
    echo "WManager.app not found. Set APP_PATH or move the app to /Applications."
    exit 1
fi

mkdir -p "${log_dir}"

cat > "${plist_path}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.wmanager.app</string>
    <key>ProgramArguments</key>
    <array>
        <string>${bin_path}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${log_dir}/WManager.app.out.log</string>
    <key>StandardErrorPath</key>
    <string>${log_dir}/WManager.app.err.log</string>
</dict>
</plist>
EOF

launchctl unload "${plist_path}" >/dev/null 2>&1 || true
launchctl load "${plist_path}"
echo "Installed and loaded ${plist_path}"
