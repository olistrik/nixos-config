let
  mkFoo = str: str;
in
{
  ml-ml = /* lua */ ''
    function foo() return end
  '';
  sl-ml =
    # lua
    "function foo() return end";
  sl-sl =
    # lua
    "function() end"; # dunno why I need that space.
  ml-sl =          /* lua */ "function() end";
  ml-sl-il = /*
    lua */ "function() end";
  fn-sl-sl =
    mkFoo
      # lua
      "function() end";
  fn-ml-sl-il = mkFoo 
      /* lua 
      */ "function() end";
  fn-ml-ml-il = mkFoo /* lua */ ''
    function() end
  '';

  # just another comment
  ml-bad =
    # eg
    mkFoo "";
}
