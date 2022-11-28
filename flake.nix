{
  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { flake-utils, nixpkgs, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # Utility functions
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
        # Settings not related to particular plugins
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
      in
      rec {
        # A function to make final derivation
        mkNeovim =
          {
            # nixpkgs to use
            pkgs
          , # should we include language servers in final closure?
            # takes up more space, but is more self-sufficient
            withLanguageServers ? true
            # base package to wrap
          , neovim ? pkgs.neovim-unwrapped
            # any extra packages to include in final closure
          , runtime ? [ ]
          }:
          let
            # Assemble list of plugins
            plugins = builtins.concatLists (
              map
                (file: import file {
                  inherit utils pkgs;
                  plugins = pkgs.vimPlugins;
                })
                [ ./ui.nix ./navigation.nix ./code.nix ]
            );
            # Assemble config
            generatedConfig = pkgs.neovimUtils.makeNeovimConfig
              {
                plugins = plugins;
                extraName = "-q_ink";
              } //
            # Add python language server to env
            pkgs.lib.optionalAttrs withLanguageServers {
              extraPython3Packages = (ps: [
                ps.python-lsp-server
              ] ++ ps.python-lsp-server.passthru.optional-dependencies.all);
            };
            # Prepend non-plugin options to generated config,
            # since `beforePlugins` isn't available with 
            # `makeNeovimConfig` for some reason
            config = generatedConfig // {
              neovimRcContent = commonRc + generatedConfig.neovimRcContent;
            };
            # Wrap final package
            package = pkgs.wrapNeovimUnstable neovim config;
          in
          # ... and assemble closure with everything we may want at runtime
          pkgs.symlinkJoin {
            name = "nvim";
            paths = [
              package
            ] ++ pkgs.lib.optionals withLanguageServers
              [
                pkgs.rnix-lsp
                pkgs.rust-analyzer
              ] ++ runtime;
          };

        packages.default = mkNeovim { inherit pkgs; };
        devShells.default = pkgs.mkShell {
          buildInputs = [ packages.default ];
        };
        overlay = _: prev: {
          neovim = mkNeovim { pkgs = prev; };
        };
      });
}
