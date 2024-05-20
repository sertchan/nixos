{
  home-manager = {
    verbose = true;
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      "seyhan" = ./seyhan;
    };
  };
}
