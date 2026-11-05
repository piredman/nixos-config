{ pkgs, ... }:

{
  # User-presence checks need an action visible to the system polkit daemon.
  # The GUI remains a Home Manager package; only this policy is system-wide.
  environment.systemPackages = [ pkgs.aegis-desktop.polkitPolicy ];
}
