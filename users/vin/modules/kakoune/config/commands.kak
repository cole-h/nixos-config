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

define-command -docstring 'switch to the previous buffer' alt-buf %{
  evaluate-commands %sh{
    source "$kak_opt_prelude_path"

    eval set -- "$kak_quoted_opt_bufhist"

    if [ $# -lt 2 ]; then
      # The history list didn't have enough items in it.
      kak_escape fail "no last buffer"
    else
      # Toss all but the last two items in the list
      shift $(( $# - 2 ))

      # Having dropped all the preceding items,
      # $1 is the previous buffer and $2 is the current buffer
      kak_escape buffer "$1"
    fi
  }
}

declare-option -hidden str modeline_readonly ''
declare-option -hidden str modeline_filetype ''
declare-option -hidden str modeline_position '100%'

define-command -hidden modeline-update %{
  set-option buffer modeline_readonly %sh{
    [ ! "$kak_opt_readonly" = "true" ] \
      && ([ -w "$kak_buffile" ] || [ -z "${kak_buffile##*\**}" ]) \
      && exit

    printf "%s\n" '[RO]'
  }

  set-option buffer modeline_filetype %sh{
    [ -n "$kak_opt_filetype" ] && printf "%s\n" "$kak_opt_filetype "
  }
}

define-command -hidden modeline-update-pos %{
  set-option window modeline_position %sh{
      printf "%s\n" "$(($kak_cursor_line * 100 / $kak_buf_line_count))%"
  }
}

declare-option -hidden str-list buffers_info
declare-option int buffers_total
declare-option int max_list_buffers 42
declare-option str alt_bufname
declare-option str current_bufname

# https://github.com/Delapouite/kakoune-buffers/blob/67959fbad727ba8470fe8cd6361169560f4fb532/buffers.kak#L11-L22
define-command -hidden refresh-buffers-info %{
  set-option global buffers_info
  set-option global buffers_total 0
  # iteration over all buffers (except debug ones)
  evaluate-commands -no-hooks -buffer * %{
    set-option -add global buffers_info "%val{bufname}_%val{modified}"
  }
  evaluate-commands %sh{
    total=$(printf '%s\n' "$kak_opt_buffers_info" | tr ' ' '\n' | wc -l)
    printf "set-option global buffers_total $total"
  }
}

# https://github.com/Delapouite/kakoune-buffers/blob/67959fbad727ba8470fe8cd6361169560f4fb532/buffers.kak#L35-L77
define-command info-buffers -docstring 'populate an info box with a numbered buffers list' %{
  refresh-buffers-info
  evaluate-commands %sh{
    # info title
    printf "info -title '$kak_opt_buffers_total buffers' -- %%^"

    index=0
    eval "set -- $kak_quoted_opt_buffers_info"
    while [ "$1" ]; do
      # limit lists too big
      index=$(($index + 1))
      if [ "$index" -gt "$kak_opt_max_list_buffers" ]; then
        printf '  …'
        break
      fi

      name=${1%_*}
      if [ "$name" = "$kak_bufname" ]; then
        printf '>'
      elif [ "$name" = "$kak_opt_alt_bufname" ]; then
        printf '#'
      else
        printf ' '
      fi

      modified=${1##*_}
      if [ "$modified" = true ]; then
        printf '+ '
      else
        printf '  '
      fi

      if [ "$index" -lt 10 ]; then
        echo "0$index - $name"
      else
        echo "$index - $name"
      fi

      shift
    done
    printf "^\n"
  }
}
