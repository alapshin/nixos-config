# Migration Plan: Current flake-parts Structure to Dendritic Nix

## 1. What is Dendritic Nix

Dendritic is a **pattern** (not a library) for writing Nix configurations where:

- Every `.nix` file is a **flake-parts module**
- Each file configures a single **aspect** (feature/concern) across multiple
  configuration **classes** (nixos, darwin, homeManager)
- Files are organized by *what they do*, not *where they run*
- No `specialArgs` -- values are shared via `let` bindings or flake-parts options
- No manual imports -- all files are auto-loaded (typically via `import-tree`)

### Key concept: `flake.modules.<class>.<aspect>`

```nix
# modules/ssh.nix
{ inputs, ... }: {
  flake.modules.nixos.ssh = {
    services.openssh.enable = true;
    # ...
  };
  flake.modules.darwin.ssh = {
    # macOS SSH config
  };
  flake.modules.homeManager.ssh = {
    programs.ssh = { /* ... */ };
  };
}
```

Hosts are then assembled by selecting aspects:

```nix
# modules/hosts.nix
{ inputs, ... }: {
  flake.nixosConfigurations.myhost = inputs.nixpkgs.lib.nixosSystem {
    modules = with inputs.self.modules.nixos; [ ssh vpn gaming ];
  };
}
```

---

## 2. Current Architecture Analysis

### 2.1 File Semantics (3 different kinds today)

| Location | Semantic | Count |
|----------|----------|-------|
| `flake/*.nix` | flake-parts modules | 9 files |
| `hosts/**/*.nix` | NixOS or Darwin modules | ~70 files |
| `users/**/home/*.nix` | Home Manager modules | ~20 files |
| `modules/nixos/**/*.nix` | NixOS modules (exported) | 4 files |
| `modules/home/*.nix` | Home Manager modules (exported) | 1 file |

In Dendritic, **all** of these become flake-parts modules.

### 2.2 Host Composition Model (layered inheritance)

```
NixOS servers:    common -> server  -> <host-specific>
NixOS personal:   common -> personal -> <host-specific> -> user modules
Darwin:           <host-specific> (standalone)
```

Each layer is a collection of NixOS/Darwin modules imported via file paths. Features
are **implicitly bundled** into layers rather than explicitly selected per host.

### 2.3 Cross-Cutting Concerns (features split across files today)

Many features are currently scattered across multiple directories:

| Feature | NixOS (hosts/) | HM (users/home/) | Notes |
|---------|---------------|-------------------|-------|
| SSH | `common/openssh.nix`, `server/openssh.nix`, `bifrost/openssh.nix`, `midgard/openssh.nix`, `carbon/services.nix`, `desktop/services.nix` | `ssh.nix` | 6+ NixOS files + 1 HM file |
| Gaming | `desktop/gaming.nix` | `gaming.nix` | NixOS Steam + HM Mangohud |
| Virtualization | `server/virtualization.nix`, `personal/virtualization.nix`, `desktop/virtualization.nix` | `podman.nix` | 3 NixOS files + 1 HM file |
| Audio | `personal/audio.nix` | (none) | NixOS only |
| Bluetooth | `personal/bluetooth.nix` | (none) | NixOS only |
| Theming | `personal/graphical-desktop.nix` | `theming.nix` | Split across classes |
| Networking | `common/networking.nix`, `server/networking.nix`, `personal/networking.nix`, per-host `networking.nix` | (none) | 3 layers + per-host |
| Backup | `common/backup.nix`, per-host `backup.nix` | (none) | Shared keys + per-host jobs |
| Secrets | `common/secrets.nix`, per-host `secrets.nix` | `modules/home/secrets.nix` | NixOS + HM |
| Nix settings | `common/nix.nix`, `server/nix.nix`, `personal/nix.nix` | (none) | 3 layers |
| Xray/VPN | `bifrost/xray-server.nix`, `midgard/xray-server.nix`, `niflheim/xray-server.nix`, `modules/nixos/vpn.nix` | (none) | Per-host + module |
| KDE Plasma | `personal/graphical-desktop.nix` | `plasma.nix` | NixOS + HM |
| Neovim | (none) | `neovim.nix` | HM only (420 lines) |
| Firefox | (none) | `firefox.nix` | HM only (210 lines) |
| Shell | `personal/programs.nix` (fish/zsh enable) | `shell.nix` | NixOS enables + HM configures |
| Syncthing | (none) | `syncthing.nix` | HM only |
| Development | `personal/programs.nix` (java) | `development.nix` | NixOS java + HM tools |

### 2.4 Anti-Patterns (from Dendritic perspective)

1. **`specialArgs` everywhere** -- `self`, `lib`, `inputs`, `dotfileDir`, `username`
   all passed via `specialArgs`/`extraSpecialArgs`
2. **Files have different semantic meanings** -- must know whether a file is NixOS,
   Darwin, HM, or flake-parts to import it correctly
3. **Manual imports** -- every host and module path is explicitly listed
4. **Host-centric organization** -- features are bundled into role layers
   (`common`, `server`, `personal`) rather than individually selectable
5. **Shared home-manager module list duplicated** in `shared.nix`, `home.nix`
6. **Extended lib** passed through `_module.args` and `specialArgs`

---

## 3. Target Architecture

### 3.1 Directory Structure

