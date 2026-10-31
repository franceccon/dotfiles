inputs:
let
  inherit inputs;
in
self: super: {
  hello-custom = super.callPackage ../packages/hello-custom { };

  # from flakes
  ghostty = inputs.ghostty.packages.${self.stdenv.hostPlatform.system}.ghostty;
  hex = inputs.hex.packages.${self.stdenv.hostPlatform.system}.default;

  # dev tools
  # bump to a newer version than nixpkgs provides.
  # https://static.ampcode.com/cli/cli-version.txt
  amp-cli = super.amp-cli.overrideAttrs (old: rec {
    version = "0.0.1793025586-g9211b5";
    src = super.fetchurl {
      url = "https://static.ampcode.com/cli/${version}/amp-linux-x64-baseline.gz";
      hash = "sha256-ZI5blkikGEy5ivq+3AbHooQvO3+rBuDdU0mfEzlLhxk=";
    };
  });
  secretspec = super.secretspec.overrideAttrs (old: {
    version = "0.21.1";
    src = inputs.secretspec;
    doCheck = false;
    cargoBuildFlags = [ "--package" "secretspec" ];
    cargoTestFlags = [ "--package" "secretspec" ];
    nativeCheckInputs = [ self.git self.jq self.sops self.cacert ];
    postPatch = (old.postPatch or "") + ''
      patchShebangs secretspec/tests/fixtures
    '';
    preCheck = ''
      export HOME=$(mktemp -d)
      export SSL_CERT_FILE=${self.cacert}/etc/ssl/certs/ca-bundle.crt
      export NO_COLOR=1
    '';
    cargoDeps = self.rustPlatform.fetchCargoVendor {
      src = inputs.secretspec;
      hash = "sha256-48k3UKeT8qjRRLrf5yqmxULIynD6FgXiW063VEoTqmU=";
    };
  });
  zed-editor-bin = super.callPackage ../packages/zed-editor-bin { };
  zed-editor-fhs = self.buildFHSEnv {
    name = "zed";
    targetPkgs =
      pkgs: with pkgs; [
        zed-editor-bin
      ];
    runScript = "zed";
  };

  apalache = super.callPackage ../packages/apalache { };
  aptakube = super.callPackage ../packages/aptakube { };
  gitbutler-cli = super.callPackage ../packages/gitbutler-cli { };

  # desktop + eye candy
  mailspring = super.callPackage ../packages/mailspring { };
  tldraw = super.callPackage ../packages/tldraw { };
  kero = super.callPackage ../packages/kero { };
  kaya-go = super.callPackage ../packages/kaya-go { };
  katrain = super.callPackage ../packages/katrain { };
  darktable = super.callPackage ../packages/darktable { withAi = true; };
  # fonts
  berkeley-mono = super.callPackage ../packages/berkeley-mono { };
  paper-mono = super.callPackage ../packages/paper-mono { };
  # pragmata-pro = super.callPackage ../packages/pragmata-pro { };
  # monolisa = super.callPackage ../packages/monolisa { };

  # neeeded by other packages
  python3Packages = super.python3Packages // {
    ffpyplayer = self.python3Packages.callPackage ../packages/ffpyplayer {
      inherit (self) SDL2 SDL2_mixer ffmpeg_6;
    };

    kivymd = self.python3Packages.callPackage ../packages/kivymd {
      inherit (self.python3Packages) kivy pillow requests;
    };
  };
}
