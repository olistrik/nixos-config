# Install and configure R and Rmarkdown

{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    pandoc
    haskellPackages.pandoc-citeproc
    haskellPackages.pandoc-crossref
  ];
}
