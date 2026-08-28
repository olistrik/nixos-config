let
  readRecipient = file: builtins.replaceStrings [ "\n" ] [ "" ] (builtins.readFile file);

  thoth = readRecipient ./secrets/recipients/thoth.pub;
  hestia = readRecipient ./secrets/recipients/hestia.pub;
in
{
  # Add encrypted secret files here. For example:
  #
  # "secrets/example.age".publicKeys = [ thoth ];
  # "secrets/shared.age".publicKeys = [ thoth hestia ];
  "secrets/oli-password.age" = {
    publicKeys = [
      thoth
      hestia
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
