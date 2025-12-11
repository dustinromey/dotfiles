# Speech-to-Text Setup on Arch Linux (Wayland/Niri)

## Overview

System-wide speech-to-text that works like a keyboard input across all applications (Brave, Zed, terminal, etc.) on Wayland.

## Quick Reference

| Component | Location |
|-----------|----------|
| ydotool service | `/etc/systemd/system/ydotool.service` |
| ydotool socket | `/tmp/.ydotool_socket` |
| waystt config | `~/.config/waystt/.env` |
| waystt models | `~/.local/share/applications/waystt/models/` |
| Niri config | `~/.config/niri/config.kdl` |

**Final config used:**
- Model: `ggml-medium.bin` (1.5GB, multilingual)
- Provider: local (offline)
- ~6 sec transcription time on Ryzen 9 7940HS

## Options Evaluated

### 1. dsnote (Speech Note)
- **URL**: https://github.com/mkiol/dsnote
- **Approach**: GUI app with "insert into active window" feature
- **AUR**: `dsnote` or `dsnote-git`
- **Pros**: Feature-rich (STT, TTS, translation), multiple engines (Whisper, Vosk, Faster Whisper), fully offline, GPU acceleration
- **Cons**: Heavy (3.6GB), more of an app than input method, uses ydotool workaround

### 2. IBus-Speech-To-Text
- **URL**: https://github.com/PhilippeRo/IBus-Speech-To-Text
- **Approach**: Proper IBus input method engine
- **Pros**: True IM integration, voice commands, auto-formatting
- **Cons**: Vosk only (no Whisper), last release Oct 2022, requires gst-vosk

### 3. waystt (Recommended for Wayland)
- **URL**: https://github.com/sevos/waystt
- **AUR**: `waystt-bin`
- **Approach**: Signal-driven Rust binary, Wayland-native
- **Pros**: Explicitly supports Niri, local Whisper or API, lightweight, active development
- **Cons**: Requires ydotool for text injection

### 4. nerd-dictation
- **URL**: https://github.com/ideasman42/nerd-dictation
- **Approach**: Minimal Python script using Vosk
- **Pros**: Hackable, single file, lightweight
- **Cons**: Vosk only (less accurate than Whisper)

## Chosen Solution: waystt + ydotool

waystt handles speech recognition, ydotool handles injecting text into any focused window on Wayland.

---

## Installation

### Step 1: Install ydotool

```bash
sudo pacman -S ydotool
```

### Step 2: Add user to input group

```bash
sudo usermod -a -G input $USER
# Log out and back in for group change to take effect
```

### Step 3: Set up ydotool daemon

On Arch, the user service often has permission issues. The system service approach is more reliable:

```bash
sudo tee /etc/systemd/system/ydotool.service << 'EOF'
[Unit]
Description=ydotoold - ydotool daemon

[Service]
ExecStart=/usr/bin/ydotoold --socket-path /tmp/.ydotool_socket --socket-perm 0666
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable --now ydotool.service
```

Verify it's running:

```bash
sudo systemctl status ydotool.service
ls -la /tmp/.ydotool_socket
```

### Step 4: Set environment variable for shell

Add to `~/.bashrc` or `~/.zshrc`:

```bash
export YDOTOOL_SOCKET=/tmp/.ydotool_socket
```

This is needed for running ydotool from the terminal. For Niri keybindings, see Step 8.

### Step 5: Test ydotool

```bash
# Open a text editor, focus it, then run:
ydotool type "hello world"
```

### Step 6: Install waystt

```bash
yay -S waystt-bin
```

### Step 7: Configure waystt

```bash
mkdir -p ~/.config/waystt
```

**For local/offline transcription (recommended):**

```bash
cat > ~/.config/waystt/.env << 'EOF'
TRANSCRIPTION_PROVIDER=local
WHISPER_MODEL=ggml-medium.bin
ENABLE_AUDIO_FEEDBACK=true
BEEP_VOLUME=0.1
EOF

# Download the model (~1.5GB)
waystt --download-model
```

**Note**: Use `ggml-medium.bin` (multilingual) instead of `ggml-medium.en.bin` (English-only) if you need multiple languages. The multilingual model auto-detects language.

**For OpenAI API transcription (faster, requires internet):**

```bash
cat > ~/.config/waystt/.env << 'EOF'
OPENAI_API_KEY=your_api_key_here
WHISPER_MODEL=whisper-1
EOF
```

### Step 8: Configure Niri

Add to `~/.config/niri/config.kdl`:

**Environment variable (required for ydotool to work from keybindings):**

```kdl
environment {
    YDOTOOL_SOCKET "/tmp/.ydotool_socket"
}
```

**Keybindings:**

```kdl
binds {
    // Speech to Text - types directly into focused window
    Mod+R { spawn "sh" "-c" "pgrep -x waystt >/dev/null && pkill --signal SIGUSR1 waystt || (waystt --pipe-to /usr/bin/ydotool type --file - &)"; }

    // Speech to Text - copies to clipboard instead
    Mod+Shift+R { spawn "sh" "-c" "pgrep -x waystt >/dev/null && pkill --signal SIGUSR1 waystt || (waystt --pipe-to /usr/bin/wl-copy &)"; }
}
```

