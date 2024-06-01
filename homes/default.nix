{ pkgs, ... }: {
  home-manager = {
    verbose = true;
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit pkgs; };
    users = { "seyhan" = ./seyhan; };
  };
}
