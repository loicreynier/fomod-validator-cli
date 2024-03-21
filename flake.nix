{
  description = "FOMod validator (CLI)";

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    nixpkgs-lor,
    pre-commit-hooks,
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
      typing-extensions
      typer
    ];

    pythonPackage = with pkgs.python3.pkgs;
      buildPythonApplication {
        pname = "fomod-validator-cli";
        version = "unstable-2024-03-21";
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
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;

        excludes = ["flake\.lock"];

        hooks = with pkgs; let
          poetryHookSettings = {
            files = "(poetry\.lock|pyproject\.toml)";
            pass_filenames = false;
          };
        in {
          poetry_check =
            {
              enable = true;
              name = "poetry check";
              entry = "${poetry}/bin/poetry check";
              description = "Check the Poetry config for errors";
            }
            // poetryHookSettings;
          poetry-lock =
            {
              enable = true;
              name = "poetry lock";
              entry = "${poetry}/bin/poetry lock";
              description = "Update the Poetry lock file";
            }
            // poetryHookSettings;
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
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
