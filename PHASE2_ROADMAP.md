# Phase 2 Roadmap: Aspect Creation & Modularization

## Overview

Phase 2 will extract reusable configuration aspects from the existing host-specific configurations and modularize them into the flake-parts module system. This maintains the current architecture while enabling composition and reuse.

---

## Current State (Phase 1 Complete)

✅ **Root configuration:** Central entry point with state version, tools
✅ **Category bases:** common/, server/, personal/
✅ **7 physical hosts:** Configured with category inheritance
✅ **24 home-manager modules:** User-level configuration
✅ **4 reusable NixOS modules:** backup, vpn, monica, webhost
✅ **flake-parts structure:** Organized flake outputs

---

## Phase 2 Goals

1. **Extract aspects** from host-specific configs into reusable modules
2. **Create modular interfaces** for each aspect (enable/disable, options)
3. **Support composition** - aspects build on category bases
4. **Maintain compatibility** - no breaking changes to existing configs
5. **Enable cli selection** - future CLI tool can compose hosts from aspects

---

## Aspect Extraction Plan

### Tier 1: Core System Aspects (Weeks 1-2)

These are fundamental and widely used across multiple hosts.

#### 1.1 Audio System
**Source:** `hosts/personal/audio.nix`
**Target:** `modules/_nixos-modules/system/audio.nix`

**Options:**
```nix
options.services.audio = {
  enable = mkEnableOption "PipeWire audio system";
  wireplumber.enable = mkOption { default = true; };
  alsa.enable = mkOption { default = true; };
  alsa.support32Bit = mkOption { default = true; };
  pulse.enable = mkOption { default = true; };
};
```

**Hosts affected:**
- personal (enable by default)
- desktop (enable by default)
- carbon (enable by default)

**Implementation:**
```bash
$ cp hosts/personal/audio.nix modules/_nixos-modules/system/audio.nix
$ # Wrap in options.services.audio, add metaConfig
$ # Update modules/_nixos-modules/default.nix to export audio
$ # Update hosts/personal/default.nix to remove import, use services.audio.enable
```

**Testing:**
```bash
$ nixos-rebuild test -h desktop  # Should still have audio
$ nixos-rebuild test -h bifrost  # Should not have audio (enable = false by default)
```

---

#### 1.2 Boot Configuration
**Source:** `hosts/personal/boot.nix` (and similar in carbon)
**Target:** `modules/_nixos-modules/system/boot.nix`

**Considerations:**
- Personal hosts use different boot config than servers
- Some are UEFI, some may use Secure Boot
- Framework 13 (carbon) has specific boot requirements

**Options:**
```nix
options.system.boot = {
  secureBootEnable = mkOption { default = false; };
  loader = mkOption { default = "systemd"; }; # or "grub"
  kernelModules = mkOption { default = []; type = listOf str; };
};
```

**Hosts affected:**
- personal (base config)
- carbon (specific settings)
- desktop (specific settings)

---

#### 1.3 Bluetooth Support
**Source:** `hosts/personal/bluetooth.nix`
**Target:** `modules/_nixos-modules/hardware/bluetooth.nix`

**Status:** Simple, minimal config
**Hosts affected:** personal (enable by default), desktop, carbon

---

### Tier 2: Desktop Aspects (Weeks 3-4)

#### 2.1 Graphical Desktop / Plasma
**Source:** `hosts/personal/graphical-desktop.nix` (66 lines)
**Target:** `modules/_nixos-modules/desktop/plasma.nix`

**Complexity:** HIGH - this is a large config affecting:
- Display manager (SDDM)
- Desktop environment (KDE Plasma 6)
- Graphics drivers and hardware acceleration
- Input devices (keyboard, touchpad, mouse)
- X11/Wayland configuration
- XKB customization (US, RU, SR layouts)

**Options:**
```nix
options.desktop.plasma = {
  enable = mkEnableOption "KDE Plasma 6 desktop";
  wayland.enable = mkOption { default = true; };
  graphics = {
    enable32Bit = mkOption { default = true; };
    drivers = mkOption { default = ["amd"]; };
  };
  keyboard = {
    layouts = mkOption { default = ["us"]; };
    options = mkOption { default = ""; };
  };
  touchpad = {
    disableWhileTyping = mkOption { default = true; };
  };
};
```

**Hosts affected:**
- personal (enable by default)
- desktop (enable by default)
- carbon (enable by default)
- altdesk (enable by default)

**Implementation complexity:** Create nested module structure for clarity

---

#### 2.2 Gaming Stack
**Source:** `hosts/desktop/gaming.nix`
**Target:** `modules/_nixos-modules/desktop/gaming.nix`

**Scope:**
- Steam configuration
- Proton/Proton-GE
- Gamescope
- Game device rules (controllers, headsets)
- Vulkan drivers

**Options:**
```nix
options.desktop.gaming = {
  enable = mkEnableOption "gaming support (Steam, Proton)";
  steam.gamescopeSession.enable = mkOption { default = true; };
  steam.protontricks.enable = mkOption { default = true; };
};
```

