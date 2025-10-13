{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    qt6ct
    catppuccin-kvantum
    kdePackages.breeze-icons
    kdePackages.qtstyleplugin-kvantum
  ];

  xdg.configFile."qt5ct/qt5ct.conf".text = ''
    [Appearance]
    style=kvantum
    icon_theme=breeze-dark

    [Fonts]
    fixed="CaskaydiaCove Nerd Font,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
    general="CaskaydiaCove Nerd Font,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"

    [Interface]
    activate_item_on_single_click=1
    buttonbox_layout=0
    cursor_flash_time=1000
    dialog_buttons_have_icons=1
    double_click_interval=400
    gui_effects=@Invalid()
    keyboard_scheme=2
    menus_have_icons=true
    show_shortcuts_in_context_menus=true
    stylesheets=@Invalid()
    toolbutton_style=4
    underline_shortcut=1
    wheel_scroll_lines=3
  '';

  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    [Appearance]
    style=kvantum
    icon_theme=breeze-dark

    [Fonts]
    fixed="CaskaydiaCove Nerd Font,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
    general="CaskaydiaCove Nerd Font,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"

    [Interface]
    activate_item_on_single_click=1
    buttonbox_layout=0
    cursor_flash_time=1000
    dialog_buttons_have_icons=1
    double_click_interval=400
    gui_effects=@Invalid()
    keyboard_scheme=2
    menus_have_icons=true
    show_shortcuts_in_context_menus=true
    stylesheets=@Invalid()
    toolbutton_style=4
    underline_shortcut=1
    wheel_scroll_lines=3
  '';

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=Catppuccin-Mocha-Blue
  '';

  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_STYLE_OVERRIDE = "kvantum";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

}
