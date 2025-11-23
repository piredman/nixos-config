{
  hostname = "luna";
  timezone = "America/Edmonton";
  locale = "en_GB.UTF-8";
  luks.device = "";
  nas = import ../_settings/nas.nix;
}
