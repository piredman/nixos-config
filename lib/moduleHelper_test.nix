let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  basePath = ../home/_modules;
  moduleHelper = import ./moduleHelper.nix { inherit lib basePath; };

  # Helper function to generate parameterized tests
  mkParameterizedTests =
    testNamePrefix: testCases: testExprFn:
    lib.mapAttrs (name: case: testExprFn case) (
      lib.listToAttrs (
        lib.imap0 (i: v: {
          name = "${testNamePrefix}${v.name}";
          value = v;
        }) testCases
      )
    );

  # Test cases for getModuleFiles
  getModuleFilesCases = [
    {
      name = "Nonexistent";
      input = "/nonexistent/path";
      expected = [ ];
    }
    {
      name = "EmptyDir";
      input = basePath + "/nonexistent";
      expected = [ ];
    }
  ];

  # Test cases for importModuleGroups - simple input/output verification
  importModuleGroupsCases = [
    {
      name = "Empty";
      input = [ ];
    }
    {
      name = "Nonexistent";
      input = [ "nonexistent" ];
    }
    {
      name = "ValidCore";
      input = [ "core" ];
    }
    {
      name = "ValidMultiple";
      input = [
        "core"
        "comms"
      ];
    }
  ];

  # Get actual core directory for detailed tests
  coreDir = basePath + "/core";
  coreFiles = moduleHelper.getModuleFiles coreDir;
in
{
  # Generated parameterized tests for getModuleFiles
}
// mkParameterizedTests "testGetModuleFiles" getModuleFilesCases (case: {
  expr = moduleHelper.getModuleFiles case.input;
  expected = case.expected;
})

// {
  # Generated parameterized tests for importModuleGroups
  testImportModuleGroupsEmpty = {
    expr = moduleHelper.importModuleGroups [ ];
    expected = [ ];
  };

  testImportModuleGroupsNonexistent = {
    expr = moduleHelper.importModuleGroups [ "nonexistent" ];
    expected = [ ];
  };

  testImportModuleGroupsValidCore = {
    expr =
      let
        result = moduleHelper.importModuleGroups [ "core" ];
      in
      builtins.length result > 0 && builtins.all (f: lib.hasSuffix ".nix" f) result;
    expected = true;
  };

  testImportModuleGroupsValidMultiple = {
    expr =
      let
        coreOnly = moduleHelper.importModuleGroups [ "core" ];
        both = moduleHelper.importModuleGroups [
          "core"
          "comms"
        ];
      in
      builtins.length both > builtins.length coreOnly;
    expected = true;
  };
}

// {
  # File filtering and content verification tests
  testGetModuleFilesExcludesDefault = {
    expr = builtins.any (lib.hasSuffix "default.nix") coreFiles;
    expected = false;
  };

  testGetModuleFilesExcludesUnderscore = {
    expr = builtins.any (n: lib.hasPrefix "_" (builtins.baseNameOf n)) coreFiles;
    expected = false;
  };

  testGetModuleFilesReturnsNixFiles = {
    expr = builtins.all (f: lib.hasSuffix ".nix" f) coreFiles;
    expected = true;
  };

  testGetModuleFilesReturnsNonEmpty = {
    expr = builtins.length coreFiles > 0;
    expected = true;
  };

  # Recursion and path structure tests
  testGetModuleFilesRecursiveTraversal = {
    expr =
      let
        allCoreFiles = moduleHelper.getModuleFiles coreDir;
        # Check that we found files from nested directories (not just top level)
        # If no recursion, we'd only have top-level .nix files
        topLevelCount = builtins.length (
          builtins.filter (
            f: !(lib.hasInfix "/" (lib.removePrefix (toString coreDir + "/") (toString f)))
          ) allCoreFiles
        );
      in
      builtins.length allCoreFiles > topLevelCount;
    expected = true;
  };

  testGetModuleFilesPathsAreValid = {
    expr = builtins.all (f: builtins.pathExists f) coreFiles;
    expected = true;
  };

  testImportModuleGroupsFiltersNonExistent = {
    expr =
      let
        result = moduleHelper.importModuleGroups [
          "core"
          "nonexistent"
        ];
      in
      builtins.all (f: builtins.pathExists f) result;
    expected = true;
  };

  testImportModuleGroupsPreservesAllFiles = {
    expr =
      let
        coreOnly = moduleHelper.importModuleGroups [ "core" ];
        commsOnly = moduleHelper.importModuleGroups [ "comms" ];
        both = moduleHelper.importModuleGroups [
          "core"
          "comms"
        ];
      in
      builtins.length both >= builtins.length coreOnly;
    expected = true;
  };
}