**Hosts affected:**
- desktop (enable by default)
- Others could enable if desired

---

#### 2.3 Input Devices (detailed)
**Source:** Scattered in `hosts/personal/graphical-desktop.nix`
**Target:** `modules/_nixos-modules/hardware/input.nix`

**Covers:**
- Keyboard layout configuration
- Touchpad settings
- Mouse settings
- Input method (IBus, Fcitx, etc.)

---

### Tier 3: Service Aspects (Weeks 5-7)

Extract service-specific configurations from niflheim and servers.

#### 3.1 Web Services Module
**Source:** niflheim: caddy.nix, nginx.nix, authelia.nix
**Target:** `modules/_nixos-modules/services/web/`

**Structure:**
```
services/web/
├── caddy.nix                [Reverse proxy, TLS]
├── nginx.nix                [Alternative web server]
├── authelia.nix             [Authentication layer]
└── webhost-multi.nix        [Multi-domain hosting]
```

**Pattern:**
```nix
options.services.web = {
  caddy = {
    enable = mkEnableOption "Caddy reverse proxy";
    # ... caddy options
  };
  nginx = {
    enable = mkEnableOption "Nginx web server";
  };
  authelia = {
    enable = mkEnableOption "Authelia authentication";
  };
};
```

---

#### 3.2 Database Services
**Source:** niflheim: postgres.nix, influxdb.nix
**Target:** `modules/_nixos-modules/services/database/`

**Structure:**
```
services/database/
├── postgres.nix             [PostgreSQL]
├── influxdb.nix             [Time-series DB]
└── mariadb.nix              [MySQL alternative] (optional)
```

---

#### 3.3 Monitoring Stack
**Source:** niflheim: prometheus.nix, grafana.nix, scrutiny.nix
**Target:** `modules/_nixos-modules/services/monitoring/`

**Structure:**
```
services/monitoring/
├── prometheus.nix           [Metrics collection]
├── grafana.nix              [Visualization]
└── scrutiny.nix             [Disk health]
```

---

#### 3.4 Media Services
**Source:** niflheim: jellyfin.nix, transmission.nix, immich.nix, etc.
**Target:** `modules/_nixos-modules/services/media/`

**Structure:**
```
services/media/
├── jellyfin.nix             [Video streaming]
├── transmission.nix         [Torrent]
├── immich.nix               [Photos]
├── audiobookshelf.nix       [Audiobooks]
├── calibre.nix              [Books]
└── handbrake.nix            [Transcoding]
```

---

#### 3.5 Data/Sync Services
**Source:** niflheim: nextcloud.nix, paperless.nix, linkwarden.nix, etc.
**Target:** `modules/_nixos-modules/services/data/`

**Structure:**
```
services/data/
├── nextcloud.nix            [File sync]
├── syncthing.nix            [P2P sync]
├── paperless.nix            [Document OCR]
└── linkwarden.nix           [Bookmarks]
```

---

#### 3.6 AI/ML Services
**Source:** niflheim: ai.nix, docling.nix, searx.nix
**Target:** `modules/_nixos-modules/services/ai/`

**Structure:**
```
services/ai/
├── open-webui.nix           [LLM interface]
├── docling.nix              [Doc parsing]
└── searx.nix                [Meta search]
```

---

### Tier 4: Development Aspects (Weeks 8)

These are mostly in home-manager but could have system-level aspects.

#### 4.1 Development Tools (System)
**Source:** Scattered across home-manager
**Target:** `modules/_nixos-modules/development/`

**Options:**
```nix
options.development = {
  enable = mkEnableOption "development tools";
  languages = {
    rust.enable = mkOption { default = false; };
    go.enable = mkOption { default = false; };
    python.enable = mkOption { default = false; };
    nodejs.enable = mkOption { default = false; };
  };
};
```

---

#### 4.2 Containers
**Source:** `users/alapshin/home/podman.nix`
**Target:** `modules/_nixos-modules/system/containers.nix`

**Covers:**
- Podman/Docker daemon
- Container networking
- Volume management

---

#### 4.3 Documentation/LaTeX
**Source:** `users/alapshin/home/texlive.nix`
**Target:** `modules/_nixos-modules/development/texlive.nix`

---

## Implementation Workflow

### For Each Aspect

1. **Create module file**
   ```bash
   mkdir -p modules/_nixos-modules/{category}
   touch modules/_nixos-modules/{category}/{aspect}.nix
   ```

2. **Convert from host config to module**
   ```nix
   # Old (in host config):
   services.pipewire = { enable = true; ... };
   
   # New (as module with options):
   options.services.audio = {
     enable = mkEnableOption "description";
   };
   config = mkIf config.services.audio.enable {
     services.pipewire = { enable = true; ... };
   };
   ```

3. **Register in registry**
   ```nix
   # modules/_nixos-modules/default.nix
   {
     # ... existing ...
     audio = import ./system/audio.nix;
     bluetooth = import ./hardware/bluetooth.nix;
   }
   ```

