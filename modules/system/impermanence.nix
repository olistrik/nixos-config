{
  nixos.system.impermanence = {
    /*
      TODO: make some smart way of configuring the persistent files so that
      they can be delcared in the modules that use them; but aren't nuked
      if the module is ever disabled.
    */
  };
}
