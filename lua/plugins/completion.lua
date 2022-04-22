return function(use)
    use 'dcampos/nvim-snippy'

    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-cmdline'
    use 'dcampos/cmp-snippy'
    use 'onsails/lspkind-nvim'

    use {
        'hrsh7th/nvim-cmp',
        config = function()
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

            local capabilities = require('cmp_nvim_lsp').update_capabilities(
                                     vim.lsp.protocol.make_client_capabilities())
            require('plugins/lsp').capabilities = capabilities
        end
    }

end
