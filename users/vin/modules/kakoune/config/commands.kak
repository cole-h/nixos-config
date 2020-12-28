# Commands
define-command -override -docstring 'evaluate selection' do %{ eval %val{selection} }

# https://github.com/shachaf/kak/blob/5169106ca617a624aa7a36375470835ee0b83774/kakrc#L263
define-command -override -docstring 'goto line begin if not count' zero %{
  eval %sh{
    [ "$kak_count" = 0 ] && echo "exec gh" || echo "exec '${kak_count}0'"
  }
}

define-command -override -docstring 'update todo highlighter' update-todo %{
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