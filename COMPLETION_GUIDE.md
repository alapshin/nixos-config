# Dendritic Migration Completion Guide

**Current Status:** Phases 1-3 complete, flake evaluates ✅  
**Goal:** Complete Phase 4 (Cleanup) and verify full functionality  
**Estimated Time:** 1-2 hours depending on system availability

---

## Phase 4: Cleanup & Verification

### Phase 4a: Build Verification (CRITICAL - Start Here)

**Objective:** Ensure all host configurations actually build before deleting anything

#### Step 1: Pick a Test Host

Start with the simplest host first. I recommend **bifrost** or **altdesk** (smallest configs):

```bash
# Test bifrost (Linode VPS - simplest)
nix build '.#nixosConfigurations.bifrost.config.system.build.toplevel' \
  --keep-going 2>&1 | tee bifrost-build.log

# If bifrost succeeds, try midgard
nix build '.#nixosConfigurations.midgard.config.system.build.toplevel' \
  --keep-going 2>&1 | tee midgard-build.log
```

#### Step 2: Check Build Results

```bash
# Review build logs for errors
grep -i "error:" bifrost-build.log

# If successful, you should see:
# ✅ Build completed successfully

# Get the result path
result=$(nix build '.#nixosConfigurations.bifrost.config.system.build.toplevel' --no-link --print-out-paths)
echo "Built to: $result"
```

#### Step 3: Troubleshoot Any Build Failures

If builds fail, common issues might be:

1. **Missing secrets files:** Check if `hosts/bifrost/secrets/` exists
   ```bash
   ls -la hosts/bifrost/secrets/
   ```

2. **Module import errors:** Check relative paths in host modules
   ```bash
   cat modules/hosts/bifrost.nix | grep "hostDir\|imports"
   ```

3. **Option errors:** Check if all referenced modules are properly exported
   ```bash
   nix eval '.#nixosModules' --json | jq 'keys'
   ```

#### Step 4: Build All Hosts

Once one succeeds, build all remaining NixOS configurations:

```bash
# Build all in sequence (safest approach)
for host in bifrost midgard niflheim carbon desktop altdesk; do
  echo "=== Building $host ==="
  nix build ".#nixosConfigurations.${host}.config.system.build.toplevel" \
    --keep-going 2>&1 | tail -5
  echo ""
done

# Or build all in parallel (faster, but harder to debug)
nix build \
  '.#nixosConfigurations.bifrost.config.system.build.toplevel' \
  '.#nixosConfigurations.midgard.config.system.build.toplevel' \
  '.#nixosConfigurations.niflheim.config.system.build.toplevel' \
  '.#nixosConfigurations.carbon.config.system.build.toplevel' \
  '.#nixosConfigurations.desktop.config.system.build.toplevel' \
  '.#nixosConfigurations.altdesk.config.system.build.toplevel' \
  --keep-going
```

#### Step 5: Expected Outcomes

```
✅ SUCCESS: All builds complete
├─ bifrost: /nix/store/...toplevel
├─ midgard: /nix/store/...toplevel
├─ niflheim: /nix/store/...toplevel
├─ carbon: /nix/store/...toplevel
├─ desktop: /nix/store/...toplevel
└─ altdesk: /nix/store/...toplevel

❌ FAILURE: Note which hosts fail and why
├─ bifrost failed: [error details]
├─ desktop failed: [error details]
└─ ... (fix issues, see troubleshooting below)
```

---

### Phase 4b: System Activation Test (Optional but Recommended)

**Objective:** Verify the new configuration actually works on a system

**WARNING:** Only do this after successful builds. Only test on a system you can recover if something goes wrong.

#### Option 1: Dry Run (Safe)

```bash
# On bifrost or any Linux system, do a dry run:
sudo nixos-rebuild dry-build -I nixos-config=./hosts/bifrost/default.nix

# Or using the flake:
sudo nixos-rebuild switch --flake '.#bifrost' --dry-run
```

#### Option 2: Test on Desktop (Easiest)

If your desktop is the most forgiving to test on:

```bash
# Backup current generation
nix-env --list-generations

# Dry run first
sudo nixos-rebuild dry-build --flake '.#desktop'

# If dry run succeeds, test (but you can roll back)
sudo nixos-rebuild test --flake '.#desktop'

# After testing, switch if everything works
sudo nixos-rebuild switch --flake '.#desktop'
```

#### Step 3: Roll Back If Needed

```bash
# If something breaks, roll back to previous generation
sudo nixos-rebuild switch --rollback

# Or explicitly switch to a generation
sudo nix-env --list-generations -p /nix/var/nix/profiles/system
sudo nix-env -p /nix/var/nix/profiles/system --switch-generation <NUM>
```

---

### Phase 4c: Cleanup Old Directory Structure

**⚠️ CRITICAL: Only proceed after successful Phase 4a+4b validation**

