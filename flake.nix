{
  
  description = "My Flake";

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

      systemSettings = {
	hostname = "mini";
	timezone = "America/Edmonton";
	local = "en_GB.UTF-8";
      };
      userSettings = {
        username = "redman";
        name = "Paul";
      };
    in {

    nixosConfigurations = {
      mini = lib.nixosSystem {
	inherit system;
	modules = [ ./hosts/mini/configuration.nix ];
	specialArgs = {
	  inherit systemSettings;
	  inherit userSettings;
	};
      };
    };

    homeConfigurations = {
      redman = home-manager.lib.homeManagerConfiguration {
	inherit pkgs;
	modules = [ ./home/redman.nix ];
	extraSpecialArgs = {
	  inherit systemSettings;
	  inherit userSettings;
	};
      };
    };

  };
}
