-- Autobootstrap
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system({
        'git', 'clone', '--depth', '1',
        'https://github.com/wbthomason/packer.nvim', install_path
    })
end

-- Autocompile
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup { ensure_installed = 'all' }
            vim.opt.foldmethod = 'expr'
            vim.cmd [[set foldexpr=nvim_treesitter#foldexpr()]]
        end
    }

    use {
        'ahmedkhalf/project.nvim',
        config = function() require('project_nvim').setup {} end
    }

    use {
        'rcarriga/nvim-notify',
        config = function() require('notify').setup {} end
    }

    use {
        'shaunsingh/nord.nvim',
        config = function()
            vim.g.nord_borders = true
            vim.cmd [[colorscheme nord]]
        end
    }

    use {
        'sunjon/shade.nvim',
        config = function()
            require'shade'.setup({ overlay_opacity = 70, opacity_step = 1 })
        end
    }

    use {
        'lewis6991/gitsigns.nvim',
        config = function() require('gitsigns').setup() end
    }

    use {
        'feline-nvim/feline.nvim',
        config = function() require('feline').setup {} end
    }

    use {
        'chentau/marks.nvim',
        config = function() require('marks').setup {} end
    }

    use { 'jghauser/mkdir.nvim' }

    use {
        'nvim-telescope/telescope.nvim',
        requires = { { 'nvim-lua/plenary.nvim' } },
        config = function()
            vim.cmd [[nnoremap <leader>ff <cmd>Telescope find_files<cr>]]
            vim.cmd [[nnoremap <leader>fg <cmd>Telescope live_grep<cr>]]
            vim.cmd [[nnoremap <leader><leader> <cmd>Telescope buffers<cr>]]
            vim.cmd [[nnoremap <leader>sr <cmd>Telescope reloader<cr>]]
        end
    }

    use { 'stevearc/dressing.nvim' }

    use({
        'olimorris/persisted.nvim',
        config = function()
            require('persisted').setup(
                { autoload = true, use_git_branch = true })
            require('telescope').load_extension('persisted') -- To load the telescope extension
        end
    })

    use {
        'folke/which-key.nvim',
        config = function() require('which-key').setup {} end
    }

    use {
        'bennypowers/nvim-regexplainer',
        requires = { 'nvim-treesitter/nvim-treesitter', 'MunifTanjim/nui.nvim' },
        config = function() require'regexplainer'.setup({ auto = true }) end
    }

    require('plugins/neotree')(use)
    require('plugins/completion')(use)
    require('plugins/lsp').setup(use)

    if PACKER_BOOTSTRAP then require('packer').sync() end
end)
