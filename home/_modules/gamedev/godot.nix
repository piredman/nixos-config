{ lib, pkgs, ... }:

let
  godot46 = pkgs.godotPackages_4_6;
  godot47 = pkgs.godotPackages_4_7;

  templateVersion = package:
    builtins.replaceStrings [ "-" ] [ "." ] package.version;
in
{
  home.packages = [
    godot47.godot
    (lib.lowPrio godot46.godot)
  ];

  home.file.".local/share/godot/export_templates/${
    templateVersion godot46.export-templates-bin
  }".source =
    godot46.export-templates-bin
    + "/share/godot/export_templates/${
      templateVersion godot46.export-templates-bin
    }";

  home.file.".local/share/godot/export_templates/${
    templateVersion godot47.export-templates-bin
  }".source =
    godot47.export-templates-bin
    + "/share/godot/export_templates/${
      templateVersion godot47.export-templates-bin
    }";
}
