{ pkgs, flake-self, nur, agenix, ... }:
let
  editor = "nvim";
in
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      flake-self.overlays.default
      nur.overlays.default
      agenix.overlays.default
    ];
  };

  # include man pages
  manual.manpages.enable = true;

  systemd.user.sessionVariables = {
    EDITOR = editor;
    MADNESS_ALLOW_LDD = "1";
    PAGER = "less -FRX";
    DIFFPROG = "zed -n -w --diff";
  };

  home = {
    packages = [
      pkgs.agenix
      pkgs.htop
      pkgs.unzip
    ];

    sessionVariables = {
      NIX_SHELL_PRESERVE_PROMPT = 1;
      EDITOR = editor;
      MADNESS_ALLOW_LDD = "1";
    };

    stateVersion = "22.05";
  };
}
