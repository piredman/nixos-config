# Plan: Omarchy-Inspired Stability Improvements

Research comparing this config against `~/code/reference/omarchy` (Arch + Hyprland desktop).
Omarchy encodes ~2 years of accumulated stability fixes; this plan ports the ones that make
sense on NixOS. Your architecture already beats omarchy's migration-script approach by being
declarative — these changes encode the fixes once.

## Status

| Item | State |
|---|---|
| Tier 1A — zram + VM tuning | **DONE** — deployed on terra (rebuilt + rebooted, verified live: zramctl, sysctls) |
| Tier 1B — oomd slice isolation + app scoping | **DONE** — deployed on terra (verified live: `oomctl`, drop-ins, ghostty session scoped in `app.slice`) |
| Tier 1 rebuild on luna / mini | **PENDING** — apply with `nrh` on each host |
| Tiers 2–5 | **PENDING** |

## Scope decision

- **Tier 1** Memory & session stability (zram + oomd slice isolation)
- **Tier 2** Screenshare & browser hardening (category of commit `e5d3540` "Fix screenshare")
- **Tier 3** Suspend/lock pipeline
- **Tier 4** systemd unit hygiene
- **Tier 5** Small omarchy ideas, optional

Apply order: 1 → 2 → 3 → 4 → 5, committing after each tier so `switch --rollback` is trivial.
Never run rebuilds automatically — the user applies `sudo nixos-rebuild switch --flake .#<host>` manually.

---

## Tier 1 — Memory & session stability (all hosts)

### A. zram + VM tuning — `hosts/_modules/core/zram.nix` — **DONE**

Implemented as written below. Auto-discovered by the core module group (no import wiring).
Deployed and verified on terra: `zramctl` shows 31.2G zstd device; all four sysctls live.

```nix
zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
};

boot.kernel.sysctl = {
    "vm.swappiness" = 150;            # zram is compressed RAM; default 60 starves page cache
    "vm.vfs_cache_pressure" = 50;
    "vm.page-cluster" = 0;            # no seek cost on zram
    "vm.watermark_boost_factor" = 0;
};
```

- Do NOT enable zswap (double compression in front of zram — omarchy explicitly disables it).

### B. oomd slice isolation + app scoping — `hosts/_modules/core/oomd.nix` — **DONE**

Omarchy's #1 stability feature: memory-pressure killing is scoped to the user service tree and
`app.slice` only; the compositor is structurally ineligible to be killed.

- oomd is already enabled (NixOS default on terra/luna/mini) — verified via flake eval, but with
  **no slice criteria** (all kill criteria default off in current nixpkgs; clean slate).
- NOTE: `systemd.oomd.extraConfig` was renamed to `systemd.oomd.settings.OOM` in current nixpkgs.

Implemented in `hosts/_modules/core/oomd.nix`:

```nix
systemd.oomd.settings.OOM = {
    DefaultMemoryPressureLimit = "50%";
    DefaultMemoryPressureDurationSec = "20s";
};
```

- `user@.service` drop-in (Fedora-style): `ManagedOOMMemoryPressure=kill` @ 50% +
  `ManagedOOMSwap=kill`. Victim selection picks the highest-pressure descendant, so a single
  runaway daemon dies — never the whole session. The compositor (hyprland/niri) runs outside
  `user@.service` (launched from the tty login shell), so it can never be an oomd victim.
