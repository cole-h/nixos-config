{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      # Actual plugins
      vim-fugitive
      ctrlp-vim
      vim-surround
      vim-repeat
      editorconfig-vim
      traces-vim
      vim-commentary
      vim-sensible
      indentLine
      # Syntax highlighting
      vim-fish
      vim-markdown
      vim-toml
      rust-vim
      vim-nix
    ];

    extraConfig = ''
      filetype plugin indent on
      set laststatus=2
      set t_Co=256
      let t_ut=""

      let g:vim_markdown_folding_disabled=1
      let g:vim_markdown_frontmatter=1

      set encoding=utf-8
      set tabstop=8
      set softtabstop=0
      set expandtab
      set shiftwidth=4
      set smarttab
      set autoindent
      set magic " unbreak vim's regex implementation

      set number
      set scrolloff=3
      set sidescroll=3
      set cursorline
      " set noesckeys

      set ruler
      set cc=80
      set nowrap

      set ignorecase
      set smartcase

      set splitbelow
      set hidden
      set notimeout

      " Search as you type, highlight results
      set incsearch
      set showmatch
      set hlsearch

      " Resize windows and move tabs and such with the mouse
      set mouse=a

      " Don't litter swp files everywhere
      set backupdir=~/.cache
      set directory=~/.cache

      set clipboard=unnamed,unnamedplus

      set foldmethod=marker
      set foldmarker={{{,}}}

      set nofoldenable
      set lazyredraw

      set tags=./tags;

      set printheader=\

      syntax on
      let mapleader = "\<space>"
      nnoremap \\ :noh<cr> " Clear higlighting
      nnoremap <silent> <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR> " Trim trailing spaces
      nnoremap Y y$
      " nnoremap cc :center<cr>
      inoremap <C-c> <ESC>
      " Ex mode is fucking dumb
      nnoremap Q <Nop>

      command Jp e ++enc=euc-jp

      " Preferences for various file formats
      autocmd FileType c setlocal noet ts=4 sw=4 tw=80
      autocmd FileType h setlocal noet ts=4 sw=4 tw=80
      autocmd FileType cpp setlocal noet ts=4 sw=4 tw=80
      autocmd FileType s setlocal noet ts=4 sw=4
      autocmd FileType go setlocal noet ts=4 sw=4
      autocmd FileType hy setlocal filetype=lisp
      autocmd FileType sh setlocal noet ts=4 sw=4
      autocmd BufRead,BufNewFile *.js setlocal et ts=2 sw=2
      autocmd FileType html setlocal et ts=2 sw=2
      autocmd FileType htmldjango setlocal et ts=2 sw=2
      autocmd FileType ruby setlocal et ts=2 sw=2
      autocmd FileType scss setlocal et ts=2 sw=2
      autocmd FileType yaml setlocal et ts=2 sw=2
      autocmd FileType markdown setlocal tw=80 et ts=2 sw=2
      autocmd FileType text setlocal tw=80
      autocmd FileType meson setlocal noet ts=2 sw=2
      autocmd FileType bzl setlocal et ts=2 sw=2
      autocmd FileType typescript setlocal et ts=2 sw=2
      autocmd FileType python setlocal et ts=4 sw=4
      autocmd BufNewFile,BufRead *.ms set syntax=python ts=4 sw=4 noet
      autocmd BufNewFile,BufRead *.scd set ts=4 sw=4 noet
      autocmd FileType tex hi Error ctermbg=NONE
      autocmd FileType mail setlocal noautoindent
      augroup filetypedetect
        autocmd BufRead,BufNewFile *mutt-*              setfiletype mail
      augroup filetypedetect
        autocmd BufRead,BufNewFile *qutebrowser-editor-* set ts=4 sw=4 et
      autocmd BufNewFile,BufRead * if expand('%:t') == 'APKBUILD' | set ft=sh | endif
      autocmd BufNewFile,BufRead * if expand('%:t') == 'PKGBUILD' | set ft=sh | endif

      set guioptions-=m
      set guioptions-=T
      set guioptions-=r
      set guioptions-=e

      nmap <leader>l :set list!<CR>
      set listchars=tab:▸\ ,eol:¬,space:.

      syntax enable
      colorscheme ron
      highlight Search ctermbg=12
      highlight NonText ctermfg=darkgrey
      highlight SpecialKey ctermfg=darkgrey
      highlight clear SignColumn
      highlight CursorLineNr ctermfg=13
      highlight clear CursorLine
      highlight Comment cterm=italic ctermfg=darkgrey
      highlight StatusLine cterm=none ctermbg=none ctermfg=darkgrey
      highlight StatusLineNC cterm=none ctermbg=none ctermfg=darkgrey
      highlight Title cterm=none ctermfg=darkgrey
      highlight TabLineFill cterm=none
      highlight TabLine cterm=none ctermfg=darkgrey ctermbg=none
      highlight ColorColumn ctermbg=darkgrey guibg=lightgrey
      highlight jsParensError ctermbg=NONE

      " Transparent editing of gpg encrypted files.
      " By Wouter Hanegraaff
      " augroup encrypted
      "   au!
      "   autocmd BufReadPre,FileReadPre *.gpg set viminfo=
      "   autocmd BufReadPre,FileReadPre *.gpg set noswapfile noundofile nobackup
      "   autocmd BufReadPre,FileReadPre *.gpg set bin
      "   autocmd BufReadPre,FileReadPre *.gpg let ch_save = &ch|set ch=2
      "   autocmd BufReadPost,FileReadPost *.gpg '[,']!gpg --decrypt --default-recipient-self 2> /dev/null
      "   autocmd BufReadPost,FileReadPost *.gpg set nobin
      "   autocmd BufReadPost,FileReadPost *.gpg let &ch = ch_save|unlet ch_save
      "   autocmd BufReadPost,FileReadPost *.gpg execute ":doautocmd BufReadPost " . expand("%:r")
      "   autocmd BufWritePre,FileWritePre *.gpg '[,']!gpg --encrypt --default-recipient-self 2>/dev/null
      "   autocmd BufWritePost,FileWritePost *.gpg u
      " augroup END
      augroup encrypted
        au!
        autocmd BufReadPre,FileReadPre *.gpg
          \ setlocal noswapfile noundofile nobackup bin
        autocmd BufReadPre,FileReadPre *.gpg
          \ setlocal viminfo=
        autocmd BufReadPost,FileReadPost *.gpg
          \ execute "'[,']!gpg --decrypt --default-recipient-self 2>/dev/null" |
          \ setlocal nobin |
          \ execute "doautocmd BufReadPost " . expand("%:r") |
          \ setlocal nomodifiable ro
        autocmd BufWritePre,FileWritePre *.gpg
          \ setlocal bin |
          \ '[,']!gpg --encrypt --default-recipient-self 2>/dev/null
        autocmd BufWritePost,FileWritePost *.gpg
          \ silent u |
          \ setlocal nobin
      augroup END

      " Persist cursor position between sessions
      augroup vimrc-remember-cursor-position
        autocmd!
        autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$")
              \| exe "normal! g`\""
              \| endif
      augroup END
    '';
  };
}
