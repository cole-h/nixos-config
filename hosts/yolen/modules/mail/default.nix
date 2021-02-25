{ config, ... }:
{
  age.secrets = {
    cole = {
      file = ./cole;
    };
  };

  security.acme.acceptTerms = true;
  security.acme.email = "cole.e.helbling@gmail.com";

  mailserver =
    let
      domain = config.networking.domain;
    in
    {
      enable = true;
      mailDirectory = "/var/lib/mail";
      dkimKeyDirectory = "/var/lib/dkim";
      fqdn = "mail.${domain}";
      domains = [ domain ];

      loginAccounts = {
        "cole@${domain}" = {
          # nix shell nixpkgs#apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2
          hashedPasswordFile = config.age.secrets.cole.path;

          aliases = [
            "@${domain}"
          ];
        };
      };

      # Use Let's Encrypt certificates.
      certificateScheme = 3;

      # Enable IMAP and POP3
      enableImap = true;
      enablePop3 = true;
      enableImapSsl = true;
      enablePop3Ssl = true;

      # Enable the ManageSieve protocol
      enableManageSieve = true;
    };
}
