# NixOS Configuration Documentation Index

## Overview Documents

This section provides comprehensive analysis and planning for the NixOS/home-manager configuration structure and the Phase 2 aspect extraction project.

### 📋 Main Documentation Files

1. **[CONFIGURATION_ANALYSIS.md](CONFIGURATION_ANALYSIS.md)** - PRIMARY REFERENCE
   - Detailed analysis of all configuration layers
   - Host taxonomy and inheritance tree
   - All 7 hosts described with their roles
   - Current modules and packages catalog
   - Statistics and scope assessment
   - ~500 lines, comprehensive

2. **[CONFIGURATION_SUMMARY.txt](CONFIGURATION_SUMMARY.txt)** - QUICK VISUAL OVERVIEW
   - ASCII-formatted directory structure
   - Host categories and taxonomy
   - Configuration layers visualization
   - Aspect categories identified
   - Statistics and readiness assessment
   - Easy to scan, ~250 lines

3. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - FILE LOCATIONS
   - Exact file paths for all configurations
   - Common base files and their purposes
   - Per-host file listings
   - Modules registry structure
   - Users and home-manager modules
   - Good for quick lookup, ~350 lines

4. **[PHASE2_ROADMAP.md](PHASE2_ROADMAP.md)** - IMPLEMENTATION PLAN
   - Phase 2 goals and strategy
   - Aspect extraction plan (4 tiers)
   - Implementation workflow per aspect
   - Timeline estimates (8 weeks)
   - Testing strategy and success criteria
   - Post-extraction directory structure
   - ~400 lines, actionable

---

## Quick Navigation by Topic

### Understanding the Current Structure

