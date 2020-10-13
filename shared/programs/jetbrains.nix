{pkgs, ...}:
{
  environment.systemPackages = with pkgs.jetbrains; [
    idea-ultimate
    clion
  ];
}
