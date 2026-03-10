{
  nvf.config.nix-comment-lang = {
    vim = {
      additionalRuntimePaths = [ ./. ];
      luaConfigRC.nix-comment-lang = /* lua */ ''
        require("nix-comment-lang").setup()
      '';
    };
  };
}
