# Migration Plan: flake.nix to flake-parts

## Overview

Migrate the current monolithic `flake.nix` (362 lines) to a modular structure using
`flake-parts.lib.mkFlake`. The `flake-parts` input already exists in `flake.lock` but
is only used transitively by `nur` and `nvf` -- the flake itself does not use it.

The goal is to replace the hand-rolled `let` block (helper functions, per-system
iteration, pkgs construction) with flake-parts' module system while preserving all
existing outputs exactly.

---

## Current Architecture

The `outputs` function defines everything in a single `let...in` block:

| Construct | Purpose |
|-----------|---------|
| `lib` | Extended nixpkgs.lib with home-manager.lib + custom `./lib` |
| `pkgConfig` | Shared nixpkgs config (unfree allowlist, etc.) from `./pkgs-config.nix` |
| `treefmtConfig` | Formatter config from `./treefmt-config.nix` |
| `mkPkgs` | Instantiates nixpkgs with config, overlays, NUR |
| `forEachSystem` / `forEachSystemPkgs` | Per-system iteration using `nix-systems` |
| `homeConfig` | Shared home-manager settings (sharedModules, extraSpecialArgs) |
| `mkNixosConfiguration` | Builds NixOS configs with shared modules |
| `mkDarwinConfiguration` | Builds nix-darwin configs with shared modules |
| `mkHomeConfiguration` | Builds standalone home-manager configs |

### Outputs produced

- `devShells.<system>.android`
- `formatter.<system>`
- `overlays` (additions, modifications)
- `nixosModules` (backup, vpn, monica, webhost)
- `homeModules` (secrets)
- `nixosConfigurations` (bifrost, midgard, niflheim, carbon, desktop, altdesk)
- `darwinConfigurations` (macbook -- conditional on aarch64-darwin)
- `homeConfigurations` (alapshin@desktop, alapshin@macbook -- latter conditional)

---

## Target Architecture

```
flake.nix                       -- mkFlake entry point, inputs, top-level imports
flake/
  nixos.nix                     -- nixosConfigurations (all 6 hosts)
  darwin.nix                    -- darwinConfigurations (macbook)
  home.nix                      -- homeConfigurations (standalone)
  dev-shells.nix                -- perSystem: devShells
  formatter.nix                 -- perSystem: formatter (treefmt)
  overlays.nix                  -- flake: overlays
  modules.nix                   -- flake: nixosModules, homeModules
  pkgs.nix                      -- perSystem: _module.args.pkgs configuration
```

---

## Step-by-Step Migration

### Step 1: Create the `flake/` directory

Create a `flake/` directory to hold the split-out modules. Each file will be a
flake-parts module (a function taking `{ self, inputs, lib, config, withSystem, ... }`).

### Step 2: Rewrite `flake.nix` as a thin entry point

Replace the current `outputs` with:

```nix
outputs = inputs@{ flake-parts, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;

    imports = [
      ./flake/pkgs.nix
      ./flake/overlays.nix
      ./flake/modules.nix
      ./flake/formatter.nix
      ./flake/dev-shells.nix
      ./flake/nixos.nix
      ./flake/darwin.nix
      ./flake/home.nix
    ];
  };
```

Keep the `description`, `nixConfig`, and `inputs` blocks unchanged.

### Step 3: Create `flake/pkgs.nix` -- centralized pkgs construction

This replaces `mkPkgs`, `forEachSystem`, `eachSystemPkgs`, and `forEachSystemPkgs`.

