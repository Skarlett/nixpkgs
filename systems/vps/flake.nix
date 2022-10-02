{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.03";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [ ({ pkgs, ... }: {
            boot.isContainer = true;
            # Let 'nixos-version --json' know about the Git revision
            # of this flake.
            system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
          
            imports =
              [ # Include the results of the hardware scan.
                ./hardware-configuration.nix
              ];

            # Bootloader.
            boot.loader.grub.enable = true;
            boot.loader.grub.device = "/dev/vda";
  
            networking.hostName = "nixos";
  
            # Set your time zone.
            time.timeZone = "America/Chicago";

            # Select internationalisation properties.
            i18n.defaultLocale = "en_US.utf8";

            # Define a user account. Don't forget to set a password with ‘passwd’.
            users.users =
              let 
                  sshkey="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILcon6Pn5nLNXEuLH22ooNR97ve290d2tMNjpM8cTm2r lunarix@masterbook";
              in 
            {
                lunarix = {
                  isNormalUser = true;
                  openssh.authorizedKeys.keys = [ sshkey ];
                  description = "test";
                  extraGroups = [ "wheel" ];
                  initialPassword = "changeme";
                  packages = with pkgs; [];
                };
                root.openssh.authorizedKeys.keys = [ sshkey ];
            };
  
            environment.systemPackages = with pkgs; [];
            services.openssh = {
              enable = true;
              passwordAuthentication = false;
              permitRootLogin = "yes";
            };
  
            system.stateVersion = "22.05";
          })
      ];
    };

  };
}
