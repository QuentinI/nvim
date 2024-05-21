# Plugins enchancing or tweaking the UI, nothing major.
# I tried to put the most controversial stuff up top for
# ease of deletion by enraged viewer.
{ plugins, utils, theme, ... }: with plugins; with utils;
[
  # Tabbar. Yes, I want to see tabs.
  # Just like in a _browser_. Fight me.
  # https://github.com/akinsho/bufferline.nvim
  {
    plugin = bufferline-nvim;
    config = vimscript ''
      nnoremap <silent> <C-j> <Cmd>BufferLineCycleNext<CR>
      nnoremap <silent> <C-k> <Cmd>BufferLineCyclePrev<CR>
      nnoremap <silent> <C-c> <Cmd>lua buf_kill(0)<CR>
      nnoremap <silent> <C-p> <Cmd>BufferLinePick<CR>
    '' + lua ''
      --vim.cmd.highlight({ "BufferLineIndicatorSelected", "guibg=#${theme.base00.hex.rgb}", "guifg=#${theme.base00.hex.rgb}" })
      --vim.cmd.highlight({ "BufferLineSeparatorSelected", "guibg=#${theme.base00.hex.rgb}", "guifg=#${theme.base00.hex.rgb}" })
      require("bufferline").setup({
        highlights = {
          background = {
            bg = "#${theme.base00.hex.rgb}",
            fg = "#${theme.base04.hex.rgb}",
          },
          tab = {
            bg = "#${theme.base00.hex.rgb}",
            fg = "#${theme.base04.hex.rgb}",
          },
          buffer = {
            bg = "#${theme.base00.hex.rgb}",
            fg = "#${theme.base04.hex.rgb}",
          },
          tab_selected = {
            bg = "#${theme.base01.hex.rgb}",
            fg = "#${theme.base04.hex.rgb}",
          },
          buffer_selected = {
            bg = "#${theme.base01.hex.rgb}",
            fg = "#${theme.base04.hex.rgb}",
          },
          buffer_visible = {
            bg = "#${theme.base01.hex.rgb}",
            fg = "#${theme.base04.hex.rgb}",
          },
          separator_selected = {
            bg = "#${theme.base00.hex.rgb}",
            fg = "#${theme.base00.hex.rgb}",
          },
          separator_visible = {
            bg = "#${theme.base00.hex.rgb}",
            fg = "#${theme.base00.hex.rgb}",
          },
          indicator_selected = {
            bg = "#${theme.base00.hex.rgb}",
            fg = "#${theme.base00.hex.rgb}",
          },
          indicator_visible = {
            bg = "#${theme.base00.hex.rgb}",
            fg = "#${theme.base00.hex.rgb}",
          },
          separator = {
            bg = "#${theme.base00.hex.rgb}",
            fg = "#${theme.base00.hex.rgb}",
          },
        },
        options = {
          show_close_icon = false,
          show_buffer_close_icons = false,
          offsets = {
            {
              filetype = "neo-tree",
              text = "EXPLORER",
              separator = '│',
            },
          }
        }
      })
    '';
  }
  # Notifications. Look, just hear me out...
  # https://github.com/rcarriga/nvim-notify
  {
    plugin = nvim-notify;
    config = lua ''
      vim.o.termguicolors = true
      require('notify').setup({})
    '';
  }
  # Show available options if you hang around indecisively
  # after starting a multi-key edit sequence
  # https://github.com/folke/which-key.nvim
  {
    plugin = which-key-nvim;
    config = genericConfig "which-key";
  }
  # Dims inactive windows slightly
  # https://github.com/TaDaa/vimade
  # {
  #   plugin = vimade;
  #   config = vimscript ''
  #     set termguicolors
  #     let g:vimade = {}
  #     let g:vimade.fadelevel = 0.7
  #     let g:vimade.enablesigns = 1
  #   '';
  # }
  # Highlight changed lines in gutter
  # https://github.com/lewis6991/gitsigns.nvim
  {
    plugin = gitsigns-nvim;
    config = lua ''
      require('gitsigns').setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = vim.keymap.set

          -- Jump to next change
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, { expr = true })

          -- Jump to previous change
          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, { expr = true })
        end
      })
    '';
  }
  # Statusline glow-up
  # https://github.com/feline-nvim/feline.nvim
  {
    plugin = feline-nvim;
    config = genericConfig "feline";
  }

  {
    plugin = nvim-web-devicons;
  }
  # General UI glow-up
  # https://github.com/stevearc/dressing.nvim
  dressing-nvim
  {
    plugin = stabilize-nvim;
    config = genericConfig "stabilize";
  }
] ++
(
  if isNull theme then
    [{
      plugin = nord-nvim;
      config = lua ''
        vim.g.nord_uniform_diff_background = true
        require('nord').set()
      '';
    }]
  else
    [{
      plugin = nvim-base16;
      config = lua ''
        require('base16-colorscheme').setup(${utils.themeToLua theme})
        vim.cmd.highlight({ "Identifier", "guifg=#${theme.base04.hex.rgb}" })
        vim.cmd.highlight({ "Statement", "guifg=#${theme.base04.hex.rgb}" })
        vim.cmd.highlight({ "TSVariable", "guifg=#${theme.base04.hex.rgb}" })
        vim.cmd.highlight({ "TSVariableBuiltin", "guifg=#${theme.base04.hex.rgb}" })
        vim.cmd.highlight({ "TSNamespace", "guifg=#${theme.base04.hex.rgb}" })
        vim.cmd.highlight({ "TSTag", "guifg=#${theme.base04.hex.rgb}" })

        vim.cmd.highlight({ "TSConstant", "guifg=#${theme.base04.hex.rgb}", "gui=bold" })

        vim.cmd.highlight({ "Todo", "guifg=#${theme.base00.hex.rgb}", "guibg=#${theme.base0A.hex.rgb}" })

        vim.cmd.highlight({ "Character", "guifg=#${theme.base0B.hex.rgb}" })
        vim.cmd.highlight({ "TSCharacter", "guifg=#${theme.base0B.hex.rgb}" })

        vim.cmd.highlight({ "TSConstMacro", "guifg=#${theme.base0E.hex.rgb}", "gui=italic" })
        vim.cmd.highlight({ "TSFuncMacro", "guifg=#${theme.base0E.hex.rgb}", "gui=italic" })

        vim.cmd.highlight({ "TSUri", "guifg=#${theme.base0D.hex.rgb}" })
        vim.cmd.highlight({ "TSType", "guifg=#${theme.base0D.hex.rgb}" })
        vim.cmd.highlight({ "TSTypeBuiltin", "guifg=#${theme.base0D.hex.rgb}" })
      '';
    }]
)
