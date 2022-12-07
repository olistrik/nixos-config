{ lib, buildGoModule, fetchFromGitHub, git }:

buildGoModule rec {
  pname = "atlas";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "ariga";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-f4Kpw6eT93zHW4OUYcMnxamTW5QM7EKDbWtUBsh0C8g=";
  } + cmd/atlas;

  vendorSha256 = "sha256-zUvHr5SI/JPOKurfOPtY0hfBREYha2hAnXigoHT/TH4=";

  ldflags = [ "-s" "-w" ];

  checkInputs = [ git ];

  meta = with lib; {
    description =
      "An open source tool that helps developers manage their database schemas by applying modern DevOps principles";
    homepage = "https://atlasgo.io";
    license = licenses.asl20;
    maintainers = with maintainers; [ dit7ya ];
  };
}
