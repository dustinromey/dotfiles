# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains a working directory for configuring the niri window manager to work with Omarchy, a beautiful, modern Linux distribution by DHH. The `omarchy/` folder contains the source code for the Omarchy distribution itself.

## Omarchy Architecture

### Core Installation System

Omarchy uses a modular installation system located in `omarchy/install/`:
- `boot.sh` - Initial installation entry point (clones repo, sets install mode)
- `install.sh` - Main orchestrator that sources all installation modules
- `install/helpers/` - Utility functions used throughout installation
- `install/preflight/` - Pre-installation checks
- `install/packaging/` - Package installation logic
- `install/config/` - System and application configuration
- `install/login/` - Display manager and login configuration
- `install/post-install/` - Final setup steps
I'm looking to configure a laptop with Niri Window Manager
### Path and Environment Setup

**Critical**: Omarchy sets PATH and environment through multiple layers:
1. `~/.local/share/omarchy/bin` is added to PATH (131 utility scripts)
2. `omarchy/default/bash/rc` sources shell configuration in order:
   - `shell` - History, completion, hash settings
   - `aliases` - Command aliases
   - `functions` - Shell functions
   - `prompt` - Prompt configuration
   - `init` - Tool initialization (mise, starship, zoxide, fzf)
   - `envs` - Environment variables
3. User's `~/.bashrc` sources `~/.local/share/omarchy/default/bash/rc`

**PATH Issues with Display Managers**: The ly display manager may not properly inherit the Omarchy PATH. The `~/.local/share/omarchy/bin` directory must be in PATH for all Omarchy commands to work.

### Theme System

Themes are located in `omarchy/themes/` with 12 available themes:
- catppuccin, catppuccin-latte, everforest, flexoki-light
- gruvbox, kanagawa, matte-black, nord
- osaka-jade, ristretto, rose-pine, tokyo-night

Theme management:
- `omarchy-theme-set <theme>` - Switch themes (updates symlink at `~/.config/omarchy/current/theme`)
- `omarchy-theme-bg-next` - Cycle backgrounds within a theme
- Theme switching restarts: waybar, swayosd, hyprland, btop, mako, and updates terminal, gnome, browser, vscode, cursor, obsidian themes

### Hyprland Configuration Structure

Omarchy's Hyprland config (`omarchy/config/hypr/hyprland.conf`) sources configs in this order:
1. **Omarchy defaults** (read-only, don't edit):
   - `default/hypr/autostart.conf` - Apps to launch on startup
   - `default/hypr/bindings/media.conf` - Media key bindings
   - `default/hypr/bindings/clipboard.conf` - Clipboard bindings
   - `default/hypr/bindings/tiling-v2.conf` - Window/workspace management
   - `default/hypr/bindings/utilities.conf` - Utility keybinds (menus, aesthetics, captures)
   - `default/hypr/envs.conf` - Wayland environment variables
   - `default/hypr/looknfeel.conf` - Visual settings
   - `default/hypr/input.conf` - Input device configuration
   - `default/hypr/windows.conf` - Window rules
   - Theme-specific: `~/.config/omarchy/current/theme/hyprland.conf`

2. **User overrides** (edit these):
   - `~/.config/hypr/monitors.conf`
   - `~/.config/hypr/input.conf`
   - `~/.config/hypr/bindings.conf`
   - `~/.config/hypr/envs.conf`
   - `~/.config/hypr/looknfeel.conf`
   - `~/.config/hypr/autostart.conf`

### Key Omarchy Keybinds (from tiling-v2.conf and utilities.conf)

**Window Management:**
- `SUPER+W` - Close window
- `SUPER+T` - Toggle floating/tiling
- `SUPER+F` - Fullscreen
- `SUPER+S` - Toggle scratchpad
- Arrow keys with SUPER - Move focus
- Arrow keys with SUPER+SHIFT - Swap windows
- `SUPER+[1-9]` - Switch workspace
- `SUPER+SHIFT+[1-9]` - Move window to workspace

**Utilities:**
- `SUPER+SPACE` - Launch Walker (app launcher)
- `SUPER+ALT+SPACE` - Omarchy menu
- `SUPER+ESCAPE` - System menu
- `SUPER+K` - Show key bindings
- `SUPER+SHIFT+SPACE` - Toggle waybar
- `SUPER+CTRL+SPACE` - Next background
- `SUPER+SHIFT+CTRL+SPACE` - Theme menu
- `PRINT` - Screenshot with editing
- `SUPER+CTRL+S` - Share menu

### Walker App Launcher

Walker is Omarchy's application launcher (config: `omarchy/config/walker/config.toml`):
- Launched via `omarchy-launch-walker` (ensures elephant backend is running)
- Requires `elephant` service running (provides search capabilities)
- Supports prefixes: `/` (providers), `.` (files), `:` (symbols), `=` (calc), `@` (websearch), `$` (clipboard)
- Theme location: `~/.local/share/omarchy/default/walker/themes/`

### Waybar Configuration

Waybar config is at `omarchy/config/waybar/`:
- `config.jsonc` - Main configuration
- `style.css` - Styling
- `omarchy-toggle-waybar` - Toggle visibility
- `omarchy-restart-waybar` - Restart after theme changes

### Omarchy Utility Scripts

All in `omarchy/bin/` (131 scripts total). Key scripts:
- **Theme**: `omarchy-theme-set`, `omarchy-theme-bg-next`, `omarchy-theme-set-*`
- **Commands**: `omarchy-cmd-screenshot`, `omarchy-cmd-screenrecord`, `omarchy-cmd-share`
- **Menus**: `omarchy-menu`, `omarchy-menu-keybindings`, `omarchy-menu-theme`
- **System**: `omarchy-update`, `omarchy-snapshot`, `omarchy-toggle-idle`, `omarchy-toggle-nightlight`
- **Hyprland**: `omarchy-hyprland-window-close-all`, `omarchy-hyprland-window-pop`
- **Launch**: `omarchy-launch-walker`, `omarchy-restart-waybar`, `omarchy-restart-swayosd`
- **Hooks**: `omarchy-hook` - Extensibility system for custom scripts on events

### Updates and Migrations

- `omarchy-update` - Update Omarchy (creates snapshot, pulls git, runs migrations)
- Migrations in `omarchy/migrations/` - Timestamped shell scripts for version upgrades
- Version tracked in `omarchy/version` file

## Niri Configuration Goal

The goal is to configure niri window manager (`~/.config/niri/config.kdl`) to:
1. Use Omarchy's Waybar, Walker, themes, and utilities
2. Align keybinds with Omarchy's Hyprland keybinds (or customize as preferred)
3. Properly set PATH so all `omarchy-*` commands work when launched via ly display manager
4. Source the same environment variables and settings that Hyprland uses

## Troubleshooting

**Issue**: Many niri keybinds don't work
**Likely Cause**: PATH not set correctly by ly display manager
**Solution**: Ensure `~/.local/share/omarchy/bin` is in PATH when niri starts. May need to set in display manager session configuration or niri's environment setup.
