{

  description = "Flake that does the things";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-stable = nixpkgs-stable.legacyPackages.${system};

      mkSystemSettings = hostname: import ./hosts/${hostname}/settings.nix;
      mkUserSettings = username: import ./home/${username}/settings.nix;

      hosts = builtins.attrNames (builtins.readDir ./hosts);
      validHosts = builtins.filter (name: name != "template") hosts;

      homeDirs = builtins.attrNames (builtins.readDir ./home);
      validUsers = builtins.filter (name: name != "template") homeDirs;

    in {

      nixosConfigurations = builtins.listToAttrs (map (hostname: {
        name = hostname;
        value = lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/${hostname}/configuration.nix ];
          specialArgs = {
            inherit pkgs-stable;
            systemSettings = mkSystemSettings hostname;
            userSettings = mkUserSettings (builtins.head validUsers);
          };
        };
      }) validHosts);

      homeConfigurations = builtins.listToAttrs (map (username: {
        name = username;
        value = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home/${username}/default.nix ];
          extraSpecialArgs = {
            inherit pkgs-stable;
            systemSettings = mkSystemSettings (builtins.head validHosts);
            userSettings = mkUserSettings username;
          };
        };
      }) validUsers);

    };
}
