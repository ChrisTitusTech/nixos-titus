{pkgs, ...}: let
  username = "titus";
in {
  imports = [
    ./packages
  ];

  fonts.fontconfig.enable = true;

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "23.11";

    packages = with pkgs; [
      vim
      wget
      w3m
      dmenu
      neofetch
      neovim
      starship
      bat
      bazecor
      cargo
      celluloid
      chatterino2
      clang-tools_9
      dunst
      efibootmgr
      elinks
      eww
      feh
      flameshot
      flatpak
      floorp
      fontconfig
      freetype
      fuse-common
      gcc
      gimp
      git
      github-desktop
      gnome.gnome-keyring
      gnugrep
      gnumake
      gparted
      gnugrep
      grub2
      hugo
      kitty
      libverto
      luarocks
      lxappearance
      mangohud
      neovim
      nfs-utils
      ninja
      nodejs
      nomacs
      openssl
      os-prober
      nerdfonts
      pavucontrol
      picom
      polkit_gnome
      powershell
      protonup-ng
      python3Full
      python.pkgs.pip
      qemu
      ripgrep
      rofi
      steam
      steam-run
      sxhkd
      st
      stdenv
      synergy
      swaycons
      terminus-nerdfont
      tldr
      trash-cli
      unzip
      variety
      virt-manager
      xclip
      xdg-desktop-portal-gtk
      xfce.thunar
      xorg.libX11
      xorg.libX11.dev
      xorg.libxcb
      xorg.libXft
      xorg.libXinerama
      xorg.xinit
      xorg.xinput
      zoxide
      (lutris.override {
        extraPkgs = pkgs: [
          # List package dependencies here
          wineWowPackages.stable
          winetricks
        ];
      })
    ];
  };
}
