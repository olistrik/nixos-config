{
        nixos.hosts.kvasir = {
                services = {
                        upower = {
                                enable = true;
                                criticalPowerAction = "HybridSleep";
                                percentageLow = 15;
                                percentageCritical = 8;
                                percentageAction = 5;
                        };

                        # A power button press (including the one that wakes s2idle) suspends instead of powering off.
                        logind.settings.Login.HandlePowerKey = "suspend";
                };

                # Hybrid sleep (suspend plus a hibernation image in swap) is the
                # critical-battery action, so a flat battery keeps the session.
                # Hibernation images only survive until the kernel changes.
                boot.resumeDevice = "/dev/kvasir/swap";

                # tiny_power_button loads alongside the normal button driver and
                # makes every power button press (including the one that wakes
                # the laptop) signal init with SIGRTMIN+4, i.e. power off,
                # bypassing logind's HandlePowerKey and niri's inhibitor.
                boot.blacklistedKernelModules = [ "tiny_power_button" ];

                # Nothing uses suspend-then-hibernate, so keep it off.
                systemd.sleep.settings.Sleep.AllowSuspendThenHibernate = "no";
        };
}
