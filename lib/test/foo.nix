{ lib, ... }:
{
  test.foo = lib.strings.toUpper "foo";
}
