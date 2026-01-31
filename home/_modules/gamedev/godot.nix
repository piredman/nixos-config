{
  config,
  lib,
  pkgs,
  pkgs-stable,
  userSettings,
  ...
}:

{

  # Once nixos unstable has Godot 4.6 avalable, change back to using it.
  /*
    home.packages = with pkgs; [
      godot
      godot_4-export-templates-bin
    ];

    home.file.".local/share/godot/export_templates/${
      builtins.replaceStrings [ "-" ] [ "." ] pkgs.godot_4-export-templates-bin.version
    }".source =
      pkgs.godot_4-export-templates-bin
      + "/share/godot/export_templates/${
        builtins.replaceStrings [ "-" ] [ "." ] pkgs.godot_4-export-templates-bin.version
      }";
  */

  home.packages = with pkgs-stable; [
    godotPackages_4_6.godot
    godotPackages_4_6.export-templates-bin
  ];
  home.file.".local/share/godot/export_templates/${
    builtins.replaceStrings [ "-" ] [ "." ] pkgs-stable.godotPackages_4_6.export-templates-bin.version
  }".source =
    pkgs-stable.godotPackages_4_6.export-templates-bin
    + "/share/godot/export_templates/${
      builtins.replaceStrings [ "-" ] [ "." ] pkgs-stable.godotPackages_4_6.export-templates-bin.version
    }";

}
