{ config, lib, pkgs, ... }:
{
  programs.neovim = {
    enable = true;

    withPython3 = false;
    withRuby = false;
    withNodeJs = false;

    plugins = with pkgs.vimPlugins; [
      vim-fugitive
      ctrlp-vim
      vim-surround
      vim-repeat
      editorconfig-vim
      traces-vim
      vim-commentary
      vim-sensible
      direnv-vim
      fzf-vim

      # Appearance
      vim-fish
      vim-markdown
      vim-toml
      rust-vim
      vim-nix
      dracula-vim
      lightline-vim
      lightline-bufferline
    ];

    extraConfig = ''
      filetype plugin indent on
      syntax enable

      set laststatus=2
      set t_Co=256
      set termguicolors
      let t_ut=""

      set encoding=utf-8
      set tabstop=8
      set softtabstop=0
      set expandtab
      set shiftwidth=4
      set smarttab
      set autoindent
      " unbreak vim's regex implementation
      set magic

      set number
      set scrolloff=3
      set sidescroll=3
      set cursorline
      set noshowmode
      set conceallevel=2
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

      set printheader=\

      syntax on
      let mapleader = "\<space>"
      " Clear higlighting
      nnoremap <silent> \\ :noh<cr>
      " Trim trailing spaces
      nnoremap <silent> <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>
      nnoremap Y y$
      " nnoremap cc :center<cr>
      inoremap <C-c> <ESC>
      " Ex mode is fucking dumb
      nnoremap Q <Nop>
      " all my homies hate command history
      nnoremap q: <Nop>
      " change the directory only for the current window
      nnoremap <silent> <leader>. :lcd %:p:h<cr>
      nnoremap <silent> <leader><tab><tab> :CtrlPBuffer<cr>

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

      set guioptions-=m
      set guioptions-=T
      set guioptions-=r
      set guioptions-=e

      nmap <leader>l :set list!<CR>
      set listchars=tab:▸\ ,eol:¬,space:.

      augroup encrypted
        autocmd!
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
        autocmd BufReadPost *
          \ if line("'\"") > 1 && line("'\"") <= line("$") |
          \ exe "normal! g`\"" |
          \ endif
      augroup END
    '' +
    # Plugin-related config
    ''
      let g:dracula_colorterm = 0

      augroup dracula
        autocmd!
        autocmd VimEnter * colorscheme dracula
      augroup END

      let g:vim_markdown_folding_disabled=1
      let g:vim_markdown_frontmatter=1

      let g:lightline = {
        \ 'colorscheme': 'dracula'
        \ }
    '';
  };
}