```nix
# flake/pkgs.nix
{ inputs, self, ... }: {
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

**Key concern**: The current `mkPkgs` allows per-call `config` overrides (the
`desktop` NixOS config adds `rocmSupport = false`). With flake-parts, the `perSystem`
pkgs is a single instance per system. For NixOS hosts that need different pkgs config,
use **Approach 1** from flake-parts docs: let NixOS manage its own pkgs via
`nixpkgs.config`/`nixpkgs.overlays` options inside the NixOS module, and do NOT use
`readOnlyPkgs` for those hosts. The `desktop` host should set `nixpkgs.config` within
its own modules instead.

### Step 4: Create `flake/overlays.nix`

```nix
# flake/overlays.nix
{ inputs, ... }: {
  flake.overlays = import ../overlays { inherit inputs; };
}
```

### Step 5: Create `flake/modules.nix`

```nix
# flake/modules.nix
{ ... }: {
  flake.nixosModules = import ../modules/nixos;
  flake.homeModules = import ../modules/home;
}
```

### Step 6: Create `flake/formatter.nix` -- treefmt integration

Two approaches:

**Option A** (recommended): Use `treefmt-nix` flake-parts module if available:

```nix
# flake/formatter.nix
{ inputs, ... }: {
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem = { ... }: {
    treefmt = import ../treefmt-config.nix;
  };
}
```

**Option B**: Manual, preserving current pattern:

```nix
# flake/formatter.nix
{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    formatter = inputs.treefmt-nix.lib.mkWrapper pkgs (import ../treefmt-config.nix);
  };
}
```

Note: `treefmt-nix` already provides a flake-parts module (`flakeModule`). Option A is
cleaner and idiomatic. Check if `treefmt-config.nix` format is compatible with the
module interface (it uses `programs.<name>.enable` rather than a config attrset -- if
the current config uses the simpler format, it may need minor adjustment for Option A).

### Step 7: Create `flake/dev-shells.nix`

```nix
# flake/dev-shells.nix
{ ... }: {
  perSystem = { pkgs, ... }: {
    devShells.android =
      let
        buildToolsVersion = "36.0.0";
        androidComposition = pkgs.androidComposition;
      in
      pkgs.mkShell rec {
        buildInputs = [ androidComposition.androidsdk ];
        ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
        ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk-bundle";
        GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_HOME}/build-tools/${buildToolsVersion}/aapt2";
        shellHook = ''
          echo "sdk.dir=${androidComposition.androidsdk}/libexec/android-sdk" > local.properties
        '';
      };
  };
}
```

### Step 8: Create `flake/nixos.nix` -- NixOS configurations

This is the most complex module. It replaces `mkNixosConfiguration` and `homeConfig`.

```nix
# flake/nixos.nix
{ self, inputs, withSystem, ... }:
let
  lib = inputs.nixpkgs.lib.extend
    (_: prev: inputs.home-manager.lib // (import ../lib { lib = prev; }));
  dotfileDir = ../dotfiles;

  homeConfig = { ... }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [
        self.homeModules.secrets
        inputs.nvf.homeManagerModules.nvf
        inputs.sops-nix.homeManagerModules.sops
        inputs.catppuccin.homeModules.catppuccin
        inputs.plasma-manager.homeModules.plasma-manager
      ];
      extraSpecialArgs = { inherit inputs dotfileDir; };
    };
  };

  sharedNixosModules = [
    ../configuration.nix
    inputs.nixpkgs.nixosModules.readOnlyPkgs
    self.nixosModules.backup
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.home-manager.nixosModules.home-manager
    homeConfig
  ];

  mkNixosHost = {
    system ? "x86_64-linux",
    nixpkgs ? inputs.nixpkgs,
    hostModules ? [],
    userModules ? [],
    extraPkgsConfig ? {},
  }:
    withSystem system ({ pkgs, ... }:
      nixpkgs.lib.nixosSystem {
        pkgs = if extraPkgsConfig == {} then pkgs
               else import nixpkgs {
                 inherit system;
                 config = (import ../pkgs-config.nix { inherit lib; }) // extraPkgsConfig;
                 overlays = (builtins.attrValues self.overlays)
                   ++ [ inputs.nur.overlays.default ];
               };
        modules = sharedNixosModules ++ hostModules ++ userModules;
        specialArgs = { inherit self lib inputs dotfileDir; };
      }
    );
