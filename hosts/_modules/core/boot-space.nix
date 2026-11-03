{ config, lib, pkgs, ... }:

let
    cfg = config.boot.loader.systemd-boot;
    esp = config.boot.loader.efi.efiSysMountPoint;
    boot = if cfg.xbootldrMountPoint == null then esp else cfg.xbootldrMountPoint;
    extraFiles = pkgs.writeText "boot-extra-files.json" (
        builtins.toJSON (lib.mapAttrs (_: source: toString source) cfg.extraFiles)
    );
in
{
    config = lib.mkIf cfg.enable {
        assertions = [ {
            assertion = cfg.configurationLimit != null && cfg.configurationLimit > 0;
            message = "The boot-space guard requires a positive systemd-boot.configurationLimit.";
        } ];

        # nprune reads the active system's limit instead of maintaining another count.
        environment.etc."nixos-generation-retention".text =
            "${toString cfg.configurationLimit}\n";

        # Runs after the build, but before the bootloader installer can delete/copy files.
        # Do not put this in activationScripts: those run too late to protect /boot.
        system.preSwitchChecks.bootSpace = ''
            case "''${2-}" in
                switch|boot)
                    ${pkgs.python3}/bin/python3 ${../../../lib/boot-space-check.py} \
                        --incoming "$1" \
                        --boot ${lib.escapeShellArg boot} \
                        --esp ${lib.escapeShellArg esp} \
                        --limit ${toString cfg.configurationLimit} \
                        --extra-files ${extraFiles} \
                        --reserve-mib 128
                    ;;
            esac
        '';
    };
}