- User `app.slice`: same criteria for scoped apps.
- Root/system slice monitoring deliberately left off (omarchy doesn't enable it either).

**IMPORTANT — implementation lesson:** the drop-ins are declared through the systemd module's
unit machinery (`systemd.services."user@"` with `overrideStrategy = "asDropin"` and
`systemd.user.slices."app".sliceConfig`), **not** via `environment.etc`. `/etc/systemd/system`
and `/etc/systemd/user` are generated *directory* entries in the NixOS etc tree — nested
`environment.etc` files underneath them fail the build (`ln: Permission denied` in the etc
derivation). Deployed and verified on terra: `oomctl` monitors both cgroups; ghostty sessions
run scoped as `app-ghostty-*.scope`.

**App scoping (omarchy's `uwsm-app` equivalent):** `wm-app-run` wrapper — shared derivation in
`lib/wm-app-run.nix`, installed as a system package by `oomd.nix`. Runs commands via
`systemd-run --user --scope --collect --slice=app.slice`, giving each app its own oomd-killable
cgroup. Unit names are `app-<name>-<pid>` (PID-unique, no `$RANDOM` collisions); `--collect`
cleans up dead scopes. Falls back to plain exec when no user manager is reachable or already
inside app.slice (no nesting). Wired into:
- walker: `config.app_launch_prefix = "${lib.getExe wmAppRun} "` (trailing space required —
  walker concatenates the prefix with the command)
- ghostty: `settings.command = "${lib.getExe wmAppRun} ${pkgs.zsh}/bin/zsh"` (no-ops when
  ghostty itself was launched via walker; zsh matches `users.nix` login shell)

---

## Tier 2 — Screenshare & browser hardening — PENDING

### C. Portal config — `home/_modules/core/xdg.nix`

Current bug: `xdg.portal.config.common.default = ["gtk"]` forces the GTK portal for *everything*,
including ScreenCast, even on Hyprland hosts where the hyprland portal is installed.

```nix
xdg.portal.config = {
    common.default = [ "gtk" ];
    "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
    "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
    "org.freedesktop.impl.portal.ScreenShare" = [ "hyprland" ];
};
```

For the niri path (`home/_modules/wm/niri/niri.nix`), map the same interfaces to `gnome`.

### D. xdph share-token QoL — hypr portal config

Add omarchy's `allow_token_by_default = true` so share choices persist across sessions
(no re-prompt every meeting). Set via the hyprland portal's config file
(`~/.config/xdg-desktop-portal-hyprland/config.toml` or equivalent for current xdph versions):

```toml
[screencopy]
allow_token_by_default = true
```

### E. Chromium/Electron env hardening — move to system-wide

`NIXOS_OZONE_WL=1` is currently set per-module (obsidian, helium, niri) and in hyprland.lua's
`hl.env`. Promote to `hosts/_modules/core/core.nix`:

```nix
environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";  # omarchy pins wayland, not auto
    GDK_BACKEND = "wayland,x11,*";
    QT_QPA_PLATFORM = "wayland;xcb";
    MOZ_ENABLE_WAYLAND = "1";
};
```

- Do NOT set `XDG_CURRENT_DESKTOP` here — that is correctly session-scoped in
  `home/_modules/wm/{hyprland,niri}/session.nix` via dbus-update.

### F. zen-browser keyring / password store

Omarchy migration 1784508556: without a portal Secret provider, browsers can fall back to the
`basic` store → cookies/passwords undecryptable after keyring swap (silent logouts). Guarantee a
Secret provider exists at system level:

```nix
services.gnome.gnome-keyring.enable = true;
```

Verify zen keeps its stored logins across rebuilds.

### G. Portal window rules — `home/redman/hypr/hyprland.lua`

```lua
hl.window_rule({ match = { class = "xdg-desktop-portal-gtk" }, float = true })
```

Optional (omarchy extras):
- `title = ".*is sharing.*"` → `special silent` (hides the "screen is being shared" toast).
- Password-manager windows → `no_screen_share = true`.

---

## Tier 3 — Suspend/lock pipeline — PENDING

### H. Lock-before-suspend — mirrors omarchy's `omarchy-sleep-lock.service`

Currently nothing locks before suspend (stasis only fires on idle timeout) → resume unlocked.

1. logind delay budget — new system drop-in:
```nix
environment.etc."systemd/logind.conf.d/20-inhibit-delay.conf".text = ''
    [Login]
    InhibitDelayMaxSec=15
'';
```

2. New user unit `wm-sleep-lock.service` (PartOf graphical-session.target):
   - Holds a `systemd-inhibit --what=sleep --mode=delay` handle.
   - On `PrepareForSleep` (dbus signal): run `wm-lock-session`, poll for lock-secured state
     within the real deadline (read from `InhibitDelayMaxUSec` via busctl, capped ~12s).
   - On failure: critical notification "Screen did not lock before suspend".

### I. Session-lock recovery — hyprland.lua `misc`

```lua
allow_session_lock_restore = true
```

Veila uses the session-lock protocol; if the lock client dies, a fresh one can re-acquire
instead of leaving the desktop unlocked.

---

## Tier 4 — systemd unit hygiene — PENDING

### J. Fast shutdown — new `hosts/_modules/core/systemd.nix`

```nix
systemd.extraConfig = "DefaultTimeoutStopSec=10s";
systemd.user.extraConfig = "DefaultTimeoutStopSec=10s";
```

Kills the 45–90s stalls when a unit misbehaves at shutdown.

### K. Deduplicate mako — `home/_modules/wm/mako.nix`

Both HM `services.mako` and a hand-rolled `systemd.user.services.mako` (socat wait) define the
same daemon. Keep the HM unit (add `After = [ "graphical-session.target" ]` via override);
delete the hand-rolled one.

### L. Extract wayland-wait loop

The socat UNIX-CONNECT wait loop is copy-pasted in mako, walker, awww, quickshell. Extract to a
shared helper (e.g. `lib/wayland-wait.nix` → single script pkg). Most waits should become
unnecessary once `wm-start-hyprland-session`'s dbus-update runs before
`graphical-session.target` is reached — keep the loop only where genuinely needed.

### M. Remove `RestartSec = mkForce` hacks (awww, walker)

HM `mkForce` fights module defaults; an explicit `Service.RestartSec` override in the unit's
config achieves the same cleanly.

---

## Tier 5 — Small wins (optional, each tiny)

- **Wi-Fi powersave off** (luna): NM drop-in `wifi.powersave = 2` — fixes 20–300ms latency spikes.
- **SSH keepalives**: `/etc/ssh/ssh_config.d` → `ServerAliveInterval 15`, `ServerAliveCountMax 3`,
  `ConnectTimeout 10`.
- **Wireplumber soft-mixer**: `api.alsa.soft-mixer = true` on all ALSA cards (avoids hardware
  mixer quirks) — wireplumber drop-in.
- **BT A2DP auto-connect**: wireplumber rule `bluez5.auto-connect = [ a2dp_sink a2dp_source ]`
  for `bluez_card.*` (only if BT audio used).
- **Power profiles**: `services.power-profiles-daemon.enable = true` on luna (laptop).
- **Idle inhibit via window tags**: `noidle` tag → `idle_inhibit = always` (nicer than stasis'
  app-regex for video players).

---

## Explicitly skipped (with rationale)

- **uwsm** — existing `wm-start-*-session` + `*-session.target` already provides the equivalent;
  rewrite for no gain.
- **Plymouth/limine/snapper** — Arch-bootloader fragility; NixOS generations are the snapshots.
- **Quickshell-everything consolidation** (idle/lock/notifications/polkit in one process) —
  stasis/veila/mako/polkit work fine; redesign, not a stability win.

---

## Verification checklist (per tier)

1. `sudo nixos-rebuild test --flake .#terra` (manual step, never automatic)
2. Tier 1: ✅ verified on terra — `zramctl` shows 31.2G zstd device; `oomctl` lists
   `user@1000.service` and `app.slice` as monitored; ghostty sessions land in
   `app-ghostty-*.scope` under `app.slice`; sysctls live (`cat /proc/sys/vm/swappiness`)
3. Tier 2: screenshare works in zen + obsidian file dialogs + portal floats when tiling
4. Tier 3: `systemctl suspend` → lock appears before sleep; resume unlocked-password correct
5. Tier 4: shutdown timing; only one mako process (`pgrep -a mako`)
6. Commit after each tier; rollback path: `sudo nixos-rebuild switch --rollback`
