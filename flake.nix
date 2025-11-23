{

  description = "Flake that does the things";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    elephant.url = "github:abenz1267/elephant";
    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      stylix,
      elephant,
      walker,
      zen-browser,
      ...
    }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      pkgs-stable = import {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      mkSystemSettings = hostname: import ./hosts/${hostname}/settings.nix;
      mkUserSettings = username: import ./home/${username}/settings.nix;

      hosts = builtins.attrNames (builtins.readDir ./hosts);
      validHosts = builtins.filter (name: name != "template") hosts;

      homeDirs = builtins.attrNames (builtins.readDir ./home);
      validUsers = builtins.filter (name: name != "template" && name != "_modules") homeDirs;
    in
    {

      nixosConfigurations = builtins.listToAttrs (
        map (hostname: {
          name = hostname;
          value = lib.nixosSystem {
            inherit system;
            modules = [
              ./hosts/${hostname}/configuration.nix
            ];
            specialArgs = {
              inherit pkgs-stable;
              systemSettings = mkSystemSettings hostname;
              userSettings = mkUserSettings (builtins.head validUsers);
            };
          };
        }) validHosts
      );

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        nixpkgs.allowUnfreePredicate = _: true;
      };

      homeConfigurations = builtins.listToAttrs (
        map (username: {
          name = username;
          value = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              stylix.homeModules.default
              walker.homeManagerModules.default
              zen-browser.homeModules.default
              ./home/${username}/default.nix
            ];
            extraSpecialArgs = {
              systemSettings = mkSystemSettings (builtins.head validHosts);
              userSettings = mkUserSettings username;
            };
          };
        }) validUsers
      );

    };
}
