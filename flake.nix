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
          # typos is an English spell checker; this site's prose is German.
          # Scope it to code files, not content/markdown/YAML.
          typos = {
            files = "\\.(js|css|nix)$";
          };
        };

        # Site config — single source of truth in Nix; hugo.toml is generated.
        hugoConfig = {
          baseURL = "https://christine-preuss.de/";
          title = "Christine Preuß";
          locale = "de-de";
          defaultContentLanguage = "de";
          disableKinds = [
            "taxonomy"
            "RSS"
          ];
          enableRobotsTXT = true;
          # allow raw HTML in content (needed by the hand-written Impressum)
          markup = {
            goldmark = {
              renderer = {
                unsafe = true;
              };
            };
          };
          params = {
            author = "Christine Preuß";
            siteName = "CHRISTINE PREUSS";
          };
          imaging = {
            resampleFilter = "lanczos";
            anchor = "smart";
            jpeg = {
              quality = 82;
            };
            webp = {
              quality = 80;
              method = 3;
              hint = "photo";
            };
          };
          caches = {
            images = {
              dir = ":cacheDir/images";
            };
          };
        };
        siteConfig = (pkgs.formats.toml { }).generate "hugo.toml" hugoConfig;

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
            # hugo.toml is generated from Nix — link it into the workspace
            ln -sfn '${siteConfig}' hugo.toml
          '';
        };

        # The static Hugo site
        site = pkgs.stdenv.mkDerivation {
          pname = "christine-preuss.de";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [ pkgs.hugo ];
          buildPhase = ''
            runHook preBuild
            cp '${siteConfig}' ./hugo.toml
            hugo --minify --gc --destination build
            runHook postBuild
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
