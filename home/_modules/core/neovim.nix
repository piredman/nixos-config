{
  config,
  pkgs,
  userSettings,
  ...
}:

{
  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      plenary-nvim
      lazydev-nvim

      telescope-nvim
      telescope-fzf-native-nvim
      telescope-live-grep-args-nvim

      nvim-treesitter.withAllGrammars
      conform-nvim
      auto-session

      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path

      neo-tree-nvim
      which-key-nvim
      lualine-nvim
      vim-tmux-navigator
      harpoon2
      lazygit-nvim

      alpha-nvim
      catppuccin-nvim
      nvim-web-devicons
    ];

    # Packages needed by plugins
    extraPackages = with pkgs; [
      ripgrep
      nodejs
      fd

      lua-language-server

      shfmt
      stylua
      nixfmt
      rubocop
      prettierd
    ];
  };

  home.file.".config/nvim" = {
    source = ../../${userSettings.username}/nvim;
    recursive = true;
  };

  stylix.targets.neovim = {
    enable = false;
  };
}
