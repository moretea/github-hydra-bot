# Nixops network to test updater; can't write a VM test, since it is supposed to contact the
# network and talk to github.com.
{
  machine = { config, pkgs, ... }:
  {
    deployment.targetEnv = "virtualbox";
    deployment.virtualbox.headless = true;

    imports = [  ../modules/nix-github/access-updater.nix ];

    nix-github.access-updater = {
      enable = true;
      org = "nixos";
    };

    users.users.nixbot = {
      isSystemUser = true;
      extraGroups = [ "nixbot" ];
    };

    users.groups.nixbot = {
    };
  };
}
