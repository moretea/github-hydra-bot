{ config, lib, pkgs, ... }:
with lib;

let

cfg = config.nix-github.access-updater;

in
{

  ###### interface

  options = {
    nix-github.access-updater = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether or not to enable the updater";
      };

      directory = mkOption {
        type = types.str;
        default = "/var/lib/nix-github-hydra";
        description = "Directory where the access file is located.";
      };

      accessFileName = mkOption {
        type = types.str;
        default = "access-file";
        description = "Name of the access file.";
      };

      org = mkOption {
        type = types.str;
        description = "The GitHub organization. All members of this organization will be added to the <literal>accesFile</literal>";
      };

      checkInterval = mkOption {
        type = types.str;
        default = "1h";
        description = ''
          Interval between re-runs. This is a systemd calendar expression.
          See <citerefentry><refentrytitle>systemd.time</refentrytitle>
          <manvolnum>5</manvolnum></citerefentry>.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "nixbot";
        description = "User running the updater";
      };

      group = mkOption {
        type = types.str;
        default = "nixbot";
        description = "Group running the updater";
      };
    };
  };

  ###### implementation
  config = mkMerge [
    (mkIf cfg.enable {

      systemd.timers.update-bot-access-list-timer = {
        wants = [ "timers.target" ];
        timerConfig = {
          OnBootSec="1m";
          OnUnitActiveSec=cfg.checkInterval;
          Unit = "update-bot-access-list";
        };
      };

      systemd.services.update-bot-access-list = {
        description = "Update access list on who can instruct the nixosbot.";
        after = [ "network.target" "network-online.target" ];
        wants = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          PermissionsStartOnly = true;
          User  = "nixbot";
          Group = "nixbot";
        };

        path = [ pkgs.jq pkgs.curl ];

        preStart = ''
          mkdir -p '${cfg.directory}'
          chown '${cfg.user}:${cfg.group}' '${cfg.directory}'
        '';

        script = ''
          curl https://api.github.com/orgs/${cfg.org}/public_members | jq .[].login -r > ${cfg.directory}/tmp_file && mv ${cfg.directory}/tmp_file ${cfg.directory}/${cfg.accessFileName}
        '';
      };
    })
  ];

  meta = {
    maintainers = with lib.maintainers; [ moretea grahamc ];
  };
}
