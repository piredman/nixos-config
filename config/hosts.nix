let
  users = import ./users.nix;
in
{
  luna = {
    hostname = "luna";
    dir = "luna";
    arch = "x86_64-linux";
    user = users.default;
  };
  mini = {
    hostname = "mini";
    dir = "mini";
    arch = "x86_64-linux";
    user = users.default;
  };
  terra = {
    hostname = "terra";
    dir = "terra";
    arch = "x86_64-linux";
    user = users.default;
  };
}
