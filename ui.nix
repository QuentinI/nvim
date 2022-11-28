# Plugins enchancing or tweaking the UI, nothing major.
# I tried to put the most controversial stuff up top for
# ease of deletion by enraged viewer.
{ plugins, utils, ... }: with plugins; with utils;
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
  # Just the theme I use. Not controversial,
  # more like usually something you'd want to change
  # for yourself.
  # https://github.com/shaunsingh/nord.nvim
  {
    plugin = nord-nvim;
    config = vimscript ''
      let g:nord_borders = v:true
      colorscheme nord
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
  # https://github.com/sunjon/Shade.nvim
  {
    plugin = Shade-nvim;
    config = lua ''
      vim.o.termguicolors = true
      require('shade').setup({
        overlay_opacity = 70,
        opacity_step = 1
      })
    '';
  }
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
  # General UI glow-up
  # https://github.com/stevearc/dressing.nvim
  dressing-nvim
]
