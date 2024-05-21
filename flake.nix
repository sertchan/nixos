{
  description = "seyhan";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    ...
  } @ inputs: let
    pkgs-stable = import nixpkgs-stable {
      system = "x86_64-linux";
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "electron-25.9.0"
        ];
      };
    };
  in {
    nixosConfigurations.asli = nixpkgs.lib.nixosSystem {
      modules = [
        home-manager.nixosModules.home-manager
        ./hosts/mainpc/default.nix
        ./homes
      ];

      specialArgs = {
        inherit self inputs;
        inherit pkgs-stable;
      };
    };
  };
}
