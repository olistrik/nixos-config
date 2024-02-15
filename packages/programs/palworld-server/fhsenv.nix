{ buildFHSUserEnv
, palworld-server-unwrapped
, steamworks-sdk-redist
, stdenv
, xdg-user-dirs
}:
buildFHSUserEnv {
  name = "junkyard-server";

  runScript = "palworld-server";

  targetPkgs = pkgs: [
    palworld-server-unwrapped
    steamworks-sdk-redist
    stdenv.cc.cc.libgcc
    xdg-user-dirs
  ];
}
