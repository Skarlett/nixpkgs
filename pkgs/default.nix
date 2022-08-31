let
  sources = import ./toplevel/sources.nix;

  skarletthello = pkgs.writeShellScriptBin "hello" ''
    echo "Hello from the skarlett channel!"
  '';

  transfer = pkgs.callPackage ../dotfiles;
  coggiebot = pkgs.callPackage ../coggiebot;

  pkgs = import sources.nixpkgs {
    overlays = [
      (self: super: {
        inherit skarletthello transfer coggiebot;
      })
    ];
  };
in
   pkgs
