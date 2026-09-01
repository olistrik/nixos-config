let
  pubkey = import ./pubkeys.nix;
  thoth = pubkey.thoth.host.age;
  hestia = pubkey.hestia.host.age;
  kvasir = pubkey.kvasir.host.age;
in
{
  # Add encrypted secret files here. For example:
  #
  # "secrets/example.age".publicKeys = [ pubkey.thoth.host.age ];
  # "secrets/shared.age".publicKeys = [ pubkey.thoth.host.age pubkey.hestia.host.age ];
  "secrets/oli-password.age" = {
    publicKeys = [
      thoth
      hestia
      kvasir
    ];
    armor = true;
  };

  "secrets/acme-cloudflare.env.age" = {
    publicKeys = [
      hestia
    ];
    armor = true;
  };

  "secrets/mosquitto-zigbee.pass.age" = {
    publicKeys = [
      hestia
    ];
    armor = true;
  };

  "secrets/zigbee2mqtt-secret.yaml.age" = {
    publicKeys = [
      hestia
    ];
    armor = true;
  };

  "secrets/msmtp-noreply.pass.age" = {
    publicKeys = [
      hestia
    ];
    armor = true;
  };

  "secrets/homewire.env.age" = {
    publicKeys = [
      hestia
    ];
    armor = true;
  };

  "secrets/nix-serve-key.pem.age" = {
    publicKeys = [
      hestia
    ];
    armor = true;
  };
}
