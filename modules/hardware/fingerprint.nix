{
  nixos.hardware.fingerprint =
    { pkgs, config, lib, ... }:
    let
      # Kvasir's FPC sensor (10a5:9800) isn't supported by upstream libfprint's
      # fpcmoc driver or any nixpkgs tod1 package. This pulls in the fpcmoh
      # (match-on-host) driver patch plus Lenovo's official proprietary
      # libfpcbep.so blob. See: https://github.com/furcom/libfprint-10a5-9800
      fpcbep = pkgs.fetchzip {
        url = "https://download.lenovo.com/pccbbs/mobiles/r1slm01w.zip";
        hash = "sha256-/buXlp/WwL16dsdgrmNRxyudmdo9m1HWX0eeaARbI3Q=";
        stripRoot = false;
      };
    in
    {
      nixpkgs.overlays = [
        (final: prev: {
          libfprint = prev.libfprint.overrideAttrs (attrs: {
            doCheck = false;
            checkPhase = ":";
            configurePhase = ''
              runHook preConfigure
              meson setup build --prefix=$out --buildtype=release --libdir=lib -Dudev_rules_dir=$out/lib/udev/rules.d -Dudev_hwdb_dir=$out/lib/udev/hwdb.d
              runHook postConfigure
            '';
            buildPhase = ''
              runHook preBuild
              ninja -C build
              runHook postBuild
            '';
            installPhase = ''
              runHook preInstall
              ninja -C build install
              runHook postInstall
            '';
            # fpcmoh.patch is pinned to the commit before furcom's rewrite for
            # libfprint v1.94.100+ (github.com/furcom/libfprint-10a5-9800),
            # rebased to apply with zero fuzz against nixos-26.05's libfprint
            # 1.94.10. When bumping nixpkgs, `patch --fuzz=0` means a
            # meson.build restructuring upstream will hard-fail the build
            # instead of silently mis-patching; if that happens, check
            # https://github.com/furcom/libfprint-10a5-9800/commits/main
            # for a commit whose patch matches the new libfprint version.
            patches = (attrs.patches or [ ]) ++ [ ./fpcmoh.patch ];
            patchFlags = (attrs.patchFlags or [ "-p1" ]) ++ [ "--fuzz=0" ];
            postPatch = (attrs.postPatch or "") + ''
              substituteInPlace meson.build --replace-fail \
                "find_library('fpcbep', required: true)" \
                "find_library('fpcbep', required: true, dirs: '$out/lib')"
            '';
            preConfigure = (attrs.preConfigure or "") + ''
              install -D "${fpcbep}/FPC_driver_linux_27.26.23.39/install_fpc/libfpcbep.so" "$out/lib/libfpcbep.so"
            '';
            postInstall = (attrs.postInstall or "") + ''
              install -Dm644 "${fpcbep}/FPC_driver_linux_libfprint/install_libfprint/lib/udev/rules.d/60-libfprint-2-device-fpc.rules" "$out/lib/udev/rules.d/60-libfprint-2-device-fpc.rules"
              substituteInPlace "$out/lib/udev/rules.d/70-libfprint-2.rules" --replace-fail "/bin/sh" "${pkgs.runtimeShell}"

              # Belt-and-suspenders: the patch could still apply cleanly but
              # land its dict entries somewhere that's syntactically valid
              # yet doesn't actually register the driver (e.g. a future
              # restructuring that only shifts line numbers within the
              # fuzz-tolerant offset search). Fail loudly instead of shipping
              # a system where the fingerprint reader silently doesn't work.
              grep -aq fpi_device_fpcmoh_get_type "$out/lib/libfprint-2.so.2" \
                || (echo "fpcmoh driver missing from libfprint build; fpcmoh.patch may need rebasing" >&2; exit 1)
            '';
          });
          fprintd = prev.fprintd.overrideAttrs (attrs: {
            doCheck = false;
            nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ attrs.nativeCheckInputs;
          });
        })
      ];

      services.fprintd = {
        enable = true;
        tod.enable = false;
      };
      services.udev.packages = [ pkgs.libfprint ];

      # sudo's PAM service always exists; swaylock's is declared by the niri
      # module (nixpkgs' wayland-session.nix). Set fprintAuth explicitly on
      # both rather than relying on its default (which just mirrors
      # services.fprintd.enable), so enabling the fprintd service doesn't
      # silently opt every future PAM service into fingerprint auth too.
      security.pam.services = {
        sudo.fprintAuth = true;

        swaylock = {
          fprintAuth = true;
          # swaylock re-authenticates on every keystroke, so with fprintd's
          # default order (auth'd first) a pending fingerprint scan blocks
          # the password field from responding at all. Putting pam_unix
          # first (with nullok, since an empty first attempt shouldn't
          # match against an unset password) keeps typing responsive, and
          # fprintd is still tried as a `sufficient` fallback. `rules.*` is
          # nixpkgs' experimental per-rule override knob (may need
          # adjusting on a nixpkgs bump if its shape changes).
          rules.auth = {
            unix.order = config.security.pam.services.swaylock.rules.auth.fprintd.order - 10;
            unix.settings.nullok = lib.mkForce true;
          };
        };
      };
    };
}
