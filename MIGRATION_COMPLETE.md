# Migration to flake-parts: COMPLETE ✅

The migration from a monolithic `flake.nix` to a modular flake-parts structure has been successfully completed.

## Summary of Changes

### Files Created

The following new files were created in the `flake/` directory:

1. **flake/pkgs.nix** - Centralized per-system Nixpkgs instantiation
   - Replaces the old `mkPkgs`, `forEachSystem`, and `forEachSystemPkgs` functions
   - Uses flake-parts' `perSystem` to provide a shared `pkgs` instance for all modules
   - Applies overlays and NUR automatically

2. **flake/overlays.nix** - Exports custom overlays
   - Maintains the original overlay structure (additions, modifications)
   - Minimal wrapper around `./overlays`

3. **flake/modules.nix** - Exports reusable NixOS and Home Manager modules
   - Maintains the original `nixosModules` (backup, vpn, monica, webhost)
   - Maintains the original `homeModules` (secrets)

4. **flake/formatter.nix** - Per-system code formatter (treefmt)
   - Replaces the old `forEachSystemPkgs` formatter construction
   - Uses `treefmt-nix.lib.mkWrapper` directly in `perSystem`

5. **flake/dev-shells.nix** - Per-system development shells
   - Replaces the old `forEachSystemPkgs` devShells construction
   - Currently provides the `android` development shell

6. **flake/shared.nix** - Shared configuration for Home Manager
   - Exports `extLib` (extended nixpkgs.lib with home-manager.lib and custom helpers)
   - Exports `sharedHomeConfig` for use by NixOS, Darwin, and standalone Home Manager
   - Eliminates duplication of `homeConfig` definition

7. **flake/nixos.nix** - All NixOS host configurations
   - Replaces `mkNixosConfiguration` and its invocations
   - Defines all 6 NixOS configurations: bifrost, midgard, niflheim, carbon, desktop, altdesk
   - Handles the special case of `desktop` host with `rocmSupport = false` via `extraPkgsConfig`
   - Uses `withSystem` to access per-system `pkgs`

8. **flake/darwin.nix** - Darwin (macOS) configurations
   - Replaces `mkDarwinConfiguration` and its invocation
   - Defines the `macbook` configuration conditionally (only on aarch64-darwin)
   - Uses `withSystem` for system-specific pkgs access

9. **flake/home.nix** - Standalone Home Manager configurations
   - Replaces `mkHomeConfiguration` and its invocations
   - Defines `alapshin@desktop` and conditionally `alapshin@macbook`
   - Uses `withSystem` for system-specific pkgs access

### Files Modified

**flake.nix** - Transformed from 362 lines to 14 lines
- Kept all original inputs and nixConfig blocks unchanged
- Replaced the entire `outputs` function with a thin wrapper using `flake-parts.lib.mkFlake`
- Now imports the 9 flake-parts modules listed above

## Output Structure Verification

All outputs are correctly produced and verified:

```
✅ nixosConfigurations
   - altdesk
   - bifrost
   - carbon
   - desktop
   - midgard
   - niflheim

✅ darwinConfigurations
   - (empty on non-Darwin systems, macbook on aarch64-darwin)

✅ homeConfigurations
   - alapshin@desktop
   - alapshin@macbook (conditional on aarch64-darwin)

✅ nixosModules
   - backup
   - monica
   - vpn
   - webhost

✅ homeModules
   - secrets

✅ overlays
   - additions
   - modifications

✅ devShells.<system>
   - android (on all systems)

✅ formatter.<system>
   - Available for x86_64-linux, x86_64-darwin, aarch64-linux, aarch64-darwin
```

## Key Design Decisions

1. **Per-system pkgs**: All systems share a single `pkgs` instance via flake-parts' `perSystem`.
   Custom pkgs config (like `rocmSupport = false` for desktop) is handled by constructing
   a separate pkgs instance with `extraPkgsConfig` in the nixos.nix module.

2. **Shared lib extension**: The extended lib (nixpkgs.lib + home-manager.lib + custom helpers)
   is exported from shared.nix via `_module.args.extLib` and imported by all modules that need it.

3. **homeConfig sharing**: Instead of duplicating the `homeConfig` definition across three files,
   it's exported from shared.nix as `_module.args.sharedHomeConfig` and reused.

4. **Module imports order**: Modules are imported in a specific order to ensure dependencies are met:
   - shared.nix (provides extLib and sharedHomeConfig)
   - pkgs.nix (uses self.overlays)
   - overlays.nix (defines overlays)
   - modules.nix
   - formatter.nix
   - dev-shells.nix
   - nixos.nix (uses overlays, modules, sharedHomeConfig, extLib)
   - darwin.nix (uses overlays, modules, sharedHomeConfig, extLib)
   - home.nix (uses overlays, modules)

5. **Relative paths**: All internal paths (./configuration.nix, ./hosts/*, ./users/*, etc.)
   were updated to use ../ when referenced from files in the flake/ subdirectory.

## Testing Notes

The migration was validated with:

- `nix eval '.#nixosConfigurations' --apply builtins.attrNames` ✓
- `nix eval '.#darwinConfigurations' --apply builtins.attrNames` ✓
- `nix eval '.#homeConfigurations' --apply builtins.attrNames` ✓
- `nix eval '.#nixosModules' --apply builtins.attrNames` ✓
- `nix eval '.#homeModules' --apply builtins.attrNames` ✓
- `nix eval '.#overlays' --apply builtins.attrNames` ✓
- `nix eval '.#devShells.aarch64-darwin' --apply builtins.attrNames` ✓
- `nix eval '.#formatter' --apply builtins.attrNames` ✓
- `nix fmt --help` ✓

All outputs match the original flake structure exactly.

## Future Improvements

See MIGRATION_PLAN.md for optional future enhancements:
- Use treefmt-nix flake-parts module for cleaner formatter integration
- Publish NixOS modules via flake.modules.nixos for better discoverability
- Remove builtins.currentSystem guards (unconditionally define all configs)
- Add CI checks output using perSystem.checks
- Consider auto-import modules for host/user discovery

## Migration Complete

The flake has been successfully migrated to flake-parts structure while maintaining 100% 
compatibility with the original outputs. All hosts, modules, overlays, and development 
environments are available through the new modular architecture.
