{ stdenv, bundlerEnv, ruby }:
let
  gems = bundlerEnv {
    name = "rubocop-sdv";
    inherit ruby;
    gemdir = ./.;
  };
in stdenv.mkDerivation {
  name = "rubocop-sdv";
  src = ./.;
  buildInputs = [gems ruby];
  installPhase = ''
  mkdir -p $out/{bin,share/rubocop-sdv}
  cp -r * $out/share/rubocop-sdv
  bin=$out/bin/rubocop
  cat > $bin << 'EOF'
#!/bin/sh
exec ${gems}/bin/rubocop $@
EOF
  chmod +x $bin
  '';
}
