{pkgs-stable, ...}: {
  home-manager = {
    verbose = true;
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit pkgs-stable;};
    users = {
      "seyhan" = ./seyhan;
    };
  };
}
