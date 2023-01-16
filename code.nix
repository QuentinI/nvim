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
    plugin = (nvim-treesitter.withPlugins (
      plugins: with plugins; [
        bash
        c
        comment
        json
        json5
        lua
        nix
        python
        regex
        rust
        toml
        vim
        yaml
      ]
    ));
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
      local checkOptions = {
        -- wastes some disk space in exchange for not
        -- locking you from using cargo while check is running
        extraArgs = { "--target-dir", "target/check" }
      }

      require('rust-tools').setup({
        server = {
          on_attach = LSPCommon.on_attach,
          capabilities = LSPCommon.capabilities,
          standalone = false,
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = checkOptions,
              diagnostics = {
                disabled = { "inactive-code" }
              }
            }
          }
        }
      })
    '';
  }
  {
    plugin = crates-nvim;
    config = lua ''
      require('crates').setup({})
      vim.api.nvim_create_autocmd("BufRead", {
          group = vim.api.nvim_create_augroup("CmpSourceCargo", { clear = true }),
          pattern = "Cargo.toml",
          callback = function()
              require('cmp').setup.buffer({ sources = { { name = "crates" } } })
          end,
      })
    '';
  }
  {
    plugin = lsp_lines-nvim;
    config = lua ''
      require("lsp_lines").setup()

      -- Don't show virtual lines by default
      vim.diagnostic.config({
        virtual_lines = false,
        virtual_text = true 
      })

      -- Toggle
      LSPCommon.toggle_diagnostics = function()
        local lines = not vim.diagnostic.config().virtual_lines
        local text = not vim.diagnostic.config().virtual_text
        vim.diagnostic.config({ virtual_lines = lines, virtual_text = text })
      end
      LSPCommon.commands.diagnostics = {
          keys = '<leader>e',
          cmd = '<cmd>lua LSPCommon.toggle_diagnostics()<cr>'
      }
    '';
  }
  # Autocompletion
  # https://github.com/hrsh7th/nvim-cmp
  nvim-snippy
  cmp-buffer
  cmp-path
  cmp-nvim-lsp
  cmp-cmdline
  cmp-snippy
  lspkind-nvim
  {
    plugin = nvim-cmp;
    config = lua ''
      local has_words_before = function()
          local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and
              vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(
                  col, col):match('%s') == nil
      end

      local cmp = require 'cmp'
      local snippy = require 'snippy'
      local lspkind = require 'lspkind'

      cmp.setup({
          snippet = {
              expand = function(args)
                  require('snippy').expand_snippet(args.body) -- For `snippy` users.
              end
          },
          window = {
              completion = cmp.config.window.bordered(),
              documentation = cmp.config.window.bordered()
          },
          mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
              ['<Tab>'] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                      cmp.select_next_item()
                  elseif snippy.can_expand_or_advance() then
                      snippy.expand_or_advance()
                  elseif has_words_before() then
                      cmp.complete()
                  else
                      fallback()
                  end
              end, { 'i', 's' }),
              ['<S-Tab>'] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                      cmp.select_prev_item()
                  elseif snippy.can_jump(-1) then
                      snippy.previous()
                  else
                      fallback()
                  end
              end, { 'i', 's' })
          }),
          sources = cmp.config.sources({
              { name = 'nvim_lsp' }, { name = 'snippy' }
          }, { { name = 'buffer' } }),
          formatting = {
              format = lspkind.cmp_format({
                  mode = 'symbol_text',
                  menu = ({
                      buffer = '[Buffer]',
                      nvim_lsp = '[LSP]',
                      luasnip = '[LuaSnip]',
                      nvim_lua = '[Lua]',
                      latex_symbols = '[Latex]'
                  })
              })
          }
      })

      cmp.setup.cmdline('/', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = { { name = 'buffer' } }
      })

      cmp.setup.cmdline(':', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({ { name = 'path' } },
              { { name = 'cmdline' } })
      })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      LSPCommon.capabilities = capabilities
    '';
  }
]
