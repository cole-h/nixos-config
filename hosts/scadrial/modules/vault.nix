/*

Bootstrap steps:

Do a deploy, it'll be sealed and uninitialized.

0. vault operator init -recovery-shares=1 -key-shares=1 -recovery-threshold=1 -key-threshold=1
   write the unseal key to ../secrets/kif-vault-unseal.json as:
     { "key": "the-token" }
   write the initial root token to ../secrets/kif-vault-login
then deploy.

1. vault write aws-personal/config/root access_key=... secret_key=... region=us-east-1
2. vault write -force aws-personal/config/rotate-root
3. vault kv put packet/config api_token=-
4. vault kv put secret/buildkite/grahamc/token token=-
5. vault kv put secret/buildkite/nixos-foundation/packet-project-id token=-
6. vault write ssh-keys/config/ca generate_signing_key=true
   this generated key is used for the nix-packet-builders repo
7. vault kv put secret/ofborg/local.nix expression=-
   paste in the ofborg/infrastructure/private/local.nix file
8. vault kv put secret/ofborg/github.key key=-
   paste in the ofborg/infrastructure/private/github.key file
9. configure the consul creds (https://www.vaultproject.io/docs/secrets/consul)
   vault write consul/config/access address=127.0.0.1:8500 token=....atoken....
then deploy with a reboot.

*/

