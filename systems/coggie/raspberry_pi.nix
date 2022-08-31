{pkgs, config, lib, ...}:
let
  hostname = "coggie";
  hashed_password = "FILL_ME_IN";

  impermanence = builtins.fetchTarball {
    url = "https://github.com/nix-community/impermanence/archive/master.tar.gz";
  };
in
{
  imports = [
    "${impermanence}/nixos"
    ../defaults/fish.nix
    ../modules/coggiebot.nix
  ];

  services.coggiebot.enable = true;

  system.stateVersion = "22.05"; # DO NOT CHANGE (without consequences)
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };
  };

  networking.hostName = hostname; # Define your hostname.
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

  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/nixos"
    ];

    files = [
      "/etc/machine-id"
    ];
  };

  environment.systemPackages = with pkgs; [
    coggiebot
    vim
    wget
    fish
    systemdMinimal
  ];

  services = {
    openssh.enable = true;
  };
}
