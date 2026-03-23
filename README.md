# 🐝 Bee-Hive SDDM Theme

> **HoneyDark glassmorphism login screen for Bee-Hive OS — powered by Qt5/Qt6, styled by the Nexus.**

A sleek SDDM login theme featuring an animated hexagonal grid, glassmorphism UI elements, and a left-aligned layout inspired by the Bee-Hive OS aesthetic.

---

## ✨ Key Features

- **Cyber Queen Nexus wallpaper** — background with signature Bee-Hive OS artwork
- **Animated hexagonal grid** — animated hex grid pulsing with the HoneyDark palette
- **Glassmorphism UI** — frosted login panel with configurable BeeAura blur
- **Functional session picker** — via `SddmComponents 2.0` native ComboBox (displays Hyprland, etc.)
- **Visible system icons** — Power Off ⏻, Restart ↺, Suspend ⏸ in honey yellow on dark background
- **Compact left-aligned panel** — formulaire 310px à gauche, horloge bas-droite
- **Multi-media backgrounds** — PNG statique, GIF animé, vidéo MP4/WebM
- **Qt5/Qt6 polyglot** — compatible avec les builds SDDM Qt5 et Qt6

---

## 📦 Dépendances

> **CRITIQUE pour les utilisateurs Arch / CachyOS** — ces paquets sont requis.

```bash
sudo pacman -S qt5-quickcontrols2 qt5-graphicaleffects qt5-multimedia sddm
```

| Package | Purpose |
|---|---|
| `qt5-quickcontrols2` | `QtQuick.Controls 2` |
| `qt5-graphicaleffects` | Blur and glow effects |
| `qt5-multimedia` | GIF / video background |
| `sddm` | Provides `SddmComponents 2.0` (ComboBox session) |

---

## 🚀 Installation

**1. Cloner le thème :**

```bash
git clone https://github.com/marcchabot/beehive-sddm ~/beehive-sddm
sudo cp -r ~/beehive-sddm /usr/share/sddm/themes/beehive
```

**2. Activer dans `/etc/sddm.conf` :**

```ini
[Theme]
Current=beehive
```

**3. Tester sans redémarrer :**

```bash
sddm-greeter --test-mode --theme /usr/share/sddm/themes/beehive
```

**4. Mettre à jour :**

```bash
cd ~/beehive-sddm && git pull
sudo cp -f ~/beehive-sddm/Main.qml /usr/share/sddm/themes/beehive/Main.qml
```

---

## ⚙️ Configuration

Éditer `theme.conf` :

```ini
[General]
# Type: "image" | "gif" | "video"
background_type=image
background=assets/cyber_queen_nexus.png
# BeeAura blur: 0.0 (none) → 1.0 (max)
blur_radius=0.18
```

### Available backgrounds

| File | Style |
|---|---|
| `assets/cyber_queen_nexus.png` | **Default** — Cyber Queen |
| `assets/hexa_neon_honey.png` | Hexa-Neon honey gold |
| `assets/cyber_bee_monochrome.png` | Cyber-Bee monochrome |
| `assets/hexa_neon_base.png` | Neutral hex |
| `assets/cyber_bee_base.png` | Neutral cyber |

---

## 🗂️ Structure

```
beehive_sddm/
├── Main.qml            # Script principal du thème
├── metadata.desktop    # Métadonnées SDDM
├── theme.conf          # Options configurables
└── assets/
    ├── cyber_queen_nexus.png
    ├── hexa_neon_honey.png
    ├── cyber_bee_monochrome.png
    ├── hexa_neon_base.png
    └── cyber_bee_base.png
```

---

## 📋 Changelog

| Version | Notes |
|---|---|
| **v0.2.6** | Fix structure QML (ComboBox bien positionné) |
| **v0.2.5** | `import SddmComponents 2.0` — functional session picker |
| **v0.1.8** | System icons in honey yellow, white labels |
| **v0.1.6** | Compact layout, bottom-right clock, centered fields |

---

## 🐝 Crédits

- **Authors:** Maya 🐝 & Marc
- **License:** GPL-3.0

*Part of the Bee-Hive OS ecosystem. The hive never sleeps.* 🍯
