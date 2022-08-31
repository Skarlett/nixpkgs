

{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  };

  impermanence = builtins.fetchTarball {
    url = "https://github.com/nix-community/impermanence/archive/master.tar.gz";
  };

in
{
  # Touch pad 
  # services.xserver.libinput.enable = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.driSupport = true;

  # if gpu locks screen on bootup
  # boot.blacklistedKernelModules = [ "i915" ];

  imports =
  [
      "${home-manager}/nixos"
      "${impermanence}/nixos"
      ./hardware-configuration.nix
  ];
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.utf8";

  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
    displayManager.lightdm.enable = true;
    desktopManager.cinnamon.enable = true;
    videoDrivers = [ "nvidia" ];
  };

  security.sudo.extraConfig = ''
      Defaults insults
  '';

  security.rtkit.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  users.users.root = {
    shell = pkgs.fish;
  };

  users.users.lunarix = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "pewter";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs;
    [
      flameshot
      tree
      pandoc
      gnumake
      texlive.combined.scheme-context      
      file
      dolphin-emu
      elementary-planner
      zeroad
      discord
      cmake
      clang
      gcc
      binutils
      ripgrep
      emacs
      firefox
      cargo
      cargo-cross
      tor-browser-bundle-bin
      bat
      vscode
      kitty
      kitty-themes
      diff-so-fancy
      xclip
      git
      cowsay
      pavucontrol
      steam
      spotify
      aide
      neofetch
      keepassxc

      lsd
      nerdfonts
      gparted
      tmux

      btop
      htop
      bmon

      nmap
      python3
      jq
    ];
  };

  programs.fish =
  {
    enable = true;
    vendor.functions.enable = true;
    vendor.config.enable = true;
    vendor.completions.enable = true;
    shellInit = ''
        # Spawns process outside of shell access
        function spawn
          $argv > /dev/null 2>&1 &
          disown
        end
    '';

    shellAliases = 
    {
        ls="ls --color always";
        l="ls -la";
        la="ls -a";
        lt="ls -tree";
        gr="git reset --soft HEAD~1";
        glog="git log --graph \
                 --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' \
                 --abbrev-commit \
                 --date=relative";
        gd="git diff --color | sed 's/^\([^-+ ]*\)[-+ ]/\\1/' | less -r";
        clr="clear";
        cls="clear";
        cp="cp -r";
        tmux = "tmux -u";
        clipboard="xclip -selection c";
        more = "less";
        cat = "bat";
        ".." = "cd ..";
        "..." = "cd ../..";
        vol = "pactl -- set-sink-volume 0";
        dmesg="dmesg --color=always";
    };
  };
  
  environment.systemPackages = with pkgs; [
     vim
     wget
     tor
     parted
     fish
  ];

  services.printing.enable = true;
  services.openssh.enable = true;
  
  # This honestly needs its own derivation
  # where our backup.ignore file is a list instead
  # and our ssh backup-key is also a string
  systemd.user.services."backup-home" = {
    enable = false;
    description = "backup home directory";
    after = [
         "multi-user.target"
         "networking.target"
    ];

    environment = {
        BACKUPKEY = "/home/lunarix/.ssh/backup.key";
        EXCLUDE = "/home/lunarix/.config/backup.ignore";
    };

    startAt = [ "*-*-* 13:00:00" ];

    script = ''
        eval "echo \"$(cat $EXCLUDE)\"" > /tmp/backup_list

        ${pkgs.rsync}/bin/rsync --max-size=100m \
          -e "${pkgs.openssh}/bin/ssh -i \$BACKUPKEY" \
          --exclude-from=/tmp/backup_list \
          -rav \
          /home upload@10.0.0.3:/srv/nfs
    '';

    serviceConfig.Type = "oneshot";
  };
  
  # This honestly needs its own derivation
  # where our backup.ignore file is a list instead
  # and our ssh backup-key is also a string
  systemd.user.services."on-boot" = {
    enable = false;
    description = "my daily startup";
    after = [
         "multi-user.target"
    ];

    environment = {
        BACKUPKEY = "/home/lunarix/.ssh/backup.key";
        EXCLUDE = "/home/lunarix/.config/backup.ignore";
    };

    script = ''
        rm -rf $HOME/Downloads
    '';

    serviceConfig.Type = "oneshot";
  };

  system.stateVersion = "22.05"; # DO NOT CHANGE (without consequences)
}
