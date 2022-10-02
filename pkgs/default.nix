let
  sources = import ./toplevel/sources.nix;

  skarlett.hello = pkgs.writeShellScriptBin "hello" ''
    echo "Hello from the skarlett channel!"
  '';
  
  skarlett.coggiebot = pkgs.callPackage ./pkgs/coggiebot {};
  
  pkgs = import sources.nixpkgs {
    overlays = [
      (self: super: {
        inherit skarlett;
        
        skarlett_version = "1.0";
      })
    ];
  };
in
   pkgs
