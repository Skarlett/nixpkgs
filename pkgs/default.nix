let
  sources = import ./toplevel/sources.nix;

  hello = pkgs.writeShellScriptBin "hello" ''
    echo "Hello from the skarlett channel!"
  '';

  transfer = pkgs.callPackage ../dotfiles;
  coggiebot = pkgs.callPackage ../coggiebot;

  pkgs = import sources.nixpkgs {
    overlays = [
      (self: super: {
        inherit hello transfer coggiebot;
      })
    ];
  };
in
   pkgs
