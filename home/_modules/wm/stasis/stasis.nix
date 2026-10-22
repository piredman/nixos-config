{ pkgs, ... }:

let
  lockDisplaySession = pkgs.writeShellScriptBin "wm-lock-session" ''
    session_id="$(${pkgs.systemd}/bin/loginctl show-user "$(${pkgs.coreutils}/bin/id -u)" --property=Display --value)"

    if [ -z "$session_id" ]; then
      echo "No graphical logind session found" >&2
      exit 1
    fi

    exec ${pkgs.systemd}/bin/loginctl lock-session "$session_id"
  '';

in
{
  home.packages = [ lockDisplaySession ];

  services.stasis = {
    enable = true;
    # Use nixpkgs' stasis package instead of the module's default (the flake's
    # own git build, whose cargo test is timing-flaky in the build sandbox).
    # nixpkgs 1.7.0 already sets doCheck = false and is Hydra-cached.
    package = pkgs.stasis;
    extraConfig = builtins.readFile ./stasis.rune;
    extraPathPackages = [
      lockDisplaySession
    ];
  };
}
