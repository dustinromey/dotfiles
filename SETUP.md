# Portable Niri-Omarchy Setup Guide

This guide explains how to replicate this niri-Omarchy setup on another machine.

## Prerequisites

1. **Arch Linux** (or Arch-based distro like CachyOS)
2. **Omarchy already installed** on the target machine
3. **Git** for dotfiles management
4. **Stow** for deploying dotfiles: `sudo pacman -S stow`

## Architecture Overview

This setup uses a **layered approach**:
1. **Omarchy base** - Installed in `~/.local/share/omarchy/` (managed by Omarchy)
2. **User configs** - In `~/.config/` (managed by you via git/stow)
3. **Hooks** - Custom scripts that run on Omarchy events (version controlled)

---

## Step 1: Install Omarchy

On the new machine:

```bash
# Install Omarchy (if not already installed)
bash <(curl -s https://omarchy.org/install)

# Or update existing installation
omarchy-update
```

---

## Step 2: Set Up Dotfiles Repository

### On Current Machine (Laptop):

```bash
# Create dotfiles repo structure
mkdir -p ~/dotfiles
cd ~/dotfiles

# Create stow packages
mkdir -p niri/.config/niri
mkdir -p hypr/.config/hypr
mkdir -p waybar-niri/.config/waybar-niri
mkdir -p omarchy-hooks/.config/omarchy/hooks
mkdir -p omarchy-scripts/.local/share/omarchy/bin
mkdir -p environment/.config/environment.d

# Copy configs to stow structure
cp ~/.config/niri/config.kdl niri/.config/niri/
cp ~/.config/hypr/bindings.conf hypr/.config/hypr/
cp ~/.config/hypr/input.conf hypr/.config/hypr/
cp ~/.config/waybar-niri/config.jsonc waybar-niri/.config/waybar-niri/
cp ~/.config/omarchy/hooks/* omarchy-hooks/.config/omarchy/hooks/
cp ~/.local/share/omarchy/bin/omarchy-theme-set-kde omarchy-scripts/.local/share/omarchy/bin/
cp ~/.config/environment.d/fcitx.conf environment/.config/environment.d/

# Create symlink for waybar styling (in stow package)
cd waybar-niri/.config/waybar-niri/
ln -sf ../../waybar/style.css style.css
cd ~/dotfiles

# Initialize git repo
git init
git add .
git commit -m "Initial niri-Omarchy dotfiles"

# Push to GitHub/GitLab (optional but recommended)
# git remote add origin <your-repo-url>
# git push -u origin main
```

### Directory Structure:

```
~/dotfiles/
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
├── omarchy-scripts/
│   └── .local/
│       └── share/
│           └── omarchy/
│               └── bin/
│                   └── omarchy-theme-set-kde
└── environment/
    └── .config/
        └── environment.d/
            └── fcitx.conf
```

---

## Step 3: Deploy to New Machine (Desktop)

### On New Machine:

```bash
# Clone your dotfiles repo
git clone <your-dotfiles-repo> ~/dotfiles
cd ~/dotfiles

# Make hooks and scripts executable
chmod +x omarchy-hooks/.config/omarchy/hooks/*
chmod +x omarchy-scripts/.local/share/omarchy/bin/*

# Deploy with stow
# Deploy everything:
stow -t ~/ niri hypr waybar-niri omarchy-hooks omarchy-scripts environment

# Or deploy selectively:
# stow -t ~/ niri waybar-niri omarchy-hooks omarchy-scripts environment
```

### Machine-Specific Configuration:

Some configs need to be customized per machine:

**1. Monitor Configuration** (if different on desktop):
```bash
# Edit niri config for your desktop monitors
nano ~/.config/niri/config.kdl
# Update the output section with your monitor setup
```

**2. PATH in environment.d** (if different user):
```bash
# Edit and update username in PATH if needed
nano ~/.config/environment.d/fcitx.conf
# Change /home/dustin/ to /home/youruser/ if needed
```

**3. Niri config PATH** (if different user):
```bash
# Edit niri config.kdl environment section
nano ~/.config/niri/config.kdl
# Update PATH line if username is different
```

---

## Step 4: Install Required Packages

Make sure these are installed on the new machine:

