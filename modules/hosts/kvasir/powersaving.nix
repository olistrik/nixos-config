{
        nixos.hosts.kvasir = {
                services = {
                        upower.enable = true;
                };

                # Hibernation was crashing, so refuse it outright.
                systemd.sleep.settings.Sleep = {
                        AllowHibernation = "no";
                        AllowSuspendThenHibernate = "no";
                        AllowHybridSleep = "no";
                };
        };
}
