{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  username = "andrei.lapshin";
in
{
  nix.enable = false;
  programs.bash.enable = true;
  programs.fish = {
    enable = true;
    useBabelfish = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  documentation = {
    enable = false;
    doc.enable = false;
    man.enable = false;
    info.enable = false;
  };

  networking.hostName = "macbook";

  environment.shells = with pkgs; [
    bash
    fish
  ];

  users.users."${username}" = {
    home = "/Users/${username}";
    shell = pkgs.fish;
  };
  system.primaryUser = username;

  homebrew = {
    enable = true;
    brews = [
    ];
    casks = [
      "alt-tab"
      "doll"
      "gimp"
      "inkscape"
      "kid3"
      "marta"
      "pinta"
      "pritunl"
      "protonvpn"
      "sol"
      "shottr"
      "steam"
      "logi-options+"
    ];
    masApps = {
      Xcode = 497799835;
    };
    global = {
      autoUpdate = false;
    };
    onActivation = {
      cleanup = "uninstall";
    };
    taps = builtins.attrNames config.nix-homebrew.taps;
  };

  nix-homebrew = {
    enable = true;
    user = config.system.primaryUser;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false;
  };

  time.timeZone = "Europe/Belgrade";

  services = {
    openssh.enable = false;
  };

  system = {
    startup.chime = false;
    defaults = {
      controlcenter = {
        BatteryShowPercentage = true;
      };
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        tilesize = 48;
        mineffect = "scale";
        orientation = "bottom";
        mru-spaces = false;
        static-only = true;
        show-recents = false;
        minimize-to-application = true;
      };
      finder = {
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "Nlsv";
        NewWindowTarget = "Home";
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
        _FXSortFoldersFirstOnDesktop = true;
      };
      menuExtraClock = {
        ShowDate = 1;
      };
      LaunchServices.LSQuarantine = false;
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        AppleShowScrollBars = "Always";
        AppleShowAllExtensions = true;
        "com.apple.keyboard.fnState" = true;
        "com.apple.swipescrolldirection" = false;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticInlinePredictionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
    };
  };

  environment.etc = {
    "sysctl.conf" = {
      enable = true;
      text = ''
        kern.maxfiles=131072
        kern.maxfilesperproc=65536
      '';
    };
  };

  launchd.daemons.limit-maxfiles = {
    command = "launchctl limit maxfiles 65536 131072";
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = false;
  };
}
