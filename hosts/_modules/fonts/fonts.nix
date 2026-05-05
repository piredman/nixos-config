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
    src = ./bluunext;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/fonts/opentype/bluunext
      cp -v *.otf $out/share/fonts/opentype/bluunext/
    '';
  };
  dynapuff = pkgs.stdenvNoCC.mkDerivation {
    pname = "dynapuff";
    version = "local";
    src = ./dynapuff;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/fonts/opentype/dynapuff
      cp -v *.ttf $out/share/fonts/opentype/dynapuff/
    '';
  };
  kavoon = pkgs.stdenvNoCC.mkDerivation {
    pname = "kavoon";
    version = "local";
    src = ./kavoon;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/fonts/opentype/kavoon
      cp -v *.ttf $out/share/fonts/opentype/kavoon/
    '';
  };
in
{
  fonts.fontDir.enable = true;
  fonts.packages = [
    bluuNext
    momentz
    dynapuff
    kavoon
  ];
}
