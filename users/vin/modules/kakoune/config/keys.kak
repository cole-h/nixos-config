# Modes
declare-user-mode grep
declare-user-mode format
declare-user-mode edit

# Aliases
alias global Q quit
alias global W write
alias global g grep

# TODO:
# https://github.com/lenormf/kakoune-extra/blob/master/readline.kak
# https://github.com/chambln/kakoune-readline

# Mappings
## edit
map global edit r ' :edit "%val{config}/kakrc"<ret>' -docstring 'edit kakrc'
map global edit k ': edit "%val{config}/keys.kak"<ret>' -docstring 'edit keys'
map global edit c ': edit "%val{config}/commands.kak"<ret>' -docstring 'edit commands'
map global edit h ': edit "%val{config}/hooks.kak"<ret>' -docstring 'edit hooks'

## user
map global user g ': enter-user-mode -lock grep<ret>' -docstring 'grep mode…'
map global user e ': enter-user-mode edit<ret>' -docstring 'edit mode…'
map global user <\> ': enter-user-mode format<ret>' -docstring 'format mode…'

## grep
map global grep p ': grep-previous-match<ret>' -docstring 'grep-previous-match'
map global grep n ': grep-next-match<ret>' -docstring 'grep-next-match'
map global grep l ': edit -existing *grep*<ret>' -docstring 'show grep results'

## format
map global format <\> ': delete-trailing-whitespace<ret>' -docstring 'delete trailing whitespace'

## normal
map global normal '#' %{: comment<ret>} -docstring 'comment line'
map global normal n nvv
map global normal i ': multi-insert<ret>'
map global normal 0 ': zero<ret>'
map global normal ^ gi
map global normal $ gl
map global normal <space> <space><semicolon>
map global normal <percent> <c-s><percent>
map global normal = '|par -w $kak_opt_autowrap_column<ret>' -docstring 'wrap selection'
# map global normal <c-o> <c-o>vv
# map global normal <tab> <tab>vv # <c-i>

## insert
map global insert <c-w> %{<a-;>: execute-keys -draft bd<ret>}