```
flake.nix                           -- Minimal: inputs + mkFlake + import-tree ./modules
modules/
  # -- Infrastructure --
  lib.nix                           -- Extended lib via flake-parts options
  pkgs.nix                          -- perSystem pkgs instantiation
  overlays.nix                      -- flake.overlays
  formatter.nix                     -- perSystem formatter (treefmt)
  dev-shells.nix                    -- perSystem devShells

  # -- Reusable NixOS/HM modules (options definitions) --
  nixos-modules/
    backup.nix                      -- services.backup options (borgbackup helper)
    vpn.nix                         -- services.vpn options
    monica.nix                      -- services.monica options
    webhost.nix                     -- services.webhost options
  home-modules/
    secrets.nix                     -- secrets options

  # -- Aspects (feature-centric, cross-class) --
  nix.nix                           -- Nix daemon settings (nixos + darwin)
  ssh.nix                           -- SSH server + client (nixos + darwin + homeManager)
  secrets.nix                       -- SOPS setup (nixos + darwin + homeManager)
  networking.nix                    -- Base networking (nixos)
  shell.nix                         -- Shell setup (nixos + homeManager)
  audio.nix                         -- PipeWire audio (nixos)
  bluetooth.nix                     -- Bluetooth (nixos)
  boot.nix                          -- Boot loader defaults (nixos)
  graphical-desktop.nix             -- KDE Plasma, Wayland, SDDM (nixos + homeManager)
  theming.nix                       -- Catppuccin theming (homeManager)
  virtualization.nix                -- Podman, libvirtd (nixos + homeManager)
  gaming.nix                        -- Steam + Mangohud (nixos + homeManager)
  backup.nix                        -- Borg backup (nixos)
  neovim.nix                        -- Neovim/nvf (homeManager)
  firefox.nix                       -- Firefox browser (homeManager)
  chromium.nix                      -- Chromium browser (homeManager)
  thunderbird.nix                   -- Email client (homeManager)
  git.nix                           -- Git + lazygit (homeManager)
  gnupg.nix                         -- GPG (homeManager)
  ai.nix                            -- AI tools (homeManager)
  development.nix                   -- Dev tools, JDK, IDEs (nixos + homeManager)
  syncthing.nix                     -- Syncthing (homeManager)
  programs.nix                      -- Misc programs & fonts (nixos + homeManager)
  services.nix                      -- User services (homeManager)
  variables.nix                     -- XDG env vars (homeManager)
  texlive.nix                       -- LaTeX/Typst (homeManager)
  anki.nix                          -- Anki (homeManager)
  podman.nix                        -- Podman user service (homeManager)

  # -- Xray/Proxy aspect --
  xray.nix                          -- Xray server config (nixos, parameterized)

  # -- Niflheim services (each is an aspect) --
  niflheim/
    ai.nix                          -- AI services (nixos)
    anki.nix                        -- Anki sync server (nixos)
    audiobookshelf.nix              -- Audiobookshelf (nixos)
    authelia.nix                    -- Authelia SSO (nixos)
    bitmagnet.nix                   -- Bitmagnet (nixos)
    caddy.nix                       -- Caddy reverse proxy (nixos)
    calibre.nix                     -- Calibre-web (nixos)
    changedetection.nix             -- Change detection (nixos)
    dashboard.nix                   -- Homepage dashboard (nixos)
    docling.nix                     -- Docling (nixos)
    forgejo.nix                     -- Forgejo git forge (nixos)
    freshrss.nix                    -- FreshRSS (nixos)
    grafana.nix                     -- Grafana (nixos)
    handbrake.nix                   -- HandBrake (nixos)
    immich.nix                      -- Immich photos (nixos)
    influxdb.nix                    -- InfluxDB (nixos)
    jellyfin.nix                    -- Jellyfin media (nixos)
    karakeep.nix                    -- Karakeep bookmarks (nixos)
    linkwarden.nix                  -- Linkwarden (nixos)
    lldap.nix                       -- LLDAP directory (nixos)
    monica.nix                      -- Monica CRM (nixos)
    netbird.nix                     -- Netbird VPN (nixos)
    nextcloud.nix                   -- Nextcloud (nixos)
    nginx.nix                       -- Nginx (nixos)
    ntfy.nix                        -- NTFY notifications (nixos)
    paperless.nix                   -- Paperless-ngx (nixos)
    pinepods.nix                    -- Pinepods (nixos)
    postgres.nix                    -- PostgreSQL (nixos)
    prometheus.nix                  -- Prometheus (nixos)
    scrutiny.nix                    -- Scrutiny disk health (nixos)
    searx.nix                       -- SearX search (nixos)
    servarr.nix                     -- Servarr stack (nixos)
    transmission.nix                -- Transmission (nixos)
    wireguard.nix                   -- WireGuard (nixos)

  # -- Host definitions --
  hosts/
    bifrost.nix                     -- bifrost host definition
    midgard.nix                     -- midgard host definition
    niflheim.nix                    -- niflheim host definition
    carbon.nix                      -- carbon host definition
    desktop.nix                     -- desktop host definition
    altdesk.nix                     -- altdesk host definition
    macbook.nix                     -- macbook host definition

  # -- Hardware (host-specific, cannot be shared) --
  hardware/
    bifrost.nix                     -- bifrost disk + hardware
    midgard.nix                     -- midgard disk + hardware + facter
    niflheim.nix                    -- niflheim disk + hardware
    carbon.nix                      -- carbon disk + hardware
    desktop.nix                     -- desktop disk + hardware
    altdesk.nix                     -- altdesk disk + hardware

  # -- User definitions --
  users/
    alapshin.nix                    -- User account + home-manager wiring

  # -- Standalone home-manager configs --
  home-configurations.nix           -- homeConfigurations output
```

### 3.2 Key Design Principles

1. **Every file under `modules/` is a flake-parts module** -- same semantic meaning
2. **Auto-import** via `import-tree` -- no manual file listing
3. **Aspects define `flake.modules.<class>.<aspect>`** -- hosts select aspects
4. **No `specialArgs`** -- use `let` bindings and flake-parts `_module.args`
5. **Host files are small** -- just select which aspects to include
6. **Hardware configs remain host-specific** -- hardware cannot be abstracted

---

## 4. Step-by-Step Migration

### Phase 1: Foundation (Infrastructure modules)

These modules are already close to Dendritic form in the current `flake/` directory.
The main change is moving them into `modules/` for auto-import.

#### Step 1.1: Add `import-tree` input

```nix
# In flake.nix inputs:
import-tree.url = "github:vic/import-tree";
```

#### Step 1.2: Rewrite `flake.nix` to use `import-tree`

```nix
outputs = inputs@{ flake-parts, import-tree, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } (import-tree ./modules);
```

This replaces the explicit `imports = [ ./flake/shared.nix ... ]` list. All `.nix`
files under `modules/` are automatically loaded as flake-parts modules.

#### Step 1.3: Move `flake/*.nix` into `modules/`

| Current | Target |
|---------|--------|
| `flake/pkgs.nix` | `modules/pkgs.nix` |
| `flake/overlays.nix` | `modules/overlays.nix` |
| `flake/formatter.nix` | `modules/formatter.nix` |
| `flake/dev-shells.nix` | `modules/dev-shells.nix` |
| `flake/modules.nix` | `modules/exported-modules.nix` |

Delete `flake/shared.nix` -- its contents (`extLib`, `sharedHomeConfig`) will be
replaced by `modules/lib.nix` and direct aspect composition.

Delete `flake/nixos.nix`, `flake/darwin.nix`, `flake/home.nix` -- replaced by
host definition files and the new aspect-based composition.

#### Step 1.4: Create `modules/lib.nix`

Replace `extLib` and `sharedHomeConfig` with flake-parts options:

```nix
# modules/lib.nix
{ inputs, ... }:
let
  extLib = inputs.nixpkgs.lib.extend
    (_: prev: inputs.home-manager.lib // (import ../lib { lib = prev; }));
in {
  _module.args.extLib = extLib;
}
```

#### Step 1.5: Create `modules/pkgs.nix`

```nix
# modules/pkgs.nix
{ inputs, self, ... }: {
  systems = import inputs.systems;
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = import ../pkgs-config.nix { lib = inputs.nixpkgs.lib; };
      overlays = (builtins.attrValues self.overlays)
        ++ [ inputs.nur.overlays.default ];
    };
  };
}
```

