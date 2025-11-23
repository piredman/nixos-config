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
            name = "Kagi";
            url = "https://kagi.com/search?q=%s";
            prefix = "k";
          }
          {
            name = "Kagi Assistant";
            url = "https://kagi.com/assistant";
            prefix = "ka";
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
