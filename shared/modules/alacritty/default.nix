
{config, lib, pkgs, ...}:

with lib;

let
  
  cfge = config.environment;
 
  cfg = config.programs.alacritty;
  
in 

{
  options = {

    programs.alacritty = {
      
      enable = mkOption {
        default = false;
        description = ''
          enable or disable alacritty.
        '';
        type = types.bool;
      };
      
      font = {
        normal = {
          family = mkOption {
            default = "monospace";
            description = ''
              Sets the font used by alacritty.
              Make sure it is accepted by fc-match.
            '';
            type = types.str;
          };
          
	  style = mkOption {
            default = "Regular";
            description = ''
              Can be used to pick a specific face.
	    '';
            type = types.str;
          };
        };

	size = mkOption {
          default = "11.0";
          description = ''
	    The point size of the font.
	  '';
          type = types.str;
        };
      };

    };

  };

  config = mkIf cfg.enable {
    system.activationScripts.alacritty = ''
      for d in $(grep -v "nologin" /etc/passwd | cut -d: -f6); do
	if [ ! -e ''${d}/.config/alacritty/alacritty.yml ]; then
          mkdir -p ~/.config/alacritty
          ln -s /etc/alacritty/alacritty.yml ''${d}/.config/alacritty/alacritty.yml
	fi
      done
    '';
    environment.systemPackages = with pkgs; [ alacritty ];  
    environment.etc."alacritty/alacritty.yml".text = ''
      #Font configuration
      font:
        normal:
          family: "${cfg.font.normal.family}"
          style: ${cfg.font.normal.style}
        size: ${cfg.font.size}
    '';
  };
}
