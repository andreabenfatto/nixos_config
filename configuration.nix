# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  # looad fbcon early in boot process

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the gummiboot efi boot loader.
  boot = {
    initrd.kernelModules = [ "fbcon" ];
    cleanTmpDir = true;
    loader = {
      gummiboot.enable = true;
      gummiboot.timeout = 6;
      efi.canTouchEfiVariables = true;
    };
    extraModprobeConfig = ''
      options libata.force=noncq # todo
      options snd_hda_intel index=0 model=intel-mac-auto id=PCH
      options snd_hda_intel index=1 model=intel-mac-auto id=HDMI
      options snd_hda_intel model=mbp101
      options hid_apple fnmode=1
      options hid_apple iso_layout=0
    '';
    kernelPackages = pkgs.linuxPackages_testing;
  };

  networking = {
    hostName = "desmond"; 
    wireless = {
      enable = true;  # Enables wireless support via wpa_supplicant.
    };
  };

  # Select internationalisation properties.
  i18n = {
     consoleFont = "ter-v32n";
     consoleKeyMap = "us";
     defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";


  environment.etc = {
    "resolvconf.conf".text =
    ''
    name_servers="8.8.8.8 8.8.4.4 208.67.222.222 208.67.220.220"
    '';
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    acpi
    autorandr
    evince
    pciutils
    awscli
    xscreensaver
    ansible2
    bluez5
    chromium
    firefox
    dmenu
    emacs
    encfs
    git
    hipchat
    luakit
    htop
    i7z
    leiningen
    mupdf
    openvpn
    python
    python27Packages.locustio
    redshift
    silver-searcher
    sysstat
    tree
    tarsnap
    usbutils
    vagrant
    vimNox
    wget
    xscreensaver
    xbindkeys
    xbindkeys-config
    xf86_input_mtrack
    xorg.xbacklight
    zsh
    kbdlight
    
    xfce.terminal

    haskellPackages.xmobar
    haskellPackages.xmonad
    haskellPackages.yeganesh
    haskellPackages.alsa-mixer
    haskellPackages.alsa-core

  ];

  nixpkgs.config = {
    # enable support for broadcom_sta
    allowUnfree = true;
    packageOverrides = pkgs : {
      bluez = pkgs.bluez5;
    };
    chromium = {
      enablePepperFlash = true; # Chromium removed support for Mozilla (NPAPI) plugins so Adobe Flash no longer works
      enablePepperPDF = true;
    }; 
    firefox = {
      enableGooglTalkPlugin = true;
      enableAdobeFlash = true;
    };
  };

  programs = {
    light.enable = true;
    ssh = {
      startAgent = true;
      agentTimeout = "1h";
    };
    bash.enableCompletion = true;
    zsh.enable = true;
  };


  # List services that you want to enable:
  services = {

    avahi = {
      enable = true;
      ipv6 = true;
      nssmdns = true;
    };

    psd = {
      enable = true;
      users = ["andrea"];
    };

    udev.extraRules = ''
      ACTION=="change", SUBSYSTEM=="drm", HOTPLUG=="1", RUN+="${pkgs.stdenv.shell} /home/andrea/.screenlayout/autorandr.sh"
      # Set bluetooth power up
      ACTION=="add", KERNEL=="hci0", RUN+="/run/current-system/sw/sbin/hciconfig hci0 up"
    '';

    upower.enable = true;

    locate = {
      enable = true;
      interval = "hourly";
    };

    # enable keyring to be able to use MysqlWorkbench
    gnome3.gnome-keyring.enable = true;

    # enable geolocation service
    geoclue2.enable = true;

    # Enable the OpenSSH daemon.
    # openssh.enable = true;

    # Enable CUPS to print documents.
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };

    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      layout = "us";
      xkbVariant = "altgr-intl";
      xkbOptions = "terminate:ctrl_alt_bksp, ctrl:nocaps";
      vaapiDrivers = [ pkgs.vaapiIntel ];

      #resolutions = [{ x = 1680; y=1050;} { x = 2560; y = 1600;}];
      #monitorSection = ''
      #    Modeline "1680x1050_60.00"
      #w'';

      displayManager = {
        slim = {
          enable = true;
          defaultUser = "andrea";
	  #theme = pkgs.fetchurl {
          #  url = "https://github.com/andreabenfatto/nixos-slim-theme/archive/master.tar.gz";
          #  sha256 = "1z905y1kfdiwrg1vxbm7bh7py2j89p09k63klkfs4hc1ijk82pw0";
          #};
        };
        desktopManagerHandlesLidAndPower = false;
	#sessionCommands = ''
        #  /run/current-system/sw/bin/xrandr --output VIRTUAL1 --off --output eDP1 --mode 1280x800 --pos 0x0 --rotate normal --output DP1 --off --output HDMI2 --off --output HDMI1 --off --output DP2 --off
        #'';
      };

      desktopManager = {
        default = "none";
        xterm.enable = false;
      };

      multitouch = {
        enable = true;
        invertScroll = true;
        ignorePalm = true;
        buttonsMap = [ 1 3 2 ];
      };

      synaptics = {
        enable = true;
        twoFingerScroll = true;
        palmDetect = true;
        vertTwoFingerScroll = true;
        dev = "/dev/input/event*";
        accelFactor = "0.005";
        buttonsMap = [ 1 3 2 ];
        additionalOptions =
        ''
        Option "VertScrollDelta" "-111"
        Option "HorizScrollDelta" "-111"
        '';
      };

      inputClassSections = [''
          Identifier "Apple Magic Trackpad"
          Driver "synaptics"

          # Match only the Apple Magic Trackpad
          MatchUSBID "05ac:030e"
          MatchIsTouchpad "on"

          # Set resolution tweaks for better response
          Option "VertResolution" "75"
          Option "HorizResolution" "75"

          # Set a timeout for multi finger click so accidental double-clicks don't
          # happen when right clicking and other gestures
          Option "EmulateMidButtonTime" "100"

          # Increase sensitivity
          Option "MinSpeed" "1.75"
          Option "MaxSpeed" "2.00"
          Option "AccelFactor" "0.1"

          # Scrolling
          Option "VertScrollDelta" "-100"
          Option "HorizScrollDelta" "-100"
      ''];

      # Enable the windowManager.
      windowManager = {
        default = "xmonad";
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
        };
      };
    };

    redshift = {
      temperature.night = 2700;
      enable = true;
      latitude = "52.5167";
      longitude = "13.3833";
    };

    tarsnap = {
      enable = true;
      archives = {
        andrea = {
          period = "hourly";
          directories = [
            "/home/andrea/"
          ];
          excludes = [
            "/home/andrea/Downloads/"
            "/home/andrea/Development/"
            "/home/andrea/VirtualBox\ VMs/"
            "/home/andrea/.cache/"
            "/home/andrea/.WebIde100"
            "/home/andrea/.config/chromium*"
          ];
        };
      };
    };
    mbpfan.enable = true;

  };

  virtualisation.virtualbox.host.enable = true;

  #services.hardware.pommed.enable = true;
  hardware.bluetooth.enable = true;

  sound = {
    enable = true;
    enableMediaKeys = true;
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.andrea = {
    description = "Andrea Benfatto";
    isNormalUser = true;
    extraGroups = ["wheel" "vboxusers"];
    shell = "/run/current-system/sw/bin/zsh";
  };
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };


  # The NixOS release to be compatible with for stateful data such as databases.
  system = {
    stateVersion = "16.03";
    autoUpgrade.enable = true;
  };


  fonts = {
    enableFontDir = true;
    enableCoreFonts = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      source-serif-pro
      source-sans-pro
      anonymousPro
      baekmuk-ttf
      bakoma_ttf
      caladea
      cantarell_fonts
      carlito
      comfortaa
      corefonts
      crimson
      culmus
      dejavu_fonts
      dina-font
      eb-garamond
      fantasque-sans-mono
      fira-code
      fira
      gentium
      gyre-fonts
      hack-font
      hasklig
      inconsolata
      liberation_ttf
      libertine
      powerline-fonts
      terminus_font
      noto-fonts
      source-code-pro
      vistafonts
      ubuntu_font_family
    ];
    fontconfig.ultimate = {
      enable = true;
      rendering = pkgs.fontconfig-ultimate.rendering.osx;
    };
  };
}
