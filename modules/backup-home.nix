{ lib, config, pkgs,  ... }:
with lib;                      

let
  cfg = config.services."backup-home";

in {
  options.services."backup-home" =
  {
    enable = mkEnableOption "backup-home service";
    
    sshkey = mkOption
    {
      type = types.str;
      default = "";
    };
    
    exclude = mkOption
    {
      type = types.listOf types.str;
      default = [ ];
    };
    
    src = mkOption
    {
      type = types.list types.str;
      default = [];
      example = [
        "/home"
	"/nix/secrets"
      ];
    };

    dest = mkOption
    {
      type = types.list types.str;
      default = [];
      example = [
        "upload@10.0.0.3:/srv/upload"
        "/mnt/usb"
      ];
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services."backup-home" =
    {
        description = "backup home directory";
        after = [
          "multi-user.target"
          "networking.target"
        ];

        #environment = {
        #  BACKUPKEY = "/home/lunarix/.ssh/backup.key";
        #  EXCLUDE = "/home/lunarix/.config/backup.ignore";
        # };

        serviceConfig.Type = "oneshot";
        startAt = [ "*-*-* 13:00:00" ];



        script = ''
            eval "echo \"$(cat $EXCLUDE)\"" > /tmp/backup_list
            ${pkgs.rsync}/bin/rsync --max-size=100m \
              -e "${pkgs.openssh}/bin/ssh -i \${options.services.backup-home.options.}" \
              --exclude-from=/tmp/backup_list \
              -rav \
              /home upload@10.0.0.3:/srv/nfs
              rm /tmp/backup_list
        '';


      };
  };
}
