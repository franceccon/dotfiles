{ config, pkgs, flake-self, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  fra.defaults = {
    user.enable = true;
    nix.enable = true;
  };

  home-manager.users.fra = flake-self.homeConfigurations.minimal;

  time.timeZone = "Europe/Amsterdam";

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "nixnas";
    networkmanager.enable = true;
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

  environment.systemPackages = with pkgs; [
    vim
    git
    kind
    cloud-provider-kind
  ];

  virtualisation.docker.enable = true;
  users.users.fra.extraGroups = [ "docker" ];

  # Allow SSH access.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "yes";
    };
  };

  # Join tailnet
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  # Setup samba
  services.samba = {
    enable = true;
    openFirewall = true;
    package = pkgs.sambaFull;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "NixOS NAS";
        "security" = "user";
        "hosts allow" = "100.64.0.0/10 192.168.2. 127.0.0.1";
        "guest account" = "nobody";
        "map to guest" = "Bad User";
        "smb3 unix extensions" = "yes";
        "vfs objects" = "acl_xattr catia fruit streams_xattr";
        "inherit permissions" = "yes";
        "server signing" = "auto";
        "getwd cache" = "yes";
        "socket options" = "TCP_NODELAY IPTOS_LOWDELAY";
        "aio read size" = "16384";
        "aio write size" = "16384";
        "use sendfile" = "yes";
        "min receivefile size" = "16384";

        # MacOS related config
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:time machine" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:posix_rename" = "yes";
        "fruit:metadata" = "stream";

        # Printing
        "load printers" = "yes";
        "printing" = "cups";
        "printcap name" = "cups";
      };
      "Photo" = {
        "path" = "/srv/shares/photo";
        "browseable" = "yes";
        "writeable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
        "force group" = "users";
      };
      "Public" = {
        "path" = "/srv/shares/public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0664";
        "directory mask" = "0775";
        "force user" = "nobody";
        "force group" = "nogroup";
      };
      "Printer" = {
        "path" = "/var/spool/samba";
        "public" = "yes";
        "browseable" = "yes";
        # to allow user 'guest account' to print.
        "guest ok" = "yes";
        "writable" = "no";
        "printable" = "yes";
        "create mode" = 0700;
      };
    };
  };
  services.avahi = {
    enable = true;
    openFirewall = true;
    nssmdns4 = true;

    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };

    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
         <name replace-wildcards="yes">%h</name>
         <service>
          <type>_adisk._tcp</type>
          <txt-record>sys=waMa=0,adVF=0x100</txt-record>
          <txt-record>dk0=adVN=Time Capsule,adVF=0x82</txt-record>
         </service>
         <service>
          <type>_smb._tcp</type>
          <port>445</port>
         </service>
         <service>
          <type>_device-info._tcp</type>
          <txt-record>model=TimeCapsule8,119</txt-record>
        </service>
        </service-group>
      '';
    };
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
  systemd.tmpfiles.rules = [
    "d /var/spool/samba 1777 root root -"
  ];

  # Share printer on network
  services.printing = {
    enable = true;

    listenAddresses = [ "*:631" ];
    allowFrom = [ "all" ];
    browsing = true;
    defaultShared = true;
    openFirewall = true;

    drivers = with pkgs; [
      cups-filters
      cups-browsed
      hplipWithPlugin
    ];
  };
  # USB auto discovery
  services.ipp-usb.enable = true;

  # Backup to Cloudflare R2 with restic.
  age.secrets = {
    "restic/env".file = ../../secrets/restic/env;
    "restic/password".file = ../../secrets/restic/password;
    "restic/repo".file = ../../secrets/restic/repo;
  };
  services.restic.backups = {
    daily = {
      initialize = true;

      environmentFile = config.age.secrets."restic/env".path;
      passwordFile = config.age.secrets."restic/password".path;
      repositoryFile = config.age.secrets."restic/repo".path;

      timerConfig = {
        OnCalendar = "03:33";
        Persistent = true;
      };

      paths = [
        "/srv/shares/photo"
        "/srv/shares/public"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
      ];

      extraOptions = [
        "forget.host=${config.networking.hostName}"
      ];
    };
  };

  # Don't wait for network on boot.
  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  system.stateVersion = "26.05";
}
