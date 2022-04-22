LSPCommon = {
    commands = {
        code_action = {
            keys = '<leader>ca',
            cmd = '<cmd>lua vim.lsp.buf.code_action()<CR>'
        },
        declaration = { keys = 'gd', cmd = '<cmd>lua lsp.buf.declaration()<CR>' },
        definition = { keys = 'gD', cmd = '<cmd>lua lsp.buf.definition()<CR>' },
        references = { keys = 'gr', cmd = '<cmd>lua lsp.buf.references()<CR>' },
        implementation = {
            keys = 'gi',
            cmd = '<cmd>lua lsp.buf.implementation()<CR>'
        },
        hover = { keys = 'K', cmd = '<cmd>lua vim.lsp.buf.hover()<CR>' },
        signature = {
            keys = '<C-k>',
            cmd = '<cmd>lua vim.lsp.buf.signature_help()<CR>'
        },
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
    end,

    setup = function(use)
        use({
            'neovim/nvim-lspconfig',
            config = function()
                local lspconfig = require('lspconfig')

                lspconfig['sumneko_lua'].setup({
                    on_attach = LSPCommon.on_attach,
                    capabilities = LSPCommon.capabilities,
                    settings = { Lua = { diagnostics = { globals = { 'vim' } } } }
                })
            end
        })

        use({
            'j-hui/fidget.nvim',
            config = function() require('fidget').setup({}) end
        })

        use({
            'simrat39/rust-tools.nvim',
            config = function()
                require('rust-tools').setup({
                    server = {
                        on_attach = LSPCommon.on_attach,
                        capabilities = LSPCommon.capabilities
                    }
                })
            end
        })

        use({
            'folke/trouble.nvim',
            requires = 'kyazdani42/nvim-web-devicons',
            config = function()
                require('trouble').setup({})
                vim.api.nvim_set_keymap('n', '<leader>ce',
                                        '<cmd>TroubleToggle workspace_diagnostics<cr>',
                                        { silent = true, noremap = true })
                vim.api.nvim_set_keymap('n', '<leader>cE',
                                        '<cmd>TroubleToggle document_diagnostics<cr>',
                                        { silent = true, noremap = true })
            end
        })

        use({
            'jose-elias-alvarez/null-ls.nvim',
            config = function()
                local null_ls = require('null-ls')

                null_ls.setup({
                    sources = {
                        null_ls.builtins.formatting.lua_format.with {
                            extra_args = {
                                '--no-use-tab',
                                '--double-quote-to-single-quote',
                                '--spaces-inside-table-braces'
                            }
                        }
                    }
                })
            end
        })

        use({
            'weilbith/nvim-code-action-menu',
            config = function()
                vim.g.code_action_menu_show_details = false
                LSPCommon.commands.code_action.cmd = '<cmd>CodeActionMenu<CR>'
            end
        })

        use({
            'simrat39/symbols-outline.nvim',
            config = function()
                LSPCommon.commands.outline = {
                    keys = '<leader>cs',
                    cmd = '<cmd>SymbolsOutline<CR>'
                }
            end
        })

        use {
            'lukas-reineke/lsp-format.nvim',
            config = function()
                LSPCommon.hooks.format = require('lsp-format').on_attach
            end
        }
    end
}

return LSPCommon
