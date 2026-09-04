{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.editor = false;
    };
    plymouth.enable = true;
    kernelParams = [
      "quiet"
      "splash"
    ];
    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  hardware = {
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-vaapi-driver
      ];
    };
  };

  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      insertNameservers = [
        "94.140.14.14#dns.adguard-dns.com"
        "94.140.15.15#dns.adguard-dns.com"
      ];
    };
    nameservers = [
      "94.140.14.14#dns.adguard-dns.com"
      "94.140.15.15#dns.adguard-dns.com"
    ];
    firewall = {
      enable = true;
      logReversePathDrops = true;
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
    };
  };

  time.timeZone = "America/Lima";
  i18n.defaultLocale = "es_PE.UTF-8";
  console.keyMap = "la-latin1";

  services = {
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        theme = "catppuccin-mocha-mauve";
      };
      defaultSession = "hyprland-uwsm";
      autoLogin = {
        enable = false;
        user = "edu";
      };
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    pulseaudio.enable = false;
    gvfs.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    resolved = {
      enable = true;
      settings.Resolve = {
        DNSSEC = "true";
        DNSOverTLS = "true";
        FallbackDNS = [
          "9.9.9.9#dns.quad9.net"
          "1.1.1.1#cloudflare-dns.com"
        ];
        LLMNR = "false";
      };
    };
    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
      openFirewall = true;
    };
  };

  security.rtkit.enable = true;

  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
    uwsm.enable = true;
    hyprlock.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
    };
    nix-ld.enable = true;
  };

  users.users.edu = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    wget
    udiskie
    tree
    git
    adw-gtk3
    vimix-cursors
    catppuccin-sddm
    qt6.qtwayland
  ];

  fonts.packages = with pkgs; [
    inter
    ubuntu-sans
    nerd-fonts.fira-code
    nerd-fonts.iosevka
  ];

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  documentation = {
    enable = true;
    man.enable = false;
    doc.enable = false;
    info.enable = false;
  };
  nixpkgs.config.allowUnfree = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  fileSystems."/mnt/Datos" = {
    device = "/dev/disk/by-uuid/4673cfcb-5a1f-4c5f-ba9e-6284325aefc1";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=5s" ];
  };

  system.autoUpgrade = {
    enable = true;
    flake = "/home/edu/nixos#nixos";
    flags = [
      "--update-input"
      "nixpkgs"
    ];
    dates = "weekly";
    randomizedDelaySec = "45min";
    persistent = true;
    operation = "boot";
    allowReboot = false;
  };

  system.stateVersion = "26.05";
}
