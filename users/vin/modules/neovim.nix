{ config, lib, pkgs, ... }:
let
  lsp_extensions = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "lsp_extensions.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "tjdevries";
      repo = "lsp_extensions.nvim";
      rev = "7c3f907c3cf94d5797dcdaf5a72c5364a91e6bd2";
      sha256 = "sha256-337MdE4Rc/4f8dxv+2lzSQ9zWQ7eivK/LBUJC0GnLzE=";
    };
  };
in
{
  home.file."${config.xdg.configHome}/nvim/parser/rust.so".source = "${pkgs.tree-sitter.builtGrammars.rust}/parser";

  programs.neovim = {
    enable = true;

    withPython = false;
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
      nvim-lspconfig
      lsp_extensions
      completion-nvim
      diagnostic-nvim
      direnv-vim
      fzf-vim
      nvim-treesitter
      neoformat

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
      nnoremap <silent> <leader><tab>1 :buffer 1<cr>
      nnoremap <silent> <leader><tab>2 :buffer 2<cr>
      nnoremap <silent> <leader><tab>3 :buffer 3<cr>
      nnoremap <silent> <leader><tab>4 :buffer 4<cr>
      nnoremap <silent> <leader><tab>5 :buffer 5<cr>
      nnoremap <silent> <leader><tab>6 :buffer 6<cr>
      nnoremap <silent> <leader><tab>7 :buffer 7<cr>
      nnoremap <silent> <leader><tab>8 :buffer 8<cr>
      nnoremap <silent> <leader><tab>9 :buffer 9<cr>
      nnoremap <silent> <leader><tab>0 :buffer 0<cr>

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

      augroup fmt
        autocmd!
        autocmd BufWritePre * undojoin | Neoformat
      augroup END
    '' +
    # LSP config -- busted
    (lib.optionalString false ''
      " Set completeopt to have a better completion experience
      set completeopt=menuone,noinsert,noselect

      " Avoid showing extra messages when using completion
      set shortmess+=c


      " Configure lsp
      " https://github.com/neovim/nvim-lspconfig#rust_analyzer
      lua <<EOF
      vim.cmd('packadd nvim-lspconfig')

      -- nvim_lsp object
      local nvim_lsp = require'lspconfig'

      -- function to attach completion and diagnostics
      -- when setting up lsp
      local on_attach = function(client)
          require'completion'.on_attach(client)
          require'diagnostic'.on_attach(client)
      end

      nvim_lsp.rust_analyzer.setup({ on_attach=on_attach })

      EOF

      " Code navigation shortcuts
      nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
      nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
      nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
      nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
      nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
      nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
      nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
      nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
      nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>

      " Trigger completion with <tab>
      " found in :help completion
      function! s:check_back_space() abort
          let col = col('.') - 1
          return !col || getline('.')[col - 1]  =~ '\s'
      endfunction

      inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ completion#trigger_completion()

      " Visualize diagnostics
      let g:diagnostic_enable_virtual_text = 1
      let g:diagnostic_trimmed_virtual_text = '40'
      " Don't show diagnostics while in insert mode
      let g:diagnostic_insert_delay = 1

      " have a fixed column for the diagnostics to appear in
      " this removes the jitter when warnings/errors flow in
      set signcolumn=yes

      " Set updatetime for CursorHold
      " 300ms of no cursor movement to trigger CursorHold
      set updatetime=300
      " Show diagnostic popup on cursor hover
      autocmd CursorHold * lua vim.lsp.util.show_line_diagnostics()

      " Goto previous/next diagnostic warning/error
      nnoremap <silent> g[ <cmd>PrevDiagnosticCycle<cr>
      nnoremap <silent> g] <cmd>NextDiagnosticCycle<cr>

      " Enable type inlay hints
      autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *
      \ lua require'lsp_extensions'.inlay_hints{ prefix = ''', highlight = "Comment" }
    '');
  };
}
