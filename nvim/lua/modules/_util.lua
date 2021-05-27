local Job = require("plenary.job")
local fn = vim.fn

_G.Util = {}

---@param stuff any Print table and return it
P = function(stuff)
  print(vim.inspect(stuff))
  return stuff
end

Util.check_backspace = function()
  local curr_col = fn.col(".")
  local is_first_col = fn.col(".") - 1 == 0
  local prev_char = fn.getline("."):sub(curr_col - 1, curr_col - 1)

  if is_first_col or prev_char:match("%s") then
    return true
  else
    return false
  end
end

Util.check_surroundings = function()
  local col = fn.col(".")
  local line = fn.getline(".")
  local prev_char = line:sub(col - 1, col - 1)
  local next_char = line:sub(col, col)
  local pattern = "[%{|%}|%[|%]]"

  if prev_char:match(pattern) and next_char:match(pattern) then
    return true
  else
    return false
  end
end

local to_rgb = function(hex)
  local red, green, blue, alpha

  if #hex == 9 then
    _, red, green, blue, alpha = hex:match("(.)(..)(..)(..)(..)")
    return string.format(
      "rgba(%s, %s, %s, %s)",
      tonumber("0x" .. red),
      tonumber("0x" .. green),
      tonumber("0x" .. blue),
      tonumber("0x" .. alpha)
    )
  end

  _, red, green, blue = hex:match("(.)(..)(..)(..)")
  return string.format(
    "rgb(%s, %s, %s)",
    tonumber("0x" .. red),
    tonumber("0x" .. green),
    tonumber("0x" .. blue)
  )
end

local to_hex = function(rgb)
  local red, green, blue, alpha
  if #rgb >= 16 then
    red, green, blue, alpha = rgb:match("%((%d+),%s(%d+),%s(%d+),%s(%d+)")
    return string.format("#%x%x%x%x", red, green, blue, alpha)
  end

  red, green, blue = rgb:match("%((%d+),%s(%d+),%s(%d+)")
  return string.format("#%x%x%x", red, green, blue)
end

Util.get_word = function()
  local first_line, last_line = fn.getpos("'<")[2], fn.getpos("'>")[2]
  local first_col, last_col = fn.getpos("'<")[3], fn.getpos("'>")[3]
  local current_word = fn.getline(first_line, last_line)[1]:sub(first_col, last_col)

  return current_word
end

-- convert colours
Util.convert_colour = function(mode)
  local result

  if mode == "rgb" then
    result = to_rgb(Util.get_word())
  elseif mode == "hex" then
    result = to_hex(Util.get_word())
  else
    return print("Not Supported!")
  end

  vim.cmd(string.format("s/%s/%s", Util.get_word(), result))
end

vim.cmd [[
  command! -nargs=? -range=% ToRgb call v:lua.Util.convert_color('rgb')
  command! -nargs=? -range=% ToHex call v:lua.Util.convert_color('hex')
]]

-- translate selected word, useful for when I do jp assignments
Util.translate = function(lang)
  local word = Util.get_word()
  local job = Job:new({
    command = "trans",
    args    = { "-b", ":" .. (lang or "en"), word },
  })

  local ok, result = pcall(function()
    return vim.trim(job:sync()[1])
  end)
  if ok then
    print(result)
  end
end
vim.cmd [[command! -range -nargs=1 Translate call v:lua.Util.translate(<f-args>)]]

Util.is_cfg_present = function(cfg_name)
  -- this returns 1 if it's not present and 0 if it's present
  -- we need to compare it with 1 because both 0 and 1 is `true` in lua
  return fn.empty(fn.glob(vim.loop.cwd() .. cfg_name)) ~= 1
end

-- helper for defining highlight groups
Util.set_hl = function(group, opts)
  local bg     = opts.bg == nil and "" or "guibg=" .. opts.bg
  local fg     = opts.fg == nil and "" or "guifg=" .. opts.fg
  local gui    = opts.gui == nil and "" or "gui=" .. opts.gui
  local guisp    = opts.guisp == nil and "" or "guisp=" .. opts.guisp
  local link   = opts.link or false

  if not link then
    vim.cmd(string.format("hi %s %s %s %s %s", group, bg, fg, gui, guisp))
  else
    vim.cmd(string.format("hi! link %s %s", group, link))
  end
end

-- might be useful
Util.spinner = function()
  local anim_frames = {
    "   ",
    "▪  ",
    "▪▪ ",
    "▪▪▪",
    "▬▪▪",
    "▬▬▪",
    "▬▬▬",
    "▪▬▬",
    "▪▪▬",
    "▪▪▪",
    " ▪▪",
    "  ▪",
    "   ",
  }

  local current_frame = 0
  local results_updated = function()
    current_frame = current_frame >= #anim_frames and 1 or current_frame + 1
    print(anim_frames[current_frame])
  end

  local timer = fn.timer_start(80, results_updated, { ["repeat"] = 100 })

  return timer
end

Util.t = function(cmd)
  return vim.api.nvim_replace_termcodes(cmd, true, true, true)
end

Util.is_git_repo = function(cwd)
  local fd = vim.loop.fs_scandir(cwd)
  if fd then
    while true do
      local name, typ = vim.loop.fs_scandir_next(fd)
      if name == nil then return false end
      if typ == 'directory' and name == '.git' then return true end
    end
  end
end

Util.borders = {
  {"🭽", "FloatBorder"},
  {"▔", "FloatBorder"},
  {"🭾", "FloatBorder"},
  {"▕", "FloatBorder"},
  {"🭿", "FloatBorder"},
  {"▁", "FloatBorder"},
  {"🭼", "FloatBorder"},
  {"▏", "FloatBorder"},
  -- {"▄", "Bordaa"},
  -- {"▄", "Bordaa"},
  -- {"▄", "Bordaa"},
  -- {"█", "Bordaa"},
  -- {"▀", "Bordaa"},
  -- {"▀", "Bordaa"},
  -- {"▀", "Bordaa"},
  -- {"█", "Bordaa"}
}

-- see lua/plugins/_compe.lua for context
Util.trigger_completion = function()
  if vim.fn.pumvisible() ~= 0 then
    if vim.fn.complete_info()["selected"] ~= -1 then
      return vim.fn["compe#confirm"]()
    end
  end

   local prev_col, next_col = vim.fn.col(".") - 1, vim.fn.col(".")
  local prev_char = vim.fn.getline("."):sub(prev_col, prev_col)
  local next_char = vim.fn.getline("."):sub(next_col, next_col)

  -- minimal autopairs-like behaviour
  if prev_char == "{" and next_char ~= "}" then return Util.t("<CR>}<C-o>O") end
  if prev_char == "[" and next_char ~= "]" then return Util.t("<CR>]<C-o>O") end
  if prev_char == "(" and next_char ~= ")" then return Util.t("<CR>)<C-o>O") end
  if prev_char == ">" and next_char == "<" then return Util.t("<CR><C-o>O") end -- html indents
  if prev_char == "(" and next_char == ")" then return Util.t("<CR><C-o>O") end -- flutter indents

  return Util.t("<CR>")
end

Util.lsp_on_attach = function()
  require("modules.lsp._mappings").lsp_mappings()
  require("lsp_signature").on_attach {
    bind = true,
    doc_lines = 2,
    hint_enable = false,
    handler_opts = {
      border = Util.borders
    }
  }
end

Util.lsp_on_init = function()
  print("Language Server Protocol started!")

  if client.config.flags then
    client.config.flags.allow_incremental_sync = true
  end
end

return Util