```bash
# Core niri-Omarchy dependencies
sudo pacman -S niri waybar mako swayosd swaybg \
               hyprpicker dolphin kvantum \
               elephant walker cliphist wl-clipboard \
               playerctl

# Optional but recommended
sudo pacman -S ghostty alacritty
```

---

## Step 5: Verify Installation

Run these checks on the new machine:

```bash
# 1. Validate niri config
niri validate

# 2. Check PATH
echo $PATH | grep omarchy

# 3. Verify waybar-niri exists
ls -la ~/.config/waybar-niri/

# 4. Check hooks are executable
ls -la ~/.config/omarchy/hooks/

# 5. Check symlink
readlink ~/.config/waybar-niri/style.css

# 6. Test omarchy commands
which omarchy-theme-set
which omarchy-theme-set-kde
```

---

## Step 6: First Boot

1. **Log out** of your current session
2. **Select niri** from the ly display manager
3. **Log in**
4. Test keybinds:
   - `MOD+K` - Show keybinds overlay
   - `MOD+SPACE` - Walker launcher
   - `MOD+E` - Dolphin file manager
   - `MOD+CTRL+SPACE` - Cycle background

---

## Syncing Changes Between Machines

### Making Changes:

**On any machine:**
```bash
cd ~/dotfiles
# Make your changes to configs...
git add .
git commit -m "Update niri keybinds"
git push
```

**On other machine:**
```bash
cd ~/dotfiles
git pull
stow -R niri  # Restow to apply changes
niri msg action load-config-file  # Reload niri (if running)
```

---

## Machine-Specific Overrides

If you need different configs per machine:

### Option 1: Git Branches (Simple)
```bash
# On laptop
git checkout -b laptop
# Make laptop-specific changes
git commit -m "Laptop monitor config"

# On desktop
git checkout -b desktop
# Make desktop-specific changes
git commit -m "Desktop monitor config"

# Merge shared changes between branches as needed
```

### Option 2: Separate Config Files (Advanced)
```bash
# In dotfiles repo, create:
niri/.config/niri/config-laptop.kdl
niri/.config/niri/config-desktop.kdl

# On each machine, symlink the right one:
ln -sf ~/.config/niri/config-laptop.kdl ~/.config/niri/config.kdl
```

---

## Using Syncthing (Optional)

If you want to use Syncthing for certain files:

### Good for Syncthing:
- `~/Pictures/Backgrounds/` - Wallpapers
- `~/Pictures/Screenshots/` - Screenshots
- `~/.config/walker/` - Walker history/cache
- `~/.local/share/applications/` - Custom .desktop files

### **DON'T** Sync with Syncthing:
- `~/.config/niri/` - Use git/stow (machine-specific)
- `~/.config/hypr/` - Use git/stow (machine-specific)
- `~/.config/environment.d/` - Use git/stow (machine-specific)

---

## Troubleshooting

### PATH not working
```bash
# Check environment.d
cat ~/.config/environment.d/fcitx.conf | grep PATH

# Verify Omarchy bin exists
ls ~/.local/share/omarchy/bin/ | head

# Log out and back in (systemd reads environment.d on login)
```

### Waybar not working
```bash
# Check if waybar-niri config exists
cat ~/.config/waybar-niri/config.jsonc | head

# Check symlink
ls -la ~/.config/waybar-niri/style.css

# Restart waybar
pkill waybar && waybar -c ~/.config/waybar-niri/config.jsonc &
```

### Themes not applying
```bash
# Run theme-set manually
omarchy-theme-set everforest

# Check hooks exist and are executable
ls -la ~/.config/omarchy/hooks/
```

---

## Updating the Setup

When you make improvements on one machine:

```bash
cd ~/dotfiles
git add .
git commit -m "Add new keybind for X"
git push

# On other machine
cd ~/dotfiles
git pull
stow -R <package-name>  # Restow the updated package
```

---

## Summary

**Best Approach:**
- ✅ Use **git + stow** for configs (version controlled, flexible)
- ✅ Use **Syncthing** only for data/backgrounds (not configs)
- ✅ Keep machine-specific configs in git branches or separate files
- ✅ Commit and push changes from whichever machine you're on
- ✅ Pull and restow on other machines

This gives you:
- Version control and history
- Ability to rollback
- Machine-specific customization
- Portability across machines
- Clean separation of concerns
