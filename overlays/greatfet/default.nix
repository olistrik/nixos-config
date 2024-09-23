{ channels, ... }:
with channels.unstable.python3Packages;
final: prev: {
  inherit (channels.unstable) pulseview sigrok-cli;
  greatfet = greatfet.overrideAttrs (prev: rec {
    version = "2021.2.1";
    src = final.fetchFromGitHub {
      owner = "greatscottgadgets";
      repo = "greatfet";
      rev = "v${version}";
      sha256 = "sha256-ZIZxK6P/LfYRAssME+5mJz5dTNLKo9217D7cAam+BgI=";
    };
    propagatedBuildInputs = prev.propagatedBuildInputs ++ [
      cmsis-svd
      setuptools
      tabulate
      tqdm
      prompt_toolkit
    ];
  });
}