{ secrets }:
{ lib, pkgs, config, ... }:
let
  address = (
    if config.services.vault.tlsKeyFile == null
    then "http://"
    else "https://"
  ) + config.services.vault.address;

  plugin_args = (
    if config.services.vault.tlsKeyFile == null
    then ""
    else "-ca-cert=/run/vault/certificate.pem"
  );

  pluginPkgs = pkgs.callPackage ./plugins.nix {};

  plugins = {
    pki = {
      type = "secret";
    };

    aws = {
      type = "secret";
    };

    consul = {
      type = "secret";
    };

    packet = {
      type = "secret";
      package = pluginPkgs.vault-plugin-secrets-packet;
      command = "vault-plugin-secrets-packet";

      # vault kv put packet/config api_token=-
      # vault kv put packet/role/nixos-foundation type=project ttl=3600 max_ttl=3600 project_id=86d5d066-b891-4608-af55-a481aa2c0094 read_only=false
    };
    #oauthapp = {
    # wl-paste | vault write oauth2/github/config -provider=github client_id=theclientid client_secret=- provider=github

    # scopes: https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/
    # vault write oauth2/bitbucket/config/auth_code_url state=foo scopes=bar,baz

    # vault write oauth2/github/config/auth_code_url state=$(uuidgen) scopes=repo,gist
    # now it is broken ... https://github.com/puppetlabs/vault-plugin-secrets-oauthapp/issues/4
    #  type = "secret";
    #  package = pkgs.vault-plugin-secrets-oauthapp;
    #  command = "vault-plugin-secrets-oauthapp";
    #};
  };
  mounts = {
    "approle/" = {
      type = "auth";
      plugin = "approle";
    };
    "aws-personal/" = {
      type = "secrets";
      plugin = "aws";
    };

    "consul/" = {
      plugin = "consul";
      type = "secrets";
    };
    "pki_ca/" = {
      type = "secrets";
      plugin = "pki";
    };
    "pki_intermediate/" = {
      type = "secrets";
      plugin = "pki";
    };
    "secret/" = {
      type = "secrets";
      plugin = "kv";
    };
    "ssh-keys/" = {
      type = "secrets";
      plugin = "ssh";
    };
    "packet/" = {
      type = "secrets";
      plugin = "packet";
    };
    #"oauth2/github/" = {
    #  type = "secrets";
    #  plugin = "oauthapp";
    #};
  };

  writes = [
    {
      path = "consul/roles/packet-machine-import";
      args = {
        policies = "packet-machine-import";
        ttl = "30m0s";
      };
    }
    {
      path = "consul/roles/consul-template-machines";
      args = {
        policies = "consul-template-machines";
        ttl = "24h";
      };
    }
    {
      path = "ssh-keys/roles/netboot";
      args = {
        allow_user_certificates = "true";
        allowed_users = "netboot";
        key_type = "ca";
        default_user = "netboot";
        ttl = "30m0s";
      };
    }
    {
      path = "ssh-keys/roles/root";
      args = {
        allow_user_certificates = "true";
        allowed_users = "root";
        key_type = "ca";
        default_user = "root";
        ttl = "30m0s";
      };
    }
    {
      path = "ssh-keys/roles/nixos-foundation-build-farm-check";
      args = {
        allow_user_certificates = "true";
        allowed_users = "check";
        key_type = "ca";
        default_user = "check";
        ttl = "30m0s";
      };
    }
    {
      path = "ssh-keys/roles/nixos-foundation-build-farm-root";
      args = {
        allow_user_certificates = "true";
        allowed_users = "root";
        key_type = "ca";
        default_user = "root";
        ttl = "30m0s";
        default_extensions = [
          {
            permit-pty = "";
          }
        ];
      };
    }
    {
      path = "aws-personal/config/rotate-root";
      force = true;
      args = {};
      canFail = true;
    }
    {
      path = "auth/approle/role/buildkite";
      args = {
        token_policies = "buildkite";
        token_ttl = "720h";
        token_max_ttl = "720h";
      };
    }
    {
      path = "auth/approle/role/buildkite-netboot";
      args = {
        token_policies = "buildkite-netboot";
        token_ttl = "720h";
        token_max_ttl = "720h";
      };
    }
    {
      path = "auth/approle/role/buildkite-r13y";
      args = {
        token_policies = "buildkite-r13y";
        token_ttl = "1h";
        token_max_ttl = "1h";
      };
    }
    {
      path = "auth/approle/role/buildkite-packet-nix-builder";
      args = {
        token_policies = "buildkite-packet-nix-builder";
        token_ttl = "1h";
        token_max_ttl = "1h";
      };
    }
    {
      path = "auth/approle/role/buildkite-packet-spot-buildkite";
      args = {
        token_policies = "buildkite-packet-spot-buildkite";
        token_ttl = "1h";
        token_max_ttl = "1h";
      };
    }
    {
      path = "auth/approle/role/buildkite-ofborg";
      args = {
        token_policies = "buildkite-ofborg";
        token_ttl = "1h";
        token_max_ttl = "1h";
      };
    }
    {
      path = "auth/approle/role/packet-import-machines";
      args = {
        token_policies = "packet-import-machines";
        token_ttl = "1h";
        token_max_ttl = "2h";
      };
    }
    {
      path = "auth/approle/role/consul-template-machines";
      args = {
        token_policies = "consul-template-machines";
        token_ttl = "1h";
        token_max_ttl = "24h";
      };
    }
    {
      path = "packet/role/nixos-foundation";
      args = {
        type = "project";
        ttl = "3600";
        max_ttl = "3600";
        project_id = "86d5d066-b891-4608-af55-a481aa2c0094";
        read_only = "false";
      };
    }
    {
      path = "packet/role/nixos-foundation-instantaneous";
      args = {
        type = "project";
        ttl = "5";
        max_ttl = "5";
        project_id = "86d5d066-b891-4608-af55-a481aa2c0094";
        read_only = "false";
      };
    }
    {
      path = "aws-personal/roles/r13y-publish";
      args = {
        credential_type = "iam_user";
        policy_document = builtins.toJSON {
          Version = "2012-10-17";
          Statement = [
            {
              Effect = "Allow";
              Action = "s3:ListBucket";
              Resource = "arn:aws:s3:::r13y-com";
            }
            {
              Effect = "Allow";
              Action = [ "s3:GetObject" "s3:PutObject" "s3:PutObjectAcl" ];
              Resource = "arn:aws:s3:::r13y-com/*";
            }
          ];
        };
      };
    }
    {
      path = "aws-personal/roles/interactive-admin";
      args = {
        credential_type = "iam_user";
        policy_document = builtins.toJSON {
          Version = "2012-10-17";
          Statement = [
            {
              Effect =  "Allow";
              Action = "*";
              Resource = "*";
            }
          ];
        };
      };
    }
    {
      path = "aws-personal/roles/nixops-deploy";
      args = {
        credential_type = "assumed_role";
        role_arns = "arn:aws:iam::223448837225:role/NixopsStateDeploy";
        # Note: the role above has something near to the policy below,
        # but if we must use a Role to be able to use KMS, and if we use
        # the role AND specify the policy document .... it doesn't work.
        /*policy_document = builtins.toJSON {
          Version = "2012-10-17";
          Statement = [
            {
              Effect = "Allow";
              Action = "s3:ListBucket";
              Resource = "arn:aws:s3:::grahamc-nixops-state";
            }
            {
              Effect = "Allow";
              Action = [ "s3:GetObject" "s3:PutObject" ];
              Resource = "arn:aws:s3:::grahamc-nixops-state/packet-spot-buildkite.nixops";
            }
            {
              Effect = "Allow";
              Action = [
                "dynamodb:GetItem"
                "dynamodb:PutItem"
                "dynamodb:DeleteItem"
              ];
              Resource = "arn:aws:dynamodb:*:*:table/grahamc-nixops-lock";
            }
            {
              Effect = "Allow";
              Action = [
                "kms:Decrypt"
                "kms:Encrypt"
                "kms:GenerateDataKey"
              ];
              Resource = "arn:aws:kms:us-east-1:223448837225:key/166c5cbe-b827-4105-bdf4-a2db9b52efb4";
            }
          ];
        };*/
      };
    }
  ];



  policies = {
    "buildkite" = {
      document = ''
        path "auth/token/create" {
          capabilities = [ "create", "update" ]
        }

        path "auth/approle/role/buildkite-r13y/role-id" {
          capabilities = [ "read" ]
        }

        path "auth/approle/role/buildkite-packet-spot-buildkite/role-id" {
          capabilities = [ "read" ]
        }

        path "auth/approle/role/buildkite-r13y/secret-id" {
          capabilities = [ "create", "update" ]
        }

        path "auth/approle/role/buildkite-packet-spot-buildkite/secret-id" {
          capabilities = [ "create", "update" ]
        }

        path "auth/approle/role/buildkite-ofborg/role-id" {
          capabilities = [ "read" ]
        }

        path "auth/approle/role/buildkite-ofborg/secret-id" {
          capabilities = [ "create", "update" ]
        }

        path "auth/approle/role/buildkite-packet-nix-builder/role-id" {
          capabilities = [ "read" ]
        }

        path "auth/approle/role/buildkite-packet-nix-builder/secret-id" {
          capabilities = [ "create", "update" ]
        }

      '';
    };
    "buildkite-netboot" = {
      document = ''
        path "auth/token/create" {
          capabilities = [ "create", "update" ]
        }

        path "auth/approle/role/buildkite-packet-nix-builder/role-id" {
          capabilities = [ "read" ]
        }

        path "auth/approle/role/buildkite-packet-nix-builder/secret-id" {
          capabilities = [ "create", "update" ]
        }

      '';
    };

    "buildkite-r13y" = {
      document = ''
        path "auth/token/create" {
          capabilities = [ "create", "update" ]
        }

        path "auth/token/revoke-self" {
          capabilities = [ "update" ]
        }

        path "aws-personal/creds/r13y-publish" {
          capabilities = [ "read" ]
        }
      '';
    };
    "buildkite-packet-spot-buildkite" = {
      document = ''
        path "auth/token/create" {
          capabilities = [ "create", "update" ]
        }

        path "auth/token/revoke-self" {
          capabilities = [ "update" ]
        }

        path "packet/creds/nixos-foundation" {
          capabilities = [ "read" ]
        }

        path "aws-personal/creds/nixops-deploy" {
          capabilities = [ "read" ]
        }

        path "secret/buildkite/grahamc/token" {
          capabilities = [ "read" ]
        }
      '';
    };
    "buildkite-packet-nix-builder" = {
      document = ''
        path "auth/token/create" {
          capabilities = [ "create", "update" ]
        }

        path "auth/token/revoke-self" {
          capabilities = [ "update" ]
        }

        path "packet/creds/nixos-foundation" {
          capabilities = [ "read" ]
        }

        path "secret/buildkite/nixos-foundation/packet-project-id" {
          capabilities = [ "read" ]
        }

        path "ssh-keys/sign/netboot" {
          capabilities = [ "create", "update" ]
        }
      '';
    };
    "buildkite-ofborg" = {
      document = ''
        path "auth/token/create" {
          capabilities = [ "create", "update" ]
        }

        path "auth/token/revoke-self" {
          capabilities = [ "update" ]
        }

        path "packet/creds/nixos-foundation" {
          capabilities = [ "read" ]
        }

        path "aws-personal/creds/nixops-deploy" {
          capabilities = [ "read" ]
        }

        path "secret/ofborg/local.nix" {
          capabilities = [ "read" ]
        }
        path "secret/ofborg/github.key" {
          capabilities = [ "read" ]
        }
      '';
    };
    "laptop-petunia" = {
      document = ''
        path "auth/token/create" {
          capabilities = [ "create", "update" ]
        }

        path "auth/token/revoke-self" {
          capabilities = [ "update" ]
        }

        path "packet/creds/nixos-foundation" {
          capabilities = [ "read" ]
        }

        path "aws-personal/creds/nixops-deploy" {
          capabilities = [ "read" ]
        }
      '';
    };
    "packet-import-machines" = {
      document = ''
        path "auth/token/create" {
          capabilities = [ "create", "update" ]
        }

        path "auth/token/revoke-self" {
          capabilities = [ "update" ]
        }

        path "packet/creds/nixos-foundation" {
          capabilities = [ "read" ]
        }

        path "consul/creds/packet-machine-import" {
          capabilities = [ "read" ]
        }

        path "secret/buildkite/nixos-foundation/packet-project-id" {
          capabilities = [ "read" ]
        }
      '';
    };
    "consul-template-machines" = {
      document = ''
        path "auth/token/create" {
          capabilities = [ "create", "update" ]
        }

        path "auth/token/revoke-self" {
          capabilities = [ "update" ]
        }

        path "consul/creds/consul-template-machines" {
          capabilities = [ "read" ]
        }

        path "ssh-keys/sign/netboot" {
          capabilities = [ "create", "update" ]
        }
      '';
    };
  };

  pluginsBin = pkgs.runCommand "vault-env" {}
    ''
      mkdir -p $out/bin

      ${builtins.concatStringsSep "\n" (
      lib.attrsets.mapAttrsToList (
        name: info:
          if info ? package then
            ''
              (
                echo "#!/bin/sh"
                echo 'exec ${info.package}/bin/${info.command} "$@"'
              ) > $out/bin/${info.command}
              chmod +x $out/bin/${info.command}
            '' else ""
      ) plugins
    )}
    '';

  writeCheckedBash = pkgs.writers.makeScriptWriter {
    interpreter = "${pkgs.bash}/bin/bash";
    check = "${pkgs.shellcheck}/bin/shellcheck";
  };

  vault-setup = writeCheckedBash "/bin/vault-setup" ''
    PATH="${pkgs.glibc}/bin:${pkgs.curl}/bin:${pkgs.procps}/bin:${pkgs.vault}/bin:${pkgs.jq}/bin:${pkgs.coreutils}/bin"

    set -eux

    scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
    function finish {
      rm -rf "$scratch"
    }
    trap finish EXIT
    chmod 0700 "$scratch"

    export VAULT_ADDR=${address}
    export VAULT_CACERT=/run/vault/certificate.pem
    export HOME=/root
 
    if ! vault status -format=json | jq -e '.initialized'; then
      echo "Uninitialized."
      exit 1
    fi

    if [ -f /run/keys/vault-unseal-json ]; then
      curl \
        --request PUT \
        --data @/run/keys/vault-unseal-json \
        --cacert /run/vault/certificate.pem \
        "${address}/v1/sys/unseal"
    fi

    if [ -f /run/keys/vault-login ]; then
      vault login - < /run/keys/vault-login > /dev/null
    fi

    echo "-truncated-" > /run/keys/vault-unseal-json
    echo "-truncated-" > /run/keys/vault-login

    vault secrets disable pki_ca || true
    vault secrets disable pki_intermediate || true

    ${builtins.concatStringsSep "\n" (
    lib.attrsets.mapAttrsToList (
      name: value:
        if value ? package then
          ''
            expected_sha_256="$(sha256sum ${pluginsBin}/bin/${value.command} | cut -d " " -f1)"

            echo "Re-registering ${name}"
            vault plugin register -command "${value.command}" -args="${plugin_args}" -sha256 "$expected_sha_256" ${value.type} ${name}
            vault write sys/plugins/reload/backend plugin=${name}
          '' else ""
    ) plugins
  )}

    ${builtins.concatStringsSep "\n" (
    lib.attrsets.mapAttrsToList (
      path: info:
        ''
          if ! vault ${info.type} list -format json | jq -e '."${path}"?'; then
            vault ${info.type} enable -path=${path} ${info.plugin}
          fi
        ''
    ) mounts
  )}

    ${builtins.concatStringsSep "\n" (
    lib.attrsets.mapAttrsToList (
      name: policy:
        ''
          echo ${lib.escapeShellArg policy.document} | vault policy write ${name} -
        ''
    ) policies
  )}

    ${builtins.concatStringsSep "\n" (
    builtins.map (
      { path, args, force ? false, canFail ? false }: ''
        echo ${lib.escapeShellArg (builtins.toJSON args)} \
          | vault write ${if force then "-force" else ""} \
            ${lib.escapeShellArg path} - ${if canFail then " || true" else ""}
      ''
    ) writes
  )}

    #vault write auth/approle/role/buildkite-nixops token_policies="buildkite-nixops" \
    #    token_ttl=720h token_max_ttl=720h

    # Replace our selfsigned cert  with a vault-made key.
    # 720h: the laptop can only run for 30 days without a reboot.
    # Note: pki backends are obliterated a section or so above.
    vault secrets tune -max-lease-ttl=720h pki_ca
    sleep 1

    echo "Generating root certificate"
    vault write -field=certificate pki_ca/root/generate/internal \
      common_name="localhost" \
      ttl=719h > "$scratch/root-certificate.pem"

    vault write pki_ca/config/urls \
        issuing_certificates="${address}/v1/pki/ca" \
        crl_distribution_points="${address}/v1/pki/crl"
    sleep 1

    echo "Generating intermediate certificate"
    vault secrets tune -max-lease-ttl=718h pki_intermediate
    vault write -format=json pki_intermediate/intermediate/generate/internal \
        common_name="localhost Intermediate Authority" \
        | jq -r '.data.csr' > "$scratch/pki_intermediate.csr"

    vault write -format=json pki_ca/root/sign-intermediate csr=@"$scratch/pki_intermediate.csr" \
        format=pem_bundle ttl="717h" \
        | jq -r '.data.certificate' > "$scratch/intermediate.cert.pem"
    vault write pki_intermediate/intermediate/set-signed certificate=@"$scratch/intermediate.cert.pem"
    sleep 1

    echo "Generating Vault's certificate"
    vault write pki_intermediate/roles/localhost \
        allowed_domains='localhost,kif.wg.gsc.io' \
        allow_bare_domains=true \
        allow_subdomains=false \
        max_ttl="716h"

    vault write -format json pki_intermediate/issue/localhost \
      common_name="localhost" alt_names="localhost,kif.wg.gsc.io" ttl="715h" > "$scratch/short.pem"

    jq -r '.data.certificate' < "$scratch/short.pem" > "$scratch/certificate.server.pem"
    jq -r '.data.ca_chain[]' < "$scratch/short.pem" >> "$scratch/certificate.server.pem"
    jq -r '.data.private_key' < "$scratch/short.pem" > "$scratch/vault.key"

    mv "$scratch/root-certificate.pem" /run/vault/certificate.pem
    mv "$scratch/vault.key" /run/vault/vault.key
    mv "$scratch/certificate.server.pem" /run/vault/certificate.server.pem

    pkill --signal HUP --exact vault
  '';


