# Install and configure R and Rmarkdown

{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    (texlive.combine { inherit (texlive) scheme-basic
                                         xcolor
                                         fancyvrb
                                         framed
                                         etoolbox
                                         booktabs
                                         mdwtools; })
  ];
}