4. **Update host configs**
   - Remove `import ./audio.nix` from `hosts/personal/default.nix`
   - Add `services.audio.enable = lib.mkDefault true;` to `hosts/personal/default.nix`

5. **Test**
   ```bash
   nix flake check
   nixos-rebuild build -h {host}
   ```

6. **Document**
   - Add entry to MODULES.md
   - Note dependencies and interactions

---

## Directory Structure After Phase 2

```
modules/_nixos-modules/
├── default.nix
├── system/
│   ├── audio.nix
│   ├── boot.nix
│   ├── containers.nix
│   └── virtualization.nix
├── hardware/
│   ├── bluetooth.nix
│   ├── graphics.nix
│   └── input.nix
├── desktop/
│   ├── plasma.nix
│   ├── gaming.nix
│   └── sddm.nix
├── services/
│   ├── web/
│   │   ├── caddy.nix
│   │   ├── nginx.nix
│   │   └── authelia.nix
│   ├── database/
│   │   ├── postgres.nix
│   │   └── influxdb.nix
│   ├── monitoring/
│   │   ├── prometheus.nix
│   │   ├── grafana.nix
│   │   └── scrutiny.nix
│   ├── media/
│   │   ├── jellyfin.nix
│   │   ├── transmission.nix
│   │   ├── immich.nix
│   │   └── ...
│   ├── data/
│   │   ├── nextcloud.nix
│   │   ├── paperless.nix
│   │   └── ...
│   ├── ai/
│   │   ├── open-webui.nix
│   │   └── docling.nix
│   ├── backup/          [existing - move here]
│   │   └── borgbackup.nix
│   ├── networking/      [existing - expand]
│   │   ├── vpn.nix
│   │   ├── wireguard.nix
│   │   └── netbird.nix
│   └── web-apps/        [existing - expand]
│       ├── monica.nix
│       └── ...
└── shared/              [if needed]
    └── common.nix       [shared definitions]
```

---

## Testing Strategy

### Unit Tests
- Each aspect module can be tested in isolation
- Example: `nix build .#nixosConfigurations.test-audio`

### Integration Tests
- Test aspect combinations
- Example: desktop (gaming + plasma + audio)

### Regression Tests
- Build all existing hosts with new modules
- Ensure behavior unchanged: `nixos-rebuild build -h {host}`

### Scenarios to Test

| Scenario | Hosts | Expected |
|----------|-------|----------|
| Audio disabled | bifrost | No PipeWire |
| Audio enabled | desktop | PipeWire + ALSA |
| Gaming disabled | bifrost | No Steam |
| Gaming enabled | desktop | Steam + Proton |
| Plasma disabled | bifrost | No KDE |
| Plasma enabled | desktop | KDE Plasma 6 |

---

## Success Criteria

- [ ] All Tier 1 aspects extracted and working
- [ ] All Tier 2 aspects extracted and working
- [ ] All Tier 3 aspects extracted (phased)
- [ ] All existing hosts build without errors
- [ ] No functional regression (services still start, config still works)
- [ ] Module options are clear and documented
- [ ] Module structure is consistent across types
- [ ] Reusable modules can be imported in multiple hosts

---

## Rollback Plan

If extraction breaks a host config:

1. **Immediate:** Revert the module import changes
2. **Diagnostic:** Compare old and new configs with `nix diff`
3. **Fix:** Adjust module options to match original behavior
4. **Re-test:** Rebuild affected host

Example:
```bash
$ git diff hosts/personal/default.nix | head -20
# Shows what imports were changed

$ git checkout hosts/personal/default.nix
# Revert to working state

$ nix rebuild -h desktop --dry-run
# Verify it builds
```

---

## Timeline Estimate

| Tier | Aspects | Effort | Timeline |
|------|---------|--------|----------|
| 1 | Audio, Boot, BT | 5 modules | Week 1-2 |
| 2 | Plasma, Gaming, Input | 3 modules | Week 3-4 |
| 3 | Web, DB, Monitoring, Media, Data, AI | 15+ modules | Week 5-7 |
| 4 | DevTools, Containers, Docs | 3 modules | Week 8 |

**Total: 8 weeks** (accelerate by parallelizing Tier 3)

---

## Stretch Goals (Phase 2+)

- [ ] CLI tool for host composition (`nix-config compose --aspects audio gaming plasma`)
- [ ] Aspect dependency resolution (e.g., gaming requires graphics)
- [ ] Documentation auto-generation from module options
- [ ] Home-manager aspect extraction (currently well-modularized)
- [ ] Package set composition (e.g., gaming-packages aspect)

---

## Related Documents

- `CONFIGURATION_ANALYSIS.md` - Detailed structure
- `CONFIGURATION_SUMMARY.txt` - Visual overview
- `QUICK_REFERENCE.md` - File locations
- `MIGRATION_PLAN.md` - flake-parts migration (completed)

---

