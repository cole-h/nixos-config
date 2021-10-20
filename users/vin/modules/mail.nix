{ config, pkgs, ... }:
let
  name = "Cole Helbling";
  address = "cole.e.helbling@outlook.com";
  host = "office365.com";
  imap = "outlook.${host}";
  smtp = "smtp.${host}";
in
{
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.notmuch = {
    enable = true;
    hooks = {
      preNew = "mbsync --all || true"; # idk why but Inbox fails
      postNew = ''
        notmuch tag +archive -inbox -- tag:inbox and folder:outlook/Archive
        notmuch tag +deleted -inbox -- tag:inbox and folder:outlook/Deleted
      '';
    };
  };

  accounts.email = {
    maildirBasePath = "${config.home.homeDirectory}/.mail";
    accounts.outlook = {
      notmuch.enable = true;
      primary = true;

      msmtp = {
        enable = true;
        extraConfig = { auth = "login"; };
      };

      inherit address;
      userName = address;
      realName = name;
      passwordCommand = "${pkgs.pass}/bin/pass Internet/outlook.com/cole.e.helbling@outlook.com/aerc";
      maildir.path = "outlook";

      smtp = {
        host = smtp;
        port = 587;
        tls.useStartTls = true;
      };

      imap = {
        host = imap;
        port = 993;
      };

      mbsync = {
        enable = true;
        create = "maildir";
        expunge = "both";
        extraConfig.account = {
          Timeout = 120;
          PipelineDepth = 50;
        };
      };
    };
  };
}
