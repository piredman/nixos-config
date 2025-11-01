{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    impala

    (pkgs.writeShellScriptBin "impala-launcher" ''
      #!/bin/bash
      exec setsid -- "$TERMINAL" --class=Impala -e impala "$@"
    '')
  ];

  # You can also add other network-related configuration here
  # networking.firewall.allowedTCPPorts = [ 80 443 ];
}
