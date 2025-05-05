{ lib, ... }:
with lib; with builtins; rec {
  attrsToArgsList = attrs: concatLists (attrValues (
    mapAttrs (name: value: if value == null then [ ] else [ "--${name}" value ]) attrs
  ));

  attrsToArgs = attrs: concatStringsSep " " (attrsToArgsList attrs);
}
