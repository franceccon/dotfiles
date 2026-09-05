inputs:
let
  inherit inputs;
in
self: super: {
  # from flakes
  # https://github.com/anomalyco/opencode/issues/23256#issuecomment-4276583712
  opencode = inputs.opencode.packages.${self.stdenv.hostPlatform.system}.opencode.overrideAttrs (old: {
    preBuild = (old.preBuild or "") + ''
      substituteInPlace packages/opencode/src/cli/cmd/generate.ts \
        --replace-fail 'const prettier = await import("prettier")' 'const prettier: any = { format: async (s: string) => s }' \
        --replace-fail 'const babel = await import("prettier/plugins/babel")' 'const babel = {}' \
        --replace-fail 'const estree = await import("prettier/plugins/estree")' 'const estree = {}'
    '';
  });
  ghostty = inputs.ghostty.packages.${self.stdenv.hostPlatform.system}.ghostty;
  tuicr = inputs.tuicr.packages.${self.stdenv.hostPlatform.system}.default;

  # dev tools
  hello-custom = super.callPackage ../packages/hello-custom { };
  zed-editor-bin = super.callPackage ../packages/zed-editor-bin { };
  zed-editor-fhs = self.buildFHSEnv {
    name = "zed";
    targetPkgs =
      pkgs: with pkgs; [
        zed-editor-bin
      ];
    runScript = "zed";
  };
  delta-bin = super.callPackage ../packages/delta-bin { };
  # bump to a newer version than nixpkgs provides.
  # https://static.ampcode.com/cli/cli-version.txt
  amp-cli = super.amp-cli.overrideAttrs (old: rec {
    version = "0.0.1788595248-g1c7a80";
    src = super.fetchurl {
      url = "https://static.ampcode.com/cli/${version}/amp-linux-x64-baseline.gz";
      hash = "sha256-8tLLVft9iMjVMKQs1sdgbAPUxgr2Q97PciMVcZHUnl4=";
    };
  });

  models-dev = super.callPackage ../packages/models-dev { };
  apalache = super.callPackage ../packages/apalache { };
  mirrord-bin = super.callPackage ../packages/mirrord-bin { };
  dagger = super.callPackage ../packages/dagger { };
  aptakube = super.callPackage ../packages/aptakube { };
  gitbutler-cli = super.callPackage ../packages/gitbutler-cli { };

  # desktop + eye candy
  msty = super.callPackage ../packages/msty { };
  mailspring = super.callPackage ../packages/mailspring { };
  smile = super.callPackage ../packages/smile { };
  en-croissant = super.callPackage ../packages/en-croissant { };
  kaya-go = super.callPackage ../packages/kaya-go { };
  katrain = super.callPackage ../packages/katrain { };
  darktable = super.callPackage ../packages/darktable { withAi = true; };
  # fonts
  berkeley-mono = super.callPackage ../packages/berkeley-mono { };
  pragmata-pro = super.callPackage ../packages/pragmata-pro { };
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
