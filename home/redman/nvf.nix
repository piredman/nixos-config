{ pkgs, lib, ... }:

{
  programs.nvf = {
    enable = true;
    settings = {
      vim.globals.mapleader = " ";
      vim.options.tabstop = 2;
      vim.options.shiftwidth = 2;
      vim.options.autoindent = true;

      vim.statusline.lualine.enable = true;
      vim.telescope.enable = true;
      vim.autocomplete.nvim-cmp.enable = true;

      # vim.theme = {
      #   enable = true;
      #   name = "catppuccin";
      #   style = "mocha";
      #   transparent = true;
      # };
      # vim.statusline.lualine.theme = "pywal";

      vim.lsp.servers = {
        nil_ls = {};
        bashls = {};
        cssls = {};
        html = {};
        marksman = {};
        lua_ls = {};
        yamlls = {};
      };

      vim.lsp.enable = true;
      vim.languages = {
	      enableTreesitter = true;

	      nix.enable = true;
        bash.enable = true;
        css.enable = true;
        html.enable = true;
        markdown.enable = true;
        lua.enable = true;
        yaml.enable = true;

        # go.enable = true;
        # sql.enable = true;
        # ts.enable = true;
        # ruby.enable = true;
      };
    };
  };
}
