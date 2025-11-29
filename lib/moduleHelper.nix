{ lib, basePath }:

let
  getModuleFiles =
    dir:
    let
      dirExists = builtins.pathExists dir;
    in
    if !dirExists then
      [ ]
    else
      let
        contents = builtins.readDir dir;

        nixFiles = lib.filterAttrs (
          name: type:
          type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix" && !lib.hasPrefix "_" name # Exclude underscore-prefixed files
        ) contents;
        subdirs = lib.filterAttrs (name: type: type == "directory") contents;

        # Get .nix files from current directory
        currentFiles = map (name: dir + "/${name}") (lib.attrNames nixFiles);

        # Recursively get files from subdirectories
        subFiles = lib.flatten (map (subdir: getModuleFiles (dir + "/${subdir}")) (lib.attrNames subdirs));
      in
      currentFiles ++ subFiles;

  importModuleGroups =
    moduleGroups:
    let
      groupPaths = map (group: basePath + "/${group}") moduleGroups;
      allModuleFiles = lib.flatten (map getModuleFiles groupPaths);

      # Filter out any empty results and validate paths exist
      validModuleFiles = builtins.filter (path: builtins.pathExists path) allModuleFiles;
    in
    validModuleFiles;

in
{
  inherit importModuleGroups getModuleFiles;
}
