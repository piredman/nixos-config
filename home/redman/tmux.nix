{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";

    baseIndex = 1;
    escapeTime = 10;
    focusEvents = true;
    mouse = true;
    prefix = "C-a";
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      resurrect
      continuum
      catppuccin
      tmux-sessionx
      tmux-fzf
    ];

    extraConfig = ''
      # Terminal settings
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -g allow-passthrough on

      set -g status-position top
      setw -g mode-keys vi

      # Key Bindings
      unbind C-b
      bind-key C-a send-prefix

      unbind %
      bind | split-window -h -c "#{pane_current_path}"

      unbind '"'
      bind - split-window -v -c "#{pane_current_path}"

      unbind c
      bind c new-window -c "#{pane_current_path}"

      unbind C-k
      bind C-k clear-history

      # Resize panes
      bind -r h resize-pane -L 5
      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
      bind -r m resize-pane -Z

      # Copy mode & clipboard integration
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'r' send-keys -X rectangle-toggle
      unbind -T copy-mode-vi MouseDragEnd1Pane

      # Plugin settings
      # tmux-resurrect
      set -g @resurrect-capture-pane-contents 'on'
      set -g @continuum-restore 'on'

      # catppuccin/tmux
      set -g @catppuccin_flavor "mocha"

      set -g @catppuccin_window_text "#W"
      set -g @catppuccin_window_status_style "custom"
      set -g @catppuccin_window_number_position "right"
      set -g @catppuccin_window_default_fill "number"
      set -g @catppuccin_window_default_text "#W"
      set -g @catppuccin_window_current_fill "number"
      set -g @catppuccin_window_current_text "#W"
      set -g @catppuccin_directory_text "#{pane_current_path}"

      set -g status-right-length 100
      set -g status-left-length 100
      set -g status-left ""
      set -g status-right "#{E:@catppuccin_status_application}"
      set -ag status-right "#{E:@catppuccin_status_session}"

      # sessionx settings
      set -g @sessionx-window-height '85%'
      set -g @sessionx-window-width '75%'
      set -g @sessionx-zoxide-mode 'on'
      set -g @sessionx-filter-current 'false'
      set -g @sessionx-preview-enabled 'true'
    '';
  };
}
