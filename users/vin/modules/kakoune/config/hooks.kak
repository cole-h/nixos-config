# Hooks
hook global BufCreate .* update-todo

hook global WinSetOption filetype=(rust) %{ # TODO: |c|cpp)
  lsp-enable-window
  set-option -add buffer powerline_format ' lsp'
}

hook -once global BufCreate ^\*scratch.*\* %{
  edit "%val{config}/kakrc"
}

hook global WinCreate ^[^*]+$ %{
  add-highlighter window/number-lines number-lines -relative -hlcursor -separator " "
  add-highlighter window/show-matching show-matching
}

hook -once global KakBegin .* %{
  evaluate-commands %sh{
    [[ -n "$SWAYSOCK" && -n "$WAYLAND_DISPLAY" ]] && echo 'provide-module wayland %{}; require-module wayland'
  }
}

hook global ModuleLoaded wayland %{
  try %{ set-option global shell_expansion_trim_newlines false }

  define-command -override -hidden paste -docstring 'paste from wl-clipboard' %{
    reg '"' %sh{ wl-paste -n }
  }

  map global normal p ': paste; execute-keys p<ret>'
  map global normal P ': paste; execute-keys P<ret>'
  map global normal R ': paste; execute-keys R<ret>'

  hook -always global RegisterModified '"' %{
   nop %sh{
      printf %s "$kak_main_reg_dquote" | wl-copy >/dev/null 2>&1 &
    }
  }
}

hook global WinSetOption filetype=.* %{
  evaluate-commands %sh{
    formatter=""

    case "$kak_opt_filetype" in
      rust) formatter="rustfmt --edition=2018" ;;
      nix) formatter="nixpkgs-fmt" ;;
    esac

    [ -n "$formatter" ] && printf %s "set-option window formatcmd '$formatter'"
  }

  hook buffer BufWritePre .* %{
    evaluate-commands %sh{
      if [ -n "$kak_opt_formatcmd" ] && [ -x "$(command -v "$kak_opt_formatcmd")" ]; then
        printf %s format
      fi
    }
  }

  hook -once -always window WinSetOption filetype=.* %{
    unset-option window formatcmd
  }
}
