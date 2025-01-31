{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dwm = {
      url = "github:joshvanl/dwm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, dwm }:
  let
    pkgsOverlays = system: [
      dwm.overlays.${system}
    ] ++
    nixpkgs.lib.mapAttrsToList (name: _: import ./overlays/${name}) (nixpkgs.lib.filterAttrs
      (name: entryType: nixpkgs.lib.hasSuffix ".nix" name && entryType == "regular")
      (builtins.readDir ./overlays)
    );


    pkgsConfig = {
      packageOverrides = pkgs: with pkgs; { 
        gke-gcloud-auth-plugin = pkgs.callPackage ./pkgs/gke-gcloud-auth-plugin {};
     };
    };

    nixosModulesPkgs = sys: {
      # propagate git revision
      system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
      nixpkgs = {
        overlays = (pkgsOverlays sys);
        config = pkgsConfig;
      };
    };

    myNixosModules = nixpkgs.lib.mapAttrs'
      (name: value:
        nixpkgs.lib.nameValuePair
          (nixpkgs.lib.removeSuffix ".nix" name)
          (import (./modules + "/${name}"))
      )
      (nixpkgs.lib.filterAttrs
        (_: entryType: entryType == "regular")
        (builtins.readDir ./modules)
      );

    machines = system: map (nixpkgs.lib.removeSuffix ".nix") (
      nixpkgs.lib.attrNames (
        nixpkgs.lib.filterAttrs
          (_: entryType: entryType == "regular")
          (builtins.readDir ./machines/${system})
      )
    );

    build-machine = machine: system: {
      name = machine;

      value = nixpkgs.lib.makeOverridable nixpkgs.lib.nixosSystem {
        system = system;

        modules = nixpkgs.lib.attrValues (myNixosModules) ++ [
          (nixosModulesPkgs system)
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.tom = { pkgs, lib, ... }: with lib; {
              imports = mapAttrsToList (name: _: ./home-manager/${name}) (filterAttrs
                 (name: entryType: hasSuffix ".nix" name && entryType == "regular")
                 (builtins.readDir ./home-manager)
              );
              home.stateVersion = "22.11";
            };
          }
          (import (./machines + "/${system}/${machine}.nix"))
          (import ./modules/shared.nix)
          (import ./modules/hardware.nix)
        ];
      };
    };

  in
  flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ]
    (system:
      let
        pkgs = (import nixpkgs) {
          system = system;
          overlays = pkgsOverlays system;
          config = pkgsConfig;
        };

      in
      rec {
        packages = {};
      }
    ) // {

    nixosConfigurations = builtins.listToAttrs (
      nixpkgs.lib.flatten (
        (map
          ( machine: [ (build-machine machine "x86_64-linux") ])
          (machines "x86_64-linux"))
        ++
        (map
          ( machine: [ (build-machine machine "aarch64-linux") ])
          (machines "aarch64-linux"))
      )
    );
    nixosModules = myNixosModules;
  };
}
