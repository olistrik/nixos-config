let
  readRecipient = file: builtins.replaceStrings [ "\n" ] [ "" ] (builtins.readFile file);
in
{
  hestia = {
    host.age = readRecipient ./secrets/recipients/hestia.pub;
  };

  kvasir = {
    host.age = readRecipient ./secrets/recipients/kvasir.pub;
    oli.ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILkCJbgtYWgHT9QaxG3u+DWu5G0JlDwtFvA4maUEOb02";
  };

  thoth = {
    host.age = readRecipient ./secrets/recipients/thoth.pub;
    oli.ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHwyuoI18ZEoo/c38XvI6HwvRlxigxd3lPzshi7RtVw2";
  };

  yubikey = {
    personal.ssh = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMcvHSxN1mFGgB6r19eHIqGKvhNOwddvVe43NwhKHmWzAAAABHNzaDo=";
  };
}
