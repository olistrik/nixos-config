{ channels, ... }: final: prev: {
  arduino-language-server = prev.arduino-language-server.overrideAttrs (old: {
    src = final.fetchFromGitHub {
      owner = "speelbarrow";
      repo = "arduino-language-server";
      rev = "6064dc30028ffa096eb541aa8dcfe2522ff5e138";
      hash = "sha256-UlNJsdhkFNgQQeQjHfJlIzX9viX/cZ82omg2wy2SQSM=";
    };
    vendorHash = "sha256-Mu9W92f8ZEaTfJ8YkhKpOvFMB/QzqoxfWkSGWlU/yVM=";
  });
}
