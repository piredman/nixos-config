{
  config,
  lib,
  pkgs,
  pkgs-stable,
  systemSettings,
  userSettings,
  ...
}:

{
  # Verifying status
  # > zramctl

  # zram: compressed RAM-backed swap. Cheaper than disk swap and keeps the
  # system responsive under memory pressure instead of thrashing disk.

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };

  # VM tuning for zram (per docs/PLAN.md Tier 1A).
  # - swappiness 150: zram is compressed RAM, not disk; default 60 starves page cache
  #   and pushes anonymous pages to slow disk swap instead of zram
  # - vfs_cache_pressure 50: keep dentries/inodes cached longer
  # - page-cluster 0: no seek cost on zram, so fault in 1 page at a time
  # - watermark_boost_factor 0: avoids pointless reclaim bursts with fast swap
  boot.kernel.sysctl = {
    "vm.swappiness" = 150;
    "vm.vfs_cache_pressure" = 50;
    "vm.page-cluster" = 0;
    "vm.watermark_boost_factor" = 0;
  };
}
