# Taken from https://flo-the.dev/posts/wireguard/
{ config
, pkgs
, ...
}:
let
  wg = "wg0";
  wan = "ens18";
in
{

  sops = {
    secrets = {
      "wireguard/public_key" = {
        owner = config.users.users.systemd-network.name;
      };
      "wireguard/private_key" = {
        owner = config.users.users.systemd-network.name;
      };
    };
  };

  networking = {
    firewall = {
      interfaces."${wg}" = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
      allowedUDPPorts = [ 51820 ];
      extraCommands = ''
        iptables -t nat -A POSTROUTING -o ${wan} -j MASQUERADE
        ip46tables -A FORWARD -i ${wan} -o ${wg} -j ACCEPT
        ip46tables -A FORWARD -i ${wg} -j ACCEPT
      '';
      # Flush the chain then remove it
      extraStopCommands = ''
        iptables -t nat -D POSTROUTING -o ${wan} -j MASQUERADE
        ip46tables -D FORWARD -i ${wan} -o ${wg} -j ACCEPT
        ip46tables -D FORWARD -i ${wg} -j ACCEPT
      '';
    };
  };
  services = {
    dnsmasq = {
      enable = true;
      settings.interface = wg;
    };
    resolved.extraConfig = ''
      DNSStubListener=no
    '';
  };

  boot.kernel.sysctl = {
    # If you use ipv4, this is all you need
    "net.ipv4.conf.all.forwarding" = true;

    # If you want to use it for ipv6
    "net.ipv6.conf.all.forwarding" = true;
  };

  systemd.network = {
    netdevs = {
      "90-wg0" = {
        netdevConfig = { Kind = "wireguard"; Name = wg; };
        wireguardConfig = {
          ListenPort = 51820;
          PrivateKeyFile = config.sops.secrets."wireguard/private_key".path;
        };
        wireguardPeers = [
          # Client config
          {
            wireguardPeerConfig = {
              PublicKey = "Ud0qU1nMNljWSheabbyCgdmUrb2BCSnm4uA643Qr3jw=";
              AllowedIPs = [ "10.1.1.2" "2001:db8:aaaa:bbbb:cccc:dddd::2" ];
              PersistentKeepalive = 15;
            };
          }
        ];
      };
    };
    networks = {
      "90-wg0" = {
        matchConfig = { Name = wg; };
        address = [ "10.1.1.1/24" "fdd6:b156:90e9::1/64" "2001:db8:aaaa:bbbb:cccc:dddd::1/80" ];
        networkConfig = {
          IPForward = true;
        };
      };
    };
  };
}