#### Step 1.6: Rename `modules/nixos/` and `modules/home/`

The existing `modules/nixos/*.nix` and `modules/home/*.nix` define NixOS/HM module
options (backup, vpn, monica, webhost, secrets). These are **not** flake-parts
modules -- they are option definitions that get imported into NixOS/HM evaluations.

Move them to avoid collision with the new `modules/` directory:

| Current | Target |
|---------|--------|
| `modules/nixos/services/backup/borgbackup.nix` | `modules/nixos-modules/backup.nix` |
| `modules/nixos/services/networking/vpn.nix` | `modules/nixos-modules/vpn.nix` |
| `modules/nixos/services/web-apps/monica5.nix` | `modules/nixos-modules/monica.nix` |
| `modules/nixos/services/web-server/webhost.nix` | `modules/nixos-modules/webhost.nix` |
| `modules/home/secrets.nix` | `modules/home-modules/secrets.nix` |

These directories must be prefixed with `_` (e.g. `_nixos-modules/`) or excluded
from auto-import. With `import-tree`, any path containing `/_` is ignored.

So the final locations are:

| Current | Target |
|---------|--------|
| `modules/nixos/` | `modules/_nixos-modules/` |
| `modules/home/` | `modules/_home-modules/` |

Update `modules/exported-modules.nix`:

```nix
# modules/exported-modules.nix
{ ... }: {
  flake.nixosModules = {
    backup = import ./_nixos-modules/backup.nix;
    vpn = import ./_nixos-modules/vpn.nix;
    monica = import ./_nixos-modules/monica.nix;
    webhost = import ./_nixos-modules/webhost.nix;
  };
  flake.homeModules = {
    secrets = import ./_home-modules/secrets.nix;
  };
}
```

---

### Phase 2: Convert Aspects (feature-centric modules)

This is the core of the migration. Each aspect file defines
`flake.modules.<class>.<aspect>` for all relevant classes.

#### Step 2.1: SSH aspect

Merge 6+ files into one:

```nix
# modules/ssh.nix
{ inputs, config, ... }:
let
  knownHosts = {
    "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    "gitlab.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
    "git.sr.ht".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
    "u399502.your-storagebox.de".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
  };
in {
  # NixOS: SSH server + known hosts + key exchange hardening
  flake.modules.nixos.ssh = {
    programs.ssh.knownHosts = knownHosts;
    services.openssh.settings.KexAlgorithms = [
      "curve25519-sha256" "curve25519-sha256@libssh.org"
      "diffie-hellman-group16-sha512" "diffie-hellman-group18-sha512"
      "sntrup761x25519-sha512@openssh.com"
    ];
  };

  # Home Manager: SSH client config
  flake.modules.homeManager.ssh = { pkgs, lib, config, ... }: {
    services.ssh-agent.enable = pkgs.stdenv.hostPlatform.isLinux;
    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
      serverAliveInterval = 60;
      matchBlocks = {
        "github.com" = { user = "git"; };
        "gitlab.com" = { user = "git"; };
        # ... (remaining match blocks from users/alapshin/home/ssh.nix)
      };
    };
  };
}
```

#### Step 2.2: Nix settings aspect

Merge `common/nix.nix` + `server/nix.nix` + `personal/nix.nix`:

```nix
# modules/nix.nix
{ inputs, ... }: {
  flake.modules.nixos.nix = { lib, pkgs, config, ... }: {
    nix = {
      gc = { automatic = true; dates = "daily"; options = "--delete-older-than 7d"; };
      package = pkgs.nixVersions.latest;
      settings = {
        auto-optimise-store = true;
        max-jobs = 2;
        builders-use-substitutes = true;
        log-lines = lib.mkDefault 25;
        experimental-features = lib.mkForce [ "flakes" "nix-command" ];
        trusted-users = [ "root" "@wheel" ];
        use-xdg-base-directories = true;
      };
    };
    systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";
    systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 250;
  };

  # Server-specific nix tuning (applied via host definition)
  flake.modules.nixos.nix-server = {
    nix = {
      daemonIOSchedClass = "best-effort";
      daemonIOSchedPriority = 4;
      daemonCPUSchedPolicy = "batch";
    };
  };

  # Personal-specific nix tuning (applied via host definition)
  flake.modules.nixos.nix-personal = {
    nix = {
      daemonIOSchedClass = "idle";
      daemonIOSchedPriority = 7;
      daemonCPUSchedPolicy = "idle";
    };
  };
}
```

#### Step 2.3: Networking aspect

```nix
# modules/networking.nix
{ ... }: {
  flake.modules.nixos.networking = { lib, ... }: {
    networking.firewall = {
      enable = lib.mkDefault true;
      logRefusedConnections = lib.mkDefault false;
    };
    systemd.network.wait-online.enable = false;
    systemd.services.NetworkManager-wait-online.enable = false;
    systemd.services.systemd-networkd.stopIfChanged = false;
    systemd.services.systemd-resolved.stopIfChanged = false;
  };

  flake.modules.nixos.networking-server = { lib, pkgs, ... }: {
    systemd.network.enable = true;
    networking = {
      useDHCP = lib.mkForce false;
      useNetworkd = lib.mkDefault true;
    };
    environment.systemPackages = with pkgs; [ traceroute wireguard-tools ];
  };

  flake.modules.nixos.networking-personal = { pkgs, ... }: {
    networking = {
      firewall.enable = false;
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
        plugins = with pkgs; [ networkmanager-openvpn ];
      };
    };
  };
}
```

#### Step 2.4: Continue for all aspects

Apply the same pattern to every feature listed in section 3.1. Each aspect file:

1. Identifies all current files that configure this feature
2. Merges NixOS config into `flake.modules.nixos.<aspect>`
3. Merges Darwin config into `flake.modules.darwin.<aspect>` (if applicable)
4. Merges HM config into `flake.modules.homeManager.<aspect>` (if applicable)
5. Uses `let` bindings for shared values instead of `specialArgs`
6. Uses `lib.mkIf pkgs.stdenv.hostPlatform.isLinux/isDarwin` for platform guards

**Complete list of aspect files to create** (roughly ordered by complexity):

