{
  # TODO: https://github.com/bqv/nixrc, https://github.com/colemickens/nixcfg
  description = "cole-h's NixOS configuration";

  inputs = {
    # Flakes
    # large.url = "github:nixos/nixpkgs/nixos-unstable";
    # master.url = "github:nixos/nixpkgs/master";
    small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # stable.url = "github:nixos/nixpkgs/nixos-20.09";

    nix = { url = "github:nixos/nix"; inputs.nixpkgs.follows = "small"; };
    home = { url = "github:rycee/home-manager"; inputs.nixpkgs.follows = "small"; };
    naersk = { url = "github:nmattia/naersk"; inputs.nixpkgs.follows = "small"; };
    passrs = { url = "github:cole-h/passrs"; inputs.nixpkgs.follows = "small"; };
    # utils = { url = "github:numtide/flake-utils"; inputs.nixpkgs.follows = "large"; };

    # Not flakes
    # TODO: flake-compat does not support file-type inputs
    secrets = { url = "/home/vin/.config/nixpkgs/secrets"; flake = false; };
    alacritty = { url = "github:alacritty/alacritty"; flake = false; };
    # baduk = { url = "github:dustinlacewell/baduk.nix"; flake = false; };
    doom = { url = "github:hlissner/doom-emacs"; flake = false; };
    # mozilla = { url = "github:mozilla/nixpkgs-mozilla"; flake = false; };
    nixus = { url = "github:infinisil/nixus"; flake = false; };
    pgtk = { url = "github:masm11/emacs"; flake = false; };
  };

  outputs = inputs:
    let
      channels = {
        pkgs = inputs.small;
        # modules = inputs.small;
        # lib = inputs.master;
      };
      # inherit (channels.lib) lib;

      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);

      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };

      pkgsFor = pkgs: system:
        import pkgs {
          inherit system config;
          overlays = [
            (import ./overlay.nix {
              inherit (inputs) doom naersk pgtk;

              passrs = inputs.passrs.defaultPackage.${system};
              alacrittySrc = inputs.alacritty;
            })
          ];
        };

      allSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: genAttrs allSystems
        (system: f {
          inherit system;
          pkgs = pkgsFor channels.pkgs system;
        });

      forOneSystem = system: f: f {
        inherit system;
        pkgs = pkgsFor channels.pkgs system;
      };

      mkSystem = system: pkgs: hostname:
        let
          inherit (pkgs.lib) mkOption;
          inherit (pkgs.lib.types) attrsOf submoduleWith;

          home = { config, ... }: {
            # "submodule types have merging semantics" -- bqv
            options.home-manager.users = mkOption {
              type = attrsOf (submoduleWith {
                modules = [ ];
                # Makes specialArgs available to home-manager modules as well
                specialArgs = specialArgs // {
                  super = config; # access NixOS configuration from h-m
                };
              });
            };

            config = {
              home-manager = {
                users = import ./users;
                useGlobalPkgs = true;
                useUserPackages = true;
                verbose = true;
              };
            };
          };

          nix = { config, ... }: {
            config = {
              nix.package = inputs.nix.defaultPackage.${system}.overrideAttrs ({ patches ? [ ], ... }: {
                patches = patches ++ [
                  (channels.pkgs.legacyPackages.x86_64-linux.writeText "log.patch" ''
                    diff --git a/src/libmain/common-args.cc b/src/libmain/common-args.cc
                    index 3411e2d7a..95b1fdb01 100644
                    --- a/src/libmain/common-args.cc
                    +++ b/src/libmain/common-args.cc
                    @@ -49,14 +49,6 @@ MixCommonArgs::MixCommonArgs(const string & programName)
                             }
                         });

                    -    addFlag({
                    -        .longName = "log-format",
                    -        .description = "format of log output; `raw`, `internal-json`, `bar` "
                    -                        "or `bar-with-logs`",
                    -        .labels = {"format"},
                    -        .handler = {[](std::string format) { setLogFormat(format); }},
                    -    });
                    -
                         addFlag({
                             .longName = "max-jobs",
                             .shortName = 'j',
                    diff --git a/src/libmain/loggers.cc b/src/libmain/loggers.cc
                    index 0a7291780..61f71f627 100644
                    --- a/src/libmain/loggers.cc
                    +++ b/src/libmain/loggers.cc
                    @@ -1,27 +1,12 @@
                     #include "loggers.hh"
                     #include "progress-bar.hh"
                     #include "util.hh"
                    +#include "globals.hh"

                     namespace nix {

                    -LogFormat defaultLogFormat = LogFormat::raw;
                    -
                    -LogFormat parseLogFormat(const std::string & logFormatStr) {
                    -    if (logFormatStr == "raw" || getEnv("NIX_GET_COMPLETIONS"))
                    -        return LogFormat::raw;
                    -    else if (logFormatStr == "raw-with-logs")
                    -        return LogFormat::rawWithLogs;
                    -    else if (logFormatStr == "internal-json")
                    -        return LogFormat::internalJson;
                    -    else if (logFormatStr == "bar")
                    -        return LogFormat::bar;
                    -    else if (logFormatStr == "bar-with-logs")
                    -        return LogFormat::barWithLogs;
                    -    throw Error("option 'log-format' has an invalid value '%s'", logFormatStr);
                    -}
                    -
                     Logger * makeDefaultLogger() {
                    -    switch (defaultLogFormat) {
                    +    switch (settings.logFormat) {
                         case LogFormat::raw:
                             return makeSimpleLogger(false);
                         case LogFormat::rawWithLogs:
                    @@ -37,12 +22,8 @@ Logger * makeDefaultLogger() {
                         }
                     }

                    -void setLogFormat(const std::string & logFormatStr) {
                    -    setLogFormat(parseLogFormat(logFormatStr));
                    -}
                    -
                     void setLogFormat(const LogFormat & logFormat) {
                    -    defaultLogFormat = logFormat;
                    +    settings.logFormat = logFormat;
                         createDefaultLogger();
                     }

                    diff --git a/src/libmain/loggers.hh b/src/libmain/loggers.hh
                    index cada03110..405c2321d 100644
                    --- a/src/libmain/loggers.hh
                    +++ b/src/libmain/loggers.hh
                    @@ -4,15 +4,6 @@

                     namespace nix {

                    -enum class LogFormat {
                    -  raw,
                    -  rawWithLogs,
                    -  internalJson,
                    -  bar,
                    -  barWithLogs,
                    -};
                    -
                    -void setLogFormat(const std::string & logFormatStr);
                     void setLogFormat(const LogFormat & logFormat);

                     void createDefaultLogger();
                    diff --git a/src/libstore/globals.cc b/src/libstore/globals.cc
                    index 4a5971c3f..ecaf7f1ce 100644
                    --- a/src/libstore/globals.cc
                    +++ b/src/libstore/globals.cc
                    @@ -2,6 +2,7 @@
                     #include "util.hh"
                     #include "archive.hh"
                     #include "args.hh"
                    +#include "loggers.hh"

                     #include <algorithm>
                     #include <map>
                    @@ -189,6 +190,52 @@ template<> void BaseSetting<SandboxMode>::convertToArg(Args & args, const std::s
                         });
                     }

                    +template<> void BaseSetting<LogFormat>::set(const std::string & str)
                    +{
                    +    if (str == "raw")
                    +        value = LogFormat::raw;
                    +    else if (str == "raw-with-logs")
                    +        value = LogFormat::rawWithLogs;
                    +    else if (str == "internal-json")
                    +        value = LogFormat::internalJson;
                    +    else if (str == "bar")
                    +        value = LogFormat::bar;
                    +    else if (str == "bar-with-logs")
                    +        value = LogFormat::barWithLogs;
                    +    else throw UsageError("option '%s' has an invalid value '%s'", name, str);
                    +
                    +    createDefaultLogger();
                    +}
                    +
                    +template<> std::string BaseSetting<LogFormat>::to_string() const
                    +{
                    +    if (value == LogFormat::raw) return "raw";
                    +    else if (value == LogFormat::rawWithLogs) return "raw-with-logs";
                    +    else if (value == LogFormat::internalJson) return "internal-json";
                    +    else if (value == LogFormat::bar) return "bar";
                    +    else if (value == LogFormat::barWithLogs) return "bar-with-logs";
                    +    else abort();
                    +}
                    +
                    +template<> nlohmann::json BaseSetting<LogFormat>::toJSON()
                    +{
                    +    return AbstractSetting::toJSON();
                    +}
                    +
                    +template<> void BaseSetting<LogFormat>::convertToArg(Args & args, const std::string & category)
                    +{
                    +    args.addFlag({
                    +        .longName = name,
                    +        .description = "format of log output; `raw`, `raw-with-logs`, `internal-json`, `bar`, "
                    +                        "or `bar-with-logs`",
                    +        .category = category,
                    +        .labels = {"format"},
                    +        .handler = {[&](std::string format) {
                    +            settings.logFormat.set(format);
                    +        }}
                    +    });
                    +}
                    +
                     void MaxBuildJobsSetting::set(const std::string & str)
                     {
                         if (str == "auto") value = std::max(1U, std::thread::hardware_concurrency());
                    diff --git a/src/libstore/globals.hh b/src/libstore/globals.hh
                    index 8a2d3ff75..260051749 100644
                    --- a/src/libstore/globals.hh
                    +++ b/src/libstore/globals.hh
                    @@ -865,6 +865,9 @@ public:
                         Setting<Strings> experimentalFeatures{this, {}, "experimental-features",
                             "Experimental Nix features to enable."};

                    +    Setting<LogFormat> logFormat{this, LogFormat::bar, "log-format",
                    +        "Default build output logging format; \"raw\", \"raw-with-logs\", \"internal-json\", \"bar\", or \"bar-with-logs\"."};
                    +
                         bool isExperimentalFeatureEnabled(const std::string & name);

                         void requireExperimentalFeature(const std::string & name);
                    diff --git a/src/libstore/local.mk b/src/libstore/local.mk
                    index d266c8efe..6d5495f99 100644
                    --- a/src/libstore/local.mk
                    +++ b/src/libstore/local.mk
                    @@ -8,6 +8,8 @@ libstore_SOURCES := $(wildcard $(d)/*.cc $(d)/builtins/*.cc)

                     libstore_LIBS = libutil

                    +libstore_ALLOW_UNDEFINED = 1
                    +
                     libstore_LDFLAGS = $(SQLITE3_LIBS) -lbz2 $(LIBCURL_LIBS) $(SODIUM_LIBS) -pthread
                     ifneq ($(OS), FreeBSD)
                      libstore_LDFLAGS += -ldl
                    @@ -32,7 +34,7 @@ ifeq ($(HAVE_SECCOMP), 1)
                     endif

                     libstore_CXXFLAGS += \
                    - -I src/libutil -I src/libstore \
                    + -I src/libmain -I src/libutil -I src/libstore \
                      -DNIX_PREFIX=\"$(prefix)\" \
                      -DNIX_STORE_DIR=\"$(storedir)\" \
                      -DNIX_DATA_DIR=\"$(datadir)\" \
                    diff --git a/src/libutil/types.hh b/src/libutil/types.hh
                    index 3af485fa0..c64440903 100644
                    --- a/src/libutil/types.hh
                    +++ b/src/libutil/types.hh
                    @@ -18,6 +18,14 @@ typedef list<string> Strings;
                     typedef set<string> StringSet;
                     typedef std::map<string, string> StringMap;

                    +enum class LogFormat {
                    +  raw,
                    +  rawWithLogs,
                    +  internalJson,
                    +  bar,
                    +  barWithLogs,
                    +};
                    +
                     /* Paths are just strings. */

                     typedef string Path;
                    diff --git a/src/nix/main.cc b/src/nix/main.cc
                    index e9479f564..428ac8149 100644
                    --- a/src/nix/main.cc
                    +++ b/src/nix/main.cc
                    @@ -173,7 +173,7 @@ void mainWrapped(int argc, char * * argv)
                         settings.verboseBuild = false;
                         evalSettings.pureEval = true;
 
                    -    setLogFormat("bar");
                    +    createDefaultLogger();

                         Finally f([] { logger->stop(); });

                  '')
                ];
              });

              nix.extraOptions = ''
                log-format = bar-with-logs
              '';
            };
          };

          modules = [
            inputs.home.nixosModules.home-manager
            (./hosts + "/${hostname}/configuration.nix")
            home
            nix
          ];

          specialArgs = {
            inherit inputs;

            my = import ./my.nix {
              inherit (pkgs) lib;
              inherit (inputs) secrets;
            };
          };
        in
        channels.pkgs.lib.nixosSystem
          {
            inherit system modules specialArgs;
          } // { inherit specialArgs modules; }; # let Nixus have access to this stuff
    in
    {
      nixosConfigurations = {
        scadrial =
          let
            system = "x86_64-linux";
            pkgs = pkgsFor channels.pkgs system;
          in
          mkSystem system pkgs "scadrial";
      };

      legacyPackages = forAllSystems ({ pkgs, ... }: pkgs);

      # TODO: nixus = system: f: ....
      defaultPackage = {
        x86_64-linux = forOneSystem "x86_64-linux" ({ system, pkgs, ... }:
          import inputs.nixus { deploySystem = system; } ({ ... }: {
            defaults = { name, ... }:
              let
                nixos = inputs.self.nixosConfigurations.${name};
              in
              {
                nixpkgs = pkgs.path;

                configuration = {
                  _module.args = nixos.specialArgs;
                  imports = nixos.modules;
                  nixpkgs = { inherit pkgs; };

                  system.configurationRevision = inputs.self.rev or "dirty";
                  system.nixos.versionSuffix =
                    let
                      inherit (inputs) self;
                      date = builtins.substring 0 8 (self.lastModifiedDate or self.lastModified);
                      rev = self.shortRev or "dirty";
                    in
                    ".${date}.${rev}-cosmere";
                };
              };

            nodes = {
              scadrial = { ... }: {
                host = "root@localhost";
                privilegeEscalationCommand = [ "exec" ];

                configuration = {
                  nix.nixPath = [
                    "pkgs=${inputs.self}/compat"
                    "nixos-config=${inputs.self}/compat/nixos"
                  ];
                };
              };
            };
          }));
      };

      apps = forAllSystems ({ system, ... }: {
        nixus = {
          type = "app";
          program = inputs.self.defaultPackage.${system}.outPath;
        };
      });

      defaultApp = forAllSystems ({ system, ... }: inputs.self.apps.${system}.nixus);
    };

}