#### Step 1: Backup Before Deleting

```bash
# Create a backup branch before cleanup
git checkout -b pre-cleanup-backup
git push origin pre-cleanup-backup

# Return to main branch
git checkout flake-parts
```

#### Step 2: What to Delete

```
DELETE (safe - content moved to modules/):
├─ flake/                       # Empty directory, all content moved
├─ hosts/common/                # All content moved to individual hosts
├─ hosts/server/                # All content moved to bifrost/midgard/niflheim
└─ hosts/personal/              # All content moved to desktop/carbon/altdesk

KEEP (still needed):
├─ hosts/bifrost/
│  ├─ [service files that stayed]
│  └─ secrets/                  ✅ DO NOT DELETE
├─ hosts/midgard/
│  ├─ [service files]
│  └─ secrets/                  ✅ DO NOT DELETE
├─ hosts/niflheim/
│  ├─ [40+ service files]
│  └─ secrets/                  ✅ DO NOT DELETE
├─ hosts/desktop/
│  ├─ [service files]
│  └─ secrets/                  ✅ DO NOT DELETE
├─ hosts/carbon/
│  ├─ [service files]
│  └─ secrets/                  ✅ DO NOT DELETE
├─ hosts/altdesk/
│  ├─ [service files]
│  └─ secrets/                  ✅ DO NOT DELETE
├─ hosts/macbook/               ✅ DO NOT DELETE
├─ users/alapshin/
│  ├─ home/                     ✅ DO NOT DELETE (imported as unit)
│  └─ secrets/                  ✅ DO NOT DELETE
└─ [everything else]
```

#### Step 3: Safe Deletion Script

```bash
# First, verify what will be deleted
echo "=== Files to be deleted ==="
find flake -type f 2>/dev/null | sort
echo ""
find hosts/common -type f 2>/dev/null | sort
find hosts/server -type f 2>/dev/null | sort
find hosts/personal -type f 2>/dev/null | sort

# If the above looks correct, proceed:
rm -rf flake/
rm -rf hosts/common/
rm -rf hosts/server/
rm -rf hosts/personal/

# Verify deletions
echo "=== Remaining hosts/ structure ==="
find hosts -maxdepth 1 -type d | sort
```

#### Step 4: Commit Cleanup

```bash
# Stage the deletions
git add -A

# Verify changes before committing
git status

# Commit with clear message
git commit -m "Phase 4 Cleanup: Remove old directory structures

DELETED:
- flake/ directory (all content moved to modules/)
- hosts/common/ (config moved to individual host modules)
- hosts/server/ (config distributed to bifrost/midgard/niflheim)
- hosts/personal/ (config distributed to desktop/carbon/altdesk)

PRESERVED:
- hosts/<name>/secrets/ (all secret files stay in place)
- hosts/<name>/[service files] (service config files stay in place)
- users/alapshin/home/ (user HM modules stay as a unit)
- users/alapshin/secrets/ (user secrets stay in place)

The configuration is now fully modularized using Dendritic Nix with
flake-parts. All functionality preserved, cleaner directory structure."
```

---

### Phase 4d: Final Validation

#### Step 1: Verify Flake Still Works

```bash
# Ensure flake still evaluates
nix flake show 2>&1 | head -20

# Check all expected outputs exist
nix eval '.#nixosConfigurations' --json | jq 'keys'
nix eval '.#homeConfigurations' --json | jq 'keys'
nix eval '.#nixosModules' --json | jq 'keys'
```

#### Step 2: Rebuild All Hosts (Final Test)

```bash
# Quick rebuild of all hosts to ensure nothing broke
nix build \
  '.#nixosConfigurations.bifrost.config.system.build.toplevel' \
  '.#nixosConfigurations.midgard.config.system.build.toplevel' \
  '.#nixosConfigurations.niflheim.config.system.build.toplevel' \
  '.#nixosConfigurations.carbon.config.system.build.toplevel' \
  '.#nixosConfigurations.desktop.config.system.build.toplevel' \
  '.#nixosConfigurations.altdesk.config.system.build.toplevel' \
  --keep-going

echo "✅ All hosts built successfully"
```

#### Step 3: Check Git History

```bash
# View migration commits
git log --oneline -15

# Verify clean history
git status  # Should show "working tree clean"
```

---

## Troubleshooting Common Issues

### Issue 1: "Module X not found"

