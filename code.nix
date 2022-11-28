# Plugins that deal with actual code part
# of this whole deal. Mostly LSP stuff.
{ plugins, utils, pkgs, ... }:
with plugins;
with utils;
let
  # Extensions to nix queries for treesitter
  # to highlight embedded vimscript
  # and lua in this very config
  nixExt = pkgs.writeTextDir
    "queries/nix/injections.scm"
    ''
      ;extends
      (apply_expression
        function: (_) @_func
        argument: [
          (string_expression (string_fragment) @lua)
          (indented_string_expression (string_fragment) @lua)
        ]
        (#match? @_func "(^|\\.)lua$"))
      (apply_expression
        function: (_) @_func
        argument: [
          (string_expression (string_fragment) @vim)
          (indented_string_expression (string_fragment) @vim)
        ]
        (#match? @_func "(^|\\.)vimscript$"))
    '';
in
[
  # Treesitter. Fancier syntax highlighting,
  # queries on source code used by other plugins.
  # https://github.com/nvim-treesitter/nvim-treesitter
  {
    plugin = nvim-treesitter;
    config = vimscript ''
      set runtimepath+=${nixExt}
      set foldmethod=expr
      set foldexpr=nvim_treesitter#foldexpr()
    '' + lua ''
      require'nvim-treesitter.configs'.setup({
        highlight = {
          enable = true,
        }
      })
    '';
  }
  # Poor man's org-mode.
  # https://github.com/nvim-neorg/neorg
  {
    plugin = neorg;
    config = lua ''
      require('neorg').setup({
        load = {
          ["core.defaults"] = {}
        }
      })
    '';
  }
  # Language servers
  # https://github.com/neovim/nvim-lspconfig
  {
    plugin = nvim-lspconfig;
    config = lua ''
      -- A global for other plugins
      LSPCommon = {
        commands = {
          diagnostic = {
            keys = '<leader>e',
            cmd = '<cmd>lua vim.diagnostic.open_float({border = "single"})<CR>',
          },
          code_action = {
            keys = '<leader>ca',
            cmd = '<cmd>lua vim.lsp.buf.code_action()<CR>'
          },
          declaration = { keys = 'gd', cmd = '<cmd>lua vim.lsp.buf.declaration()<CR>' },
          definition = { keys = 'gD', cmd = '<cmd>lua vim.lsp.buf.definition()<CR>' },
          references = { keys = 'gr', cmd = '<cmd>lua vim.lsp.buf.references()<CR>' },
          implementation = {
            keys = 'gi',
            cmd = '<cmd>lua vim.lsp.buf.implementation()<CR>'
          },
          hover = { keys = 'K', cmd = '<cmd>lua vim.lsp.buf.hover()<CR>' },
          ws_add_folder = {
            keys = '<leader>wa',
            cmd = '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>'
          },
          ws_remove_folder = {
            keys = '<leader>wr',
            cmd = '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>'
          },
          ws_list_folders = {
            keys = '<leader>wl',
            cmd = '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>'
          },
          type_defition = {
            keys = '<leader>D',
            cmd = '<cmd>lua vim.lsp.buf.type_definition()<CR>'
          },
          rename = {
            keys = '<leader>cr',
            cmd = '<cmd>lua vim.lsp.buf.rename()<CR>'
          },
          format = {
            keys = '<leader>cf',
            cmd = '<cmd>lua vim.lsp.buf.formatting()<CR>'
          }
        },

        hooks = {},

        on_attach = function(client, bufnr)
            local buf_set_keymap = vim.api.nvim_buf_set_keymap
            local opts = { noremap = true, silent = true }

            for _, hook in pairs(LSPCommon.hooks) do hook(client, bufnr) end

            for _, bind in pairs(LSPCommon.commands) do
                buf_set_keymap(bufnr, 'n', bind.keys, bind.cmd, opts)
            end
        end
      }

      -- actual setup
      local lspconfig = require('lspconfig')

      lspconfig['sumneko_lua'].setup({
          on_attach = LSPCommon.on_attach,
          capabilities = LSPCommon.capabilities,
          settings = { Lua = { diagnostics = { globals = { 'vim' } } } }
      })

      lspconfig['pylsp'].setup({
          on_attach = LSPCommon.on_attach,
          capabilities = LSPCommon.capabilities,
      })

      lspconfig['rnix'].setup({
          on_attach = LSPCommon.on_attach,
          capabilities = LSPCommon.capabilities,
      })
    '';
  }
  # Show status of LSP server when loading
  # https://github.com/j-hui/fidget.nvim
  {
    plugin = fidget-nvim;
    config = genericConfig "fidget";
  }
  # Show a nice list of diagnostics
  # https://github.com/folke/trouble.nvim
  {
    plugin = trouble-nvim;
    config = lua ''
      require('trouble').setup({})
      LSPCommon.commands.workspace_errors = {
        keys = '<leader>ce',
        cmd = '<cmd>TroubleToggle workspace_diagnostics<cr>',
      }
      LSPCommon.commands.document_errors = {
        keys = '<leader>cE',
        cmd = '<cmd>TroubleToggle document_diagnostics<cr>',
      }
    '';
  }
  # In the same vein, show a list of
  # symbols defined in the document
  # https://github.com/simrat39/symbols-outline.nvim
  {
    plugin = symbols-outline-nvim;
    config = lua ''
      LSPCommon.commands.outline = {
          keys = '<leader>cs',
          cmd = '<cmd>SymbolsOutline<CR>'
      }
    '';
  }
  # Apply code actions easier
  # https://github.com/weilbith/nvim-code-action-menu
  {
    plugin = nvim-code-action-menu;
    config = lua ''
      --vim.g.code_action_menu_show_details = false
      LSPCommon.commands.code_action.cmd = '<cmd>CodeActionMenu<CR>'
    '';
  }
  # Autoformat
  # https://github.com/lukas-reineke/lsp-format.nvim
  {
    plugin = lsp-format-nvim;
    config = lua ''
      LSPCommon.hooks.format = require('lsp-format').on_attach
    '';
  }
  # Improved experience for rust-analyzer
  # https://github.com/simrat39/rust-tools.nvim
  {
    plugin = rust-tools-nvim;
    config = lua ''
      require('rust-tools').setup({
        server = {
          on_attach = LSPCommon.on_attach,
          capabilities = LSPCommon.capabilities,
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = {
                -- wastes some disk space in exchange for not
                -- locking you from using cargo while check is running
                extraArgs = { "--target-dir", "target/check" }
              }
            }
          }
        }
      })
    '';
  }
]
