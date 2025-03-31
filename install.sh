#!/bin/bash

# Paths for installation
INSTALL_DIR="$HOME/.local/bin"
ICON_DIR="$HOME/.local/share/icons/samsung_platform_profile_monitor"
SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_PATH="$SERVICE_DIR/samsung_platform_profile_monitor.service"
SCRIPT_PATH="$INSTALL_DIR/samsung_platform_profile_monitor.sh"

# Ensure the script is not run as root
if [[ "$EUID" -eq 0 ]]; then
    echo "This script must be run as a normal user, not root or with sudo."
    exit 1
fi

install() {
    echo "Installing Samsung Platform Profile Monitor..."

    # Create necessary directories
    mkdir -p "$INSTALL_DIR" "$ICON_DIR" "$SERVICE_DIR"

    # Download script and icons
    if ! curl -sSL "https://raw.githubusercontent.com/kity-linuxero/samsung-profile-monitor/refs/heads/main/samsung_profile_monitor.sh" -o "$SCRIPT_PATH"; then
        echo "Error: Failed to download script. Installation aborted."
        uninstall
        exit 1
    fi
    chmod +x "$SCRIPT_PATH"

    for i in {0..3}; do
        if ! curl -sSL "https://github.com/kity-linuxero/samsung-profile-monitor/blob/main/icons/$i.png?raw=true" -o "$ICON_DIR/$i.png"; then
            echo "Error: Failed to download icon $i. Installation aborted."
            uninstall
            exit 1
        fi
    done

    # Create systemd user service file
    cat > "$SERVICE_PATH" << EOF
[Unit]
Description=Samsung Platform Profile Monitor
After=graphical.target

[Service]
ExecStartPre=/bin/sleep 10
ExecStart=$SCRIPT_PATH
Restart=always
Environment=DISPLAY=:0
Environment=XDG_RUNTIME_DIR=/run/user/$(id -u)

[Install]
WantedBy=default.target
EOF

    # Reload systemd, enable and start the service
    systemctl --user daemon-reload
    if ! systemctl --user enable samsung_platform_profile_monitor.service; then
        echo "Error: Failed to enable systemd service. Installation aborted."
        uninstall
        exit 1
    fi
    if ! systemctl --user start samsung_platform_profile_monitor.service; then
        echo "Error: Failed to start systemd service. Installation aborted."
        uninstall
        exit 1
    fi

    echo "Installation complete. The Samsung platform profile monitor will now start automatically."
}

uninstall() {
    echo "Uninstalling Samsung Platform Profile Monitor..."
    
    # Stop and disable service
    systemctl --user stop samsung_platform_profile_monitor.service 2>/dev/null
    systemctl --user disable samsung_platform_profile_monitor.service 2>/dev/null

    # Remove files
    rm -f "$SCRIPT_PATH"
    rm -rf "$ICON_DIR"
    rm -f "$SERVICE_PATH"

    # Reload systemd
    systemctl --user daemon-reload
    
    echo "Uninstallation complete. The Samsung platform profile monitor has been removed."
}

# Check for arguments
if [[ "$1" == "--uninstall" ]]; then
    uninstall
else
    install
fi
