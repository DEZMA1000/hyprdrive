#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

dnf5 install -y dnf5-plugins

# Build dependencies for razerctl
dnf5 install -y \
    git \
    gcc \
    make

# Hyprland ecosystem
dnf5 copr enable -y hermitfeather/hyprland

# GUI display configuration
dnf5 copr enable -y tofik/nwg-shell

# Animated wallpaper daemon
dnf5 copr enable -y scottames/awww

dnf5 install -y \
    hyprland \
    hyprland-guiutils \
    hyprpolkitagent \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    SwayNotificationCenter \
    uwsm \
    rofi \
    waybar \
    awww \
    hypridle \
    hyprlock \
    nwg-displays \
    wl-clipboard \
    cliphist \
    grim \
    slurp \
    swappy \
    brightnessctl \
    playerctl \
    pavucontrol \
    jq \
    ImageMagick \
    pamixer \
    socat \
    rsync \
    yad \
    xdg-utils \
    xdg-user-dirs

### Razer Blade control

# Pin to known-good revision tested on this Blade 16
RAZERCTL_COMMIT="7a8980671cfce1abe7f37405071509c04385fc04"

git clone \
    https://github.com/TimandXiyu/blade-cli.git \
    /tmp/blade-cli

git -C /tmp/blade-cli checkout "$RAZERCTL_COMMIT"

make -C /tmp/blade-cli

# Install into immutable image-owned paths
install -Dm755 \
    /tmp/blade-cli/razerctl \
    /usr/bin/razerctl

install -Dm755 \
    /tmp/blade-cli/razerctld \
    /usr/bin/razerctld

install -Dm644 \
    /tmp/blade-cli/razerctl.1 \
    /usr/share/man/man1/razerctl.1

# Install systemd unit into vendor unit directory
install -Dm644 \
    /tmp/blade-cli/razerctld.service \
    /usr/lib/systemd/system/razerctld.service

# Upstream service expects /usr/local/bin.
# Hyprdrive installs razerctld into /usr/bin instead.
sed -i \
    's|ExecStart=/usr/local/bin/razerctld|ExecStart=/usr/bin/razerctld|' \
    /usr/lib/systemd/system/razerctld.service

# Restore Blade settings after suspend/resume
install -Dm755 \
    /tmp/blade-cli/zz-razerctld-resume \
    /usr/lib/systemd/system-sleep/zz-razerctld-resume

systemctl enable razerctld.service

rm -rf /tmp/blade-cli

# Don't leave third-party COPRs enabled in the deployed image
dnf5 copr disable -y scottames/awww
dnf5 copr disable -y tofik/nwg-shell
dnf5 copr disable -y hermitfeather/hyprland

systemctl enable podman.socket