in
{
  deployment.keys = {
    "vault-unseal-json".keyFile = secrets.kif.vault-unseal-json;
    "vault-login".keyFile = secrets.kif.vault-login;
  };

  environment = {
    systemPackages = [ pkgs.vault vault-setup ];
    variables = {
      VAULT_ADDR = address;
      VAULT_CACERT = "/run/vault/certificate.pem";
    };
    etc."vault.sh".text = ''
      export VAULT_ADDR=${address}
      export VAULT_CACERT=/run/vault/certificate.pem
    '';
  };

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 8200 ];
  services.vault = {
    enable = true;
    package = pkgs.vault.overrideAttrs (
      { patches ? [], version, ... }:
      # Note: 1.4.3 has the fix we need for SHA2 signatures: https://github.com/hashicorp/vault/pull/9096
      # based on the work in https://github.com/hashicorp/vault/pull/8383/files
      # However, the "upgrade" path from this patch to that isn't clear enough that I'm comfortable
      # doing it in the middle of a work day.
        # assert version == "1.3.6";
        {
          version = "1.4.0";
          src = pkgs.fetchFromGitHub {
            owner = "hashicorp";
            repo = "vault";
            rev = "v1.4.0";
            sha256 = "13ycg9shara4ycbi79wj28z6nimnsqgisbf35ca3q9w066ac0ja2";
          };
          patches = patches ++ [
            ./e8470811779ddac60ea104464a61b77b6767dc30.patch
          ];
        }
    );
    address = "localhost:8200";
    storageBackend = "file";
    storagePath = "/persist/vault/";
    extraConfig = ''
      listener "tcp" {
        address     = "10.10.2.16:8200"
        tls_cert_file = "${config.services.vault.tlsCertFile}"
        tls_key_file = "${config.services.vault.tlsKeyFile}"
      }
      api_addr = "${address}"
      cluster_addr = "${address}"
      plugin_directory = "${pluginsBin}/bin"
      log_level = "trace"
    '';
    tlsCertFile = "/run/vault/certificate.server.pem";
    tlsKeyFile = "/run/vault/vault.key";
  };

  systemd.services.vault = {
    wantedBy = [ "vault.target" ];
    after = [ "wireguard-wg0.service" ];
    restartIfChanged = lib.mkForce true;
    postStart = ''
      set -x
      . /etc/vault.sh
      while ${pkgs.vault}/bin/vault status; [ $? -eq 1 ]; do
        sleep 1
      done
    '';
  };

  systemd.services.vault-tls-bootstrap = {
    wantedBy = [ "vault.service" "vault.target" ];
    path = with pkgs; [ openssl ];
    unitConfig.BindsTo = [ "vault.service" ];
    unitConfig.Before = [ "vault.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = let sslcfg = pkgs.writeText "conf" ''
      [req]
      default_bits = 2048
      prompt = no
      default_md = sha256
      x509_extensions = v3_req
      distinguished_name = dn
      
      [dn]
      C = ES
      ST = MyState
      L = MyCity
      O = MyOrg
      emailAddress = email@mydomain.com
      CN = localhost
      
      [v3_req]
      subjectAltName = @alt_names
      
      [alt_names]
      DNS.1 = localhost
      '';
    in ''
      set -eux
      rm -rf /run/vault
      mkdir /run/vault

      touch /run/vault/vault.key
      chmod 0600 /run/vault/vault.key

      touch /run/vault/certificate.pem
      chmod 0644 /run/vault/certificate.pem

      openssl req -x509 -new -sha256 -nodes -newkey rsa:4096 -days 1 \
         -config ${sslcfg} \
         -keyout /run/vault/vault.key \
         -out /run/vault/certificate.pem

      #openssl req -x509 -subj /CN=localhost -nodes -newkey rsa:4096 -days 1 \
      #  -keyout /run/vault/vault.key \
      #  -out /run/vault/certificate.pem

      cp  /run/vault/certificate.pem  /run/vault/certificate.server.pem

      chown ${config.systemd.services.vault.serviceConfig.User}:${config.systemd.services.vault.serviceConfig.Group} /run/vault/{vault.key,certificate.pem}
      ${pkgs.systemd}/bin/systemctl kill -s HUP vault || true
      sleep 1
      ${pkgs.systemd}/bin/systemctl kill -s HUP vault || true
    '';
  };
  systemd.services.vault-unlock = {
    unitConfig.BindsTo = [ "vault.service" ];
    wantedBy = [ "vault.service" "vault.target" "multi-user.target" ];
    wants = [ "vault-unseal-json-key.service" "vault-login-key.service" ];
    unitConfig.After = [ "vault-tls-bootstrap.service" "vault.service" "vault-unseal-json-key.service" "vault-login-key.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      . /etc/vault.sh
      ${vault-setup}/bin/vault-setup
    '';
  };

  systemd.targets.vault = {
    requires = [ "vault-unlock.service" "vault.service" ];
  };
}
