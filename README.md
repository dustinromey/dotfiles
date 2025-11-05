# Niri-Omarchy Dotfiles

Personal dotfiles for niri window manager integrated with Omarchy.

## Quick Start

### On a New Machine

1. Install Omarchy: `bash <(curl -s https://omarchy.org/install)`
2. Clone this repo: `git clone <your-repo> ~/dotfiles`
3. Make scripts executable: `chmod +x ~/dotfiles/omarchy-hooks/.config/omarchy/hooks/* ~/dotfiles/omarchy-scripts/.local/share/omarchy/bin/*`
4. Deploy with stow: `cd ~/dotfiles && stow -t ~/ niri hypr waybar-niri omarchy-hooks omarchy-scripts environment`
5. Validate: `niri validate`
6. Log in to niri via ly display manager

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
