# Plugins relating to navigating around a codebase.
{ plugins, utils, ... }:
with plugins;
with utils;
[
  # Search and preview basically anything.
  # Pretty sure I'm using like 10% of it's true power.
  # https://github.com/nvim-telescope/telescope.nvim
  {
    plugin = telescope-nvim;
    config = vimscript ''
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>fg <cmd>Telescope live_grep<cr>
      nnoremap <leader>fs <cmd>Telescope lsp_dynamic_workspace_symbols<cr>
      nnoremap <leader><leader> <cmd>Telescope buffers<cr>
      nnoremap <leader>sr <cmd>Telescope reloader<cr>
    '';
  }
  # Filetree. Open/close with <leader>+v.
  # https://github.com/nvim-neo-tree/neo-tree.nvim
  {
    plugin = neo-tree-nvim;
    config = lua ''
      vim.g.neo_tree_remove_legacy_commands = 1

      vim.fn.sign_define('DiagnosticSignError', {
          text = ' ',
          texthl = 'DiagnosticSignError'
      })
      vim.fn.sign_define('DiagnosticSignWarn',
                         { text = ' ', texthl = 'DiagnosticSignWarn' })
      vim.fn.sign_define('DiagnosticSignInfo',
                         { text = ' ', texthl = 'DiagnosticSignInfo' })
      vim.fn.sign_define('DiagnosticSignHint',
                         { text = '', texthl = 'DiagnosticSignHint' })

      require('neo-tree').setup({
          close_if_last_window = true,
          default_component_configs = {
              name = {
                  trailing_slash = true,
              },
              git_status = {
                  symbols = {
                      added = "✚",
                      modified = "",
                  }
              }
          },
          window = {
              width = 35,
              mappings = {
                  ['<tab>'] = {
                      'toggle_node',
                      nowait = false
                  },
              }
          },
          filesystem = {
              follow_current_file = { enabled = true },
              group_empty_dirs = true,
          },
      })

      vim.cmd([[nnoremap <leader>v :Neotree reveal toggle=true<cr>]])
    '';
  }
  # Project management. It's here mostly because it
  # auto-cds to project directory, which really helps
  # with .envrc.
  # https://github.com/ahmedkhalf/project.nvim
  {
    plugin = project-nvim;
    config = lua ''
      require("project_nvim").setup({
        silent_chdir = false
      })
      require('telescope').load_extension('projects')
    '' + vimscript ''
      nnoremap <leader>fp <cmd>Telescope projects<cr>
    '';
  }
  # Nicer experience with marks
  # https://github.com/chentoast/marks.nvim
  {
    plugin = marks-nvim;
    config = genericConfig "marks";
  }
  # Automatically create missing directories on file save
  # https://github.com/jghauser/mkdir.nvim
  mkdir-nvim
  # Direnv integration
  # https://github.com/direnv/direnv.vim
  direnv-vim
  # Github issues
  # https://github.com/pwntester/octo.nvim
  {
    plugin = octo-nvim;
    config = genericConfig "octo";
  }
  # Poor man's magit
  # https://github.com/TimUntersberger/neogit
  {
    plugin = neogit;
    config = genericConfig "neogit" + vimscript ''
      nnoremap <leader>g <cmd>Neogit<cr>
    '';
  }
]
