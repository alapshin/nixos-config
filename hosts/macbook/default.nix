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
  programs.fish.enable = true;

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
      "sol"
      "doll"
      "marta"
      "alt-tab"
      "pritunl"
      "android-studio"
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
    openssh.enable = true;
    karabiner-elements.enable = true;
  };

  system = {
    startup.chime = false;
    defaults = {
      controlcenter = {
        BatteryShowPercentage = true;
      };
      dock = {
        autohide = true;
        tilesize = 48;
        static-only = true;
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
}
