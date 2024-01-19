# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  documentation.nixos.enable = false; # .desktop

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (pkg: builtins.elem (builtins.parseDrvName pkg.name).name [ "steam" ]);
      permittedInsecurePackages = [
        "openssl-1.1.1v"
        "python-2.7.18.6"
      ];
    };

    overlays = [
      (final: prev: {
        dwm = prev.dwm.overrideAttrs (old: { src = /home/titus/GitHub/dwm-titus ;});
      })
    ];
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      substituters = ["https://nix-gaming.cachix.org"];
      trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
    };
  };

  hardware = {
    opengl.driSupport32Bit = true;
    pulseaudio = {
      enable = true;
      support32Bit = true;
    };
  };


  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  boot = {
    tmp.cleanOnBoot = true;
    supportedFilesystems = [ "ntfs" ];
    loader = {
	efi.canTouchEfiVariables = true;
#	efi.efiSysMountPoint = "/boot/efi";
	grub = {
		device = "nodev";
	        efiSupport = true;
	        enable = true;	
		useOSProber = true;
		timeoutStyle = "menu";
	};
        timeout = 300;
    };
   # Enable BBR congestion control
  kernelModules = [ "tcp_bbr" ];
  kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
  kernel.sysctl."net.core.default_qdisc" = "fq"; # see https://news.ycombinator.com/item?id=14814530

  # Increase TCP window sizes for high-bandwidth WAN connections, assuming
  # 10 GBit/s Internet over 200ms latency as worst case.
  #
  # Choice of value:
  #     BPP         = 10000 MBit/s / 8 Bit/Byte * 0.2 s = 250 MB
  #     Buffer size = BPP * 4 (for BBR)                 = 1 GB
  # Explanation:
  # * According to http://ce.sc.edu/cyberinfra/workshops/Material/NTP/Lab%208.pdf
  #   and other sources, "Linux assumes that half of the send/receive TCP buffers
  #   are used for internal structures", so the "administrator must configure
  #   the buffer size equals to twice" (2x) the BPP.
  # * The article's section 1.3 explains that with moderate to high packet loss
  #   while using BBR congestion control, the factor to choose is 4x.
  #
  # Note that the `tcp` options override the `core` options unless `SO_RCVBUF`
  # is set manually, see:
  # * https://stackoverflow.com/questions/31546835/tcp-receiving-window-size-higher-than-net-core-rmem-max
  # * https://bugzilla.kernel.org/show_bug.cgi?id=209327
  # There is an unanswered question in there about what happens if the `core`
  # option is larger than the `tcp` option; to avoid uncertainty, we set them
  # equally.
  kernel.sysctl."net.core.wmem_max" = 1073741824; # 1 GiB
  kernel.sysctl."net.core.rmem_max" = 1073741824; # 1 GiB
  kernel.sysctl."net.ipv4.tcp_rmem" = "4096 87380 1073741824"; # 1 GiB max
  kernel.sysctl."net.ipv4.tcp_wmem" = "4096 87380 1073741824"; # 1 GiB max
  # We do not need to adjust `net.ipv4.tcp_mem` (which limits the total
  # system-wide amount of memory to use for TCP, counted in pages) because
  # the kernel sets that to a high default of ~9% of system memory, see:
  # * https://github.com/torvalds/linux/blob/a1d21081a60dfb7fddf4a38b66d9cef603b317a9/net/ipv4/tcp.c#L4116 
  };

  networking = {
    hostName = "nixos-studio"; # Define your hostname.
    enableIPv6 = false;
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    firewall.enable = false;
  };


  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    packages=[ pkgs.terminus_font ];
    font="${pkgs.terminus_font}/share/consolefonts/ter-i22b.psf.gz";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # List services that you want to enable:
  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      layout = "us";
      windowManager = {
        # This installs dwm so there's no need to have it in environment.systemPackages.
        dwm.enable = true;

        # Uncomment this to install bspwm - removing from environment.systemPackages.
        # bspwm.enable = true;
      };

      displayManager = {
        lightdm.enable = true;
        autoLogin = {
          enable = true;
          user = "titus";
        };
        setupCommands = ''
          ${pkgs.xorg.xrandr}/bin/xrandr --output DP-1 --off --output DP-2 --off --output DP-3 --off --output HDMI-1 --mode 1920x1080 --pos 0x0 --rotate normal
        '';
      };
    };

    # Enable picom
    picom.enable = true;

    # Enable flatpak support. This already installs Flatpak so there's no need to have it in environment.systemPackages.
    flatpak.enable = true;

    # Enable dbus
    dbus.enable = true;
  };

  # Enable sound.
  sound.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.titus = {
    isNormalUser = true;
    description = "Titus";
    extraGroups = [    
      "flatpak"
      "disk"
      "qemu"
      "kvm"
      "libvirtd"
      "sshd"
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "libvirtd"
      "root"
    ];
  };

  home-manager.useGlobalPkgs = true;