| File | Sources merged | Classes |
|------|---------------|---------|
| `modules/ssh.nix` | `common/openssh.nix`, `server/openssh.nix`, per-host `openssh.nix`, `home/ssh.nix` | nixos, hm |
| `modules/nix.nix` | `common/nix.nix`, `server/nix.nix`, `personal/nix.nix` | nixos, darwin |
| `modules/networking.nix` | `common/networking.nix`, `server/networking.nix`, `personal/networking.nix` | nixos |
| `modules/secrets.nix` | `common/secrets.nix`, `home-modules/secrets.nix` | nixos, hm |
| `modules/backup.nix` | `common/backup.nix`, `_nixos-modules/backup.nix` | nixos |
| `modules/boot.nix` | `personal/boot.nix` | nixos |
| `modules/audio.nix` | `personal/audio.nix` | nixos |
| `modules/bluetooth.nix` | `personal/bluetooth.nix` | nixos |
| `modules/graphical-desktop.nix` | `personal/graphical-desktop.nix`, `home/plasma.nix` | nixos, hm |
| `modules/theming.nix` | `home/theming.nix` | hm |
| `modules/virtualization.nix` | `server/virtualization.nix`, `personal/virtualization.nix`, `desktop/virtualization.nix`, `home/podman.nix` | nixos, hm |
| `modules/gaming.nix` | `desktop/gaming.nix`, `home/gaming.nix` | nixos, hm |
| `modules/shell.nix` | `personal/programs.nix` (fish/zsh enable), `home/shell.nix` | nixos, hm |
| `modules/neovim.nix` | `home/neovim.nix` | hm |
| `modules/firefox.nix` | `home/firefox.nix` | hm |
| `modules/chromium.nix` | `home/chromium.nix` | hm |
| `modules/thunderbird.nix` | `home/thunderbird.nix` | hm |
| `modules/git.nix` | `home/git.nix` | hm |
| `modules/gnupg.nix` | `home/gnupg.nix` | hm |
| `modules/ai.nix` | `home/ai.nix` | hm |
| `modules/development.nix` | `personal/programs.nix` (java), `home/development.nix` | nixos, hm |
| `modules/syncthing.nix` | `home/syncthing.nix` | hm |
| `modules/programs.nix` | `home/programs.nix` | hm |
| `modules/services.nix` | `common/services.nix`, `personal/services.nix`, `home/services.nix` | nixos, hm |
| `modules/variables.nix` | `home/variables.nix` | hm |
| `modules/texlive.nix` | `home/texlive.nix` | hm |
| `modules/anki.nix` | `home/anki.nix` | hm |
| `modules/xray.nix` | `bifrost/xray-server.nix`, `midgard/xray-server.nix`, `niflheim/xray-server.nix` | nixos |
| `modules/configuration.nix` | `configuration.nix` | nixos, darwin |

#### Step 2.5: Niflheim services

The ~35 service files in `hosts/niflheim/` are already effectively single-aspect NixOS
modules. Wrap each in a flake-parts module:

```nix
# modules/niflheim/jellyfin.nix
{ ... }: {
  flake.modules.nixos.jellyfin = { /* current content of hosts/niflheim/jellyfin.nix */ };
}
```

These remain NixOS-only aspects. They can stay in a `modules/niflheim/` subdirectory
for organization, or move into `modules/services/` if you prefer a flatter structure.

---

### Phase 3: Host Definitions

Each host becomes a small flake-parts module that assembles aspects.

#### Step 3.1: Server host example (bifrost)

```nix
# modules/hosts/bifrost.nix
{ inputs, self, ... }:
let
  system = "x86_64-linux";
in {
  flake.nixosConfigurations.bifrost = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = with self.modules.nixos; [
      # Infrastructure
      configuration
      nix
      nix-server
      networking
      networking-server
      ssh
      ssh-server       # enables openssh
      secrets
      backup

      # Host-specific hardware
      ../hardware/bifrost.nix

      # Host-specific overrides
      ({ config, ... }: {
        networking.hostName = "bifrost";
        # Xray, host networking, root user, etc.
      })

      # Aspects
      xray
    ];
  };
}
```

Note: `self.modules.nixos` is automatically populated by `flake.modules.nixos.*`
definitions from all aspect files.

#### Step 3.2: Personal host example (desktop)

```nix
# modules/hosts/desktop.nix
{ inputs, self, ... }:
let
  system = "x86_64-linux";
in {
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = with self.modules.nixos; [
      # Infrastructure
      configuration
      nix
      nix-personal
      networking
      networking-personal
      ssh
      secrets
      backup

      # Personal machine aspects
      audio
      bluetooth
      boot
      graphical-desktop
      virtualization
      gaming
      shell
      development
      services

      # Host-specific
      ../hardware/desktop.nix
      ({ config, ... }: {
        networking.hostName = "desktop";
        nixpkgs.config.rocmSupport = false;  # host-specific override
      })
    ]
    ++ (with self.modules.homeManager; [
      # Wire in home-manager aspects for this host's user
      # (via a home-manager integration module)
    ]);
  };
}
```

#### Step 3.3: Darwin host (macbook)

```nix
# modules/hosts/macbook.nix
{ inputs, self, ... }:
let
  system = "aarch64-darwin";
in {
  flake.darwinConfigurations.macbook = inputs.nix-darwin.lib.darwinSystem {
    inherit system;
    modules = with self.modules.darwin; [
      configuration
      nix
      ssh
      secrets
    ] ++ [
      # macOS-specific inline config (homebrew, system defaults, etc.)
      # ... (content of current hosts/macbook/default.nix)
    ];
  };
}
```

#### Step 3.4: Home-manager integration

Instead of the current `sharedHomeConfig` NixOS module + `extraSpecialArgs` pattern,
create a home-manager integration aspect:

```nix
# modules/home-manager-integration.nix
{ inputs, self, ... }:
let
  dotfileDir = ../dotfiles;
  hmAspects = with self.modules.homeManager; [
    secrets theming shell neovim firefox chromium thunderbird
    git gnupg ai development syncthing programs services
    variables texlive anki gaming ssh podman
    graphical-desktop  # plasma.nix content
  ];
in {
  # NixOS integration
  flake.modules.nixos.home-manager = { pkgs, ... }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = hmAspects ++ [
        inputs.nvf.homeManagerModules.nvf
        inputs.sops-nix.homeManagerModules.sops
        inputs.catppuccin.homeModules.catppuccin
        inputs.plasma-manager.homeModules.plasma-manager
        self.homeModules.secrets
      ];
      extraSpecialArgs = { inherit inputs dotfileDir; };
    };
  };

  # Darwin integration
  flake.modules.darwin.home-manager = { pkgs, ... }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = hmAspects ++ [
        inputs.nvf.homeManagerModules.nvf
        inputs.sops-nix.homeManagerModules.sops
        inputs.catppuccin.homeModules.catppuccin
        inputs.plasma-manager.homeModules.plasma-manager
        self.homeModules.secrets
      ];
      extraSpecialArgs = { inherit inputs dotfileDir; };
    };
  };
}
```

Note: `extraSpecialArgs` for `inputs` and `dotfileDir` is retained here as a
pragmatic concession. A purer Dendritic approach would eliminate `extraSpecialArgs`
entirely by passing values through flake-parts options or `let` bindings, but this
requires each HM aspect to access `inputs` from the flake-parts module scope rather
than from HM module args. This can be done incrementally.

#### Step 3.5: User definition

