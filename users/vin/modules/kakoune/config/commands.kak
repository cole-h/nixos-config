# Commands
define-command -override -docstring 'evaluate selection' do %{ eval %val{selection} }

# https://github.com/shachaf/kak/blob/5169106ca617a624aa7a36375470835ee0b83774/kakrc#L263
define-command -override -docstring 'goto line begin if not count' zero %{
  eval %sh{
    [ "$kak_count" = 0 ] && echo "exec gh" || echo "exec '${kak_count}0'"
  }
}

define-command -override -docstring 'insert multiple times with count' multi-insert %{
  evaluate-commands %sh{
    if [ $kak_count -gt 1 ]; then
      # https://github.com/mawww/kakoune/issues/1106#issuecomment-523776280
      echo 'execute-keys -with-hooks \;i.<esc>hd %val{count} Ph %val{count} HLs.<ret>c'
    else
      echo 'execute-keys -with-hooks i'
    fi
  }
}

# https://discuss.kakoune.com/t/flygrep-like-grepping-in-kakoune/662
define-command -override -docstring 'run grep on every key' flygrep %{
  edit -scratch *grep*
  prompt "flygrep: " -on-change %{
    flygrep-call-grep %val{text}
  } -on-abort %{
    delete-buffer
  } nop
}

define-command -override -hidden flygrep-call-grep -params 1 %{
  evaluate-commands %sh{
    length=$(printf "%s" "$1" | wc -m)
    [ -z "${1##*&*}" ] && text=$(printf "%s\n" "$1" | sed "s/&/&&/g") || text="$1"
    if [ ${length:-0} -gt 2 ]; then
        printf "%s\n" "info"
        printf "%s\n" "evaluate-commands %&grep '$text'&"
    else
        printf "%s\n" "info -title flygrep %{$((3-${length:-0})) more chars}"
    fi
  }
}

define-command -override -hidden lsp-show-hover -params 3 -docstring %{
    lsp-show-hover <anchor> <info> <diagnostics>
    Render hover info.
} %{ evaluate-commands %sh{
    lsp_info=$2
    lsp_diagnostics=$3
    content=$(eval "${kak_opt_lsp_show_hover_format}")
    # remove leading whitespace characters
    content="${content#"${content%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    content="${content%"${content##*[![:space:]]}"}"

    # if there is nothing to display, don't
    [ -z "$content" ] && exit

    if [ $kak_opt_lsp_hover_max_lines -gt 0 ]; then
        content=$(printf %s "$content" | head -n $kak_opt_lsp_hover_max_lines)
    fi

    content=$(printf %s "$content" | sed s/\'/\'\'/g)

    case $kak_opt_lsp_hover_anchor in
        true) printf "info -anchor %%arg{1} '%s'" "$content";;
        *)    printf "info '%s'" "$content";;
    esac
}}

define-command -override delete-trailing-whitespace -docstring 'delete trailing whitespace' %{
  evaluate-commands -save-regs 'a/' -draft %{
    execute-keys -draft '"aZ'
    try %{ execute-keys -draft '%s\h+$<ret><a-d>' }
    execute-keys -draft '"az'
  }
}

define-command -override -params ..1 -file-completion CD -docstring "cd to the current file's directory" %{
  try %{
    evaluate-commands %sh{
      if [ -n "$1" ]; then
        printf %s "cd "$1""
      else
        printf %s "cd $(dirname "$kak_buffile")"
      fi
    }
  }
}

define-command -docstring 'comment-line and fallback to comment-block' comment %{
  try %{execute-keys ': comment-line<ret>'} catch %{execute-keys ': comment-block<ret>'}
}

define-command alt-buf %{
  evaluate-commands %sh{
    source "$kak_opt_prelude_path"

    eval set -- "$kak_quoted_opt_bufhist"
    lastbuf=""
    for bufname; do
      lastbuf="$bufname"
    done

    lastbuf="$(printf %s "$lastbuf" | sed 's/\([*?.]\)/\\&/g')"
    bufs="$(printf %s "$kak_opt_bufhist" | sed "s@$lastbuf@@g" | tr -s ' ')"
    bufs="${bufs%% }"
    bufs="${bufs## }"
    prev="${bufs##* }"

    if [ -z "$prev" ]; then
      kak_escape fail 'No other buffers available.'
    else
      kak_escape buffer "$prev"
    fi
  }
}
