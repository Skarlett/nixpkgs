{
  lib, fetchFromGitHub, rustPlatform
}:
let
  owner = "Skarlett";
in
rustPlatform.buildRustPackage rec {
  pname = "coggiebot";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = owner;
    repo = pname;
    rev = "v${version}";
    sha256 = lib.fakeHash;
  };

  cargoSha256 = lib.fakeHash;

  meta = with lib; {
    description = "an open source bot for our server";
    homepage = "https://github.com/${owner}/coggie-bot";
    license = licenses.bsd2;
    maintainers = [ owner ];
  };
}
