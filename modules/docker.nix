{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.services.tom.docker;
in {
  options.services.tom.docker = {
    enable = mkEnableOption "docker";
  };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      storageDriver = "zfs";
    };
    systemd.services.docker.wantedBy = lib.mkForce [];
  };
}
