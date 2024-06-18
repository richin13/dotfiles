local M = {}

M.insertspace = function(count)
  if count and count > 0 then
    return " "
  else
    return ""
  end
end

M.Align = { provider = "%=" }

M.Space = { provider = " " }

-- this means that the statusline is cut here when there's not enough space
M.Cut = { provider = "%<" }

return M
