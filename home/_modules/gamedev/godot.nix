{
  config,
  lib,
  pkgs,
  userSettings,
  ...
}:

{

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

}
