{

  description = "Nix Dotfilesx with flake";

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
      ...
    }@inputs:

    let
      lib = inputs.nixpkgs.lib;

      hostDirs = builtins.attrNames (
        lib.filterAttrs (name: type: type == "directory" && !lib.hasPrefix "_" name) (
          builtins.readDir ./hosts
        )
      );

      mkHostConfig =
        hostDir:
        let
          settings = import ./hosts/${hostDir}/settings.nix;
        in
        {
          name = settings.hostname;
          value = mkNixOSConfigurations {
            host = settings;
            nixpkgs = inputs.nixpkgs;
            home-manager = inputs.home-manager;
          };
        };

      mkNixOSConfigurations =
        {
          host,
          nixpkgs,
          home-manager,
        }:
        let
          systemSettings = host;
          hostDir = host.hostname;
        in
        inputs.nixpkgs.lib.nixosSystem {
          system = host.arch;
          modules = [
            ./hosts/${hostDir}/configuration.nix
            inputs.stylix.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            {
              nixpkgs.config.allowUnfree = true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = false;
              home-manager.backupFileExtension = "backup";
              home-manager.sharedModules = [
                inputs.walker.homeManagerModules.default
                inputs.zen-browser.homeModules.default
              ];
              home-manager.extraSpecialArgs = {
                userSettings = import ./home/${host.user}/settings.nix;
                systemSettings = systemSettings;
                zen-browser = inputs.zen-browser;
              };
              home-manager.users."${host.user}" = import ./hosts/${hostDir}/home.nix;
            }
          ];
          specialArgs = {
            inherit systemSettings;
            pkgs-stable = import inputs.nixpkgs-stable {
              system = host.arch;
              config.allowUnfree = true;
            };
            userSettings = import ./home/${host.user}/settings.nix;
          };
        };
    in
    {
      nixosConfigurations = builtins.listToAttrs (map mkHostConfig hostDirs);
    };
}
