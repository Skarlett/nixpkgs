let
  sources = import ./toplevel/sources.nix;

  skarletthello = pkgs.writeShellScriptBin "hello" ''
    echo "Hello from the skarlett channel!"
  '';

  skarlett.hello = pkgs.writeShellScriptBin "hello" ''
    echo "Hello from the skarlett channel!"
  '';

  # transfer = pkgs.callPackage dotfiles {};
  coggiebot = pkgs.callPackage ./pkgs/coggiebot {};

  pkgs = import sources.nixpkgs {
    overlays = [
      (self: super: {
        inherit skarlett skarletthello transfer coggiebot;
        
        skarlett_version = "1.0";
      })
    ];
  };
in
   pkgs
