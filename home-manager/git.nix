{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userEmail = "thomas.meadows@jetstack.io";
    userName  = "chaosinthecrd";
    ignores = [
      "*.swp"
      ".envrc"
    ];
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };
}