**For a comprehensive overview:**
1. Start with [CONFIGURATION_SUMMARY.txt](CONFIGURATION_SUMMARY.txt) - 5 min read
2. Then [CONFIGURATION_ANALYSIS.md](CONFIGURATION_ANALYSIS.md) - 20 min read
3. Reference [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for specific files

**For finding specific files:**
→ Use [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

**For understanding host configurations:**
→ See Section 1 of [CONFIGURATION_ANALYSIS.md](CONFIGURATION_ANALYSIS.md)

**For understanding home-manager setup:**
→ See Section 3 of [CONFIGURATION_ANALYSIS.md](CONFIGURATION_ANALYSIS.md)

### Planning Phase 2 Work

**For project overview:**
→ See [PHASE2_ROADMAP.md](PHASE2_ROADMAP.md) - "Overview" and "Phase 2 Goals"

**For aspect extraction timeline:**
→ See [PHASE2_ROADMAP.md](PHASE2_ROADMAP.md) - "Aspect Extraction Plan"

**For understanding what exists:**
→ See [CONFIGURATION_ANALYSIS.md](CONFIGURATION_ANALYSIS.md) - "Existing Aspects Ready for Refactoring"

**For implementation details:**
→ See [PHASE2_ROADMAP.md](PHASE2_ROADMAP.md) - "Implementation Workflow"

---

## Configuration Hierarchy

```
ROOT CONFIGURATION (configuration.nix - 21 lines)
  ↓ (all systems)
CATEGORY BASES
  ├─ common/ (all Linux hosts)
  ├─ server/ (VPS + home server)
  └─ personal/ (workstations + laptops)
    ↓
INDIVIDUAL HOSTS (7 hosts)
  ├─ bifrost (VPN relay)
  ├─ midgard (Web server)
  ├─ niflheim (Home hub - 40+ services)
  ├─ desktop (Main workstation)
  ├─ carbon (Framework laptop)
  ├─ altdesk (Secondary desktop)
  └─ macbook (macOS)
    ↓
USER LEVEL (home-manager)
  └─ alapshin/ (24 modules)
```

---

## File Location Cheat Sheet

| Component | Location | Count | Ref |
|-----------|----------|-------|-----|
| Root config | `/configuration.nix` | 1 | Quick Ref |
| Common base | `/hosts/common/` | 7 files | Config Analysis §1 |
| Server base | `/hosts/server/` | 5 files | Config Analysis §1 |
| Personal base | `/hosts/personal/` | 10 files | Config Analysis §1 |
| VPS hosts | `/hosts/{bifrost,midgard,niflheim}/` | 18 files | Config Analysis §1 |
| Desktop hosts | `/hosts/{desktop,carbon,altdesk}/` | 21 files | Config Analysis §1 |
| macOS | `/hosts/macbook/` | 1 file | Config Analysis §1 |
| User config | `/users/alapshin/default.nix` | 1 file | Config Analysis §3 |
| Home-manager | `/users/alapshin/home/` | 24 files | Config Analysis §3 |
| NixOS modules | `/modules/_nixos-modules/` | 4 modules | Config Analysis §4 |
| HM modules | `/modules/_home-modules/` | 1 module | Config Analysis §4 |
| Flake modules | `/modules/` | 7 files | Quick Ref |
| Custom packages | `/packages/` | 13 items | Config Analysis §5 |
| Overlays | `/overlays/` | 2 overlays | Config Analysis §5 |

---

## Key Statistics at a Glance

| Metric | Count |
|--------|-------|
| Physical hosts | 7 |
| NixOS hosts | 6 |
| Users (system) | 1 (alapshin) |
| Home-manager modules | 24 |
| NixOS aspect modules | 4 |
| Home-manager aspect modules | 1 |
| Custom packages | 13 |
| Overlays | 2 |
| Total .nix files | 150+ |
| Services on niflheim | 40+ |

---

## Aspect Categories (Current State)

### Fully Extracted & Modular
- ✅ backup (borgbackup)
- ✅ vpn (Xray/Wireguard)
- ✅ monica (CRM)
- ✅ webhost (multi-domain)

### Partially Scattered (Good for Extraction)
- 🟡 audio (personal/audio.nix)
- 🟡 boot (personal/boot.nix)
- 🟡 graphical-desktop (personal/graphical-desktop.nix)
- 🟡 gaming (desktop/gaming.nix)
- 🟡 virtualization (scattered)

### Service-Specific (Niflheim-centric)
- 🔵 web (caddy, nginx, authelia)
- 🔵 database (postgres, influxdb)
- 🔵 monitoring (prometheus, grafana, scrutiny)
- 🔵 media (jellyfin, transmission, immich)
- 🔵 data (nextcloud, paperless, linkwarden)
- 🔵 ai/ml (open-webui, docling, searx)

### Home-Manager (Well-Organized)
- ✅ 24 modules covering all user concerns

---

## Phase 2 Extraction Priorities

### Tier 1 (Weeks 1-2) - Core Fundamentals
1. audio → `modules/_nixos-modules/system/audio.nix`
2. boot → `modules/_nixos-modules/system/boot.nix`
3. bluetooth → `modules/_nixos-modules/hardware/bluetooth.nix`

### Tier 2 (Weeks 3-4) - Desktop Stack
1. graphical-desktop/plasma → `modules/_nixos-modules/desktop/plasma.nix`
2. gaming → `modules/_nixos-modules/desktop/gaming.nix`
3. input (keyboard, touchpad) → `modules/_nixos-modules/hardware/input.nix`

### Tier 3 (Weeks 5-7) - Services
- Web (caddy, nginx, authelia)
- Database (postgres, influxdb)
- Monitoring (prometheus, grafana, scrutiny)
- Media (jellyfin, transmission, immich, etc.)
- Data (nextcloud, paperless, linkwarden)
- AI/ML (open-webui, docling, searx)

### Tier 4 (Week 8) - Development
- Development tools (compilers, runtimes)
- Containers (podman/docker)
- Documentation (texlive)

---

## How to Use These Documents

### Scenario 1: "I need to understand the full structure"
1. Read CONFIGURATION_SUMMARY.txt (visual overview) - 5 min
2. Read CONFIGURATION_ANALYSIS.md (detailed) - 30 min
3. Keep QUICK_REFERENCE.md handy for lookups

### Scenario 2: "I need to find a specific configuration file"
→ Use QUICK_REFERENCE.md - File Location Cheat Sheet section

### Scenario 3: "I need to plan Phase 2 work"
1. Read CONFIGURATION_ANALYSIS.md §8-9 (scope assessment)
2. Read PHASE2_ROADMAP.md (full plan)
3. Reference QUICK_REFERENCE.md for file paths

### Scenario 4: "I need to extract a specific aspect"
1. Check CONFIGURATION_ANALYSIS.md §8 - is it a priority?
2. Check PHASE2_ROADMAP.md - which tier?
3. Check QUICK_REFERENCE.md for current file locations
4. Follow implementation workflow in PHASE2_ROADMAP.md

### Scenario 5: "I need to understand niflheim (the hub)"
→ See CONFIGURATION_ANALYSIS.md §1 - niflheim subsection
→ See CONFIGURATION_SUMMARY.txt §8 - service breakdown

---

## Related Project Files

- **MIGRATION_PLAN.md** - Original flake-parts migration plan (Phase 1)
- **MIGRATION_COMPLETE.md** - Migration status and completion notes
- **dendritic-migration.md** - Detailed migration walkthrough
- **README.md** - Project overview

---

## Contributing to Phase 2

### Before You Start
1. Read CONFIGURATION_ANALYSIS.md (understand current state)
2. Read PHASE2_ROADMAP.md (understand what you're doing)
3. Identify your aspect from the extraction plan

### During Implementation
1. Follow "Implementation Workflow" section in PHASE2_ROADMAP.md
2. Use QUICK_REFERENCE.md to locate source files
3. Test following "Testing Strategy" section

### After Implementation
1. Update relevant documentation files
2. Add entry to aspect registry (PHASE2_ROADMAP.md)
3. Run test suite and document results

---

## Document Maintenance

These documents are auto-generated summaries of the actual configuration. They should be updated when:

- New hosts are added
- Major configuration structure changes occur
- New aspect modules are created
- Significant file moves/renames happen

To regenerate (once automation is in place):
```bash
$ nix run .#generate-docs
# or
$ ./scripts/generate-docs.sh
```

---

## Questions & Answers

**Q: Where do I find the definition for a specific host?**
A: See QUICK_REFERENCE.md - each host has a subsection with all its files

**Q: What's the inheritance structure for configurations?**
A: See CONFIGURATION_ANALYSIS.md §6 or CONFIGURATION_SUMMARY.txt §7

**Q: How do I understand what's on niflheim?**
A: See CONFIGURATION_ANALYSIS.md §1 (niflheim subsection) or CONFIGURATION_SUMMARY.txt §8

**Q: What should I extract in Phase 2?**
A: See PHASE2_ROADMAP.md - Aspect Extraction Plan section

**Q: What files should I edit to add a new aspect?**
A: See PHASE2_ROADMAP.md - Implementation Workflow section

**Q: Where can I find all NixOS modules?**
A: `/modules/_nixos-modules/` - see QUICK_REFERENCE.md §B

**Q: How many home-manager modules exist?**
A: 24 modules in `/users/alapshin/home/` - see CONFIGURATION_ANALYSIS.md §3

---

## Contact/Support

For questions about the configuration structure:
1. Check the relevant documentation file above
2. Review QUICK_REFERENCE.md for file locations
3. Check git history for context

---

**Last Updated:** March 13, 2026
**Phase:** 1 (Complete) - Ready for Phase 2
**Status:** All documentation current and comprehensive

