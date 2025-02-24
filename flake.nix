{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
    ]
      (system:
        let
          nord-theme = {
            base00.hex.rgb = "2E3440";
            base01.hex.rgb = "3B4252";
            base02.hex.rgb = "434C5E";
            base03.hex.rgb = "4C566A";
            base04.hex.rgb = "D8DEE9";
            base05.hex.rgb = "E5E9F0";
            base06.hex.rgb = "ECEFF4";
            base07.hex.rgb = "8FBCBB";
            base08.hex.rgb = "BF616A";
            base09.hex.rgb = "D08770";
            base0A.hex.rgb = "EBCB8B";
            base0B.hex.rgb = "A3BE8C";
            base0C.hex.rgb = "88C0D0";
            base0D.hex.rgb = "81A1C1";
            base0E.hex.rgb = "B48EAD";
            base0F.hex.rgb = "5E81AC";
          };
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
            icons = {
              git = {
                added = "✚";
                modified = "✹";
                deleted = "✖";
              };
              diagnostics = {
                error = " ";
                warn = " ";
                info = " ";
                hint = "󰅏";
              };
            };
          };
          # Settings not related to particular plugins
          commonRc = utils.lua ''
            dofile("${./utils.lua}")
          '' + utils.vimscript ''
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
            , theme ? nord-theme
            ,
            }:
            let
              # Assemble list of plugins
              plugins = builtins.concatLists (
                map
                  (file: import file {
                    inherit utils pkgs theme inputs system;
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
                pkgs.nodejs_20
              ] ++ pkgs.lib.optionals withLanguageServers
                [
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

