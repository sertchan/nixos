{inputs, ...}: {
  home-manager = {
    verbose = true;
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
    users = {
      "seyhan" = ./seyhan;
    };
  };
}
