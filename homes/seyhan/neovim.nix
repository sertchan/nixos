{inputs, ...}: {
  imports = [inputs.nvf.homeManagerModules.default];
  config = {
    programs.nvf = {
      enable = true;
      settings = {
        vim = {
          viAlias = false;
          vimAlias = true;
          lsp.enable = true;

          luaConfigRC = {
            # this section takes verbatim Lua code
            # and adds it to the Neovim configuration path
            # you can use it to set up your own colorscheme
            theme-setup = ''

              -- if you want syntax highlight, `builtins.readFile` can be used
              -- to read contents of an actual lua file.
            '';
          };
        };
      };
    };
  };
}
