-- Standard awesome library
local awful = require("awful")

local M = {}

function M.get ()
  local tags = {}

  awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    tags[s] = awful.tag(
      { "一", "二", "三", "四", "五", "六" }, s, RC.layouts[1]
    )
  end)

  return tags
end

return setmetatable({}, { __call = function(_, ...) return M.get(...) end })
