local M = {}

local block_captures = {
  ['block.outer'] = true,
  ['class.outer'] = true,
  ['conditional.outer'] = true,
  ['function.outer'] = true,
  ['loop.outer'] = true,
}

local function block_edge(node, row)
  local first, _, last, last_col = node:range()
  if last_col == 0 then last = last - 1 end
  if first >= last then return end
  if row == first then return 'zt' end
  if row == last then return 'zb' end
end

local function in_function_header(node, body, row, col)
  local first, first_col, last, last_col = node:range()
  if body then
    last, last_col = body:start()
  end
  return (row > first or row == first and col >= first_col) and (row < last or row == last and col < last_col)
end

local function brace_edge(node, row)
  local opener = node and node:child(0)
  if opener and opener:type() == '{' then return block_edge(node, row) end
end

local function placement()
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  local parser = vim.treesitter.get_parser(buf)
  if not parser then return 'zz' end

  local query = vim.treesitter.query.get(parser:lang(), 'textobjects')
  local tree = query and parser:parse()[1]
  if not tree then return 'zz' end

  local position = 'zz'
  for id, node in query:iter_captures(tree:root(), buf, row, row + 1) do
    local capture = query.captures[id]
    local edge
    if block_captures[capture] then
      local body = node:field('body')[1]
      if capture == 'function.outer' and in_function_header(node, body, row, col) then return 'zt' end
      -- Braces on their own lines are edges too, even when the capture starts at the header.
      edge = brace_edge(body, row) or block_edge(node, row)
    elseif capture == 'block.inner' then
      edge = brace_edge(node, row)
    end
    if edge == 'zt' then return 'zt' end
    if edge == 'zb' then position = 'zb' end
  end
  return position
end

function M.place()
  local ok, position = pcall(placement)
  vim.cmd.normal { 'zv' .. (ok and position or 'zz'), bang = true }
end

return M
