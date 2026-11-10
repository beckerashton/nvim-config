vim.pack.add { { src = 'https://github.com/nvim-mini/mini.files', version = 'main' } }
require('mini.files').setup {
  windows = {
    max_number = 4,
    preview = true,
    width_focus = 30,
    width_nofocus = 20,
    width_preview = 80,
  },
  options = {
    use_as_default_explorer = true,
  },
}

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    vim.keymap.set('n', '<Esc>', MiniFiles.close, { buffer = args.data.buf_id, desc = 'Close mini.files' })
    vim.keymap.set('n', '<C-t>', function()
      local entry = MiniFiles.get_fs_entry()
      if not entry or entry.fs_type ~= 'file' then return end
      local target = MiniFiles.get_explorer_state().target_window
      local tab_window = vim.api.nvim_win_call(target, function()
        vim.cmd 'tab split'
        return vim.api.nvim_get_current_win()
      end)
      MiniFiles.set_target_window(tab_window)
      MiniFiles.go_in { close_on_file = true }
    end, { buffer = args.data.buf_id, desc = 'Open file in new tab' })
  end,
})

vim.keymap.set('n', '-', function()
  -- Opens mini.files focusing on the directory of the current file
  require('mini.files').open(vim.api.nvim_buf_get_name(0), true)
end, { desc = 'Open mini.files (Current File)' })

vim.keymap.set('n', '_', function()
  -- Opens mini.files focusing on your current working directory
  require('mini.files').open(vim.uv.cwd(), true)
end, { desc = 'Open mini.files (cwd)' })
