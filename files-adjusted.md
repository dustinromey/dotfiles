# Files Adjusted for Niri-Omarchy Setup

This document tracks all files modified or created to integrate niri window manager with Omarchy.

## Created Files

### Niri-Specific Waybar Config
- **Path**: `~/.config/waybar-niri/config.jsonc`
- **Purpose**: Separate waybar config for niri (uses `niri/workspaces` instead of `hyprland/workspaces`)
- **Note**: Copied from `~/.config/waybar/config.jsonc` and modified for niri compatibility
- **Stow**: Include in dotfiles

### Waybar Styling Symlink
- **Path**: `~/.config/waybar-niri/style.css`
- **Purpose**: Symlink to `~/.config/waybar/style.css` to share Omarchy themes
- **Command**: `ln -sf ~/.config/waybar/style.css ~/.config/waybar-niri/style.css`
- **Stow**: Create symlink in stow package

### Omarchy Post-Update Hook
- **Path**: `~/.config/omarchy/hooks/post-update`
- **Purpose**: Runs after `omarchy-update` to maintain niri-specific customizations
- **Features**:
  - Recreates waybar-niri style.css symlink if broken
  - Updates waybar-niri config from main waybar config
  - Converts hyprland modules to niri modules
  - Fixes OMARCHY_PATH variable
  - Fixes environment.d PATH if needed
  - Restarts waybar if running in niri
- **Permissions**: Executable (`chmod +x`)
- **Stow**: Include in dotfiles

### Omarchy Theme-Set Hook
- **Path**: `~/.config/omarchy/hooks/theme-set`
- **Purpose**: Runs after `omarchy-theme-set` to handle niri-specific theme changes
- **Features**:
  - Only runs when in niri (checks `XDG_CURRENT_DESKTOP`)
  - Restarts waybar with niri-specific config
  - Restarts swaybg with updated background
- **Permissions**: Executable (`chmod +x`)
- **Stow**: Include in dotfiles

### Documentation
- **Path**: `~/Code/desktops/niri-omarchy/CLAUDE.md`
- **Purpose**: Architecture documentation for Claude Code instances
- **Stow**: Include in repository, not dotfiles

---

## Modified Files

### Niri Configuration
- **Path**: `~/.config/niri/config.kdl`
- **Changes**:
  1. **Environment Section** (line ~299):
     - Added PATH with Omarchy bin directory
     - Ensures omarchy commands work when launched via ly display manager

  2. **Keybinds** (lines 47-190):
     - Added `MOD+K` for keybind overlay
     - Added `MOD+ALT+SPACE` for Omarchy menu
     - Added `MOD+ESCAPE` for system menu
     - Added `MOD+SHIFT+SPACE` to toggle waybar
     - Added `MOD+CTRL+SPACE` for next background
     - Added `MOD+SHIFT+CTRL+SPACE` for theme menu
     - Changed `MOD+Q` → `MOD+W` for close window
     - Changed `MOD+V` kept for clipboard history
     - Replaced `CTRL+SHIFT+1/2/3` with `PRINT` keys for screenshots
     - Added `MOD+PRINT` for color picker
     - Changed `MOD+W` (tabbed display) → `MOD+SHIFT+T` (conflict resolution)
     - Updated media keys to use swayosd-client (with OSD)
     - Added brightness controls with swayosd-client

  3. **Startup Applications** (lines 195-215):
     - Added `mako` (notification daemon)
     - Added `swayosd-server` (OSD for volume/brightness)
     - Added `elephant` (walker search backend)
     - Added `walker --gapplication-service` (walker as service)
     - Changed background from `swww` to `swaybg` with Omarchy background
     - Changed waybar command to use niri config: `waybar -c ~/.config/waybar-niri/config.jsonc`
     - Added fcitx5 (commented out, for Asian language input)

- **Stow**: Include in dotfiles

### Environment Variables (systemd)
- **Path**: `~/.config/environment.d/fcitx.conf`
- **Changes**:
  - Fixed PATH from `~/.config/omarchy/bin` → `~/.local/share/omarchy/bin`
  - **Line 5**: Corrected Omarchy bin directory location
- **Stow**: Include in dotfiles

### Hyprland Keybind Overrides
- **Path**: `~/.config/hypr/bindings.conf`
- **Changes** (lines 34-37):
  - Unbind default `SUPER+V` (universal paste)
  - Unbind default `SUPER+CTRL+V` (clipboard manager)
  - Rebind `SUPER+V` to clipboard manager (matches niri setup)
