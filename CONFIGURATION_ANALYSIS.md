# NixOS/Home-Manager Configuration Structure Analysis

**Generated:** March 13, 2026

## Executive Summary

This configuration uses a **modular, host-centric architecture** with:
- **7 physical hosts** across 3 categories (Server, Personal, Desktop)
- **Aspect-based organization** using shared modules (common, server, personal)
- **Home-manager integration** with 24 user-level modules
- **Custom packages & overlays** for specialized needs
- **flake-parts based structure** for outputs management

---

## 1. HOSTS DIRECTORY STRUCTURE

### Host Categories

#### A. **Common Base** (`hosts/common/`)
**Shared configuration for all Linux hosts** (11 files)

| File | Purpose |
|------|---------|
| `default.nix` | Central import hub; kernel, security, hardware, nix settings |
| `nix.nix` | Nix daemon config: garbage collection, flakes, settings |
| `openssh.nix` | SSH hardening: key exchange algorithms, known hosts |
| `secrets.nix` | sops-nix secrets integration |
| `backup.nix` | Borgbackup configuration (Storagebox integration) |
| `services.nix` | Core services (syslogd, resolved, etc.) |
| `networking.nix` | Base networking: firewall, DNS |

**Key settings applied to all hosts:**
- Kernel modules: kvm-amd, kvm-intel
- Boot: zen kernel, systemd initrd, SysRq enabled
- Security: wheel-only sudo, TPM2 support, file limits (8192)
- Hardware: CPU microcode updates, redistributable firmware

---

#### B. **Server Base** (`hosts/server/`)
**Minimal server configuration** (5 files)

| File | Purpose |
|------|---------|
| `default.nix` | Server-specific policies, virtualization, ssh |
| `nix.nix` | Server-specific Nix settings |
| `openssh.nix` | Server SSH configuration |
| `networking.nix` | Server networking |
| `virtualization.nix` | Libvirtd/KVM support |

**Key settings:**
- TCP BBR congestion control for throughput
- Immutable users (userborn service enabled)
- No documentation, minimal fonts
- Tools: bottom, ghostty terminfo, shpool

**Hosts using server base:** bifrost, midgard, niflheim

---

#### C. **Personal Base** (`hosts/personal/`)
**Graphical workstation configuration** (10 files)

| File | Purpose |
|------|---------|
| `default.nix` | Desktop-specific imports and localization |
| `audio.nix` | PipeWire, ALSA, pulse, RTKit |
| `boot.nix` | Boot-specific settings |
| `bluetooth.nix` | Bluetooth support |
| `graphical-desktop.nix` | KDE Plasma6, Wayland/X11, input devices |
| `networking.nix` | Desktop networking |
| `nix.nix` | Desktop-specific Nix settings |
| `programs.nix` | System programs |
| `services.nix` | Desktop services |
| `virtualization.nix` | Libvirtd/QEMU for VMs |
| `xray-client.nix` | VPN client configuration |

**Key settings:**
- KDE Plasma6 on Wayland with SDDM
- PipeWire audio with 32-bit support
- Typography optimized (Noto fonts, JetBrains Mono)
- Locales: en_US, en_DK, en_IE, ru_RU, sr_RS
- Console: 32pt font, early setup

**Hosts using personal base:** desktop, carbon, altdesk

---

### Individual Host Configurations

#### **bifrost** (Linode VPS - VPN Relay)
**Inherits:** server
**Files:** 7 total

```
bifrost/
├── default.nix                 [openssh, secrets, xray-server, networking, hardware]
├── openssh.nix                 [SSH tuning]
├── secrets.nix                 [Secret management]
├── xray-server.nix            [VPN server]
├── networking.nix             [Network config]
├── hardware-configuration.nix [Linode-specific]
└── disk-config.nix            [Disk layout]
```

**Role:** Primary VPN server relay
**Services:** Xray (proxy protocol)
**Network:** Public IP 212.193.3.155 (provided as module arg)

---

#### **midgard** (Vultr VPS - Web Server)
**Inherits:** server
**Files:** 7 total

