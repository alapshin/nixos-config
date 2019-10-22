# Overlay containing customisations for packages from nixpkgs
self: super:
{
  skrooge = super.skrooge.overrideAttrs (oldAttrs: rec {
    pname = "skrooge";
    version = "2.21.0";

    src = super.fetchgit {
      url = "https://anongit.kde.org/skrooge.git";
      rev = "08f400c7c5db0f262c320ee1ccad6960d755910e";
      sha256 = "1n6akxwk3jbjbp7nayvpk4lzkzjpq4f7lk6463gycbyndy93hyi4";
    };

    patches = [];
  });
}
