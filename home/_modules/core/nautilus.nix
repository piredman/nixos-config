{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    nautilus
    nautilus-python
    nautilus-open-any-terminal
  ];

}
