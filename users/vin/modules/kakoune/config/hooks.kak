# Hooks
## highlight todos and similar notation in comments
hook global BufCreate .* %{
  try %{ remove-highlighter buffer/todo }
  try %{
    add-highlighter buffer/todo group
    add-highlighter buffer/todo/todo dynregex \
      (?S)^.*%opt{comment_line}\h+(TODO:?).*$ 1:yellow+fb
    add-highlighter buffer/todo/fixme dynregex \
      (?S)^.*%opt{comment_line}\h+((?:FIXME|XXX):?).*$ 1:red+fb
    add-highlighter buffer/todo/note dynregex \
      (?S)^.*%opt{comment_line}\h+(NOTE:?).*$ 1:green+fb
  }
}

## show lsp info in lsp buffers
hook global WinSetOption filetype=(rust) %{ # TODO: |c|cpp)
  lsp-enable-window
  set-option -add buffer powerline_format ' lsp'
}

## line numbers in actual buffers only
hook global WinCreate ^[^*]+$ %{
  add-highlighter window/number-lines number-lines -relative -hlcursor -separator " "
  add-highlighter window/show-matching show-matching
}

## wayland
hook -once global KakBegin .* %{
  evaluate-commands %sh{
    [[ -n "$WAYLAND_DISPLAY" ]] && echo 'provide-module wayland %{}; require-module wayland'
  }
}

hook global ModuleLoaded wayland %{
  try %{ set-option global shell_expansion_trim_newlines false }

  define-command -override -hidden paste -docstring 'paste from wl-clipboard' %{
    evaluate-commands %sh{
      source "$kak_opt_prelude_path"

      [ "$kak_main_reg_dquote" != "$(wl-paste -n)" ] && kak_escape reg '"' "$(wl-paste -n)"
    }
  }

  map global normal p ': paste; execute-keys p<ret>'
  map global normal P ': paste; execute-keys P<ret>'
  map global normal R ': paste; execute-keys R<ret>'

  hook -always global RegisterModified '"' %{
   nop %sh{
      printf %s "$kak_main_reg_dquote" | wl-copy >/dev/null 2>&1
    }
  }
}

## set formatter
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

## git gutter
hook global WinCreate .* %{ try %{ git show-diff } }
hook global BufWritePost .* %{ try %{ git update-diff } }

## bufhist list for better alternate buffer functionality
declare-option str-list bufhist

hook global WinDisplay .* %{
  # move the current buffer to the end of the list
  set-option -remove global bufhist %val{hook_param}
  set-option -add global bufhist %val{hook_param}
}

hook global BufClose .* %{
  # This is no longer a valid buffer, remove it from the list
  set-option -remove global bufhist %val{hook_param}
}
