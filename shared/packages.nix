{config, pkgs, ...}:

{

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    
    # Web get tools. 
    wget	# for wgeting things.
    git

    # Editor
    neovim	# prefered editor
    vim		# nice to have a backup
   
    # Terminal
    alacritty	# prefered terminal
    xterm	# nice to have a backup
  ];

}
