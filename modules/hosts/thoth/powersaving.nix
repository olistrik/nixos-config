{
  nixos.hosts.thoth.services = {
    # TODO:
    # thoth seems to have a battery life of 10 minutes.
    # Also won't go to sleep when the lit shuts.

    thermald.enable = true;
    tlp.enable = true;
    upower.enable = true;
  };
}
