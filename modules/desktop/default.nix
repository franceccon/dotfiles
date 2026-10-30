{ config, lib, pkgs, flake-self, ... }:
with lib;
let
  cfg = config.fra.desktop;
in
{
  options.fra.desktop = {
    enable = mkEnableOption "the default desktop configuration";

    hostname = mkOption {
      type = types.str;
      default = null;
      example = "nixos";
      description = "the machine hostname";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.fra = flake-self.homeConfigurations.desktop;

    fra = {
      defaults = {
        fonts.enable = true;
        user.enable = true;
        nix.enable = true;
      };
    };

    madness.enable = true;

    i18n.inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [
        libpinyin
      ];
    };

    environment.systemPackages = with pkgs; [
      git
      vim
      virt-manager
      man-pages
      man-pages-posix
      gnome-tweaks

      wineWow64Packages.waylandFull
      # uv
      # config.boot.kernelPackages.perf
    ];

    # Yubikey
    security.pam = {
      u2f = {
        enable = true;
        settings = {
          interactive = true;
          cue = true;
          origin = "pam://yubi";
          authFile = pkgs.writeText "u2f-mappings" ''
            fra
            :Ek7piRaKrfqKy5sd2dcoR8tBWtd8AaKHJx2Blvglxl5Omm+EC5kkj/Es77PaYIWWZrhyfzokHrPQqujNGsOOiw==,8tqVvK6XIXo99G+iFLUH+FDWlUvRznG0XSU1dR/9jaI+g1n/3f8VxE31vjEp65+9UXAAG6OHxnf0kPyP0wVu7Q==,es256,+presence
          '';
        };
      };
      services = {
        login.u2fAuth = true;
        sudo.u2fAuth = true;
      };
    };

    services = {
      pcscd.enable = true;
      udev.packages = [ pkgs.yubikey-personalization ];
    };

    # Setup networking.
    networking = {
      networkmanager.enable = true;
      hostName = cfg.hostname;

      nftables.enable = true;
      firewall = {
        enable = true;
        trustedInterfaces = [ config.services.tailscale.interfaceName ];
        allowedUDPPorts = [ config.services.tailscale.port ];
        allowedTCPPorts = [ 22 ];
      };


      nameservers = [
        "1.1.1.1"
      ];
    };

    documentation = {
      enable = true;
      man.enable = true;
      info.enable = true;
      dev.enable = true;
      nixos.enable = true;
    };

    # Setup docker/podman and qemu.
    programs.virt-manager.enable = true;
    virtualisation = {
      waydroid.enable = true;
      podman = {
        enable = true;
        dockerSocket.enable = true;
        autoPrune.enable = true;
      };

      libvirtd = {
        enable = true;
        qemu.swtpm.enable = true;
      };
      spiceUSBRedirection.enable = true;
    };

    # Enable Gnome.
    services.xserver = {
      enable = true;
    };
    services.desktopManager.gnome.enable = true;
    services.displayManager.gdm.enable = true;

    environment = {
      gnome.excludePackages = with pkgs; [
        gnome-photos
        gnome-tour
        gnome-music
        epiphany
        tali
        iagno
        hitori
        atomix
        yelp
        gnome-initial-setup
      ];
    };

    # Enable geoclue2.
    services.geoclue2.enable = true;
    services.localtimed.enable = true;

    # Setup dconf.
    programs.dconf.enable = true;
    services.dbus.packages = [ pkgs.dconf ];

    # Setup bluetooth.
    services.blueman.enable = true;
    hardware.bluetooth.enable = true;

    # Setup gnome keyring.
    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;

    # Setup tailscale.
    services.tailscale = {
      enable = true;
      openFirewall = true;
      extraSetFlags = [ "--operator=fra" ];
    };
    systemd.services.tailscaled.serviceConfig.Environment = [
      "TS_DEBUG_FIREWALL_MODE=nftables"
    ];

    # Local service discovery (client onyl)
    services.avahi = {
      enable = true;
      nssmdns4 = true;

      # Disable broadcasting your own machine details
      publish = {
        enable = false;
        addresses = false;
        workstation = false;
        userServices = false;
      };
    };

    # Setup audio.
    security.rtkit.enable = true;
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;
    };

    programs.bcc.enable = true;

    # Fix for kube + podman
    systemd.services."user@".serviceConfig = {
      Delegate = "memory pids cpu cpuset io";
    };

    # Don't wait for network on boot.
    systemd.network.wait-online.enable = false;
    boot.initrd.systemd.network.wait-online.enable = false;

    nixpkgs.config.allowUnfree = true;
  };
}
