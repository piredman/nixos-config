{
  config,
  lib,
  pkgs,
  ...
}:

let
  veiladForDisplaySession = pkgs.writeShellScript "veilad-for-display-session" ''
    session_id="$(${pkgs.systemd}/bin/loginctl show-user "$(${pkgs.coreutils}/bin/id -u)" --property=Display --value)"

    if [ -z "$session_id" ]; then
      echo "No graphical logind session found" >&2
      exit 1
    fi

    exec ${config.programs.veila.package}/bin/veilad --session-id="$session_id"
  '';
in
{
  programs.veila = {
    enable = true;
    service.enable = true;
  };

  systemd.user.services.veilad.serviceConfig.ExecStart = lib.mkForce veiladForDisplaySession;
}
