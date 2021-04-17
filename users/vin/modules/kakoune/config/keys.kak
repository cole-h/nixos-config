# Modes
declare-user-mode grep
declare-user-mode format
declare-user-mode edit

# Aliases
alias global Q quit
alias global W write
# alias global g grep

# TODO:
# https://github.com/lenormf/kakoune-extra/blob/master/readline.kak
# https://github.com/chambln/kakoune-readline

# Mappings
## user
map global user g ': enter-user-mode -lock grep<ret>' -docstring 'grep mode…'
map global user e ': enter-user-mode edit<ret>' -docstring 'edit mode…'
map global user <\> ': enter-user-mode format<ret>' -docstring 'format mode…'

## edit
map global edit r ' :edit "%val{config}/kakrc"<ret>' -docstring 'edit kakrc'
map global edit k ': edit "%val{config}/keys.kak"<ret>' -docstring 'edit keys'
map global edit c ': edit "%val{config}/commands.kak"<ret>' -docstring 'edit commands'
map global edit h ': edit "%val{config}/hooks.kak"<ret>' -docstring 'edit hooks'

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
# map global normal <space> <space><semicolon>
map global normal <percent> <c-s><percent>
map global normal = '|dfmt<ret>' -docstring "wrap selection"
map global normal <c-^> %{: alt-buf<ret>} -docstring "alternate buffer"
# map global normal u ': execute-keys -draft u<ret>' -docstring "undo but don't move cursor"
# map global normal U ': execute-keys -draft U<ret>' -docstring "redo but don't move cursor"
# map global normal <a-x> %{ try %{
#   <a-x>S.<ret><a-K><c-v><ret><ret><a-_>
# } catch %{
#   <a-x>
# }}

## insert
# https://github.com/chambln/kakoune-readline/blob/master/readline.kak
map global insert <c-w> '<a-;><a-/>\S+\s*<ret><a-;>d'
map global insert <a-d> '<a-;>;<a-;>E<a-;>"_d'

## goto
map global goto a %{<esc>: alt-buf<ret>} -docstring 'alternate buffer'
