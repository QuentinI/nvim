{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { flake-utils, nixpkgs, ... }@inputs:
    flake-utils.lib.eachSystem [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # Theme bases
        bases = [ "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F" ];
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
          baseToLua = theme: base:
            let
              basename = "base0${base}";
              basevalue = builtins.getAttr basename theme;
            in
            "${basename} = '#${basevalue.hex.rgb}'";
          themeToLua = theme: "{" + builtins.concatStringsSep ", " (map (baseToLua theme) bases) + "}";
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
          " trigger `autoread` when files changes on disk
          set autoread
          autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
          " GUI-specific
          if exists("g:neovide")
          endif
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
          , theme ? null
          ,
          }:
          let
            # Assemble list of plugins
            plugins = builtins.concatLists (
              map
                (file: import file {
                  inherit utils pkgs theme;
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
                pkgs.haskellPackages.tidal
                pkgs.haskellPackages.ghci
                pkgs.nil
                pkgs.rust-analyzer
                pkgs.lua-language-server
              ] ++ runtime;
          };

        packages.default = mkNeovim { inherit pkgs; };
        devShells.default = pkgs.mkShell {
          buildInputs = [ packages.default ];
        };
        overlays.default = _: prev: {
          neovim = mkNeovim { pkgs = prev; };
          inherit mkNeovim;
        };
      });
}

