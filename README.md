# Personal NIX OS Configuration

This configuration.nix is not meant to be used, but instead referenced for syntax when using NIX. 

If you do end up using it, make sure to change the titus user folder and cloning my dwm-titus repo into your `~/GitHub/dwm-titus` folder from the overlay portion. This will build dwm every time `sudo nixos-rebuild switch` is run. 

My hardware configuration is an example of NFS shares, LVM, and traditional partitions being mounted. Your Disk IDs and addresses will be different and it should NOT be used.
