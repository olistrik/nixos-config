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
        LARF
        sjPlot
        oddsratio
        boot
        ggplot2
        ggpubr
      ];
    })
    pandoc
    haskellPackages.pandoc-citeproc
    haskellPackages.pandoc-crossref
  ];
}
