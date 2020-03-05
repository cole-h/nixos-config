final: super:
with super;

let
  pythonSupport = true;
  perlSupport = false;
  tclSupport = false;
  rubySupport = false;
  guileSupport = false;
  luaSupport = false;
in {
  weechat-unwrapped = weechat-unwrapped.override {
    inherit pythonSupport perlSupport tclSupport rubySupport guileSupport
      luaSupport;
  };

  weechat = weechat.override {
    configure = { availablePlugins, ... }: {
      plugins = with availablePlugins;
        with lib;
        [ ] ++ optional pythonSupport python ++ optional perlSupport perl
        ++ optional tclSupport tcl ++ optional rubySupport ruby
        ++ optional guileSupport guile ++ optional luaSupport lua;
    };
  };
}
