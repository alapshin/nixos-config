# Quick Reference: Configuration File Locations

## Root Files

| File | Purpose | Lines |
|------|---------|-------|
| `flake.nix` | Flake entry point, inputs | 77 |
| `configuration.nix` | Root config (all systems) | 21 |
| `flake.lock` | Dependency lock file | - |
| `pkgs-config.nix` | Shared nixpkgs config | - |
| `treefmt-config.nix` | Code formatter config | - |

## Hosts Directory (`/hosts/`)

### Common Base - `/hosts/common/` (7 files)
```
common/
├── default.nix          # Entry point: imports all, boot, security, hardware
├── nix.nix              # Nix daemon: GC, flakes, optimization
├── openssh.nix          # SSH hardening + known hosts
├── secrets.nix          # sops-nix secret decryption
├── backup.nix           # Borgbackup configuration
├── services.nix         # Core services (syslogd, resolved, etc)
└── networking.nix       # Firewall, DNS, default networking
```

**Key Exports:**
- `services.backup` - Borgbackup service
- `boot.kernelPackages` - Zen kernel
- `security.sudo`, `security.tpm2` - Security hardening

---

### Server Category - `/hosts/server/` (5 files)
```
server/
├── default.nix          # Entry point: imports nix, ssh, networking
├── nix.nix              # Server-specific Nix daemon settings
├── openssh.nix          # Server SSH hardening
├── networking.nix       # TCP BBR, network tuning
└── virtualization.nix   # libvirtd, KVM, QEMU
```

**Inherited By:** bifrost, midgard, niflheim

**Key Settings:**
- `boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr"`
- `users.mutableUsers = false` (immutable user config)
- `services.userborn.enable = true`

---

### Personal Category - `/hosts/personal/` (10 files)
```
personal/
├── default.nix          # Entry point: imports and locale settings
├── audio.nix            # PipeWire, ALSA, RTKit, 32-bit audio
├── boot.nix             # Boot loader + kernel settings
├── bluetooth.nix        # Bluetooth device support
├── graphical-desktop.nix # Plasma6, Wayland/X11, input devices
├── networking.nix       # Desktop-specific network config
├── nix.nix              # Desktop Nix settings
├── programs.nix         # System programs
├── services.nix         # Desktop services (avahi, geoclue2, kmscon)
└── virtualization.nix   # libvirtd, KVM for VMs
```

**Inherited By:** desktop, carbon, altdesk

**Key Settings:**
- `services.desktopManager.plasma6.enable = true`
- `services.displayManager.sddm.wayland.enable = true`
- Keyboard layouts: US, RU (Serbian variant), SR
- Locale: en_US, en_DK, en_IE, ru_RU

---

### VPS Hosts

#### bifrost - `/hosts/bifrost/` (6 files)
**Parent:** server
**Role:** VPN relay

```
bifrost/
├── default.nix          # Imports: openssh, secrets, xray-server, networking, hardware
├── openssh.nix          # SSH config
├── secrets.nix          # sops secrets (root password, etc)
├── xray-server.nix      # Xray/Trojan VPN server
├── networking.nix       # Network interface config
├── hardware-configuration.nix # Linode-specific hardware
└── disk-config.nix      # disko partition layout
```

#### midgard - `/hosts/midgard/` (6 files)
**Parent:** server
**Role:** Web server + secondary VPN relay

```
midgard/
├── default.nix          # Imports: openssh, secrets, caddy, xray-server, networking, hardware
├── openssh.nix          # SSH config
├── secrets.nix          # sops secrets
├── caddy.nix            # Reverse proxy + TLS termination
├── xray-server.nix      # Secondary VPN server
├── networking.nix       # Network interface config
├── disk-config.nix      # disko partition layout
└── facter.json          # Machine facts (Vultr)
```

#### niflheim - `/hosts/niflheim/` (44 files)
**Parent:** server
**Role:** Home server hub with 40+ services

**Web/Proxy:**
- caddy.nix, nginx.nix, authelia.nix

**Media:**
- jellyfin.nix, immich.nix, audiobookshelf.nix, calibre.nix (disabled), transmission.nix

**Data/Sync:**
- nextcloud.nix, syncthing.nix, paperless.nix, linkwarden.nix, changedetection.nix

**Social:**
- freshrss.nix, forgejo.nix (disabled), monica.nix, pinepods.nix, karakeep.nix

**AI/ML:**
- ai.nix, docling.nix, searx.nix, handbrake.nix

**Infrastructure:**
- postgres.nix, influxdb.nix, lldap.nix, prometheus.nix, grafana.nix, scrutiny.nix, wireguard.nix, xray-server.nix

**Admin:**
- backup.nix, dashboard.nix, anki.nix, networking.nix, hardware-configuration.nix, disk-config.nix, secrets.nix, webhost.nix

---

### Desktop Hosts

#### desktop - `/hosts/desktop/` (9 files)
**Parent:** personal
**Role:** Primary workstation with gaming

