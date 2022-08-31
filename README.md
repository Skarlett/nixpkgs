# Nix packages

## `/modules`
nixos stuff

## `/pkgs`
nix packages

## `/systems`
my systems

### Install
```
nix-channel add https://github.com/skarlett/nixpkgs/archive/master.tar.gz skarlett
nix-channel --update

cd /tmp

nix-build '<skarlett>' -A skarletthello

result/bin/hello
```
