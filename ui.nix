# Plugins enchancing or tweaking the UI, nothing major.
# I tried to put the most controversial stuff up top for
# ease of deletion by enraged viewer.
{ plugins, utils, theme, ... }: with plugins; with utils;
[
  # Tabbar. Yes, I want to see tabs.
  # Just like in a _browser_. Fight me.
  # https://github.com/romgrk/barbar.nvim
  {
    plugin = barbar-nvim;
    config = vimscript ''
      nnoremap <silent> <C-j> <Cmd>BufferPrevious<CR>
      nnoremap <silent> <C-k> <Cmd>BufferNext<CR>
      nnoremap <silent> <C-c> <Cmd>BufferClose<CR>
      nnoremap <silent> <C-p> <Cmd>BufferPick<CR>
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
    plugin = vim-devicons;
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
      config = vimscript ''
        colorscheme nord
      '';
    }]
  else
    [{
      plugin = nvim-base16;
      config = lua ''
        require('base16-colorscheme').setup(${utils.themeToLua theme})
      '';
    }]
)