```
midgard/
├── default.nix                 [openssh, secrets, caddy, xray-server]
├── openssh.nix                 [SSH config]
├── secrets.nix                 [Secret management]
├── caddy.nix                   [Reverse proxy/TLS]
├── xray-server.nix            [Secondary VPN server]
├── networking.nix             [Network config]
└── disk-config.nix            [Disk layout]
```

**Role:** Secondary web server + VPN relay
**Services:** Caddy (TLS termination), Xray
**Network:** Public IP passed as module arg

---

#### **niflheim** (Home Server - Media/Services Hub)
**Inherits:** server
**Files:** 44+ total (extensive service configuration)

```
niflheim/ (The "World Tree" - hub with 40+ services)
├── default.nix                 [44 service imports]
├── secrets.nix
├── webhost.nix                 [Domain config]
├── networking.nix
├── hardware-configuration.nix
├── disk-config.nix
│
├── [Web/Reverse Proxy]
│   ├── caddy.nix              [Reverse proxy]
│   ├── nginx.nix              [Alternate web server]
│   └── authelia.nix           [Auth gateway]
│
├── [Media Services]
│   ├── jellyfin.nix           [Video streaming]
│   ├── audiobookshelf.nix     [Audiobook server]
│   ├── immich.nix             [Photo management]
│   └── calibre.nix            [Book manager] (commented)
│
├── [Data Services]
│   ├── nextcloud.nix          [File sync]
│   ├── paperless.nix          [Document OCR]
│   ├── linkwarden.nix         [Bookmark manager]
│   ├── freshrss.nix           [RSS reader]
│   ├── transmission.nix       [Torrent client]
│   └── changedetection.nix    [Website monitor]
│
├── [Self-Hosted Apps]
│   ├── forgejo.nix            [Git server] (commented)
│   ├── monica.nix             [CRM]
│   ├── karakeep.nix           [Karaoke]
│   ├── anki.nix               [Flashcard]
│   ├── dashboard.nix          [Admin dashboard]
│   └── bitmagnet.nix          [Torrent indexer]
│
├── [Infrastructure]
│   ├── lldap.nix              [LDAP directory]
│   ├── postgres.nix           [Database]
│   ├── influxdb.nix           [Time-series DB]
│   ├── grafana.nix            [Monitoring]
│   ├── prometheus.nix         [Metrics]
│   ├── scrutiny.nix           [Drive health]
│   ├── netbird.nix            [VPN] (commented)
│   ├── wireguard.nix          [VPN]
│   └── xray-server.nix        [Proxy]
│
├── [AI/ML]
│   ├── ai.nix                 [Open WebUI, LLM service]
│   ├── docling.nix            [Document parsing]
│   ├── searx.nix              [Meta-search]
│   └── handbrake.nix          [Video encoding]
│
├── [Development]
│   ├── backup.nix             [Borgbackup]
│   └── pg-upgrade.nix         [Database migration]
│
└── [Pinepods, ntfy.sh, servarr (Arr stack)]
```

**Role:** Central hub for media, data, infrastructure, AI services
**Service Count:** 40+ active services
**Storage:** Media group support, multi-database backend
**Special:** Comment-disabled services can be toggled

---

#### **carbon** (Framework 13 Laptop - Development)
**Inherits:** personal
**Files:** 9 total

```
carbon/
├── default.nix                 [boot, backup, secrets, networking, services, users, graphical-desktop, hw]
├── boot.nix                    [Secure boot, kernel]
├── backup.nix                  [Borgbackup]
├── secrets.nix                 [sops secrets]
├── networking.nix              [Network config]
├── services.nix                [System services]
├── users.nix                   [User definitions]
├── graphical-desktop.nix       [Plasma, input devices]
└── hardware-configuration.nix  [Framework 13 specific]
```

**Role:** Portable development workstation
**Notable:** Full graphical desktop + backup support

---

#### **desktop** (Main Workstation - Gaming/Development)
**Inherits:** personal
**Files:** 12 total

