# Niri-Omarchy Dotfiles

Personal dotfiles for niri window manager integrated with Omarchy.

## Quick Start

### On a New Machine

1. **Install base system:**
   ```bash
   sudo pacman -Syu
   sudo pacman -S git stow
   bash <(curl -s https://omarchy.org/install)
   ```

2. **Install niri and dependencies:**
   ```bash
   sudo pacman -S niri ly waybar mako swayosd swaybg \
                  hyprpicker dolphin kvantum elephant \
                  walker cliphist wl-clipboard playerctl ghostty
   sudo systemctl enable ly.service
   ```

3. **Clone and deploy dotfiles:**
   ```bash
   git clone git@github.com:dustinromey/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   chmod +x omarchy-hooks/.config/omarchy/hooks/*
   chmod +x omarchy-scripts/.local/share/omarchy/bin/*
   stow -t ~/ niri hypr waybar-niri omarchy-hooks omarchy-scripts environment
   ```

4. **Validate and reboot:**
   ```bash
   niri validate
   # Log out and select niri from ly display manager
   ```

See `SETUP.md` for detailed instructions.

## Structure

- `niri/` - Niri window manager config
- `hypr/` - Hyprland config overrides
- `waybar-niri/` - Waybar config for niri
- `omarchy-hooks/` - Custom Omarchy hooks
- `omarchy-scripts/` - Custom Omarchy scripts
- `environment/` - Environment variables

## Documentation

- `SETUP.md` - Complete setup guide
- `CLAUDE.md` - Architecture documentation
- `files-adjusted.md` - List of all modified files
