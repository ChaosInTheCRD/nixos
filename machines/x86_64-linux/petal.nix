{ config, pkgs, lib, modulesPath, ... }: {

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "sr_mod" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    interfaces.enp0s5.useDHCP = true;
    hostName = "purple";
    hostId = "deadbeef";
  };

  services.tom = {
    dwm = {
      enable = true;
      xrandr = "--output Virtual-1 --mode 4096x2160 --output Virtual-2 --off";
    };
  };

  home-manager.users.tom = {
    gcloud.enable = true;
  };

  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "prl-tools" ];
    allowUnsupportedSystem = true;
  };

  hardware.parallels.enable = true;

  environment.systemPackages = with pkgs; [
    brightnessctl
    kubectl
    python3
    imagemagick
    envsubst
    git-crypt
    age
    terraform
    dive
  ];
}
