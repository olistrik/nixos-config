{
  nvf.config.autoformat =
    { lib, ... }:
    let
      inherit (lib.nvim.dag) entryAnywhere;
    in
    {
      config.vim = {
        formatter.conform-nvim = {
          enable = true;
          setupOpts.formatters_by_ft = {
            nix = [ "nixfmt" ];
            "*" = [ "injected" ];
          };
        };
        lsp.formatOnSave = true;

        pluginRC.conform-nvim = entryAnywhere /* lua */ ''
          vim.api.nvim_create_user_command("FormatDisable", function(args)
          	if args.bang then
          		-- FormatDisable! will disable formatting just for this buffer
          		vim.b.disableFormatSave = true
          	else
          		vim.g.formatsave = false
          	end
          end, {
          	desc = "Disable autoformat-on-save",
          	bang = true,
          })
          vim.api.nvim_create_user_command("FormatEnable", function()
          	vim.b.disableFormatSave = false
          	vim.g.formatsave = true
          end, {
          	desc = "Re-enable autoformat-on-save",
          })
        '';
      };
    };
}
