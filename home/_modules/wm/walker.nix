{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.walker = {
    enable = true;
    runAsService = true;

    config = {
      websearch = {
        engines = [
          {
            name = "websearch";
            url = "https://duckduckgo.com/?q=%s";
            prefix = "web";
          }
          {
            name = "GitHub";
            url = "https://github.com/search?q=%s";
            prefix = "gh";
          }
        ];
      };
    };
  };
}