- **Purpose**: Consistency between niri and Hyprland clipboard keybinds
- **Stow**: Include in dotfiles

### Hyprland Input Configuration
- **Path**: `~/.config/hypr/input.conf`
- **Changes**:
  - **Line 21**: Uncommented `natural_scroll = true`
  - **Line 24**: Uncommented `clickfinger_behavior = true`
- **Purpose**: Consistency between niri and Hyprland touchpad behavior
- **Stow**: Include in dotfiles

---

## Key Integration Points

### PATH Setup (Critical for Omarchy Commands)
1. **systemd user environment**: `~/.config/environment.d/fcitx.conf`
2. **niri environment section**: `~/.config/niri/config.kdl`
3. **Both must include**: `/home/dustin/.local/share/omarchy/bin`

### Waybar Setup (Separate Configs)
1. **Hyprland**: Uses `~/.config/waybar/config.jsonc` (with `hyprland/workspaces`)
2. **Niri**: Uses `~/.config/waybar-niri/config.jsonc` (with `niri/workspaces`)
3. **Shared styling**: Both use `~/.config/waybar/style.css` via symlink

### Hook System (Maintains Customizations)
1. **Post-update**: Syncs waybar changes, fixes PATH issues after Omarchy updates
2. **Theme-set**: Ensures waybar restarts with correct config when switching themes

### Background System
- **Hyprland**: Uses `swaybg` (Omarchy default)
- **Niri**: Also uses `swaybg` (for consistency)
- **Both**: Point to `~/.config/omarchy/current/background` symlink

---

## Stow Structure Recommendation

```
dotfiles/
├── niri/
│   └── .config/
│       └── niri/
│           └── config.kdl
├── hypr/
│   └── .config/
│       └── hypr/
│           ├── bindings.conf
│           └── input.conf
├── waybar-niri/
│   └── .config/
│       └── waybar-niri/
│           ├── config.jsonc
│           └── style.css -> ../../waybar/style.css
├── omarchy-hooks/
│   └── .config/
│       └── omarchy/
│           └── hooks/
│               ├── post-update
│               └── theme-set
└── environment/
    └── .config/
        └── environment.d/
            └── fcitx.conf
```

---

## Testing After Stow

After stowing dotfiles, verify:

1. **PATH is correct**:
   ```bash
   echo $PATH | grep omarchy
   ```

2. **Waybar configs exist**:
   ```bash
   ls -la ~/.config/waybar-niri/
   ```

3. **Hooks are executable**:
   ```bash
   ls -la ~/.config/omarchy/hooks/
   ```

4. **Niri config validates**:
   ```bash
   niri validate
   ```

5. **Symlinks are correct**:
   ```bash
   readlink ~/.config/waybar-niri/style.css
   ```

---

## Notes

- All hooks must be executable (`chmod +x`)
- Symlinks should be relative where possible for portability
- Environment.d files are read by systemd user session
- Niri config changes require session restart or `niri msg action load-config-file`
- Omarchy updates may modify `~/.config/waybar/config.jsonc` - hook auto-syncs to waybar-niri

---

## Additional Changes

### Hyprland File Manager Keybind
- **Path**: `~/.config/hypr/bindings.conf`
- **Change** (line 6):
  - Changed from: `SUPER SHIFT, F, File manager, exec, uwsm-app -- nautilus --new-window`
  - Changed to: `SUPER, E, File manager, exec, uwsm-app -- dolphin`
- **Purpose**: Consistency between niri and Hyprland - both use MOD+E with Dolphin
- **Stow**: Already included in dotfiles

### KDE/Qt Theming Script
- **Path**: `~/.local/share/omarchy/bin/omarchy-theme-set-kde`
- **Purpose**: Theme Qt/KDE apps (like Dolphin) to match Omarchy themes
- **Features**:
  - Sets Kvantum theme based on light/dark mode
  - Configures icon theme from Omarchy theme settings
  - Creates `~/.config/Kvantum/kvantum.kvconfig`
  - Creates `~/.config/kdeglobals.d/icons.conf`
- **Permissions**: Executable (`chmod +x`)
- **Called by**: `~/.config/omarchy/hooks/theme-set`
- **Stow**: Include in dotfiles as Omarchy extension

### Omarchy Theme-Set Hook (Updated)
- **Path**: `~/.config/omarchy/hooks/theme-set`
- **Additional feature**: Now calls `omarchy-theme-set-kde` to theme Qt/KDE apps