in
{
  flake.nixosConfigurations = {
    bifrost = mkNixosHost {
      hostModules = [ ../hosts/common ../hosts/server ../hosts/bifrost ];
    };

    midgard = mkNixosHost {
      hostModules = [ ../hosts/common ../hosts/server ../hosts/midgard ];
    };

    niflheim = mkNixosHost {
      hostModules = [
        ../hosts/common ../hosts/server ../hosts/niflheim
        self.nixosModules.vpn
        self.nixosModules.monica
        self.nixosModules.webhost
        "${inputs.nixpkgs-nextcloud}/nixos/modules/services/web-apps/nextcloud.nix"
      ];
    };

    carbon = mkNixosHost {
      hostModules = [ ../hosts/common ../hosts/personal ../hosts/carbon ];
      userModules = [ ../users/alapshin ../users/alapshin/home ];
    };

    desktop = mkNixosHost {
      extraPkgsConfig = { rocmSupport = false; };
      hostModules = [ ../hosts/common ../hosts/personal ../hosts/desktop ];
      userModules = [ ../users/alapshin ../users/alapshin/home ];
    };

    altdesk = mkNixosHost {
      hostModules = [ ../hosts/common ../hosts/personal ../hosts/altdesk ];
      userModules = [ ../users/alapshin ../users/alapshin/home ];
    };
  };
}
```

**Design decisions**:
- `homeConfig` and `sharedNixosModules` move into this module's `let` block.
- `withSystem` is used to access the per-system `pkgs` from Step 3.
- The `desktop` host with `rocmSupport = false` gets a custom pkgs instantiation
  via `extraPkgsConfig`, while all other hosts use the shared `perSystem` pkgs.
- `lib` extension is done locally. Consider whether this can be simplified or
  moved to a shared location.

### Step 9: Create `flake/darwin.nix` -- Darwin configurations

```nix
# flake/darwin.nix
{ self, inputs, withSystem, lib, ... }:
let
  extLib = inputs.nixpkgs.lib.extend
    (_: prev: inputs.home-manager.lib // (import ../lib { lib = prev; }));
  dotfileDir = ../dotfiles;

  homeConfig = { ... }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [
        self.homeModules.secrets
        inputs.nvf.homeManagerModules.nvf
        inputs.sops-nix.homeManagerModules.sops
        inputs.catppuccin.homeModules.catppuccin
        inputs.plasma-manager.homeModules.plasma-manager
      ];
      extraSpecialArgs = { inherit inputs dotfileDir; };
    };
  };

  sharedDarwinModules = [
    ../configuration.nix
    inputs.determinate.darwinModules.default
    inputs.sops-nix.darwinModules.sops
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.home-manager.darwinModules.home-manager
    homeConfig
  ];
