{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Grant the active desktop session read/write access to USB devices,
  # required for WebUSB from a browser (e.g. flash.android.com flashing).
  # android-tools ships no udev rules itself, so a manual rule is needed.
  # Vendor 18d1 covers all Google USB modes (MTP, adb, fastboot).
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", TAG+="uaccess"
  '';
  environment.systemPackages = with pkgs; [
    android-tools
    apksigner
  ];
}
