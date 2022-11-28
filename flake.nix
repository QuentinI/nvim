{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { flake-utils, nixpkgs, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        utils = rec {
          vimscript = conf: conf;
          lua = conf: ''
            lua << EOF
            ${conf}
            EOF
          '';
          genericConfig = name: lua ''
            require('${name}').setup({})
          '';
        };
        commonRc = utils.vimscript ''
          let mapleader = " "
          " use system clipboard
          set clipboard=unnamedplus 
          " don't fold everything authomatically
          set nofoldenable
          " show line numbers in gutter,
          " relative to cursor
          set number
          set relativenumber
          " highlight current line number
          set cursorline
          set cursorlineopt=number
          " don't beep
          set visualbell
          " show invisibles which shouldn't be there
          set list
          set listchars=tab:▸\ ,trail:·,nbsp:⍽
          " Global statusline
          set laststatus=3
          " No tabs. Ever.
          set autoindent
          set expandtab
          set tabstop=4
          set softtabstop=4
          set shiftwidth=4
        '';
        mkNeovim = pkgs:
          let
            plugins = builtins.concatLists (
              map
                (file: import file {
                  inherit utils pkgs;
                  plugins = pkgs.vimPlugins;
                })
                [ ./ui.nix ./navigation.nix ./code.nix ]
            );
            generatedConfig = pkgs.neovimUtils.makeNeovimConfig {
              plugins = plugins;
              extraName = "-q_ink";
            };
            config = generatedConfig // {
              neovimRcContent = commonRc + generatedConfig.neovimRcContent;
            };
          in
          pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped config;
      in
      {
        defaultPackage = mkNeovim (import nixpkgs { inherit system; });
        overlay = _: prev: {
          neovim = mkNeovim prev;
        };
      });
}