```nix
# modules/users/alapshin.nix
{ inputs, self, ... }:
let
  username = "alapshin";
in {
  flake.modules.nixos.user-alapshin = { pkgs, config, ... }: {
    users.users.${username} = {
      uid = 1000;
      shell = pkgs.fish;
      isNormalUser = true;
      description = "Andrei Lapshin";
      extraGroups = [ "adbusers" "audio" "docker" /* ... */ ];
      packages = with pkgs; [ /* ... */ ];
    };
    home-manager.users.${username} = import ../users/alapshin/home/home.nix;
  };

  flake.modules.darwin.user-alapshin = { pkgs, ... }: {
    users.users."andrei.lapshin" = {
      home = "/Users/andrei.lapshin";
      shell = pkgs.fish;
    };
    home-manager.users."andrei.lapshin" = import ../users/alapshin/home/home.nix;
  };
}
```

Alternatively, `home.nix` itself can be decomposed -- but since it already imports
feature-specific sub-files (ai.nix, git.nix, etc.), the incremental benefit is
limited. The sub-files under `users/alapshin/home/` can remain as they are initially
and be converted to HM aspects in `flake.modules.homeManager.*` incrementally.

---

### Phase 4: Cleanup

#### Step 4.1: Remove old directory structure

After all aspects are migrated and verified:

```
rm -rf flake/                  # replaced by modules/
rm -rf hosts/common/           # merged into aspect modules
rm -rf hosts/server/           # merged into aspect modules
rm -rf hosts/personal/         # merged into aspect modules
rm -rf hosts/bifrost/          # merged into modules/hosts/ + modules/hardware/
rm -rf hosts/midgard/          # merged into modules/hosts/ + modules/hardware/
rm -rf hosts/carbon/           # merged into modules/hosts/ + modules/hardware/
rm -rf hosts/desktop/          # merged into modules/hosts/ + modules/hardware/
rm -rf hosts/altdesk/          # merged into modules/hosts/ + modules/hardware/
rm -rf hosts/macbook/          # merged into modules/hosts/macbook.nix
# hosts/niflheim/ services -> modules/niflheim/
# modules/nixos/ -> modules/_nixos-modules/
# modules/home/ -> modules/_home-modules/
```

Keep `users/alapshin/home/` files initially (they are imported by the user aspect).
These can be incrementally migrated to `flake.modules.homeManager.*` aspects later.

#### Step 4.2: Eliminate `specialArgs`

Replace each `specialArgs` usage:

| Current specialArg | Replacement |
|--------------------|-------------|
| `self` | Access via `inputs.self` in flake-parts module scope |
| `inputs` | Access via flake-parts module `inputs` arg |
| `lib` (extLib) | Access via `_module.args.extLib` or define in `let` |
| `dotfileDir` | Define in `let` binding at aspect level |
| `username` | Define in `let` binding at user aspect level |

#### Step 4.3: Remove `configuration.nix`

Merge its contents into the `configuration` aspect:

```nix
# modules/configuration.nix
{ inputs, ... }: {
  flake.modules.nixos.configuration = { lib, pkgs, ... }: {
    system.stateVersion = "24.11";
    system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;
    environment.systemPackages = with pkgs; [
      manix nixfmt nix-index nix-prefetch-git nix-prefetch-github
    ];
  };
  flake.modules.darwin.configuration = { lib, pkgs, ... }: {
    system.stateVersion = 6;
    system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;
    environment.systemPackages = with pkgs; [
      manix nixfmt nix-index nix-prefetch-git nix-prefetch-github
    ];
  };
}
```

---

## 5. Migration Order and Dependencies

The migration should proceed in phases, each resulting in a working flake:

```
Phase 1: Foundation (keep existing structure working)
  1.1 Add import-tree input
  1.2 Create modules/ directory, move flake/ modules into it
  1.3 Set up auto-import in flake.nix
  1.4 Rename modules/nixos/ -> modules/_nixos-modules/
  1.5 Rename modules/home/ -> modules/_home-modules/
  1.6 Verify: nix flake check

Phase 2: Aspects (convert one at a time, test after each)
  2.1 Start with simple HM-only aspects (theming, variables, anki, texlive)
  2.2 Convert cross-class aspects (ssh, nix, networking, shell)
  2.3 Convert complex aspects (graphical-desktop, gaming, virtualization)
  2.4 Convert niflheim services (already nearly aspect-shaped)
  2.5 Verify after each: nix flake check

Phase 3: Hosts (convert one at a time)
  3.1 Convert simplest host first (altdesk)
  3.2 Convert servers (bifrost, midgard)
  3.3 Convert personal hosts (carbon, desktop)
  3.4 Convert niflheim (most complex)
  3.5 Convert macbook (darwin)
  3.6 Convert standalone homeConfigurations
  3.7 Verify: nix flake check, nix flake show

Phase 4: Cleanup
  4.1 Remove old hosts/, flake/ directories
  4.2 Eliminate remaining specialArgs
  4.3 Remove configuration.nix (merged into aspect)
  4.4 Final verification
```

---

## 6. Secrets Handling Strategy

SOPS secrets are the trickiest part of this migration because they depend on
**relative file paths** resolved at Nix evaluation time. This section defines
the concrete strategy for each category of secrets.

### 6.1 The Core Problem

In Nix, a path literal like `./secrets.yaml` resolves relative to the **file
containing the expression**. When a NixOS module at `hosts/niflheim/backup.nix`
references `./secrets/borg/passphrase.yaml`, it points to
`hosts/niflheim/secrets/borg/passphrase.yaml`.

In Dendritic, code moves but secrets files don't. An aspect module at
`modules/niflheim/backup.nix` using `./secrets/borg/passphrase.yaml` would try
to find `modules/niflheim/secrets/borg/passphrase.yaml` -- which doesn't exist.

### 6.2 Inventory Summary

The repository contains **~72 `sops.secrets` declarations**, **20 `sops.templates`**,
**7 YAML secrets files**, and **15 binary secret files** across three tiers:

| Tier | Scope | Secrets | Files referenced |
|------|-------|---------|-----------------|
| NixOS shared | All NixOS hosts | ~5 | `hosts/common/secrets.yaml`, `hosts/common/secrets/borg/` |
| NixOS per-host | Individual hosts | ~60 | `hosts/<host>/secrets.yaml`, `hosts/<host>/secrets/` |
| Home Manager | User alapshin | 6 | `users/alapshin/secrets/secrets.yaml`, `users/alapshin/secrets/syncthing/` |

### 6.3 Strategy: Secrets Files Do Not Move

**All secrets files stay in their current locations.** The `.sops.yaml` creation
rules, encrypted files, and decryption key configuration remain untouched.

