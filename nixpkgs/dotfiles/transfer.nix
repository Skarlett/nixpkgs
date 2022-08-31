{ config, lib, pkgs, stdenv, ... }:
let
  script = pkgs.writeShellScriptBin "transfer"
  ''
    #!/usr/bin/env sh
    set -ex

    if [ $# -eq 0 ]; then
      ${pkgs.coreutils-full}/bin/echo -e  \
          "No arguments specified. \n Usage: cat /tmp/test.md | transfer test.md";
      return 1;

    tmpfile=$(${pkgs.coreutils-full}/bin/mktemp -t transferXXXX)

    if ${pkgs.coreutils-full}/bin/tty -s;
      then basefile=$(${pkgs.coreutils-full}/bin/basename | ${pkgs.gnused}/bin/sed)
      ${pkgs.curl}/bin/curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile
    else
      ${pkgs.curl}/bin/curl --progress-bar --upload-file "-" "https://transfer.sh/$basefile" >> $tmpfile
    fi

    ${pkgs.coreutils-full}/bin/cat $tmpfile
    ${pkgs.coreutils-full}/bin/rm $tmpfile
  '';
in stdenv.mkDerivation {
  name = "dotfiles.transfer";
  buildInputs = [
    pkgs.coreutils-full
    pkgs.curl
    pkgs.gnused
    script
  ];
}
