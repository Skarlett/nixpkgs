{ lib, config, pkgs,  ... }:
with lib;
let
  sname = "coggiebot";
  cfg = config.services."coggiebot";
in
{
  options.services."${coggiebot}" = {
    enable = mkEnableOption "coggie bot service";
  };

  config = mkIf cfg.enable {
    systemd.user.services."backup-home" = {
        description = "backup home directory";
        after = [
          "multi-user.target"
          "networking.target"
        ];

        ExecStart = "${pkgs.coggiebot}/bin/coggiebot";
        serviceConfig.Type = "simple";
    };
  };
}
