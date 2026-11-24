-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd('CmdlineLeave', {
  desc = 'Center a line-number jump',
  group = vim.api.nvim_create_augroup('center-line-number-jump', { clear = true }),
  pattern = ':',
  callback = function()
    local aborted = vim.v.event.abort
    if aborted == true or aborted == 1 then return end
    local line = tonumber(vim.fn.getcmdline():match '^%s*(%d+)%s*$')
    if not line then return end
    line = math.max(line, 1)

    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_get_current_buf()
    -- The Ex address is applied after CmdlineLeave.
    vim.schedule(function()
      if win == vim.api.nvim_get_current_win() and buf == vim.api.nvim_get_current_buf() and line == vim.fn.line '.' then
        vim.cmd.normal { 'zvzz', bang = true }
      end
    end)
  end,
})
