{
  description = "DeepSeek Harness (dsh) — the npm packaging and the terminal-profile data for trantor";

  # The host flake (/etc/nixos) calls `package.nix` through `final.callPackage`
  # against its own package set, so this pin decides only what `nix build` and
  # `nix flake check` do here. `rust-pkgs` supplies `dsh-patch`, the patcher the
  # build runs over the installed tree; the host passes its own instance the
  # same way.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.rust-pkgs = {
    url = "github:neg-serg/rust-pkgs";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, rust-pkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          system = pkgs.stdenv.hostPlatform.system;
        in
        {
          default = pkgs.callPackage ./package.nix {
            dsh-patch = rust-pkgs.packages.${system}.dsh-patch;
          };
        }
      );

      # CI gate: building the harness is the check the packaging has.
      checks = forAllSystems (system: {
        build = self.packages.${system}.default;
      });
    };
}