home-manager.users.titus = { pkgs, ... }: {
  home.packages = [ pkgs.gitAndTools.gh ];
  programs.gh.enable = true;
  # make sure to use gh auth setup-git otherwise it will ask for username
  programs.git.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
  home.stateVersion = "23.11";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    autojump
    cargo
    celluloid
    chatterino2
    clang-tools_9
    davinci-resolve
    dmenu
    dunst
    elinks
    eww
    feh
    flameshot
    floorp
    fontconfig
    freetype
    gcc
    gh
    gimp
    git
    github-desktop
    gnugrep
    gnumake
    gparted
    hugo
    kitty
    libverto
    luarocks
    lutris
    mangohud
    neofetch
    neovim
    nfs-utils
    ninja
    nodejs
    nomacs
    openssl
    pavucontrol
    picom
    polkit_gnome
    powershell
    protonup-ng
    python3Full
    python.pkgs.pip
    ripgrep
    rofi
    st
    starship
    stdenv
    steam-run
    sxhkd
    synergy
    swaycons
    terminus-nerdfont
    tldr
    trash-cli
    unzip
    variety
    vim
    virt-manager
    w3m
    wget
    xclip
    xfce.thunar
    xorg.libX11
    xorg.libX11.dev
    xorg.libxcb
    xorg.libXft
    xorg.libXinerama
    xorg.xinit
    xorg.xinput
    (lutris.override {
      extraPkgs = pkgs: [
        # List package dependencies here
        wineWowPackages.stable
        winetricks
      ];
    })
  ];

  ## Gaming
  programs.steam = {
    # This installs Steam, so there's no need to have it in environment.systemPackages.
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # This installs QEMU, so there's no need to have it in environment.systemPackages
  virtualisation.libvirtd.enable = true;

  xdg.portal = {
    enable = true;
    # wlr.enable = true;
    # gtk portal needed to make gtk apps happy. Since it's declared here, there's no need to have it in environment.systemPackages.
    extraPortals = with pkgs; [xdg-desktop-portal-gtk];
  };

  # Enable Polkit
  security.polkit.enable = true;

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    # Set timeout to 10 seconds
    extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';
  };

  fonts = {                                           # This is the new syntax.
    packages = with pkgs; [                           # Changing it so you don't have to later on.
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      source-han-sans
      source-han-sans-japanese
      source-han-serif-japanese
      # Nerdfonts is declared here, so there's no need to have it in environment.systemPackages.
      (nerdfonts.override { fonts = [ "Meslo" ]; })
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Meslo LG M Regular Nerd Font Complete Mono" ];
        serif = [ "Noto Serif" "Source Han Serif" ];
        sansSerif = [ "Noto Sans" "Source Han Sans" ];
      };
    };
  };

  system = {
    # Copy the NixOS configuration file and link it from the resulting system
    # (/run/current-system/configuration.nix). This is useful in case you
    # accidentally delete configuration.nix.
    copySystemConfiguration = true;
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      channel = "https://channels.nixos.org/nixos-23.11";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

  # TL;DR: Don't change this value! It determines the version this config was
  # created with, NOT the version, you're actually running!
  system.stateVersion = "22.11"; # Did you read the comment?
}
