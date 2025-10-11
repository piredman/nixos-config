{

  description = "Flake that does the things";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

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
            systemSettings = mkSystemSettings (builtins.head validHosts);
            userSettings = mkUserSettings username;
          };
        };
      }) validUsers);

    };
}