```
desktop/
├── default.nix                 [backup, gaming, networking, secrets, services, users, virt, graphical-desktop, hw]
├── backup.nix                  [Borgbackup]
├── gaming.nix                  [Steam, Gamescope, Proton, game device rules]
├── networking.nix              [Network config]
├── secrets.nix                 [sops secrets]
├── services.nix                [Avahi, Geoclue, KMScon, SSH]
├── users.nix                   [User definitions]
├── virtualization.nix          [libvirtd, KVM]
├── graphical-desktop.nix       [Plasma6, Wayland]
└── hardware-configuration.nix  [Desktop hardware]
```

**Role:** Primary daily-use gaming + development machine
**Unique:** Gaming stack (Steam, Proton, Gamescope), extensive services

---

#### **altdesk** (Secondary Workstation)
**Inherits:** personal
**Files:** 4 total

```
altdesk/
├── default.nix                 [networking, graphical-desktop, hardware]
├── networking.nix              [Network config]
├── graphical-desktop.nix       [Plasma6]
└── hardware-configuration.nix  [Hardware]
```

**Role:** Secondary/test machine
**Timezone:** Europe/Moscow (differs from other hosts)
**Minimal:** Only essential services

---

#### **macbook** (Darwin/macOS - Development)
**Inherits:** none (Darwin-specific, not using NixOS base)
**Files:** 1 total

```
macbook/
└── default.nix                 [homebrew, system defaults, nix-darwin config]
```

**Role:** macOS development environment
**Special:** 
- Nix disabled, using homebrew for packages
- nix-darwin defaults: Dock, Finder, security settings
- Fish shell with Babelfish
- Applications: Xcode, game apps, development tools
- macOS-specific: alt-tab, ProtonVPN, Steam, zoom

---

## 2. ROOT CONFIGURATION.NIX

**File:** `/configuration.nix` (21 lines)

**Purpose:** Minimal root-level settings applied to ALL outputs

```nix
{
  system = {
    stateVersion = "24.11" (Linux) | 6 (Darwin)
    configurationRevision = self.rev (if available)
  };

  environment.systemPackages = [
    manix            # Nix documentation search
    nixfmt           # Nix code formatter
    nix-index        # Nix package index
    nix-prefetch-git # Prefetch git repos
    nix-prefetch-github # Prefetch GitHub repos
  ];
}
```

**Cross-cutting concerns handled:**
- State version management (unified across all hosts)
- Git revision tracking (for reproducibility)
- Developer tools universally available (nixfmt, manix)

---

## 3. USERS DIRECTORY

### Structure

```
users/
└── alapshin/                    [Primary user account]
    ├── default.nix             [NixOS user configuration]
    ├── secrets/                [User secrets for home-manager]
    │   ├── build/secrets.json  [Built secrets]
    │   └── secrets.yaml        [Source secrets]
    └── home/                   [home-manager modules - 24 files]
```

### A. User Definition (`users/alapshin/default.nix`)

**Configuration:**
- UID: 1000
- Shell: fish
- Groups: adbusers, audio, docker, input, jackaudio, libvirtd, networkmanager, syncthing, tss, wheel

**System packages (scope: all hosts):**
- Media: audacity, calibre, gimp, inkscape, kid3-qt, qbittorrent, tor-browser
- Office: LibreOffice (Qt), smplayer
- Crypto: feather, electrum
- Dictionaries: aspell, hunspell (en, es, ru, sr)
- KDE apps: ark, dolphin, filelight, gwenview, kate, kleopatra, spectacle

---

### B. Home-Manager Modules (`users/alapshin/home/`)

**24 modules organized by concern:**

#### Core Configuration
| Module | Lines | Purpose |
|--------|-------|---------|
| `home.nix` | 143 | Central imports, home-manager setup, XDG, Darwin targeting |
| `default.nix` | 12 | Wrapper - imports home.nix with username handling |
| `variables.nix` | ? | Environment variables, locale settings |
| `theming.nix` | ? | Visual theming (Catppuccin, color schemes) |

#### Shell & Tools
| Module | Purpose |
|--------|---------|
| `shell.nix` | Fish config, shell tools (atuin, bat, bottom, fzf, etc.) |
| `programs.nix` | System programs (mpv, keepassxc, element, joplin) |
| `services.nix` | User services (syncthing, etc.) |