**Critical notes:**
- The `environment` block is required because processes spawned by Niri don't inherit your shell's environment variables
- The `--pipe-to` arguments must NOT be quoted together
- Use full paths (`/usr/bin/ydotool`) since waystt doesn't inherit PATH

---

## Verification

After completing all steps, verify the setup:

```bash
# 1. Check ydotool daemon is running
sudo systemctl status ydotool.service

# 2. Check socket exists with correct permissions
ls -la /tmp/.ydotool_socket
# Should show: srw-rw-rw- ... /tmp/.ydotool_socket

# 3. Test ydotool standalone (focus a text editor first)
sleep 2 && ydotool type "hello world"

# 4. Check model is downloaded
ls -la ~/.local/share/applications/waystt/models/
# Should show: ggml-medium.bin

# 5. Test waystt transcription (outputs to terminal)
waystt
# Then in another terminal: pkill --signal SIGUSR1 waystt
# Speak after the beep, send signal again to stop

# 6. Test the full pipeline (focus a text editor first)
waystt --pipe-to /usr/bin/ydotool type --file -
# Send SIGUSR1, speak, send SIGUSR1 again - text should appear
```

---

## Usage

1. Press `Mod+R` to start waystt (first press starts the daemon)
2. Press `Mod+R` again to trigger recording (beep confirms)
3. Speak
4. Press `Mod+R` again to stop and transcribe (beep confirms)
5. Text appears at cursor position

Or use `Mod+Shift+R` to copy transcription to clipboard instead.

### Manual testing from terminal

```bash
# Direct typing (focus a text editor first)
waystt --pipe-to /usr/bin/ydotool type --file -

# Clipboard
waystt --pipe-to /usr/bin/wl-copy

# Then trigger with Mod+R or from another terminal:
pkill --signal SIGUSR1 waystt

# Expected: ~6 sec transcription time with ggml-medium.bin
```

---

## Available Whisper Models (Local)

| Model | Size | Languages | Notes |
|-------|------|-----------|-------|
| `ggml-tiny.en.bin` | 39 MB | English | Fastest, least accurate |
| `ggml-tiny.bin` | 39 MB | Multilingual | Fast, least accurate |
| `ggml-base.en.bin` | 142 MB | English | Good speed/accuracy balance |
| `ggml-base.bin` | 142 MB | Multilingual | Good speed/accuracy balance |
| `ggml-small.en.bin` | 466 MB | English | Better accuracy |
| `ggml-small.bin` | 466 MB | Multilingual | Better accuracy |
| `ggml-medium.en.bin` | 1.5 GB | English | High accuracy |
| `ggml-medium.bin` | 1.5 GB | **Multilingual** | **Recommended for bilingual use** |
| `ggml-large-v3.bin` | 2.9 GB | Multilingual | Best accuracy, slowest |

**Performance notes (CPU-only, ~5 sec audio clip):**
- Base models: ~1-2 sec processing
- Medium models: ~6 sec processing (tested on Ryzen 9 7940HS)
- Large models: ~15-30 sec processing

GPU acceleration (Vulkan/CUDA) can reduce these times by 3-5x but requires building waystt from source.

---

## Troubleshooting

### ydotool permission denied
- Ensure you're in the `input` group: `groups $USER`
- Log out and back in after adding to group
- Check socket exists with correct permissions: `ls -la /tmp/.ydotool_socket`
- Socket should show `srw-rw-rw-` (world-readable/writable)

### ydotool service won't start
- On Arch, `systemctl --user enable ydotool.service` may fail with "Unit does not exist" - use the system service approach in Step 3 instead
- Check status: `sudo systemctl status ydotool.service`
- View logs: `journalctl -u ydotool.service`

### waystt not transcribing
- Check model downloaded: `ls ~/.local/share/applications/waystt/models/ggml-medium.bin`
- Test with debug: `RUST_LOG=debug waystt`
- Verify microphone works: `arecord -l`

### Text not appearing in application
- **Missing YDOTOOL_SOCKET in Niri**: Add `environment { YDOTOOL_SOCKET "/tmp/.ydotool_socket" }` to niri config
- waystt doesn't inherit your shell's PATH - use full paths like `/usr/bin/ydotool`
- Don't quote the `--pipe-to` arguments together (wrong: `"ydotool type --file -"`)
- Some apps may need focus delay; ydotool has `--delay` option
- Verify ydotool works standalone: `ydotool type "test"`
- Kill stale waystt processes before testing: `pkill waystt`

---

## Alternative: dsnote for GUI workflow

If you prefer a GUI or need TTS/translation:

```bash
yay -S dsnote
# or flatpak
flatpak install net.mkiol.SpeechNote
```

dsnote CLI for active window insertion:
```bash
flatpak run net.mkiol.SpeechNote --action start-listening-active-window
```

---

## Dependencies Summary

```bash
# Required
sudo pacman -S ydotool pipewire

# For clipboard support
sudo pacman -S wl-clipboard

# waystt from AUR
yay -S waystt-bin
```

---

## References

- waystt: https://github.com/sevos/waystt
- ydotool: https://github.com/ReimuNotMoe/ydotool
- dsnote: https://github.com/mkiol/dsnote
- nerd-dictation: https://github.com/ideasman42/nerd-dictation
- IBus-Speech-To-Text: https://github.com/PhilippeRo/IBus-Speech-To-Text