```
desktop/
├── default.nix          # Imports: backup, gaming, networking, secrets, services, users, virt, graphical-desktop, hw
├── backup.nix           # Borgbackup configuration
├── gaming.nix           # Steam, Proton, Gamescope, game device rules
├── networking.nix       # Network config
├── secrets.nix          # sops secrets
├── services.nix         # Avahi, Geoclue2, KMScon, SSH
├── users.nix            # User accounts (alapshin)
├── virtualization.nix   # libvirtd for VMs
├── graphical-desktop.nix # Plasma6, Wayland
└── hardware-configuration.nix # Desktop hardware
```

#### carbon - `/hosts/carbon/` (8 files)
**Parent:** personal
**Role:** Portable development laptop

```
carbon/
├── default.nix          # Imports: boot, backup, secrets, networking, services, users, graphical-desktop, hw
├── boot.nix             # Secure boot + kernel (Framework 13)
├── backup.nix           # Borgbackup
├── secrets.nix          # sops secrets
├── networking.nix       # Network config
├── services.nix         # Services
├── users.nix            # User config
├── graphical-desktop.nix # Plasma6
└── hardware-configuration.nix # Framework 13 specific
```

#### altdesk - `/hosts/altdesk/` (4 files)
**Parent:** personal
**Role:** Secondary workstation (minimal)

```
altdesk/
├── default.nix          # Imports: networking, graphical-desktop, hardware
├── networking.nix       # Network config
├── graphical-desktop.nix # Plasma6
└── hardware-configuration.nix
```

**Special:** Timezone = Europe/Moscow (vs others: Europe/Belgrade)

---

### macOS Host

#### macbook - `/hosts/macbook/` (1 file)
**Parent:** none (Darwin-only)
**Role:** macOS development environment

```
macbook/
└── default.nix          # Darwin configuration
                         # - homebrew setup
                         # - system defaults (dock, finder, keyboard)
                         # - nix-darwin configuration
                         # - app management (Xcode, games, etc)
                         # - macOS-specific limits
```

**Features:**
- Homebrew enabled with casks and masApps
- nix-homebrew for reproducibility
- macOS system defaults configured
- Fish shell with Babelfish

---

## Modules Directory (`/modules/`)

### Flake-Parts Structure - `/modules/` (7 files)

```
modules/
├── default.nix          # Main entry point
│                        # imports: lib, pkgs, overlays, formatter, dev-shells, exported-modules
│                        # sets: systems = import inputs.systems
│
├── lib.nix              # Extended lib = nixpkgs.lib + home-manager.lib + custom lib
├── pkgs.nix             # perSystem: _module.args.pkgs (nixpkgs instantiation)
├── overlays.nix         # flake: overlays setup
├── formatter.nix        # perSystem: formatter (treefmt)
├── dev-shells.nix       # perSystem: devShells
└── exported-modules.nix # flake: nixosModules, homeModules exports
```

---

### Reusable NixOS Modules - `/modules/_nixos-modules/` (4 modules)

```
_nixos-modules/
├── default.nix                              # Registry
├── services/
│   ├── backup/
│   │   └── borgbackup.nix                   # Borgbackup module
│   ├── networking/
│   │   └── vpn.nix                          # VPN abstraction (Xray/Wireguard)
│   ├── web-apps/
│   │   └── monica5.nix                      # Monica CRM module
│   └── web-server/
│       └── webhost.nix                      # Multi-domain web hosting
```

**Usage:** Imported by hosts via flake outputs, used in niflheim and other servers

---

### Reusable Home-Manager Modules - `/modules/_home-modules/` (1 module)

```
_home-modules/
├── default.nix          # Registry
└── secrets.nix          # Secret management helper for home-manager
```

---

## Users Directory (`/users/`)

### Primary User - `/users/alapshin/` (27 files total)

```
alapshin/
├── default.nix          # User definition
│                        # - UID: 1000
│                        # - Shell: fish
│                        # - Groups: wheel, audio, docker, etc
│                        # - Packages: media, office, dev, crypto, KDE apps
│
├── secrets/             # Secret management
│   ├── build/
│   │   └── secrets.json # Built/compiled secrets
│   └── secrets.yaml     # Source secrets (encrypted via sops)
│
└── home/                # 24 home-manager modules
    ├── home.nix         # Central entry + imports all modules
    ├── default.nix      # Wrapper (imports home.nix)
    │
    ├── [Core]
    │   ├── home.nix     # Central imports, home settings, XDG
    │   ├── variables.nix # Environment variables, locale
    │   └── theming.nix  # Catppuccin, visual theming
    │
    ├── [Shell]
    │   ├── shell.nix    # Fish shell, atuin, fzf, tools
    │   ├── programs.nix # System programs (keepassxc, etc)
    │   └── services.nix # User-level services (syncthing)
    │
    ├── [Development]
    │   ├── development.nix  # Compilers, runtimes, dev tools
    │   ├── git.nix          # Git config, signing
    │   ├── neovim.nix       # Neovim editor
    │   └── neovim.lua       # Lua config (separate file)
    │
    ├── [Applications]
    │   ├── firefox.nix      # Firefox + addons
    │   ├── chromium.nix     # Chromium browser
    │   ├── thunderbird.nix  # Email
    │   ├── ssh.nix          # SSH client
    │   ├── gnupg.nix        # GnuPG keys
    │   └── podman.nix       # Container runtime
    │
    ├── [Desktop/Media]
    │   ├── plasma.nix       # KDE Plasma config
    │   ├── gaming.nix       # Lutris, Proton, games
    │   ├── texlive.nix      # LaTeX packages
    │   ├── syncthing.nix    # File sync
    │   ├── ai.nix           # AI tools
    │   └── anki.nix         # Anki flashcards
    │
    └── [Misc]
        └── opencode         # Directory (custom config)
```

