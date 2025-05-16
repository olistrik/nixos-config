# Temporary overlay for unstable packages.
{ channels, ... }: final: prev: {
  # inherit (channels.unstable) ...;

  # inherit (channels.unstable) cudatoolkit cudaPackages;
}
