{ lib
, config
, pkgs
, helpers
, inputs
, ...
}:
let
  servers = [
    # {
    #   name = "matlab-ls";
    #   serverName = "matlab_ls";
    #   description = "matlab language server";
    #   package = pkgs.matlab-language-server;
    #   cmd = cfg: [
    #     "${cfg.package}/bin/matlab-language-server"
    #     "--stdio"
    #   ];
    #   settings = cfg: { MATLAB = cfg; };
    #   settingsOptions = {
    #     indexWorkspace = helpers.defaultNullOpts.mkBool true ''
    #     '';
    #     intallPath = helpers.defaultNullOpts.mkStr "" ''
    #     '';
    #     matlabConnectionTiming = helpers.defaultNullOpts.mkStr "onStart" ''
    #     '';
    #     telemetry = helpers.defaultNullOpts.mkBool true ''
    #     '';
    #   };
    # }
  ];
  mkLsp = import "${inputs.nixvim}/plugins/lsp/language-servers/_mk-lsp.nix";
in
{
  imports = map mkLsp servers;
}
