#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

dnf5 install -y dnf5-plugins

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

# Don't leave third-party COPRs enabled in the deployed image
dnf5 copr disable -y scottames/awww
dnf5 copr disable -y tofik/nwg-shell
dnf5 copr disable -y hermitfeather/hyprland

systemctl enable podman.socket
