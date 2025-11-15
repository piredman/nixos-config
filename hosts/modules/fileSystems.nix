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
    device = "//192.168.1.12/${shareName}";
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
  fileSystems."/mnt/apps" = mkNasMount "apps";
  fileSystems."/mnt/backups" = mkNasMount "backups";
  fileSystems."/mnt/docker" = mkNasMount "docker";
  fileSystems."/mnt/documents" = mkNasMount "documents";
  fileSystems."/mnt/scans" = mkNasMount "scans";
  fileSystems."/mnt/syncthing" = mkNasMount "syncthing";
}
