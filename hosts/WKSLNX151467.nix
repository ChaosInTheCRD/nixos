{ lib, pkgs, ... }:

{
  networking = {
    hostName = "WKSLNX151467";
    hostId   = "49ab6f90";
    interfaces = {
      wlp0s20f3.useDHCP = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      brightnessctl
      kubectl
      kind
      helm
      cmctl
      python3
    ];

    etc = {
      "joshvanl/window-manager/kanshi.cfg" = {
        text = ''
          {
            output DP-1 mode 2560x1440 position 0,0
            output eDP-1 mode 3840x2400 scale 1.6 position 2560,0
          }

          {
            output eDP-1 mode 3840x2400 scale 1.6 position 0,0
          }
        '';
        mode = "644";
      };
    };
  };

  sentinelone = {
    enable     = (builtins.pathExists /keep/etc/nixos/modules/sentinelone);
    site_token = (builtins.readFile /persist/etc/sentinelone/site_token);
  };

  nixpkgs = {
    config = {
      packageOverrides = super: {
        kind  = pkgs.callPackage /keep/etc/nixos/pkgs/kind {};
        helm  = pkgs.callPackage /keep/etc/nixos/pkgs/helm {};
        cmctl = pkgs.callPackage /keep/etc/nixos/pkgs/cmctl {};
      };
    };

    overlays = [
      (self: super: {
        somestatus = super.somestatus.overrideAttrs (attrs: rec {
          patches = attrs.patches ++ [
            (super.fetchpatch {
              name = "somebar.joshvanl-module-battery";
              url  = "https://raw.githubusercontent.com/joshvanl/somestatus/d71bf508a23cf436344ed7141f27b4390440565d/patches/001-module-battery.patch";
              hash = "sha256-9U83CJ6UJJ6KrrRVxn/6OEorijUF2VcD2+f4TG+RwQ0=";
            })
            (super.fetchpatch {
              name = "somebar.joshvanl-module-backlight";
              url  = "https://raw.githubusercontent.com/joshvanl/somestatus/c2ccb473abc40b9db0beb04c9fe659672bc0959f/patches/002-module-backlight-intel.patch";
              hash = "sha256-R6NI0SPvDWERvD2GObe6Dk/2GODQkxjnSwxfFTZdhl4=";
            })
          ];
        });
      })
    ];
  };
}

