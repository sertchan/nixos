{
  description = "seyhan";
  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs/cc046e57bcc8a70a49a965a1cb808f82a425b64a";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config = { allowUnfree = true; };
      };
    in {
      nixosConfigurations.asli = nixpkgs.lib.nixosSystem {
        modules = [
          home-manager.nixosModules.home-manager
          ./hosts/mainpc/default.nix
          ./homes
        ];
        specialArgs = { inherit self inputs; };
      };
    };
}
