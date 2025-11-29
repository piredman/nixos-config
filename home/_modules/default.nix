{ lib, ... }:

import ../../lib/moduleHelper.nix { inherit lib; basePath = ./.; }
