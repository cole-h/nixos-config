{ pkgs, ... }:
let
  ofborg = pkgs.callPackage ./src { };
in
{
  networking.extraHosts = ''
    127.0.0.1 borg.local
  '';

  ## prometheus
  services.nginx.virtualHosts."borg.local".locations."/prometheus".proxyPass = "http://127.0.0.1:9090";

  services.prometheus.enable = true;
  services.prometheus.stateDir = "prometheus2";
  services.prometheus.extraFlags = [
    "--web.external-url=http://borg.local/prometheus/"
    "--storage.tsdb.retention.time=3d"
  ];
  services.prometheus.scrapeConfigs = [
    {
      job_name = "node";
      static_configs = [{ targets = [ "borg.local:9100" ]; labels.distro = "nixos"; }];
    }
    {
      job_name = "rabbitmq";
      static_configs = [{ targets = [ "borg.local:9419" ]; }];
    }

  ];
  services.prometheus.exporters.node.enable = true;
  services.prometheus.exporters.node.enabledCollectors = [ "systemd" ];

  ## grafana
  services.nginx.virtualHosts."borg.local".locations."/".proxyPass = "http://127.0.0.1:3000";

  services.grafana = {
    enable = true;
    auth.anonymous.enable = true;
  };

  ## rabbitmq
  # Management IO available at http://127.0.0.1:15672.
  # Create users (as the rabbitmq service's user):
  #   $ rabbitmqctl add_vhost ofborg
  #   $ rabbitmqctl add_user admin password
  #   $ rabbitmqctl set_user_tags admin administrator
  #   $ rabbitmqctl add_user builder-1 password
  #   $ rabbitmqctl add_user node-exporter password
  #   $ rabbitmqctl set_user_tags node-exporter monitoring
  services.rabbitmq.enable = true;
  services.rabbitmq.listenAddress = "0.0.0.0";
  services.rabbitmq.plugins = [ "rabbitmq_management" "rabbitmq_web_stomp" ];

  systemd.services."rabbitmq".postStart = ''
    (
    rabbitmqctl wait --timeout 60 --pid $MAINPID ; \
    rabbitmqctl add_vhost ofborg 2>/dev/null ; \
    rabbitmqctl add_user builder-1 password 2>/dev/null ; \
    rabbitmqctl set_permissions -p ofborg builder-1 ".*" ".*" ".*" 2>/dev/null ; \
    rabbitmqctl add_user node-exporter password 2>/dev/null ; \
    rabbitmqctl set_user_tags node-exporter monitoring 2>/dev/null ; \
    rabbitmqctl set_permissions -p ofborg node-exporter ".*" ".*" ".*" 2>/dev/null ; \
    echo "*** Log in the WebUI at port 15672 (example: http://localhost:15672) ***"
    ) || :
  '';

  ## prometheus-rabbitmq-exporter
  # Optional, if you want to test something related to the rabbitmq metrics.
  systemd.services."prometheus-rabbitmq-exporter".serviceConfig.ExecStart =
    "${pkgs.prometheus-rabbitmq-exporter}/bin/rabbitmq_exporter";
  systemd.services."prometheus-rabbitmq-exporter".wantedBy = [ "multi-user.target" ];
  systemd.services."prometheus-rabbitmq-exporter".serviceConfig.DynamicUser = "yes";
  systemd.services."prometheus-rabbitmq-exporter".environment.PUBLISH_PORT = "9419";
  systemd.services."prometheus-rabbitmq-exporter".environment.RABBIT_CAPABILITIE = "bert,no_sort";
  systemd.services."prometheus-rabbitmq-exporter".environment.RABBIT_EXPORTERS =
    "connections,exchange,node,queue";
  systemd.services."prometheus-rabbitmq-exporter".environment.RABBIT_USER = "node-exporter";
  # Password of node-exporter user with monitoring permissions
  systemd.services."prometheus-rabbitmq-exporter".environment.RABBIT_PASSWORD = "password";
  # systemd.services."prometheus-rabbitmq-exporter".environment.RABBIT_PASSWORD_FILE =
  #   "/run/keys/rabbitmq_exporter";

  ## loki
  services.loki = {
    enable = true;
    configFile = ./loki.yml;
  };

  ## promtail
  # Optional, forward logging to loki.
  systemd.services."promtail".after = [ "loki.service" ];
  systemd.services."promtail".wantedBy = [ "multi-user.target" ];
  systemd.services."promtail".serviceConfig.ExecStart =
    "${pkgs.grafana-loki}/bin/promtail -config.file ${./promtail.yml}";

  containers.ofborg = {
    autoStart = true;

    config =
      let
        mkBorgSvc = bin: {
          name = "ofborg-${toString bin}";
          value = {
            wantedBy = [ "multi-user.target" ];
            path = [ pkgs.git pkgs.nix ];
            environment.GIT_AUTHOR_NAME = "Ofborg";
            environment.GIT_AUTHOR_EMAIL = "ofborg@nixos.org";
            environment.RUST_LOG = "debug,async_std=error";
            environment.RUST_LOG_JSON = "1";
            # Place config.json in /var/lib/containers/ofborg/home/ofborg/config.json.
            serviceConfig.ExecStart = "${ofborg.ofborg.rs}/bin/${bin} /home/ofborg/config.json";
            serviceConfig.User = "ofborg";
            serviceConfig.Group = "ofborg";
          };
        };
      in
      { config, pkgs, ... }:
      {
        systemd.services = builtins.listToAttrs (
          map
            (bin: mkBorgSvc bin)
            [
              "builder"
              "evaluation-filter"
              "mass-rebuilder"
            ]
        );

        users.mutableUsers = false;
        users.groups.ofborg = { gid = 542; };
        users.users.ofborg = {
          createHome = true;
          home = "/home/ofborg";
          shell = pkgs.bash;
          uid = 542;
          group = "ofborg";
          password = "ofborg";
        };

        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDD4tjx4CFZ6X1ap4oNB9oI/UVPO8cbJ/ypsbsVQN6x/LwFtHjzdtQiL3pTPyfAFI50bEI09/r0arar5D2eY6Ll+G24jJqY6yQ0qaVNVo77OTsyBaRf8fv+i6sGM0OWHTtIIND9lmb2cuTyEK3ar5pPyHXpLSSyRQSZ3z6/jU5PujjsC9RgFYk9afOqOm/7i6V+dNRC7j2j92c85yERdb9XSpgQYyKtrYi+AmohvaL4NKg2DjXQNTGPrmAPF/Ow5OY+PiBEewiTJ41if3KGZY+eVL48RWmrR5CzykGuhdoTMX1/0kFsRNdsFXhC4KNh/xrhFqkRT5l4udBGeLaH/mlW9TRO/sp8eif64cuS1N1zg5/PSzUM45mmG2OaxKRIEevQBoyCshZt+mc3oSEfdyg0G1mrMmlxmdcq/x+aE3N4nn/bjWcVNByjpXgEPAhV+cPWJM3XZASXcoEEA9Fp7I218zwKnFxNdORoLs9NlE75ScQs5KJz9e0bDlaQZ+VTgOpwGGUalF9GyMNCX7Fpqb7CGEJMJfxFNrFPx9EYaHqxDtxa0wfumWmedLhzfjmyrBA2B+8eaOEChAcGIeqVbZE0u+sY1iibdV7mzcRLfX4WhkFWff4KKjCTFVvJKcd/q5kx7cLTiFcwK4GSRPU6Qfu9N0p+0F/kMBVERO+6VLLQgw== openpgp:0x69277DD3"
        ];
      };

    bindMounts = {
      "sonarr" = {
        mountPoint = "/home/ofborg/nixpkgs";
        hostPath = "/home/vin/.nix-test-rs";
        isReadOnly = false;
      };
    };
  };
}