```
hosts/                              # UNCHANGED -- secrets files stay here
  common/
    secrets.yaml                    # shared NixOS secrets (defaultSopsFile for all hosts)
    secrets/borg/                   # borg SSH keys (binary)
  bifrost/
    secrets.yaml                    # bifrost secrets
    secrets/                        # bifrost binary secrets + build keys
  midgard/
    secrets.yaml
    secrets/
  niflheim/
    secrets.yaml                    # niflheim secrets (~50 keys)
    secrets/                        # authelia, nextcloud, calibre, borg binaries
  carbon/
    secrets/                        # passwd, borg, wireguard
  desktop/
    secrets.yaml
    secrets/                        # passwd, borg
  personal/
    secrets/xray/                   # xray client secrets

users/alapshin/secrets/             # UNCHANGED -- HM secrets stay here
  secrets.yaml                      # HM runtime sops default
  build/secrets.json                # build-time JSON (email addresses etc.)
  syncthing/                        # per-host syncthing certs (binary)

.sops.yaml                          # UNCHANGED -- creation rules match hosts/<name>/secrets.*
```

### 6.4 NixOS System Secrets: Anchored Paths from Aspect Modules

For **shared NixOS aspects** (secrets, backup) that reference files in
`hosts/common/`, use `let` bindings in the flake-parts module scope to capture
path literals pointing back to the original locations.

The key technique: the `let` binding is evaluated in the **flake-parts module**
context, where `../../hosts/common/secrets.yaml` is a valid Nix path literal.
The resulting absolute Nix store path is then passed into the NixOS module
definition, so the NixOS module never needs to resolve relative paths itself.

#### Secrets aspect (SOPS base configuration):

```nix
# modules/secrets.nix
{ ... }:
let
  commonDefaultSopsFile = ../hosts/common/secrets.yaml;
in {
  flake.modules.nixos.secrets = { lib, ... }: {
    sops = {
      age.sshKeyPaths = lib.mkForce [ "/etc/ssh/ssh_host_ed25519_key" ];
      gnupg.sshKeyPaths = [];
      defaultSopsFile = lib.mkDefault commonDefaultSopsFile;
    };
  };
}
```

#### Backup aspect (borg SSH keys):

```nix
# modules/backup.nix
{ ... }:
let
  commonSecretsDir = ../hosts/common/secrets;
in {
  flake.modules.nixos.backup = { config, ... }: {
    sops.secrets."borg/borg_ed25519" = {
      mode = "0600";
      format = "binary";
      sopsFile = commonSecretsDir + "/borg/borg_ed25519";
    };
    sops.secrets."borg/borg_ed25519.pub" = {
      mode = "0600";
      format = "binary";
      sopsFile = commonSecretsDir + "/borg/borg_ed25519.pub";
    };
    services.backup = {
      port = 23;
      user = "u399502";
      host = "u399502.your-storagebox.de";
      sshKeyFile = config.sops.secrets."borg/borg_ed25519".path;
    };
  };
}
```

#### Per-host `defaultSopsFile` override:

Each host definition overrides the shared default with its own `secrets.yaml`:

```nix
# modules/hosts/niflheim.nix
{ inputs, self, ... }:
let
  hostSecretsFile = ../../hosts/niflheim/secrets.yaml;
  hostSecretsDir = ../../hosts/niflheim/secrets;
in {
  flake.nixosConfigurations.niflheim = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.modules.nixos; [
      secrets       # sets mkDefault to hosts/common/secrets.yaml
      ({ ... }: {   # host overrides it
        sops.defaultSopsFile = hostSecretsFile;
      })
      # ...
    ];
  };
}
```

### 6.5 NixOS Per-Host Secrets: Keep as Plain NixOS Module Imports

Host-specific service files with dense secrets usage (especially niflheim's ~50
secrets across 35+ service files) remain **plain NixOS modules** imported directly
in the host definition. They are **not** converted to `flake.modules.nixos.*`
aspects.

Rationale:
- These services are bound to a single host and will never be shared
- They contain dozens of `sops.secrets` and `sops.templates` with relative paths
- Converting each to a flake-parts wrapper adds boilerplate with no reusability gain
- The relative paths (`./secrets.yaml`, `./secrets/authelia/jwk_rsa_key.pem`)
  continue working because the files haven't moved

```nix
# modules/hosts/niflheim.nix
{ inputs, self, ... }:
let
  hostSecretsFile = ../../hosts/niflheim/secrets.yaml;
  hostDir = ../../hosts/niflheim;
in {
  flake.nixosConfigurations.niflheim = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.modules.nixos; [
      # Shared aspects (no host-specific secrets)
      configuration nix nix-server ssh networking networking-server secrets backup

      # Host override for defaultSopsFile
      ({ ... }: { sops.defaultSopsFile = hostSecretsFile; })

      # Host-specific NixOS modules imported directly from hosts/ directory.
      # Their relative sopsFile paths (./secrets.yaml, ./secrets/...) resolve
      # correctly because these files remain in hosts/niflheim/.
      (hostDir + "/secrets.nix")
      (hostDir + "/webhost.nix")
      (hostDir + "/ai.nix")
      (hostDir + "/authelia.nix")
      (hostDir + "/backup.nix")
      (hostDir + "/caddy.nix")
      (hostDir + "/grafana.nix")
      (hostDir + "/immich.nix")
      (hostDir + "/jellyfin.nix")
      (hostDir + "/nextcloud.nix")
      (hostDir + "/wireguard.nix")
      (hostDir + "/xray-server.nix")
      # ... all other niflheim service files

      # Hardware
      (hostDir + "/hardware-configuration.nix")
      (hostDir + "/networking.nix")
    ];
  };
}
```

The same approach applies to other hosts with per-host secrets:

```nix
# modules/hosts/carbon.nix
{ inputs, self, ... }:
let
  hostDir = ../../hosts/carbon;
in {
  flake.nixosConfigurations.carbon = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.modules.nixos; [
      configuration nix nix-personal ssh networking networking-personal
      secrets backup audio bluetooth boot graphical-desktop

      # Host-specific modules with secrets (relative paths intact)
      (hostDir + "/secrets.nix")       # wireguard keys
      (hostDir + "/users.nix")         # sopsFile = ./secrets/passwd.yaml
      (hostDir + "/backup.nix")        # sopsFile = ./secrets/borg/passphrase.yaml
      (hostDir + "/services.nix")
      (hostDir + "/networking.nix")
      (hostDir + "/graphical-desktop.nix")
      (hostDir + "/hardware-configuration.nix")
    ];
  };
}
```

For simple servers (bifrost, midgard) with few secrets, the same pattern:

```nix
# modules/hosts/bifrost.nix
{ inputs, self, ... }:
let
  hostDir = ../../hosts/bifrost;
in {
  flake.nixosConfigurations.bifrost = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.modules.nixos; [
      configuration nix nix-server ssh networking networking-server secrets backup

      (hostDir + "/secrets.nix")       # defaultSopsFile + linux/root
      (hostDir + "/openssh.nix")       # PasswordAuthentication = false
      (hostDir + "/xray-server.nix")   # xray secrets + templates
      (hostDir + "/networking.nix")    # hostName + systemd.network
      (hostDir + "/hardware-configuration.nix")
    ];
  };
}
```

