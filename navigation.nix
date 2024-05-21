# Plugins relating to navigating around a codebase.
{ plugins, utils, theme, ... }:
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
          text = '${utils.icons.diagnostics.error}',
          texthl = 'DiagnosticSignError'
      })
      vim.fn.sign_define('DiagnosticSignWarn', {
          text = '${utils.icons.diagnostics.warn}', 
          texthl = 'DiagnosticSignWarn'
      })
      vim.fn.sign_define('DiagnosticSignInfo', {
          text = '${utils.icons.diagnostics.info}',
          texthl = 'DiagnosticSignInfo'  
      })
      vim.fn.sign_define('DiagnosticSignHint', {
          text = '${utils.icons.diagnostics.hint}',
          texthl = 'DiagnosticSignHint'
      })

      require('neo-tree').setup({
          close_if_last_window = true,
          sources = {
            "filesystem",
            "buffers",
            "git_status",
            "document_symbols",
          },
          source_selector = {
            winbar = true,
            content_layout = "center",
            tabs_layout = "equal",
            show_separator_on_edge = true,
            sources = {
              { source = "filesystem", display_name = "󰉓" },
              { source = "buffers", display_name = "󰈙" },
              { source = "git_status", display_name = "" },
              { source = "document_symbols", display_name = "" },
              { source = "diagnostics", display_name = "󰒡" },
            },
          },
          default_component_configs = {
              name = {
                  trailing_slash = true,
              },
              git_status = {
                  symbols = {
                      added = "${utils.icons.git.added}",
                      modified = "${utils.icons.git.modified}",
                      deleted = "${utils.icons.git.deleted}",
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
                  ['<S-j>'] = {
                      'next_source',
                      nowait = false
                  },
                  ['<S-k>'] = {
                      'prev_source',
                      nowait = false
                  }
              }
          },
          filesystem = {
              follow_current_file = { enabled = true },
              group_empty_dirs = true,
              filtered_items = {
                hide_dotfiles = false,
                hide_gitignored = false,
              },
          }
      })

      vim.cmd.highlight({ "NeoTreeTabInactive", "guibg=#${theme.base00.hex.rgb}" })
      vim.cmd.highlight({ "NeoTreeTabActive",   "guibg=#${theme.base00.hex.rgb}" })
      vim.cmd.highlight({ "NeoTreeTabSeparatorActive", "guibg=#${theme.base00.hex.rgb}", "guifg=#${theme.base00.hex.rgb}" })
      vim.cmd.highlight({ "NeoTreeTabSeparatorInactive", "guibg=#${theme.base00.hex.rgb}", "guifg=#${theme.base00.hex.rgb}" })

      vim.keymap.set('n', '<Leader>v', function()
        vim.cmd[[Neotree reveal toggle=true]]
      end)
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
  diffview-nvim
  # Poor man's magit
  # https://github.com/TimUntersberger/neogit
  {
    plugin = neogit;
    config = genericConfig "neogit" + vimscript ''
      nnoremap <leader>g <cmd>Neogit<cr>
    '';
  }
]