#### Development
| Module | Purpose |
|--------|---------|
| `development.nix` | Dev tools (bun, node, rust, go, python, lua, java) |
| `git.nix` | Git configuration, signing |
| `neovim.nix` + `neovim.lua` | Neovim editor (Lua config) |

#### Applications
| Module | Purpose |
|--------|---------|
| `firefox.nix` | Firefox + addons, privacy settings |
| `chromium.nix` | Chromium browser |
| `thunderbird.nix` | Email client |
| `ssh.nix` | SSH client configuration |
| `gnupg.nix` | GnuPG key management |
| `syncthing.nix` | File sync daemon |

#### Desktop & Media
| Module | Purpose |
|--------|---------|
| `plasma.nix` | KDE Plasma configuration (desktop shortcuts, widgets) |
| `gaming.nix` | Lutris, Proton, game tools |
| `podman.nix` | Container runtime (Podman desktop) |
| `texlive.nix` | LaTeX packages (mathematics, languages) |
| `ai.nix` | AI/ML tools (ChatGPT CLI, etc.) |
| `anki.nix` | Anki flashcard setup |

#### Infrastructure
| Module | Purpose |
|--------|---------|
| `opencode` | ? (directory - likely custom config) |

**Total lines in home-manager:** ~2000+ lines of configuration

**Key Features:**
- Modular by use-case (development, media, communication)
- Platform-aware (Linux vs Darwin conditionals)
- Secrets management via sops-nix
- Declarative dotfile management via XDG
- Catppuccin color scheme integration
- Home state version: 24.11

---

## 4. MODULES DIRECTORY

### A. NixOS Modules (`modules/_nixos-modules/`)

**Purpose:** Reusable NixOS configuration modules exported in flake.nixosModules

```
_nixos-modules/
├── default.nix                          [Export list]
├── services/
│   ├── backup/
│   │   └── borgbackup.nix              [Borgbackup service module]
│   ├── networking/
│   │   └── vpn.nix                     [VPN (Xray/Wireguard) abstraction]
│   ├── web-apps/
│   │   └── monica5.nix                 [Monica CRM service module]
│   └── web-server/
│       └── webhost.nix                 [Multi-domain web hosting abstraction]
```

**Export Registry:**
```nix
{
  backup = import ./services/backup/borgbackup.nix
  vpn = import ./services/networking/vpn.nix
  monica = import ./services/web-apps/monica5.nix
  webhost = import ./services/web-server/webhost.nix
}
```

**Usage:**
These are used in `niflheim/default.nix` and potentially other hosts through the flake outputs.

---

### B. Home-Manager Modules (`modules/_home-modules/`)

**Purpose:** Reusable home-manager modules exported in flake.homeModules

```
_home-modules/
├── default.nix                  [Export list]
└── secrets.nix                  [Secret management helper]
```

**Export Registry:**
```nix
{
  secrets = import ./secrets.nix
}
```

---

### C. Flake Module Support (`modules/default.nix`)

**Core flake-parts structure:**

```
modules/
├── default.nix                  [Main entry point for flake-parts]
├── lib.nix                      [Extended lib functions]
├── pkgs.nix                     [Nixpkgs instantiation per-system]
├── overlays.nix                 [Overlay system imports]
├── formatter.nix                [treefmt configuration]
├── dev-shells.nix               [Development shell definitions]
├── exported-modules.nix         [flake.nixosModules & flake.homeModules export]
```

**Key patterns:**
- Each file is a flake-parts module function
- `default.nix` imports all and sets system list
- Per-system config in `pkgs.nix`, `formatter.nix`, `dev-shells.nix`
- Flake-wide config in `overlays.nix`, `exported-modules.nix`

---

## 5. OVERLAYS AND PACKAGES

### A. Overlays (`overlays/default.nix`)

**Two overlays defined:**

#### 1. **additions** - Custom packages
```nix
additions = final: prev: import ../packages { inherit final prev; }
```
Brings in custom package definitions from `packages/` directory.

