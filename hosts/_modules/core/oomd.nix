{
  config,
  lib,
  pkgs,
  pkgs-stable,
  systemSettings,
  userSettings,
  ...
}:

let
  wmAppRun = import ../../../lib/wm-app-run.nix { inherit pkgs; };
in
{
  # Verifying status
  # > systemctl status systemd-oomd
  # > systemctl cat user@.service  (shows the oomd drop-in)
  # > systemctl --user show app.slice -p ManagedOOMMemoryPressure
  # > systemd-cgls /user.slice/user-$(id -u).slice/user@1000.service/app.slice

  # oomd: memory-pressure based killing. NixOS enables the daemon by default
  # but with no slice criteria; these drop-ins scope killing to the user
  # service tree and app.slice only. The compositor (hyprland/niri) runs
  # outside user@.service, so it can never be an oomd victim.
  #
  # NOTE: the drop-ins are declared through the systemd module's unit
  # machinery, not environment.etc - /etc/systemd/system and
  # /etc/systemd/user are generated directory entries, and nested
  # environment.etc files underneath them fail to build.

  systemd.oomd.settings.OOM = {
    DefaultMemoryPressureLimit = "50%";
    DefaultMemoryPressureDurationSec = "20s";
  };

  # Fedora-style: monitor every user manager's service tree. The victim is
  # the highest-pressure descendant, so a single runaway daemon gets killed
  # instead of the whole session.
  systemd.services."user@" = {
    overrideStrategy = "asDropin";
    serviceConfig = {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "50%";
      ManagedOOMSwap = "kill";
    };
  };

  # app.slice: kill criteria for apps launched in their own scope via wm-app-run
  systemd.user.slices."app".sliceConfig = {
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "50%";
    ManagedOOMSwap = "kill";
  };

  environment.systemPackages = [ wmAppRun ];
}