**Symptom:**
```
error: The option `services.backup' does not exist
```

**Solution:**
1. Check if the module is exported in `modules/_nixos-modules/default.nix`
2. Verify the module file exists and is readable
3. Check that shared modules in `configurations.nix` include it

```bash
# Debug
nix eval '.#nixosModules' --json | jq 'keys | sort'
grep "backup" modules/_nixos-modules/default.nix
```

### Issue 2: "Secrets file not found"

**Symptom:**
```
error: Cannot open /nix/store/.../path/to/secrets.nix: No such file or directory
```

**Solution:**
1. Verify the secrets file exists in the original location
2. Check the anchored path in the host module is correct
3. Ensure the sops-nix module is imported

```bash
# Debug
ls -la hosts/bifrost/secrets/
cat modules/hosts/bifrost.nix | grep "hostDir\|secrets"
```

### Issue 3: Home-manager module errors

**Symptom:**
```
error: attribute 'username' missing
```

**Solution:**
Check that `modules/users/alapshin.nix` properly passes `_module.args`:

```bash
# Verify
grep "_module.args" modules/users/alapshin.nix
grep "username" modules/users/alapshin.nix
```

### Issue 4: Build hangs or takes very long

**Symptom:**
```
nix build hangs for >30 minutes
```

**Solution:**
1. Check if large packages are being rebuilt (normal)
2. Check for infinite recursion or loops
3. Use `--keep-going` to see all errors at once

```bash
# Limit to binary cache (skip builds)
nix build '.#nixosConfigurations.bifrost...' \
  --keep-going \
  --no-build-outputs

# Or use faster flake check
nix flake check --allow-import-from-derivation
```

---

## Recommended Completion Timeline

### Day 1: Verification
- **30 min:** Phase 4a - Build verification (all hosts)
- **30 min:** Phase 4b - System activation test (if applicable)
- **15 min:** Phase 4d - Final validation

**Outcome:** Confident that new structure works

### Day 2: Cleanup (if Day 1 successful)
- **5 min:** Create backup branch
- **5 min:** Execute cleanup script
- **5 min:** Commit cleanup
- **10 min:** Final test builds
- **5 min:** Document completion

**Outcome:** Clean, modularized, production-ready configuration

### Optional: Phase 2 Completion
- **1-2 hours:** Create remaining 25+ aspect modules
- **15 min:** Document aspect library

**Outcome:** Complete, fully modular aspect library

---

## Checklist for Completion

### Pre-Cleanup Checklist
- [ ] All 6 NixOS hosts build successfully
- [ ] At least one host tested with `nixos-rebuild` (dry-run minimum)
- [ ] Flake still evaluates with `nix flake show`
- [ ] No uncommitted changes in git
- [ ] Backup branch created with `git checkout -b pre-cleanup-backup`

### Cleanup Checklist
- [ ] Deleted `flake/` directory
- [ ] Deleted `hosts/common/` directory
- [ ] Deleted `hosts/server/` directory
- [ ] Deleted `hosts/personal/` directory
- [ ] Verified all `hosts/*/secrets/` directories still exist
- [ ] Verified all host service files still exist
- [ ] Verified `users/alapshin/home/` still exists
- [ ] Changes committed with clear message

### Post-Cleanup Checklist
- [ ] Flake evaluates: `nix flake show`
- [ ] All hosts build: `nix build '.#nixosConfigurations.*'`
- [ ] Git history is clean: `git status`
- [ ] Can view migration commits: `git log --oneline -20`

---

## Success Criteria

✅ **You're done when:**

1. **All hosts build** - `nix build` succeeds for all nixosConfigurations
2. **Flake evaluates** - `nix flake show` shows all expected outputs
3. **Old dirs deleted** - `flake/`, `hosts/common/server/personal/` removed
4. **Secrets intact** - All `hosts/*/secrets/` and `users/alapshin/secrets/` unchanged
5. **System tested** - At least one host passes `nixos-rebuild test` or dry-run
6. **Git clean** - All changes committed, working tree clean

---

## Quick Start Commands

```bash
# 1. Test builds (takes 5-60 min depending on system)
nix build '.#nixosConfigurations.bifrost.config.system.build.toplevel' --keep-going

# 2. Create backup
git checkout -b pre-cleanup-backup && git push origin pre-cleanup-backup && git checkout flake-parts

# 3. Delete old directories
rm -rf flake/ hosts/common/ hosts/server/ hosts/personal/

# 4. Commit cleanup
git add -A && git commit -m "Phase 4: Cleanup old directory structures"

# 5. Final validation
nix flake show && nix build '.#nixosConfigurations.bifrost...' --keep-going

# 6. Done! ✅
git log --oneline -5
```

---

## Next Actions

**Choose one:**

### Option A: Start Phase 4 Now
- Time investment: 1-2 hours
- Outcome: Production-ready, fully cleaned up configuration
- **Recommended if:** You have a Linux system available for testing

### Option B: Test Incrementally
- Time investment: 30 min/day over several days
- Outcome: Gradual validation with low risk
- **Recommended if:** You want to test carefully on live systems

### Option C: Document First, Cleanup Later
- Time investment: 15 min (doc) + 1 hour (cleanup)
- Outcome: Clear instructions for team/future reference
- **Recommended if:** You're not the only person using this config

---

*Follow this guide to safely complete the migration from hand-rolled flake to fully modularized Dendritic Nix.*