#### 2. **modifications** - Package patches & overrides

| Package | Modification | Reason |
|---------|--------------|--------|
| karakeep | Patch for next.js 15.3.8 | Upstream patch targets wrong line |
| mos | Version override | 4.0.0 with custom buildId |
| open-webui | Add postgres deps | Enable postgres backend |
| changedetection-io | Add flask-babel, diff-match-patch | Enhanced functionality |
| pythonPackagesExtensions | Add autobean | Custom Python package |

---

### B. Custom Packages (`packages/`)

**13 custom package definitions:**

```
packages/
├── default.nix                  [Package registry]
├── androidenv/                  [Android development environment]
├── autobean/                    [Beancount extension (Python package)]
├── cuesplit/                    [Audio CUE sheet splitter]
├── firefox-addons/              [Custom Firefox extensions]
├── firefox-ui-fix/              [Firefox UI patches]
├── hunspell/                    [Custom spell-check dictionaries]
│   └── sr/                      [Serbian dictionary]
├── monica/                      [CRM package]
├── pg-fix-collation/            [PostgreSQL collation fix]
├── sandbox-runtime/             [Sandbox execution layer]
└── xkb/                         [Custom keyboard layouts]
```

---

## 6. KEY CONFIGURATION ASPECTS MATRIX

### Aspect Categories Identified

#### A. **Core System** (Common to all)
- **Boot:** Zen kernel, systemd initrd, SysRq, microcode updates
- **Security:** Sudo hardening, TPM2, file limits, PAM
- **Nix:** Flakes, garbage collection, optimizations
- **SSH:** Hardened algorithms, known hosts
- **Secrets:** sops-nix integration

#### B. **Server-Only Aspects**
- TCP BBR congestion control
- Immutable user configuration (userborn)
- Minimal documentation
- Virtualization (libvirtd)

#### C. **Desktop-Only Aspects**
- Audio: PipeWire, ALSA, 32-bit support, RTKit
- Graphics: Hardware acceleration, Wayland/X11
- Display Manager: SDDM
- Desktop Environment: KDE Plasma 6
- Input: Keyboard layouts (US/RU/SR), touchpad settings
- Bluetooth support
- Localization: Multi-locale support

#### D. **Service Aspects**

**Backup Services:**
- Borgbackup (storagebox integration)
- Available on: desktop, carbon, niflheim

**VPN/Networking:**
- Xray proxy server (bifrost, midgard, niflheim)
- Xray client (personal hosts)
- WireGuard (niflheim)
- NetBird (niflheim - commented)

**Web/Proxy:**
- Caddy (midgard, niflheim)
- Nginx (niflheim)
- Authelia (niflheim auth)

**Media:**
- Jellyfin (niflheim)
- Transmission torrent (niflheim)
- Audiobookshelf (niflheim)
- Immich photos (niflheim)
- Calibre (niflheim, commented)

**Data/Sync:**
- Nextcloud (niflheim)
- Syncthing (user service, all hosts)
- Paperless (niflheim)

**Infrastructure:**
- PostgreSQL (niflheim)
- InfluxDB (niflheim)
- Prometheus (niflheim)
- Grafana (niflheim)
- LLDAP (niflheim)

**Applications:**
- Monica CRM (niflheim)
- Forgejo git (niflheim, commented)
- Freshrss (niflheim)
- Linkwarden bookmarks (niflheim)
- Anki flashcards (niflheim)

**AI/ML:**
- Open WebUI (niflheim)
- Docling (niflheim)
- Searx search (niflheim)
- Handbrake (niflheim)

#### E. **User/Development Aspects**
- Shell: Fish configuration (atuin, fzf, completion)
- Editors: Neovim (full Lua config)
- Git: Signing, SSH key management
- Development: Python, Node, Rust, Go, Lua, Java toolchains
- Container: Podman
- Documentation: LaTeX/TeXLive
- Gaming: Steam, Lutris, Proton, Gamescope (desktop only)
- Browsers: Firefox, Chromium with extensions
- Mail: Thunderbird
- Crypto: GnuPG, SSH keys
- Media: Audacity, GIMP, Inkscape
- KDE apps: Plasma configuration, dolphin, kate, kleopatra

