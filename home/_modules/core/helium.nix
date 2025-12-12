{
  config,
  lib,
  pkgs,
  ...
}:

let
  # UPDATE: Check https://github.com/imputnet/helium-linux/releases for new versions
  # 1. Update version below
  # 2. Get hashes: nix-prefetch-url "https://github.com/imputnet/helium-linux/releases/download/VERSION/helium-VERSION-ARCH.AppImage"
  #    (repeat for x86_64 and arm64)
  # 3. Convert to sha256: nix-hash --type sha256 --to-base16 <nix32_hash>
  # 4. Update hashes below
  # 5. nix flake check && sudo nixos-rebuild switch --flake .#terra
  helium = pkgs.appimageTools.wrapType2 rec {
    pname = "helium";
    version = "0.7.3.1";

    src =
      let
        platformMap = {
          "x86_64-linux" = "x86_64";
          "aarch64-linux" = "arm64";
        };

        platform = platformMap.${pkgs.system};

        hashes = {
          "x86_64-linux" = "sha256:ad8c4038682310feff2d94b7cf70b75e876c57e4e40e5de9dd56dd4a8cc715f6";
          "aarch64-linux" = "sha256:cce319960d2f5238199e61e88994ecdd09af0b7eef5d65b7f686e14f19f8d7ea";
        };

        hash = hashes.${pkgs.system};
      in
      pkgs.fetchurl {
        url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-${platform}.AppImage";
        inherit hash;
      };

    extraInstallCommands =
      let
        contents = pkgs.appimageTools.extractType2 { inherit pname version src; };
      in
      ''
        mkdir -p "$out/share/applications"
        mkdir -p "$out/share/lib/helium"
        cp -r ${contents}/opt/helium/locales "$out/share/lib/helium"
        cp -r ${contents}/usr/share/* "$out/share"
        cp "${contents}/${pname}.desktop" "$out/share/applications/"
        substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
      '';

    meta = {
      description = "Private, fast, and honest web browser based on Chromium";
      homepage = "https://github.com/imputnet/helium-chromium";
      changelog = "https://github.com/imputnet/helium-linux/releases/tag/${version}";
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      license = lib.licenses.gpl3;
      mainProgram = "helium";
    };
  };
in
{
  home = {
    packages = [
      helium
    ];
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
