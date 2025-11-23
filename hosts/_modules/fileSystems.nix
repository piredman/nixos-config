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
  mkNasMount = shareName: {
    device = "//${systemSettings.nas.ip}/${shareName}";
    fsType = "cifs";
    options = [
      "credentials=/home/${userSettings.username}/.dotfiles/secrets/smb-secrets"
      "noauto"
      "x-systemd.automount"
      "uid=1000"
      "gid=100"
      "file_mode=0664"
      "dir_mode=0775"
    ];
  };
in
{
  fileSystems = builtins.listToAttrs (
    map (share: {
      name = "/mnt/${share}";
      value = mkNasMount share;
    }) systemSettings.nas.mounts
  );
}
