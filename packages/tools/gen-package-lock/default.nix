{ pkgs }: pkgs.writeScriptBin "gen-package-lock" ''
  #!/bin/sh
  cd $1 || exit 1

  rev=$(perl -n -e'/rev\s*=\s*"(.*)"/ && print $1' ./default.nix)
  owner=$(perl -n -e'/owner\s*=\s*"(.*)"/ && print $1' ./default.nix)
  repo=$(perl -n -e'/pname\s*=\s*"(.*)"/ && print $1' ./default.nix)
  pkg="https://raw.githubusercontent.com/$owner/$repo/$rev/package.json"

  curl $pkg > ./package.json
  ${pkgs.nodejs}/bin/npm i --package-lock-only
  rm -rf ./package.json
''
