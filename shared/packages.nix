{config, pkgs, ...}:

{

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    
    # Web get tools. 
    wget	# for wgeting things.
    git 	# if you don't know what this is git lost.
    
    # Editor
    neovim	# prefered editor
    vim		# nice to have a backup
   
    # Terminal
    alacritty	# prefered terminal
    xterm	# nice to have a backup
  ];

}