in
{
  flake.darwinConfigurations =
    lib.optionalAttrs
      (builtins ? currentSystem && builtins.currentSystem == "aarch64-darwin")
      {
        macbook = withSystem "aarch64-darwin" ({ pkgs, ... }:
          inputs.nix-darwin.lib.darwinSystem {
            inherit pkgs;
            modules = sharedDarwinModules ++ [
              ../hosts/macbook
              ../users/alapshin/home
            ];
            specialArgs = {
              inherit self inputs dotfileDir;
              lib = extLib;
            };
          }
        );
      };
}
```

### Step 10: Create `flake/home.nix` -- standalone Home Manager configurations

```nix
# flake/home.nix
{ self, inputs, withSystem, lib, ... }:
let
  extLib = inputs.nixpkgs.lib.extend
    (_: prev: inputs.home-manager.lib // (import ../lib { lib = prev; }));
  dotfileDir = ../dotfiles;

  sharedHomeModules = [
    self.homeModules.secrets
    inputs.nvf.homeManagerModules.nvf
    inputs.sops-nix.homeManagerModules.sops
    inputs.catppuccin.homeModules.catppuccin
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  mkHome = { system, hostname, username, homeModules }:
    withSystem system ({ pkgs, ... }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = sharedHomeModules ++ homeModules;
        extraSpecialArgs = {
          inherit inputs dotfileDir username;
          osConfig = { networking.hostName = hostname; };
        };
      }
    );
in
{
  flake.homeConfigurations = {
    "alapshin@desktop" = mkHome {
      system = "x86_64-linux";
      hostname = "desktop";
      username = "alapshin";
      homeModules = [ ../users/alapshin/home/home.nix ];
    };
  }
  // lib.optionalAttrs
    (builtins ? currentSystem && builtins.currentSystem == "aarch64-darwin")
    {
      "alapshin@macbook" = mkHome {
        system = "aarch64-darwin";
        hostname = "macbook";
        username = "andrei.lapshin";
        homeModules = [ ../users/alapshin/home/home.nix ];
      };
    };
}
```

---

## Migration Checklist

- [ ] 1. Create `flake/` directory
- [ ] 2. Create `flake/pkgs.nix` (perSystem pkgs configuration)
- [ ] 3. Create `flake/overlays.nix` (flake overlays)
- [ ] 4. Create `flake/modules.nix` (nixosModules + homeModules)
- [ ] 5. Create `flake/formatter.nix` (treefmt perSystem)
- [ ] 6. Create `flake/dev-shells.nix` (android devShell)
- [ ] 7. Create `flake/nixos.nix` (all 6 NixOS configurations)
- [ ] 8. Create `flake/darwin.nix` (macbook darwin configuration)
- [ ] 9. Create `flake/home.nix` (standalone home-manager configurations)
- [ ] 10. Rewrite `flake.nix` as thin entry point with `mkFlake`
- [ ] 11. Run `nix flake check` to verify all outputs
- [ ] 12. Run `nix flake show` to verify output structure matches original
- [ ] 13. Test `nix build .#nixosConfigurations.<host>.config.system.build.toplevel` for each host
- [ ] 14. Test `nix fmt` still works
- [ ] 15. Test `nix develop .#android` still works

---

## Risks and Considerations

### 1. Shared `lib` extension
The current flake extends `nixpkgs.lib` with `home-manager.lib` and custom helpers.
In flake-parts, the top-level `lib` argument is the unextended `nixpkgs.lib`. The
extended lib must be constructed in each module that needs it, or passed via a shared
`let` binding. Consider creating a small flake-parts module that exposes the extended
lib via `_module.args` or `specialArgs`.

### 2. `homeConfig` duplication
The `homeConfig` attrset (shared home-manager settings) is used by NixOS, Darwin, and
standalone home-manager configs. After splitting into separate files, this will be
duplicated across `nixos.nix`, `darwin.nix`, and `home.nix`. Consider extracting it
into a shared file (`flake/shared.nix`) that all three import.

### 3. Conditional Darwin/Home outputs
The current flake uses `builtins.currentSystem` to conditionally include Darwin and
macOS home configs. This is an impurity. Consider whether this guard is still needed
or if it can be removed (flake-parts evaluates all systems regardless).

### 4. Per-host pkgs config overrides
The `desktop` host overrides `rocmSupport = false`. With flake-parts' centralized
`perSystem` pkgs, this host needs special handling. The cleanest approach is to set
`nixpkgs.config` within the host's NixOS modules and not use `readOnlyPkgs` for that
host, or construct a separate pkgs instance in the nixos.nix module as shown above.

### 5. `self` references in overlays
`mkPkgs` uses `self.overlays` which means overlays must be defined before pkgs is
constructed. In flake-parts, this works naturally since `self` is available via module
args, but circular references should be watched for.

### 6. `readOnlyPkgs` compatibility
The current config uses `nixpkgs.nixosModules.readOnlyPkgs` to prevent NixOS modules
from overriding the flake-provided pkgs. This is compatible with flake-parts'
`withSystem` approach (Approach 2 in docs) but must be disabled for any host that
needs custom pkgs config (like `desktop`).

### 7. Relative paths
When splitting into `flake/`, all relative paths (e.g. `./configuration.nix`,
`./hosts/common`) must be adjusted to `../configuration.nix`, `../hosts/common`, etc.

---

## Optional Future Improvements

1. **Use `treefmt-nix` flake-parts module** instead of manual `mkWrapper` call
2. **Use `flake.modules.nixos`** to publish NixOS modules via the flake-parts module
   system instead of raw `flake.nixosModules`
3. **Extract `homeConfig`** into a shared flake-parts module to eliminate duplication
4. **Remove `builtins.currentSystem` guards** -- define all configs unconditionally
   and rely on flake-parts' system handling
5. **Add `checks`** output using flake-parts `perSystem.checks` for CI validation
6. **Consider `ez-configs`** or `auto-import` flake-parts modules for automatic
   host/user discovery instead of manual enumeration
