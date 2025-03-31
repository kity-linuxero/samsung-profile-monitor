#!/bin/bash

# Paths for installation
INSTALL_DIR="/usr/local/bin"
ICON_DIR="/usr/share/icons/samsung_platform_profile"
SERVICE_PATH="/etc/systemd/system/samsung_platform_profile_monitor.service"
SCRIPT_PATH="$INSTALL_DIR/samsung_platform_profile_monitor.sh"

install() {
    echo "Installing Samsung Platform Profile Monitor..."

    # Create necessary directories
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$ICON_DIR"

    # Download script and icons
    curl -sSL "https://raw.githubusercontent.com/kity-linuxero/samsung-profile-monitor/refs/heads/main/samsung_profile_monitor.sh" -o "$SCRIPT_PATH"
    curl -sSL "https://github.com/kity-linuxero/samsung-profile-monitor/blob/797e6a640304681fa289d7c29f58d7624a95e272/icons/0.png" -o "$ICON_DIR/0.png"
    curl -sSL "https://github.com/kity-linuxero/samsung-profile-monitor/blob/797e6a640304681fa289d7c29f58d7624a95e272/icons/1.png" -o "$ICON_DIR/1.png"
    curl -sSL "https://github.com/kity-linuxero/samsung-profile-monitor/blob/797e6a640304681fa289d7c29f58d7624a95e272/icons/2.png" -o "$ICON_DIR/2.png"
    curl -sSL "https://github.com/kity-linuxero/samsung-profile-monitor/blob/797e6a640304681fa289d7c29f58d7624a95e272/icons/3.png" -o "$ICON_DIR/3.png"

    # Make script executable
    chmod +x "$SCRIPT_PATH"

    # Create systemd service file
    cat > "$SERVICE_PATH" << EOF
[Unit]
Description=Samsung Platform Profile Monitor
After=graphical.target

[Service]
ExecStartPre=/bin/sleep 30
ExecStart=$SCRIPT_PATH
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd, enable and start the service
    systemctl daemon-reload
    systemctl enable samsung_platform_profile_monitor.service
    systemctl start samsung_platform_profile_monitor.service

    echo "Installation complete. The Samsung platform profile monitor will now start automatically."
}

uninstall() {
    echo "Uninstalling Samsung Platform Profile Monitor..."

    # Stop and disable service
    systemctl stop samsung_platform_profile_monitor.service
    systemctl disable samsung_platform_profile_monitor.service

    # Remove files
    rm -f "$SCRIPT_PATH"
    rm -rf "$ICON_DIR"
    rm -f "$SERVICE_PATH"

    # Reload systemd
    systemctl daemon-reload

    echo "Uninstallation complete. The Samsung platform profile monitor has been removed."
}

# Check for arguments
if [[ "$1" == "--uninstall" ]]; then
    uninstall
else
    install
fi
