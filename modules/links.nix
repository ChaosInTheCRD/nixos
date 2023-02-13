{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.services.tom.links;
in {
  options.services.tom.links = {
    enable = mkEnableOption "links";
  };

  config = mkIf cfg.enable {
    environment.pathsToLink = [ "/share/zsh/site-functions" ];

    systemd.tmpfiles.rules = [
      # /persist to maintain.
      "d /persist/home           0755 tom wheel - -"
      "d /keep/home/go           0755 tom wheel - -"
      "d /keep/home/downloads    0755 tom wheel - -"
      "d /keep/var/lib/docker    0755 tom wheel - -"
      "d /persist/home/.mozilla  0755 tom wheel - -"
      "d /persist/home/documents 0755 tom wheel - -"

      "d /persist/home/.config          0755 tom wheel - -"
      "d /persist/home/.config/chromium 0755 tom wheel - -"
      "d /persist/home/.docker          0755 tom wheel - -"

      "d /persist/home/.cache          0755 tom wheel - -"
      "d /persist/home/.cache/mozilla  0755 tom wheel - -"
      "d /persist/home/.cache/chromium 0755 tom wheel - -"

      "d /persist/home/.ssh 0755 tom wheel - -"

      # Locals to pre-create with correct perms.
      "d /home/tom/.config      0755 tom wheel - -"
      "d /home/tom/.cache       0755 tom wheel - -"
      "d /home/tom/.local       0755 tom wheel - -"
      "d /home/tom/.local/share 0755 tom wheel - -"
      "d /root/.config           0755 root root - -"

      # /etc to save.
      "d  /persist/etc/NetworkManager                     0755 tom wheel - -"
      "L+ /etc/NetworkManager/system-connections          - - - - /persist/etc/NetworkManager/system-connections"
      "L+ /etc/nixos                                      - - - - /keep/etc/nixos"

      # Histories/Caches.
      "R  /home/tom/.zsh_history   - - - -"
      "L+ /home/tom/.zsh_history   - - - - /persist/home/.zsh_history"
      "L+ /home/tom/go             - - - - /keep/home/go"
      "L+ /home/tom/.mozilla       - - - - /persist/home/.mozilla"
      "L+ /home/tom/.cache/mozilla - - - - /persist/home/.cache/mozilla"
      "L+ /home/tom/downloads      - - - - /keep/home/downloads"
      "L+ /home/tom/Downloads      - - - - /home/tom/downloads"
      "L+ /home/tom/documents      - - - - /persist/home/documents"
      "L+ /home/tom/.docker        - - - - /persist/home/.docker"
      "L+ /home/tom/.viminfo       - - - - /persist/home/.viminfo"

      "L+ /home/tom/.config/chromium - - - - /persist/home/.config/chromium"
      "L+ /home/tom/.cache/chromium  - - - - /persist/home/.cache/chromium"

      "L+ /var/lib/docker - - - - /keep/var/lib/docker"
    ];
  };
}
