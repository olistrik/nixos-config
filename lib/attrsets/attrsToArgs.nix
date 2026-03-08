{ lib, ... }:
let
  inherit (lib)
    concatLists
    attrValues
    mapAttrs
    concatStringsSep
    ;

  attrsToArgsList =
    attrs:
    concatLists (
      attrValues (
        mapAttrs (
          name: value:
          if value == null then
            [ ]
          else
            [
              "--${name}"
              value
            ]
        ) attrs
      )
    );

  attrsToArgs = attrs: concatStringsSep " " (attrsToArgsList attrs);
in
{
  attrsets = {
    inherit attrsToArgsList attrsToArgs;
  };
}
