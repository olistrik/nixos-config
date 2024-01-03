{ pkgs, ... }: {
  environment.systemPackages = with pkgs.jetbrains; [
    # editors
    goland
    webstorm
  ];
}
