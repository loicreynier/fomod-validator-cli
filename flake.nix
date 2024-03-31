{
  description = "FOMod validator (CLI)";

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    nixpkgs-lor,
    git-hooks,
    ...
  }: (flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        nixpkgs-lor.overlays.default
      ];
    };

    pythonDeps = with pkgs.python3Packages; [
      pyfomod
      rich
      typing-extensions
      typer
    ];

    pythonPackage = with pkgs.python3.pkgs;
      buildPythonApplication {
        pname = "fomod-validator-cli";
        version = "unstable-2024-03-31";
        src = self;
        format = "pyproject";

        nativeBuildInputs = with pkgs; [
          poetry-core
        ];

        propagatedBuildInputs = pythonDeps;

        pythonImportsCheck = [
          "fomod_validator_cli"
        ];

        meta = with pkgs.lib; {
          description = "CLI FOMod validator";
          mainProgram = "fomod-validator";
          homepage = "https://github.com/loicreynier/fomod-validator-cli";
          license = licenses.unlicense;
          maintainers = with maintainers; [loicreynier];
        };
      };
  in {
    packages.default = pythonPackage;

    devShells.default = pkgs.mkShell {
      inherit (self.checks.${system}.pre-commit-check) shellHook;
      packages = with pkgs; [
        poetry
        ruff
        (python3.withPackages (_: pythonDeps))
      ];
    };

    checks = {
      pre-commit-check = git-hooks.lib.${system}.run {
        src = ./.;

        excludes = ["flake\.lock"];

        hooks = {
          poetry-check.enable = true;
          poetry-lock.enable = true;
          alejandra.enable = true;
          commitizen.enable = true;
          deadnix.enable = true;
          editorconfig-checker.enable = true;
          prettier.enable = true;
          statix.enable = true;
          ruff.enable = true;
          typos.enable = true;
        };
      };
    };
  }));

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixpkgs-lor = {
      url = "github:loicreynier/nixpkgs-lor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
