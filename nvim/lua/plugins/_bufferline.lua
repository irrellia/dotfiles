-- originally was taken from https://github.com/cooper-anderson/dotfiles
-- with some modifications and refactoring that I did
local get_diagnostics_count = function(key)
  local result = {
    error = vim.lsp.diagnostic.get_count(0, [[Error]]),
    warning = vim.lsp.diagnostic.get_count(0, [[Warning]]),
    info = vim.lsp.diagnostic.get_count(0, [[Information]]),
    hint = vim.lsp.diagnostic.get_count(0, [[Hint]]),
  }

  return result[key]
end

local options = {
  show_buffer_close_icons = false,
  separator_style         = { "", "" },
  diagnostics             = "nvim_lsp",
  buffer_close_icon       = "",
  close_icon              = '',
  custom_areas = {
    right = function()
      local result = {}
      local error = vim.lsp.diagnostic.get_count(0, [[Error]])
      local warning = vim.lsp.diagnostic.get_count(0, [[Warning]])
      local info = vim.lsp.diagnostic.get_count(0, [[Information]])
      local hint = vim.lsp.diagnostic.get_count(0, [[Hint]])

      if error ~= 0 then
        result[1] = { text = "  " .. error, guifg = "#EC5241" }
      end

      if warning ~= 0 then
        result[2] = { text = "  " .. warning, guifg = "#EFB839" }
      end

      if hint ~= 0 then
        result[3] = { text = "  " .. hint, guifg = "#A3BA5E" }
      end

      if info ~= 0 then
        result[4] = { text = "  " .. info, guifg = "#7EA9A7" }
      end

      return result
    end
  },
}

require("bufferline").setup({
  options = options,
})

-- vim.o.tabline = "%!v:lua.nvim_diagnostics_tab()"