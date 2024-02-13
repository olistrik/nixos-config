{ pkgs, ... }: {

  environment.systemPackages = with pkgs.olistrik; [ palworld-server ];
  # plusultra.services.palworld.enable = true;
}