### 6.6 Home-Manager User Secrets: Keep In Place, Import as Unit

Home-manager secrets use **two mechanisms**:

#### Build-time secrets (`config.secrets.contents`)

The custom `modules/home/secrets.nix` module reads `users/alapshin/secrets/build/secrets.json`
at Nix **evaluation time** via `builtins.readFile`. This provides non-sensitive values
(email addresses) accessible as `config.secrets.contents.email.fastmail` etc.

Set in `users/alapshin/home/home.nix` line 39-41:
```nix
secrets.path = ../secrets/build/secrets.json;
```

#### Runtime secrets (sops-nix)

Set in `users/alapshin/home/home.nix` lines 43-46:
```nix
sops = {
  age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";
  defaultSopsFile = ../secrets/secrets.yaml;
};
```

Individual HM modules declare secrets against this default:

| HM module | Secret | sopsFile override |
|-----------|--------|-------------------|
| `ai.nix` | `opencode_api_key` | (uses default) |
| `ai.nix` | `openrouter_api_key` | (uses default) |
| `thunderbird.nix` | `nextcloud_caldav` | (uses default) |
| `thunderbird.nix` | `nextcloud_carddav` | (uses default) |
| `syncthing.nix` | `syncthing/key` | `../secrets/syncthing/${hostname}-key.pem` (binary) |
| `syncthing.nix` | `syncthing/cert` | `../secrets/syncthing/${hostname}-cert.pem` (binary) |

#### Strategy: Keep `users/alapshin/home/` as-is

The HM sub-modules are **user-specific** (hardcoded email addresses, Syncthing
device IDs, SSH host aliases). They are not reusable aspects. Converting them to
`flake.modules.homeManager.*` provides no Dendritic benefit.

The user aspect module imports the existing HM tree as a unit:

```nix
# modules/users/alapshin.nix
{ inputs, self, ... }:
let
  homeDir = ../../users/alapshin/home;
  dotfileDir = ../../dotfiles;
in {
  flake.modules.nixos.user-alapshin = { pkgs, ... }:
  let
    username = "alapshin";
  in {
    users.users.${username} = {
      uid = 1000;
      shell = pkgs.fish;
      isNormalUser = true;
      description = "Andrei Lapshin";
      extraGroups = [ "adbusers" "audio" "docker" "input" "libvirtd"
                      "networkmanager" "syncthing" "tss" "wheel" ];
      packages = with pkgs; [ /* ... */ ];
    };
    home-manager.users.${username} = import (homeDir + "/home.nix");
  };

  flake.modules.darwin.user-alapshin = { pkgs, ... }:
  let
    username = "andrei.lapshin";
  in {
    users.users.${username} = {
      home = "/Users/${username}";
      shell = pkgs.fish;
    };
    system.primaryUser = username;
    home-manager.users.${username} = import (homeDir + "/home.nix");
  };
}
```

This works because:
- `homeDir + "/home.nix"` is evaluated in the flake-parts module, resolving to
  the real path `users/alapshin/home/home.nix`
- Inside `home.nix`, its own relative paths (`../secrets/secrets.yaml`, `./ai.nix`,
  `./syncthing.nix`) resolve relative to `home.nix`'s location -- unchanged
- `syncthing.nix`'s `../secrets/syncthing/${hostname}-key.pem` continues to resolve
  to `users/alapshin/secrets/syncthing/`
- The build-time `secrets.json` read continues working
- `osConfig.networking.hostName` remains available inside HM evaluation (provided
  by NixOS/Darwin, or faked in standalone homeConfigurations)

#### `username` and `dotfileDir` handling

Today these are passed via `extraSpecialArgs`. Two approaches:

**Approach A (pragmatic, for initial migration):** Keep `extraSpecialArgs` for
`username` and `dotfileDir` in the home-manager integration module:

```nix
# modules/home-manager-integration.nix
{ inputs, self, ... }:
let
  dotfileDir = ../dotfiles;
in {
  flake.modules.nixos.home-manager = { ... }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [
        inputs.nvf.homeManagerModules.nvf
        inputs.sops-nix.homeManagerModules.sops
        inputs.catppuccin.homeModules.catppuccin
        inputs.plasma-manager.homeModules.plasma-manager
        self.homeModules.secrets
      ];
      extraSpecialArgs = { inherit inputs dotfileDir; };
    };
  };

  flake.modules.darwin.home-manager = { ... }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [
        inputs.nvf.homeManagerModules.nvf
        inputs.sops-nix.homeManagerModules.sops
        inputs.catppuccin.homeModules.catppuccin
        inputs.plasma-manager.homeModules.plasma-manager
        self.homeModules.secrets
      ];
      extraSpecialArgs = { inherit inputs dotfileDir; };
    };
  };
}
```

Note: `username` is set per-user in the user aspect module (`modules/users/alapshin.nix`)
where the `home-manager.users.<name>` call provides it. The user aspect can pass
`username` by calling `import home.nix` with the arg, as the current
`users/alapshin/home/default.nix` does:

```nix
home-manager.users.${username} = import (homeDir + "/home.nix");
```

But `home.nix` expects `username` as a function argument (`{ ... username, ... }:`).
This requires either keeping it in `extraSpecialArgs` per the user aspect, or
converting `home.nix` to use `config.home.username` instead. For initial migration,
keep `extraSpecialArgs`:

```nix
# In modules/users/alapshin.nix, NixOS user module:
home-manager.users.${username} = {
  imports = [ (homeDir + "/home.nix") ];
  _module.args.username = username;
};
```

**Approach B (cleaner, do later):** Refactor `home.nix` to derive `username` from
`config.home.username` and `dotfileDir` from a custom HM option, eliminating both
`extraSpecialArgs` entries.

### 6.7 Standalone Home Configurations

The standalone `homeConfigurations` (used for `home-manager switch` without
NixOS/Darwin) need the same secrets setup. Since these don't go through
`home-manager.users.<name>`, they wire secrets differently:

