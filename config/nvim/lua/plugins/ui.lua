return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })
      opts.presets.lsp_doc_border = true
    end,
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 1000,
    },
  },
  -- filename
  {
    "b0o/incline.nvim",
    event = "BufReadPre",
    priority = 1200,
    config = function()
      require("incline").setup({
        highlight = {
          groups = {
            InclineNormal = { guibg = "#ebbcba", guifg = "#191724" },
            InclineNormalNC = { guifg = "#ebbcba", guibg = "#191724" },
          },
        },
        window = { margin = { vertical = 0, horizontal = 1 } },
        hide = {
          cursorline = true,
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if vim.bo[props.buf].modified then
            filename = "[+]" .. filename
          end
          local icon, color = require("nvim-web-devicons").get_icon_color(filename)
          return { { icon, guifg = color }, { " " }, { filename } }
        end,
      })
    end,
  },
  -- bufferline
  {
    "akinsho/bufferline.nvim",
    key = {
      { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
      { "<S-l>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
      { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
      { "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
    },
    opts = {
      options = {
        mode = "tabs",
        show_buffer_close_icons = false,
        show_close_icon = false,
      },
    },
  },
  -- statusline
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   event = "VeryLazy",
  --   opts = {
  --     options = {
  --       theme = "rose-pine",
  --     },
  --   },
  -- },
  -- animations
  -- {
  --   "echasnovski/mini.animate",
  --   event = "VeryLazy",
  --   opts = function(_, opts)
  --     opts.scroll = {
  --       enabled = false,
  --     }
  --   end,
  -- },
  -- logo
  --{
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[

████████████████████       ████████████            ███████████                ▒▒▒▒▒▒▒▒▒▒      
██████████████████████     ████████████        ██████████████████             ██████████      
███████████████████████    ████████████     ███████████████████████           ██▒▒▒▒▒▒██      
████████████████████████   ████████████   ████████████████████████          ██▒▒▒▒▒▒▒▒▓▓██    
██████████   ████████████  ████████████  ████████████████████████         ██▒▒▒▒▒▒▒▒▒▒▓▓▓▓██  
██████████    ███████████  ████████████ █████████████████  █████          ██▒▒▒▒▒▒▒▒▒▒▓▓▓▓██  
██████████   ████████████  ██████████████████████████        ██         ██▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓██
████████████████████████   ████████████████████████                     ██▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓██
███████████████████████    ███████████████████████                      ██▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓██
█████████████████████████  ███████████████████████        ████████████  ██▒▒▒▒▒▒▒▒░░░░▒▒▒▒▒▒██
██████████   █████████████ ███████████████████████        ████████████  ██▒▒▒▒▒▒▒▒    ▒▒▒▒▒▒██
██████████    █████████████████████████ ███████████       ████████████  ██▒▒▒▒    ▒▒▒▒▒▒  ▒▒██
██████████   ██████████████████████████ ███████████████   ████████████  ██▒▒    ▒▒        ▒▒██
███████████████████████████████████████  █████████████████████████████  ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██
██████████████████████████ ████████████   ████████████████████████████  ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██
████████████████████████   ████████████      ██████████████████ ██████  ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██
█████████████████████      ████████████         █████████████   ██████  ██▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓██
                                                                        ██▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓██
                                        █████   █████  ██       █████   ██▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓██
                                       ██   ██ ██   ██ ██      ██   ██  ██▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓██
                                       ██      ██   ██ ██      ███████  ██▒▒▒▒██████████▓▓▓▓██
                                       ██   ██ ██   ██ ██      ██   ██  ██▒▒▒▒██      ██▓▓▓▓██
                                        █████   █████  ███████ ██   ██    ████          ████  
      ]],
        -- stylua: ignore
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
        },
      },
    },
  },
}
