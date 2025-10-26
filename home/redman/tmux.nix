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

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
    ];

    extraConfig = ''
      set-option -sg escape-time 10
      set-option -g focus-events on
      set-option -g allow-passthrough on
      set-option -g history-limit 100000

      set -g status-position top
      set -g mouse on
      set-window-option -g mode-keys vi

      # Colour and italic support
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1

      # Prefix & rebinds
      set -g prefix C-a
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

      unbind C-l
      bind C-l send-keys C-z \; send-keys " reset && fg > /dev/null" \; send-keys "Enter" \; send-keys C-k

      unbind r
      bind r source-file ~/.tmux.conf

      # Resize panes
      bind -r h resize-pane -L 5
      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
      bind -r m resize-pane -Z

      # Copy mode & clipboard integration
      bind-key -T copy-mode-vi 'v' send -X begin-selection # start selecting text with "v"
      bind-key -T copy-mode-vi 'r' send-keys -X rectangle-toggle
      unbind -T copy-mode-vi MouseDragEnd1Pane # don't exit copy mode after dragging with mouse
    '';
  };
}