```nix
# modules/home-configurations.nix
{ inputs, self, ... }:
let
  homeDir = ../users/alapshin/home;
  dotfileDir = ../dotfiles;

  sharedHomeModules = [
    inputs.nvf.homeManagerModules.nvf
    inputs.sops-nix.homeManagerModules.sops
    inputs.catppuccin.homeModules.catppuccin
    inputs.plasma-manager.homeModules.plasma-manager
    self.homeModules.secrets
  ];

  mkHome = { system, hostname, username }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = import ../pkgs-config.nix { lib = inputs.nixpkgs.lib; };
        overlays = (builtins.attrValues self.overlays)
          ++ [ inputs.nur.overlays.default ];
      };
      modules = sharedHomeModules ++ [
        (homeDir + "/home.nix")
      ];
      extraSpecialArgs = {
        inherit inputs dotfileDir username;
        osConfig = { networking.hostName = hostname; };
      };
    };
in {
  flake.homeConfigurations = {
    "alapshin@desktop" = mkHome {
      system = "x86_64-linux";
      hostname = "desktop";
      username = "alapshin";
    };
    "alapshin@macbook" = mkHome {
      system = "aarch64-darwin";
      hostname = "macbook";
      username = "andrei.lapshin";
    };
  };
}
```

All relative paths in `home.nix` and its sub-modules continue to work because
`homeDir + "/home.nix"` resolves to the original file location.

### 6.8 Summary: What Moves vs. What Stays

| Component | Current location | After migration | Path strategy |
|-----------|-----------------|-----------------|---------------|
| **Secrets YAML/binary files** | `hosts/<host>/secrets*`, `users/alapshin/secrets/` | **Same** (no change) | N/A |
| `.sops.yaml` | repo root | **Same** | N/A |
| **Shared NixOS aspects** (secrets, backup) | `hosts/common/secrets.nix`, `hosts/common/backup.nix` | `modules/secrets.nix`, `modules/backup.nix` | Anchored `let` path to `../hosts/common/` |
| **Per-host NixOS modules** (with dense secrets) | `hosts/<host>/*.nix` | **Same** (imported via `hostDir + "/file.nix"`) | Relative paths intact |
| **HM modules** (with secrets) | `users/alapshin/home/*.nix` | **Same** (imported via `homeDir + "/home.nix"`) | Relative paths intact |
| **Host definitions** | `flake/nixos.nix`, `flake/darwin.nix` | `modules/hosts/<host>.nix` | Uses anchored `let` paths for both secrets files and host module imports |

---

## 7. Risks and Mitigations

### 7.1 `flake.modules` requires `flake-parts` modules support

The `flake.modules.<class>.<name>` option requires importing
`inputs.flake-parts.flakeModules.modules` in your `mkFlake` imports. Verify this
is available in your pinned flake-parts version. Add to flake.nix:

```nix
imports = [
  inputs.flake-parts.flakeModules.modules
  # ... (auto-imported modules from import-tree)
];
```

### 7.2 Hardware configs with relative paths

`hardware-configuration.nix` files reference `./disk-config.nix` and similar.
**Mitigation**: These files stay in `hosts/<name>/` and are imported via anchored
paths (`hostDir + "/hardware-configuration.nix"`), so internal relative references
(`./disk-config.nix`) continue to resolve correctly.

### 7.3 Niflheim complexity (49 files)

The niflheim host has ~35 service files with ~50 secrets declarations.
**Mitigation**: Keep all niflheim service files in `hosts/niflheim/` as plain NixOS
modules. Import them via anchored paths in `modules/hosts/niflheim.nix`. Convert
to `flake.modules.nixos.*` wrappers only if reuse across hosts is ever needed.

### 7.4 Home-manager `osConfig` usage

HM modules `syncthing.nix`, `thunderbird.nix`, `development.nix` reference
`osConfig.networking.hostName` for hostname-conditional logic.
**Mitigation**: In NixOS/Darwin contexts, `osConfig` is provided automatically.
In standalone homeConfigurations, it's faked via `extraSpecialArgs`. This pattern
is preserved unchanged in `modules/home-configurations.nix`.

### 7.5 `import-tree` and evaluation performance

Auto-importing all files means all aspects are always evaluated, even if not used
by a host. This is typically fine for NixOS module evaluation (options are lazy),
but watch for unconditional side effects.

### 7.6 Incremental migration

The migration does not need to be all-or-nothing. You can keep the current
`flake/nixos.nix` host assembly while converting aspects one at a time. Each
converted aspect adds a `flake.modules.<class>.<aspect>` entry that hosts can
start referencing. Once all aspects for a host are converted, that host's
definition can be rewritten to use `self.modules.<class>.*`.

---

## 8. What Stays the Same

| Item | Reason |
|------|--------|
| `flake.nix` inputs | No change needed (add import-tree only) |
| `flake.lock` | Unchanged (add import-tree) |
| `pkgs-config.nix` | Standalone config file, works from any location |
| `treefmt-config.nix` | Standalone config file |
| `lib/default.nix` | Custom lib extension, referenced by `modules/lib.nix` |
| `overlays/` | Package overlays, unchanged |
| `packages/` | Custom packages, unchanged |
| `pkgs/` | Package patches, unchanged |
| `dotfiles/` | Raw dotfiles, unchanged |
| `.sops.yaml` | SOPS config, unchanged -- creation rules still match `hosts/<name>/secrets.*` |
| `hosts/<name>/secrets*` | All NixOS secrets files stay in place |
| `hosts/<name>/*.nix` | Per-host NixOS modules with dense secrets stay in place |
| `users/alapshin/secrets/` | All HM secrets files stay in place |
| `users/alapshin/home/*.nix` | HM modules stay in place, imported as a unit |
| `ci/` | CI scripts may need minor path updates |

---

## 9. Validation Checklist

After full migration, verify:

- [ ] `nix flake check` passes (or only has expected cross-platform build errors)
- [ ] `nix flake show` shows identical output structure to pre-migration
- [ ] `nix eval '.#nixosConfigurations' --apply builtins.attrNames` returns all 6 hosts
- [ ] `nix eval '.#darwinConfigurations' --apply builtins.attrNames` returns `["macbook"]`
- [ ] `nix eval '.#homeConfigurations' --apply builtins.attrNames` returns both configs
- [ ] `nix eval '.#nixosModules' --apply builtins.attrNames` returns 4 modules
- [ ] `nix eval '.#homeModules' --apply builtins.attrNames` returns `["secrets"]`
- [ ] `nix eval '.#overlays' --apply builtins.attrNames` returns 2 overlays
- [ ] `nix eval '.#devShells.aarch64-darwin' --apply builtins.attrNames` returns `["android"]`
- [ ] `nix fmt` works
- [ ] `ci/build.sh` scripts work
- [ ] Each NixOS host builds: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`
- [ ] Darwin switch works: `darwin-rebuild switch --flake .#macbook`
- [ ] Home-manager switch works: `home-manager switch --flake .#alapshin@macbook`
- [ ] All SOPS secrets decrypt correctly on each host
- [ ] Syncthing certs load per-hostname (test on multiple hosts)
- [ ] Build-time secrets JSON (`config.secrets.contents`) resolves correctly
- [ ] All aspects are individually toggleable per host (add/remove from module list)
- [ ] No file outside `modules/` is manually imported (except `hosts/` and `users/` for secrets)
- [ ] Every `.nix` file in `modules/` is a flake-parts module
