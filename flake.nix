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
      hosts = import ./config/hosts.nix;

      mkNixOSConfigurations =
        {
          host,
          nixpkgs,
          home-manager,
        }:
        let
          systemSettings = import ./hosts/${host.dir}/settings.nix;
        in
        inputs.nixpkgs.lib.nixosSystem {
          system = host.arch;
          modules = [
            ./hosts/${host.dir}/configuration.nix
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
              };
              home-manager.users."${host.user}" = import ./hosts/${host.dir}/home.nix;
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

      nixosConfigurations."${hosts.luna.hostname}" = mkNixOSConfigurations {
        host = hosts.luna;
        nixpkgs = inputs.nixpkgs;
        home-manager = inputs.home-manager;
      };
      nixosConfigurations."${hosts.mini.hostname}" = mkNixOSConfigurations {
        host = hosts.mini;
        nixpkgs = inputs.nixpkgs;
        home-manager = inputs.home-manager;
      };
      nixosConfigurations."${hosts.terra.hostname}" = mkNixOSConfigurations {
        host = hosts.terra;
        nixpkgs = inputs.nixpkgs;
        home-manager = inputs.home-manager;
      };

    };
}
