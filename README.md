# Bee-Hive SDDM Theme

> **HoneyDark glassmorphism login screen for Bee-Hive OS — powered by Qt5/Qt6, styled by the Nexus.**

A sleek SDDM login theme featuring an animated hexagonal grid, glassmorphism UI elements, and a left-aligned layout inspired by the Bee-Hive OS aesthetic. Built on top of [SilentSDDM](https://github.com/uiriansan/SilentSDDM) with heavy customization.

---

## Key Features

- **Cyber Queen Nexus wallpaper** — default background featuring the signature Bee-Hive OS artwork (`cyber_queen_nexus.png`)
- **Animated hexagonal grid** — subtle honeycomb overlay that pulses with the HoneyDark palette
- **Glassmorphism UI** — frosted-glass login panel with configurable BeeAura blur (`blur_radius`)
- **Compact left-aligned panel** — 310 px-wide login form on the left; clock sits bottom-right so neither overlaps
- **Vertically-centred input text** — `userField` / `passwordField` use pure `verticalAlignment: AlignVCenter` without any top-margin offset
- **Multi-media backgrounds** — supports static images (PNG), animated GIFs, and video loops (MP4/WebM)
- **Multiple built-in wallpapers** — four alternative assets included out of the box
- **Qt5/Qt6 polyglot** — compatible with both Qt5 and Qt6 SDDM builds

---

## Dependencies

> **CRITICAL for Arch / CachyOS users** — missing these packages causes `"Library import requires a version"` or `"module not installed"` errors at the greeter.

Install the required Qt5 modules:

```bash
sudo pacman -S qt5-quickcontrols2 qt5-graphicaleffects qt5-multimedia
```

| Package | Purpose |
|---|---|
| `qt5-quickcontrols2` | Required for `QtQuick.Controls 2` imports |
| `qt5-graphicaleffects` | Required for blur/glow visual effects |
| `qt5-multimedia` | Required for GIF/video background support |

---

## Installation

**1. Clone the theme into the SDDM themes directory:**

```bash
sudo git clone https://github.com/your-org/beehive-os /tmp/beehive-sddm
sudo cp -r /tmp/beehive-sddm/projects/beehive_sddm /usr/share/sddm/themes/beehive
```

Or clone directly:

```bash
sudo git clone https://github.com/your-org/beehive-os /usr/share/sddm/themes/beehive --depth 1
```

**2. Enable the theme in `/etc/sddm.conf`:**

```ini
[Theme]
Current=beehive
```

If `/etc/sddm.conf` does not exist, create it or edit `/etc/sddm.conf.d/theme.conf`.

**3. Test without rebooting (optional):**

```bash
sddm-greeter --test-mode --theme /usr/share/sddm/themes/beehive
```

---

## Configuration

Edit `/usr/share/sddm/themes/beehive/theme.conf` to customize the appearance:

```ini
[General]

# Background type: "image" | "gif" | "video"
background_type=image

# Path to the background asset (relative to theme root)
background=assets/cyber_queen_nexus.png

# BeeAura blur intensity: 0.0 (none) → 1.0 (maximum)
blur_radius=0.18
```

### Available Backgrounds

| File | Style |
|---|---|
| `assets/cyber_queen_nexus.png` | **Default** — Cyber Queen flagship artwork |
| `assets/hexa_neon_honey.png` | Hexa-Neon golden honey |
| `assets/cyber_bee_monochrome.png` | Cyber-Bee monochrome |
| `assets/hexa_neon_base.png` | Neutral hexa variant |
| `assets/cyber_bee_base.png` | Neutral cyber variant |

### Background Type Examples

```ini
# Static image (with slow breathing animation, scale 1.0 ↔ 1.05)
background_type=image
background=assets/hexa_neon_honey.png

# Animated GIF
background_type=gif
background=assets/bee_loop.gif

# Video loop (MP4 or WebM)
background_type=video
background=assets/bee_loop.mp4
```

---

## Layout

```
┌────────────────────────────────────────────────────────┐
│  [Login Panel 310px]          [Wallpaper / artwork]    │
│  left: 60px                                            │
│  verticalCenter                                        │
│                                               HH:MM    │
│                                       Day DD Mon YYYY  │
└────────────────────────────────────────────────────────┘
```

- **Login panel** — left-aligned, 310 px wide, vertically centred.
- **Clock / date** — bottom-right, right-aligned. Keeps the artwork centre-stage and prevents overlap with the panel.
- **Input fields** — 38 px tall; text centred purely via `verticalAlignment: AlignVCenter` (no `topMargin` offset that would push the baseline low).

---

## File Structure

```
beehive_sddm/
├── Main.qml            # Main theme script
├── metadata.desktop    # SDDM theme metadata
├── theme.conf          # User-configurable options
└── assets/
    ├── cyber_queen_nexus.png
    ├── hexa_neon_honey.png
    ├── cyber_bee_monochrome.png
    ├── hexa_neon_base.png
    └── cyber_bee_base.png
```

---

## Credits

- **Authors:** Maya & Marc
- **Base:** [SilentSDDM](https://github.com/uiriansan/SilentSDDM) by uiriansan
- **License:** GPL-3.0
- **Version:** 0.1.6

---

*Part of the Bee-Hive OS ecosystem. The hive lives on.*
