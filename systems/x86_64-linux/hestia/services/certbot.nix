{ ... }: {
  services.certbot = {
    enable = true;
    agreeTerms = true;
  };
}