---

## Overlays and Packages

### Overlays - `/overlays/default.nix` (59 lines)

Two overlays defined:

1. **additions** - Custom packages
   ```nix
   additions = final: prev: import ../packages { inherit final prev; }
   ```

2. **modifications** - Package overrides
   - karakeep: Patch for next.js 15.3.8
   - mos: Version override (4.0.0)
   - open-webui: Add postgres dependencies
   - changedetection-io: Add flask-babel, diff-match-patch
   - pythonPackagesExtensions: Add autobean

---

### Custom Packages - `/packages/` (13 items)

```
packages/
├── default.nix          # Package registry
├── androidenv/          # Android dev environment
├── autobean/            # Beancount Python extension
├── cuesplit/            # Audio CUE splitter
├── firefox-addons/      # Custom Firefox extensions
├── firefox-ui-fix/      # Firefox UI patches
├── hunspell/            # Custom spell-check dicts
│   └── sr/              # Serbian dictionary
├── monica/              # Monica CRM package
├── pg-fix-collation/    # PostgreSQL collation fix
├── sandbox-runtime/     # Sandbox execution
└── xkb/                 # Custom keyboard layouts (US, RU, SR)
```

---

## Documentation Files

| File | Purpose |
|------|---------|
| `CONFIGURATION_ANALYSIS.md` | Detailed structure analysis (this repo's spec) |
| `CONFIGURATION_SUMMARY.txt` | Visual ASCII summary |
| `QUICK_REFERENCE.md` | This file - file locations |
| `MIGRATION_PLAN.md` | flake-parts migration plan |
| `MIGRATION_COMPLETE.md` | Migration status |
| `dendritic-migration.md` | Detailed migration walkthrough |
| `README.md` | Project overview |

---

## Key File Statistics

| Category | Count | Files |
|----------|-------|-------|
| Host directories | 10 | bifrost, midgard, niflheim, carbon, desktop, altdesk, macbook, common, server, personal |
| NixOS host configs | 6 | bifrost, midgard, niflheim, carbon, desktop, altdesk |
| Home-manager modules | 24 | In users/alapshin/home/ |
| Reusable NixOS modules | 4 | In modules/_nixos-modules/ |
| Reusable HM modules | 1 | In modules/_home-modules/ |
| Custom packages | 13 | In packages/ |
| Overlays | 2 | In overlays/default.nix |
| Flake-parts modules | 7 | In modules/ |
| Total .nix files | 150+ | Across entire repo |

---

## Important Locations for Phase 2

When creating new aspects, they should be added to:

1. **NixOS Aspects:** `/modules/_nixos-modules/services/{category}/{aspect}.nix`
   - Example: `services/audio/pipewire.nix`
   - Register in `/modules/_nixos-modules/default.nix`

2. **Home-Manager Aspects:** `/users/alapshin/home/{aspect}.nix`
   - Import in `/users/alapshin/home/home.nix`

3. **Custom Packages:** `/packages/{name}/default.nix`
   - Register in `/packages/default.nix`

4. **Overlays:** `/overlays/default.nix`
   - Add to `modifications` overlay

---

## Aspect Inheritance Pattern

```
Per-aspect file: /modules/_nixos-modules/services/{category}/{aspect}.nix

Structure:
{ lib, pkgs, config, ... }:

{
  options.services.{aspect} = {
    enable = mkEnableOption "description";
    # ... more options
  };

  config = mkIf config.services.{aspect}.enable {
    # Implementation
  };
}
```

Usage in host config:
```nix
# In hosts/{host}/default.nix
imports = [ ../common ];

# OR in category base:
services.{aspect}.enable = true;
```

---

## Next Steps (Phase 2 Guidance)

1. **Identify aspects to extract** from hosts/personal/ and hosts/desktop/
   - Priority: audio, boot, graphical-desktop, gaming, virtualization

2. **Create module files** in `/modules/_nixos-modules/`
   - Follow pattern: `services/{category}/{aspect}.nix`
   - Define options and implementation

3. **Register in** `/modules/_nixos-modules/default.nix`

4. **Test by enabling** in host configs:
   ```nix
   services.{aspect}.enable = true;
   ```

5. **Update imports** in hosts to use new modules

6. **Preserve** category structure (common, server, personal)
   - Aspects build ON these, not replace them
