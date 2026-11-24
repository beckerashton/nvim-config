local M = {}
local received = {}
local spinner = { '|', '/', '-', '\\' }
local last_buffer = vim.api.nvim_get_current_buf()

local group = vim.api.nvim_create_augroup('csharp-diagnostics-status', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
  group = group,
  callback = function(event)
    if vim.bo[event.buf].buftype == '' then last_buffer = event.buf end
  end,
})
vim.api.nvim_create_autocmd('LspDetach', {
  group = group,
  callback = function(event)
    local reports = received[event.data.client_id]
    if reports then reports[vim.uri_from_bufnr(event.buf)] = nil end
  end,
})

local function mark_received(client_id, uri)
  received[client_id] = received[client_id] or {}
  received[client_id][uri] = true
end

function M.publish_diagnostics(err, result, ctx, config)
  local response = vim.lsp.handlers['textDocument/publishDiagnostics'](err, result, ctx, config)
  if not err and result and result.uri and result.diagnostics then mark_received(ctx.client_id, result.uri) end
  return response
end

function M.pull_diagnostics(err, result, ctx, config)
  local response = vim.lsp.handlers['textDocument/diagnostic'](err, result, ctx, config)
  if not err and result then mark_received(ctx.client_id, ctx.params.textDocument.uri) end
  return response
end

function M.status()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype == 'TelescopePrompt' then bufnr = last_buffer end
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= 'cs' then return '' end

  local uri = vim.uri_from_bufnr(bufnr)
  local clients = vim.lsp.get_clients { bufnr = bufnr, name = 'roslyn_ls' }
  if #clients == 0 then clients = vim.lsp.get_clients { bufnr = bufnr, name = 'omnisharp' } end
  for _, client in ipairs(clients) do
    -- Clear the spinner on the first diagnostic report for this file.
    if not (received[client.id] and received[client.id][uri]) then
      local frame = math.floor(vim.uv.hrtime() / 150000000) % #spinner + 1
      return spinner[frame] .. ' C#'
    end
  end
  return ''
end

return M
