{ self, ... }:
let
  inherit (self.lib.test) foo;
in
{
  test.bar = foo + "bar";
}
