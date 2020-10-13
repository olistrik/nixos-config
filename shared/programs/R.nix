# Install and configure R and Rmarkdown

{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    (pkgs.rWrapper.override {
      packages = with pkgs.rPackages; [
        rmarkdown
        UsingR
        Ecdat
        car
        bestglm
        faraway
        ISLR
      ];
    })
    pandoc
    haskellPackages.pandoc-citeproc
  ];
}
