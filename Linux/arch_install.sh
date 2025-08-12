#!/usr/bin/env bash
# Arch + Hyprland setup (Hyprland, PipeWire, apps: firefox, chrome, vscode, obsidian, tor, spotify, signal)
# Run as a regular user with sudo privileges.

set -euo pipefail

confirm() { read -rp "$1 [y/N]: " a; [[ "${a:-}" =~ ^[Yy]$ ]]; }
have() { command -v "$1" >/dev/null 2>&1; }

# ---- System prep ----
sudo sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf || true
sudo pacman -Syu --needed --noconfirm

# ---- Base / essentials ----
sudo pacman -S --needed --noconfirm base-devel linux-headers networkmanager \
  git wget curl unzip zip p7zip tar xz \
  xorg-xwayland wl-clipboard grim slurp swappy \
  waybar rofi-wayland swaylock-effects swayidle dunst \
  xdg-desktop-portal-hyprland \
  alacritty thunar thunar-archive-plugin gvfs \
  pipewire pipewire-alsa pipewire-pulse wireplumber pavucontrol \
  ttf-jetbrains-mono ttf-fira-code noto-fonts noto-fonts-emoji \
  lxappearance qt5ct qt6ct \
  neovim trash-cli ufw gufw timeshift \
  hyprland firefox obsidian signal-desktop torbrowser-launcher mesa

sudo systemctl enable --now NetworkManager
sudo systemctl enable --now ufw || true

# ---- GPU drivers (auto-detect; override by exporting GPU=amd|nvidia|intel) ----
GPU="${GPU:-auto}"
if [[ "$GPU" == "auto" ]]; then
  if lspci | grep -qi 'NVIDIA\|GeForce'; then GPU=nvidia
  elif lspci | grep -qi 'AMD/ATI'; then GPU=amd
  elif lspci | grep -qi 'Intel'; then GPU=intel
  else GPU=intel
  fi
fi

case "$GPU" in
  nvidia)
    sudo pacman -S --needed --noconfirm nvidia nvidia-utils nvidia-settings
    ;;
  amd)
    sudo pacman -S --needed --noconfirm xf86-video-amdgpu
    ;;
  intel)
    sudo pacman -S --needed --noconfirm intel-media-driver
    ;;
esac

# ---- AUR helper (yay) ----
if ! have yay; then
  tmpdir="$(mktemp -d)"
  pushd "$tmpdir"
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  popd
  rm -rf "$tmpdir"
fi

# ---- Apps from AUR: Chrome, VS Code (MS build), Spotify ----
yay -S --needed --noconfirm google-chrome visual-studio-code-bin spotify

# ---- Optional: flatpak support (skip if you don't want it) ----
if confirm "Install Flatpak support (optional)?"; then
  sudo pacman -S --needed --noconfirm flatpak xdg-desktop-portal xdg-desktop-portal-gtk
fi

# ---- Autostart Hyprland on TTY1 ----
shell_profile=""
if [[ -n "${ZSH_VERSION:-}" ]]; then shell_profile="$HOME/.zprofile"; else shell_profile="$HOME/.bash_profile"; fi
if ! grep -q 'exec Hyprland' "$shell_profile" 2>/dev/null; then
  cat >> "$shell_profile" <<'EOF'

# Auto-start Hyprland on first TTY
if [[ -z "$DISPLAY" && "${TTY:-$(tty)}" == "/dev/tty1" ]]; then
  exec Hyprland
fi
EOF
fi

# ---- Wayland-friendly defaults ----
mkdir -p "$HOME/.config/environment.d"
cat > "$HOME/.config/environment.d/wayland.conf" <<'EOF'
# Wayland env
MOZ_ENABLE_WAYLAND=1
QT_QPA_PLATFORM=wayland
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
XDG_CURRENT_DESKTOP=Hyprland
XDG_SESSION_TYPE=wayland
GDK_BACKEND=wayland
EOF

# ---- Done ----
echo "OK"
