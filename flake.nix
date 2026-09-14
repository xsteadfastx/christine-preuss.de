{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit.url = "git+https://git.xsfx.dev/xsteadfastx/pre-commit-nix.git";
    pre-commit.inputs.pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    let
      inherit (inputs.flake-utils.lib) eachDefaultSystem;
    in
    eachDefaultSystem (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};

        # Custom additional hooks
        extraHooks = {
          have-a-nice-day-hook = {
            enable = true;
            entry = "echo 'have a nice day'";
            stages = [ "pre-commit" ];
            pass_filenames = false;
          };
          # typos is an English spell checker; this site's prose is German.
          # Scope it to code files, not content/markdown/YAML.
          typos = {
            files = "\\.(js|css|nix)$";
          };
        };

        # Generate pre-commit hooks with extras
        preCommitGen = inputs.pre-commit.lib.generate {
          inherit pkgs system;
          src = ./.;
          extra = {
            hooks = extraHooks;
          };
          extraPackages = [
            pkgs.git
            pkgs.hugo
            pkgs.imagemagick
          ];
          extraShellHook = ''
            echo "christine-preuss.de devshell"
          '';
        };

        # The static Hugo site
        site = pkgs.stdenv.mkDerivation {
          pname = "christine-preuss.de";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [ pkgs.hugo ];
          buildPhase = ''
            hugo --minify --gc --destination build
          '';
          installPhase = ''
            mkdir -p "$out"
            cp -r build/* "$out/"
          '';
        };

      in
      {
        packages.default = site;
        checks.pre-commit-check = preCommitGen.pre-commit-check;
        inherit (preCommitGen) formatter;
        devShells.default = preCommitGen.devShell;
      }
    );
}
