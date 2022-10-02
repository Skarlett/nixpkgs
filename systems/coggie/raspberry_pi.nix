{pkgs, config, lib, ...}:
let
  hostname = "coggie";
  hashed_password = "FILL_ME_IN";

  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;

  lunarixTarball =
    fetchTarball
      https://github.com/skarlett/nixpkgs/archive/master.tar.gz;

  impermanence =
    fetchTarball
      https://github.com/nix-community/impermanence/archive/master.tar.gz;
in
{
  system.stateVersion = "22.05"; # DO NOT CHANGE (without consequences)

  imports = [
    "${impermanence}/nixos"
    ../defaults/fish.nix
    ../modules/coggiebot.nix
  ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };
  };

  networking.hostName = hostname; # Define your hostname.
  networking.hosts =
    {
      "127.0.0.1" = [ "localhost" "router.lan" ];
      "10.0.0.3" = [ "pve.lan" ];
    };

  networking.interfaces.eth0.ipv4.addresses =
    [{
      address = "10.0.0.4";
      prefixLength = 24;
    }];

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.utf8";

  sound.enable = false;
  systemd.services.systemd-journald.enable = false;

  users = {
    mutableUsers = false;
    users = {
      lunarix = {
          shell = pkgs.fish;
          isNormalUser = true;
          description = "pewter";
          extraGroups = [ "wheel" ];
          packages = with pkgs;
            [];
          initialHashedPassword = hashed_password;
      };

      root = {
          shell = pkgs.fish;
          initialHashedPassword = hashed_password;
      };
    };
  };

  services.openvpn.servers = {
    client = {
      config = ''
        client
        proto udp
        explicit-exit-notify
        remote unallocatedspace.dev 55544
        dev tun
        resolv-retry infinite
        nobind
        persist-key
        persist-tun
        remote-cert-tls server
        verify-x509-name server_NMjeI2faSWSlqrSQ name
        auth SHA256
        auth-nocache
        cipher AES-128-GCM
        #tls-client
        #tls-version-min 1.2
        #tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
        ignore-unknown-option block-outside-dns
        setenv opt block-outside-dns # Prevent Windows 10 DNS leak
        verb 3

        route 10.0.1.0 255.255.255.0 172.16.2.1

        ca /nix/secret/vpn/ca.crt
        cert /nix/secret/vpn/alice.crt
        key /nix/secret/vpn/alice.key
      '';

      up = "echo nameserver $nameserver | ${pkgs.openresolv}/sbin/resolvconf -m 0 -a $dev";
      down = "${pkgs.openresolv}/sbin/resolvconf -d $dev";
    };
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/nixos"
    ];

    files = [
      "/etc/machine-id"
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    fish
    systemdMinimal
  ];

  services = {
    openssh.enable = true;
  };
}
