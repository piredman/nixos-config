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
  momentz = pkgs.stdenvNoCC.mkDerivation {
    pname = "momentz";
    version = "local";
    src = ./momentz;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/fonts/opentype/momentz
      cp -v *.ttf $out/share/fonts/opentype/momentz/
    '';
  };
  # https://github.com/velvetyne/BluuNext/blob/master/README.md
  bluuNext = pkgs.stdenvNoCC.mkDerivation {
    pname = "bluu-next";
    version = "local";
    src = ./blueenext;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/fonts/opentype/bluunext
      cp -v *.otf $out/share/fonts/opentype/bluunext/
    '';
  };
in
{
  fonts.fontDir.enable = true;
  fonts.packages = [
    bluuNext
    momentz
  ];
}