---

## 7. HOST-TO-CONFIGURATION MAPPING

### Inheritance Tree
```
               ┌─────────────────────────────────────┐
               │        configuration.nix            │
               │  (State version, nix tools)        │
               └─────────────────────────────────────┘
                           ↓
        ┌──────────────────────────────────────────┐
        │          hosts/common/                   │
        │  (Kernel, security, SSH, backup, nix)   │
        └──────────────────────────────────────────┘
               ↙          ↓          ↘
    ┌──────────────┐  ┌──────────┐  ┌──────────────┐
    │ server/      │  │personal/ │  │macbook/      │
    │ (minimal)    │  │(graphical)   │(darwin)      │
    └──────────────┘  └──────────┘  └──────────────┘
        ↙        ↘        ↙       ↘
    bifrost   midgard  desktop  altdesk
    niflheim  carbon   macbook
```

### Host Configuration Summary

| Host | Type | Inherits | Key Services | Notable Aspects |
|------|------|----------|--------------|-----------------|
| bifrost | VPS | server | Xray VPN | Public relay |
| midgard | VPS | server | Caddy, Xray | Web + VPN |
| niflheim | Home server | server | 40+ (media, data, infra, AI) | Hub device |
| desktop | Workstation | personal | Steam, services | Gaming + dev |
| carbon | Laptop | personal | (minimal services) | Portable dev |
| altdesk | Workstation | personal | (minimal services) | Secondary |
| macbook | macOS | (none) | homebrew apps | Darwin-only |

---

## 8. EXISTING ASPECTS READY FOR REFACTORING

### Already Modularized
1. **Backup** - `modules/_nixos-modules/services/backup/borgbackup.nix`
2. **VPN** - `modules/_nixos-modules/services/networking/vpn.nix`
3. **Monica** - `modules/_nixos-modules/services/web-apps/monica5.nix`
4. **Webhost** - `modules/_nixos-modules/services/web-server/webhost.nix`
5. **Secrets** (HM) - `modules/_home-modules/secrets.nix`

### Ready to Extract to Modules
The following aspects are currently defined in host configs but are good candidates for extraction:

**NixOS Aspects:**
- Audio (PipeWire) - currently in `hosts/personal/audio.nix`
- Bluetooth - currently in `hosts/personal/bluetooth.nix`
- Boot - currently in `hosts/personal/boot.nix` and `hosts/carbon/boot.nix`
- Gaming (Steam) - currently in `hosts/desktop/gaming.nix`
- Virtualization - currently in `hosts/personal/virtualization.nix`, `hosts/desktop/virtualization.nix`
- Graphical Desktop (Plasma) - currently in `hosts/personal/graphical-desktop.nix` (replicated)
- Services - scattered across hosts
- Programs - scattered across hosts
- Xray (client) - currently in `hosts/personal/xray-client.nix`

**Home-Manager Aspects:**
All 24 modules in `users/alapshin/home/` are well-structured and modular - minimal refactoring needed.

---

## 9. SCOPE FOR PHASE 2 (ASPECT CREATION)

### Aspects to Create/Extract

#### Priority 1: Core System Aspects
1. **audio** - PipeWire, ALSA, RTKit configuration
2. **boot** - Boot loader, kernel, early system setup
3. **graphical-desktop** - DE + WM configuration
4. **virtualization** - libvirtd/KVM setup
5. **gaming** - Steam, Proton, drivers

#### Priority 2: Service Aspects
6. **backup** - Already modularized, can be extracted further
7. **vpn** - Already modularized
8. **web-services** - Caddy, Nginx, Authelia
9. **database** - PostgreSQL, InfluxDB
10. **monitoring** - Prometheus, Grafana
11. **media** - Jellyfin, Transmission, etc.
12. **ai-ml** - Open WebUI, Docling, etc.

#### Priority 3: Development Aspects
13. **development-tools** - Compilers, runtimes, IDEs
14. **containers** - Podman/Docker setup
15. **documentation** - LaTeX, texlive

