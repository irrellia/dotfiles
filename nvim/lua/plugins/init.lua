vim.cmd [[ packadd packer.nvim ]]

local packer_ok, packer = pcall(require, "packer")
if not packer_ok then
  return
end

packer.init {
  git = {
    clone_timeout = 300, -- 5 minutes, I have horrible internet
  },
  display = {
    open_fn = function()
      return require("packer.util").float { border = Util.borders }
    end,
  },
}

local plugins = {
  { "wbthomason/packer.nvim", opt = true },

  require("plugins.compe").plugin,
  require("plugins.gitsigns").plugin,
  require("plugins.null-ls").plugin,
  require("plugins.nvim-bufferline").plugin,
  require("plugins.nvim-jdtls").plugin,
  require("plugins.nvim-tree").plugin,
  require("plugins.rest-nvim").plugin,
  require("plugins.rust-tools").plugin,
  require("plugins.flutter-tools").plugin,
  require("plugins.telescope").plugin,
  require("plugins.treesitter").plugin,
  require("plugins.tsserver").plugin,
  require("plugins.which-key").plugin,

  -- plenary: full; complete; entire; absolute; unqualified.
  { "nvim-lua/plenary.nvim" },

  -- An implementation of the Popup API from vim in Neovim.
  { "nvim-lua/popup.nvim" },

  {
    "rktjmp/lush.nvim",
    event = "VimEnter",
    requires = { "~/repos/gruvy", "~/repos/icy" },
    config = function()
      -- require('lush')(require('lush_theme.gruvy'))
      require "lush"(require "lush_theme.icy")
    end,
  },

  {
    "neovim/nvim-lspconfig",
    event = "BufRead",
    config = function()
      require "modules.lsp"
    end,
  },

  { "tweekmonster/startuptime.vim", cmd = "StartupTime" },

  { "tpope/vim-commentary", keys = "gc" },

  {
    "mapkts/enwise",
    event = "BufRead",
    setup = function()
      vim.g.enwise_enable_globally = 1
    end
  },

  {
    "steelsojka/headwind.nvim",
    cmd = { "HeadwindBuf", "HeadwindVisual" },
    setup = function()
      vim.cmd [[
        command! -nargs=0 -range=% HeadwindBuf lua require "headwind".buf_sort_tailwind_classes(0)
        command! -nargs=0 -range=% HeadwindVisual lua require "headwind".sort_tailwind_classes(0)
      ]]
    end,
  },

  { "junegunn/vim-easy-align", keys = "<Plug>(EasyAlign)" },

  { "AndrewRadev/splitjoin.vim", keys = "gS" },

  { "dhruvasagar/vim-table-mode", ft = { "text", "markdown" } },

  { "machakann/vim-sandwich", keys = "s" },

  { "mhinz/vim-sayonara", cmd = "Sayonara" },

  {
    "kyazdani42/nvim-web-devicons",
    after = "lush.nvim",
    config = function()
      require("nvim-web-devicons").setup { default = true }
    end,
    requires = {
      -- requires nonicons font installed
      { "yamatsum/nvim-nonicons", after = "nvim-web-devicons" },
    },
  },

  {
    "phaazon/hop.nvim",
    cmd = "HopWord",
    setup = function()
      vim.api.nvim_set_keymap(
        "n",
        "<Leader>w",
        "<CMD>HopWord<CR>",
        { noremap = true }
      )
    end,
    config = function()
      require("hop").setup {}
    end,
  },

  {
    "mattn/emmet-vim",
    cmd = "EmmetInstall",
    setup = function()
      vim.g.user_emmet_install_global = 0
      vim.g.user_emmet_leader_key = ","
    end,
  },

  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    config = function()
      require("zen-mode").setup {
        window = {
          backdrop = 1, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
          width = 80, -- width of the Zen window
          height = 32, -- height of the Zen window
          linebreak = true,
          wrap = true,
        },
        plugins = {
          options = {
            enabled = true,
            ruler = false,
            showcmd = false,
          },
          gitsigns = { enabled = true }, -- disables git signs
          tmux = { enabled = false }, -- disables the tmux statusline
        },
        on_open = function(win)
          vim.api.nvim_win_set_option(win, "wrap", true)
          vim.api.nvim_win_set_option(win, "linebreak", true)
        end,
      }
    end,
  },

  {
    "plasticboy/vim-markdown",
    filetype = "markdown",
    setup = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_frontmatter = 1
    end,
  },

  {
    "andymass/vim-matchup",
    event = "CursorMoved",
    setup = function()
      vim.g.matchup_matchparen_offscreen = {
        method = "popup",
        fullwidth = true,
        highlight = "Normal",
      }
    end,
  },

  {
    "TimUntersberger/neogit",
    cmd = "Neogit",
    config = function()
      require("neogit").setup {
        disable_signs = false,
        disable_context_highlighting = true,
        signs = {
          -- { CLOSED, OPENED }
          section = { "", "" },
          item = { "+", "-" },
          hunk = { "", "" },
        },
        integrations = {
          diffview = true,
        },
      }
    end,
    requires = {
      {
        "sindrets/diffview.nvim",
        after = "neogit",
      },
    },
  },

  {
    "vim-test/vim-test",
    cmd = { "TestFile", "TestNearest", "TestSuite", "TestVisit" },
    setup = function()
      local remap = vim.api.nvim_set_keymap

      remap("n", "<Leader>tn", "<CMD>TestNearest<CR>", { noremap = true })
      remap("n", "<Leader>tf", "<CMD>TestFile<CR>", { noremap = true })
      remap("n", "<Leader>ts", "<CMD>TestSuite<CR>", { noremap = true })
      remap("n", "<Leader>tl", "<CMD>TestLast<CR>", { noremap = true })
      remap("n", "<Leader>tg", "<CMD>TestVisit<CR>", { noremap = true })
      vim.g["test#strategy"] = "neovim"
    end,
  },

  {
    "lervag/vimtex",
    ft = "latex",
    setup = function()
      vim.g.vimtex_quickfix_enabled = false
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_latexmk = {
        options = {
          "--shell-escape",
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }
    end,
  },

  {
    "norcalli/nvim-colorizer.lua",
    cmd = "ColorizerToggle",
    config = function()
      require("colorizer").setup {
        ["*"] = {
          css = true,
          css_fn = true,
          mode = "background",
        },
      }
    end,
  },

  {
    "mfussenegger/nvim-dap",
    keys = "<Leader>d",
    config = function()
      require "modules.dap"
    end,
  },
}

packer.startup(function(use)
  for _, v in pairs(plugins) do
    use(v)
  end
end)
