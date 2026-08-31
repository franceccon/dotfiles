{ lib, pkgs, ... }:
{
  fra = {
    programs = {
      bash.enable = true;
      gnome.enable = true;
      neovim.enable = true;
      obs-studio.enable = true;
      tmux.enable = true;
      # xplr.enable = true;
      zed.enable = true;
      k9s.enable = true;
      ghostty.enable = true;
      opencode.enable = true;
      ampcode.enable = true;
    };
    i18n.enable = true;
  };

  home.packages = with pkgs; [
    # nix
    any-nix-shell
    nil

    # system
    bind
    cachix
    zip
    mediainfo
    libguestfs-with-appliance
    unrar
    unzip
    pavucontrol
    file
    scrot
    xclip
    wl-clipboard
    yubikey-manager
    easyeffects
    bitwarden-cli

    # cli
    btop
    htop
    feh
    fortune
    ranger
    ripgrep

    # perf tools
    sysstat
    bpftrace
    bpftools
    bpftop

    # dev
    python315
    secretspec
    docker-client
    git
    grpcurl
    gh-notify
    jq
    ngrok
    tree
    httpie
    httpie-desktop
    pgcli
    tig
    youplot
    meld
    buildah
    skopeo
    kubectl
    # code-cursor
    apalache
    duckdb
    bruno
    hotspot
    fblog
    ollama
    aptakube
    heaptrack
    samply
    valgrind
    azure-cli
    dagger
    kubelogin
    kubelogin-oidc
    kubernetes-helm
    bun
    clinfo
    gitbutler-cli
    hexyl
    # tuicr
    quint
    delta-bin

    # office
    anki-bin
    chromium
    libqalculate
    qalculate-gtk
    inkscape
    pinta
    font-manager
    mailspring
    gradia
    # figma-linux
    slack
    telegram-desktop
    zathura
    zoom-us
    mpv
    ffmpeg
    framesh
    en-croissant
    kaya-go
    katrain
    katago
    notion-app-enhanced
    smile
    obsidian
    mailspring
    discord
    supercollider
    bitwig-studio
    bottles
    gcolor3
    xournalpp
    cherry-studio
    # photo
    nufraw-thumbnailer
    art
    darktable
  ];

  # Setup X11 session.
  xsession.enable = true;
  home.pointerCursor = {
    package = pkgs.phinger-cursors;
    name = "phinger-cursors-light";
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  programs.git = {
    enable = true;
    iniContent = {
      user = {
        name = "Francesco Ceccon";
        email = "francesco@ceccon.me";
        signingkey = "ECCB5F68902EF443";
      };
      core = {
        editor = "zed -n -w";
        autocrlf = "input";
      };
      commit = {
        verbose = true;
        gpgsign = true;
      };
      gitbutler = {
        signCommits = true;
      };
      but = {
        alias = {
          "ci" = "commit";
          "st" = "status -f";
          "stu" = "status -f -u";
        };
      };
      merge = {
        conflictStyle = "zdiff3";
      };
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
      };
      column = {
        ui = "auto";
      };
      branch = {
        sort = "-committerdate";
      };
      tag = {
        sort = "version:refname";
      };
      init = {
        defaultBranch = "main";
      };
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };
      pull.rebase = true;
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      alias = {
        ca = "commit --amend";
        ab = "absorb";
        st = "status";
        br = "branch";
        ci = "commit";
        co = "checkout";
        sw = "switch";
        swc = "switch --create";
        re = "restore";
        reee = "restore --source=HEAD";
        rc = "rebase --continue";
        ra = "rebase --abort";
        brrr = "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
        lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
      };
    };
  };

  programs.gh = {
    enable = true;

    settings = {
      git_protocol = "https";
      enableGitCredentialHelper = true;
    };
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

  programs.rbw = {
    enable = true;
    settings = {
      email = "francesco@ceccon.me";
    };
  };

  programs.bat = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    options = [
      "--cmd j"
    ];
  };

  gtk = {
    enable = true;
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=0
      '';
    };
    gtk3.extraCss = ''
      VteTerminal,
      TerminalScreen,
      vte-terminal {
        padding: 10px 10px 10px 10px;
        -VteTerminal-inner-border: 10px 10px 10px 10px;
      }
    '';

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=0
      '';
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  services.redshift = {
    enable = true;
    provider = "manual";
    latitude = 52.0;
    longitude = 0.12;
  };

  services.easyeffects = {
    enable = true;
  };

  programs.gpg = {
    enable = true;

    # https://support.yubico.com/hc/en-us/articles/4819584884124-Resolving-GPG-s-CCID-conflicts
    scdaemonSettings = {
      disable-ccid = true;
    };

    # https://github.com/drduh/config/blob/master/gpg.conf
    settings = {
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";
      charset = "utf-8";
      fixed-list-mode = true;
      no-comments = true;
      no-emit-version = true;
      keyid-format = "0xlong";
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";
      with-fingerprint = true;
      require-cross-certification = true;
      no-symkey-cache = true;
      use-agent = true;
      throw-keyids = true;
    };
  };

  services.gpg-agent = {
    enable = true;

    # https://github.com/drduh/config/blob/master/gpg-agent.conf
    defaultCacheTtl = 60;
    maxCacheTtl = 120;
    pinentry.package = lib.mkForce pkgs.pinentry-gnome3;
    extraConfig = ''
      ttyname $GPG_TTY
    '';
  };

  services.ssh-agent = {
    enable = true;
  };

  xdg = {
    mime.enable = true;
    mimeApps.defaultApplications = {
      "text/html" = "chromium.desktop";
      "x-scheme-handler/http" = "chromium.desktop";
      "x-scheme-handler/https" = "chromium.desktop";
      "x-scheme-handler/about" = "chromium.desktop";
      "x-scheme-handler/unknown" = "chromium.desktop";
    };
  };

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
    NIXPKGS_ALLOW_INSECURE = "1";
    DEFAULT_BROSWER = "${pkgs.chromium}/bin/chromium";
  };
}