#### Priority 4: User/Dotfile Aspects
16. **shell-config** - Fish, atuin, fzf setup
17. **editor-config** - Neovim configuration
18. **browser-config** - Firefox/Chromium setup
19. **terminal** - Terminal emulator settings

---

## 10. SPECIAL CONFIGURATIONS

### Secrets Management
- **sops-nix** integration in all hosts
- Secrets stored in `hosts/*/secrets/` (encrypted YAML)
- Home-manager secrets in `users/alapshin/secrets/`
- Age key setup required per system

### Custom Overlays/Packages
- **autobean**: Python beancount extension
- **hunspell**: Serbian dictionary customization
- **karakeep**: Upstream patch for next.js compatibility
- **sandbox-runtime**: Custom sandbox execution
- **xkb**: Custom keyboard layouts (US, RU, SR)

### Hardware-Specific Files
- `**/hardware-configuration.nix` - Auto-generated per host
- `**/disk-config.nix` - disko declarative partitioning (bifrost, midgard, niflheim, desktop)
- `**/facter.json` - Machine facts (midgard)

### Per-Host Customizations
- **niflheim:** Massive service hub (44 imported config files)
- **desktop:** Gaming focus (Steam, Gamescope, Proton)
- **bifrost/midgard:** VPN-centric relay servers
- **carbon/altdesk:** Minimal, portable setups
- **macbook:** Darwin-only, homebrew-based

---

## 11. FLAKE OUTPUTS STRUCTURE

**Current outputs (via modules/):**

| Output | Defined In | Purpose |
|--------|-----------|---------|
| devShells.{system}.android | dev-shells.nix | Android dev environment |
| formatter.{system} | formatter.nix | treefmt (nix formatter) |
| overlays.additions | overlays.nix | Custom packages |
| overlays.modifications | overlays.nix | Package overrides |
| nixosModules.{backup,vpn,monica,webhost} | exported-modules.nix | Reusable NixOS modules |
| homeModules.secrets | exported-modules.nix | Reusable home-manager modules |
| nixosConfigurations.{bifrost,midgard,niflheim,carbon,desktop,altdesk} | (currently missing, needs implementation) | NixOS systems |
| darwinConfigurations.macbook | (currently missing, needs implementation) | macOS system |
| homeConfigurations.{alapshin@desktop,alapshin@macbook} | (currently missing, needs implementation) | Standalone HM |

**Note:** The flake.nix currently imports `./modules` but nixOS/darwin/home configurations need to be added to the flake-parts structure.

---

## 12. CONFIGURATION STATISTICS

| Category | Count | Notes |
|----------|-------|-------|
| Physical Hosts | 7 | 5 Linux + 1 macOS + 1 VPS category |
| NixOS Hosts | 6 | bifrost, midgard, niflheim, carbon, desktop, altdesk |
| Users | 1 | alapshin (primary) |
| Home-Manager Modules | 24 | Modular per concern |
| NixOS Modules | 4 | Reusable (backup, vpn, monica, webhost) |
| Custom Packages | 13 | Specialized tools and patches |
| Overlays | 2 | additions (custom), modifications (patches) |
| Total Nix Files | 150+ | Across hosts, modules, packages, users |

---

## Summary for Phase 2 Planning

**The current structure is:**
- ✅ Well-organized with clear separation of concerns
- ✅ Host-centric with shared base configs
- ✅ Modular home-manager setup
- ✅ Reusable NixOS modules for complex services
- ✅ Custom package ecosystem with overlays
- ✅ flake-parts based for maintainability

**Ready for extraction:**
- Audio system configuration
- Boot/kernel configuration
- Graphical desktop configuration
- Virtualization setup
- Gaming configuration
- Service-specific modules (web, database, monitoring, media, AI)
- Development tool stacks

**The refactoring approach should:**
1. Extract host-specific configs into reusable aspect modules
2. Follow the existing pattern in `modules/_nixos-modules/services/`
3. Define clear interfaces per aspect
4. Use configuration options (e.g., `services.{aspect}.enable`)
5. Preserve the hierarchy: root → common → category → host
