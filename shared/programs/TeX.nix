# Install and configure R and Rmarkdown

{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    (texlive.combine { inherit (texlive) scheme-basic
                                         xcolor
                                         fancyvrb
                                         framed
                                         setspace
                                         booktabs
                                         mdwtools
                                         subfig
                                         caption
                                         float
                                         etoolbox; })
   liberation_ttf
  ];
}
