# 🐝 Bee-Hive SDDM Theme

> **HoneyDark glassmorphism login screen for Bee-Hive OS — powered by Qt5/Qt6, styled by the Nexus.**

A sleek SDDM login theme featuring an animated hexagonal grid, glassmorphism UI elements, and a left-aligned layout inspired by the Bee-Hive OS aesthetic.

---

## ✨ Key Features

- **Cyber Queen Nexus wallpaper** — background avec l'artwork signature Bee-Hive OS
- **Animated hexagonal grid** — grille hexagonale animée qui pulse avec la palette HoneyDark
- **Glassmorphism UI** — panneau de connexion givré avec flou BeeAura configurable
- **Session picker fonctionnel** — via `SddmComponents 2.0` ComboBox natif (affiche Hyprland, etc.)
- **Icônes système visibles** — Éteindre ⏻, Redémarrer ↺, Veille ⏸ en jaune miel sur fond sombre
- **Compact left-aligned panel** — formulaire 310px à gauche, horloge bas-droite
- **Multi-media backgrounds** — PNG statique, GIF animé, vidéo MP4/WebM
- **Qt5/Qt6 polyglot** — compatible avec les builds SDDM Qt5 et Qt6

---

## 📦 Dépendances

> **CRITIQUE pour les utilisateurs Arch / CachyOS** — ces paquets sont requis.

```bash
sudo pacman -S qt5-quickcontrols2 qt5-graphicaleffects qt5-multimedia sddm
```

| Paquet | Utilité |
|---|---|
| `qt5-quickcontrols2` | `QtQuick.Controls 2` |
| `qt5-graphicaleffects` | Effets de flou et de lueur |
| `qt5-multimedia` | Fond GIF / vidéo |
| `sddm` | Fournit `SddmComponents 2.0` (ComboBox session) |

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
# Type : "image" | "gif" | "video"
background_type=image
background=assets/cyber_queen_nexus.png
# Flou BeeAura : 0.0 (aucun) → 1.0 (maximum)
blur_radius=0.18
```

### Fonds disponibles

| Fichier | Style |
|---|---|
| `assets/cyber_queen_nexus.png` | **Défaut** — Cyber Queen |
| `assets/hexa_neon_honey.png` | Hexa-Neon doré miel |
| `assets/cyber_bee_monochrome.png` | Cyber-Bee monochrome |
| `assets/hexa_neon_base.png` | Hexa neutre |
| `assets/cyber_bee_base.png` | Cyber neutre |

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
| **v0.2.5** | `import SddmComponents 2.0` — session picker fonctionnel |
| **v0.1.8** | Icônes système en jaune miel, labels en blanc |
| **v0.1.6** | Layout compact, horloge bas-droite, champs centrés |

---

## 🐝 Crédits

- **Auteurs :** Maya 🐝 & Marc
- **Licence :** GPL-3.0

*Part of the Bee-Hive OS ecosystem. The hive never sleeps.* 🍯
