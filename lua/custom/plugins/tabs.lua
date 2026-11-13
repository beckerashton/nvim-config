vim.o.showtabline = 2

vim.pack.add { 'https://github.com/nanozuki/tabby.nvim' }

require('tabby').setup {
  line = function(line)
    local theme = {
      fill = { fg = '#87e58e', bg = 'NONE' },
      head = { fg = '#87e58e', bg = '#04075a' },
      current_tab = { fg = '#282a36', bg = '#bd93f9', style = 'bold' },
      tab = { fg = '#bd93f9', bg = '#04075a' },
      current_win = { fg = '#282a36', bg = '#bd93f9', style = 'bold' },
      win = { fg = '#f8f8f2', bg = '#04075a' },
      tail = { fg = '#87e58e', bg = '#04075a' },
    }

    local cwd = ' ' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t') .. ' '
    local strwidth = vim.api.nvim_strwidth
    local left_width = strwidth(cwd) + 1
    local right_width = 3
    local win_line = line.wins_in_tab(line.api.get_current_tab())
    for _, win in ipairs(win_line.wins) do
      right_width = right_width + strwidth(win.buf_name()) + 4
    end

    return {
      { cwd, hl = { fg = theme.head.bg, bg = theme.head.fg } },
      { '', hl = { fg = theme.head.fg, bg = theme.fill.bg } },
      line.tabs().foreach(function(tab)
        local hl = tab.is_current() and theme.current_tab or theme.tab
        local name = tab.name()
        left_width = left_width + strwidth(name) + 4

        return {
          line.sep('', hl, theme.fill),
          name,
          line.sep('', hl, theme.fill),
          hl = hl,
          margin = ' ',
        }
      end),

      string.rep('=', math.max(0, vim.o.columns - left_width - right_width)),

      win_line.foreach(function(win)
        local hl = win.is_current() and theme.current_win or theme.win
        local name = win.buf_name()

        return {
          line.sep('', hl, theme.fill),
          name,
          line.sep('', hl, theme.fill),
          hl = hl,
          margin = ' ',
        }
      end),

      { '██', hl = { fg = theme.fill.fg, bg = theme.fill.bg } },
      hl = theme.fill,
    }
  end,

  option = {
    theme = {},
    nerdfont = true,
    buf_name = { mode = 'tail' },
  },
}

vim.keymap.set('n', '<leader>ta', ':$tabnew<CR>', { noremap = true, desc = '[T]ab [A]dd' })
vim.keymap.set('n', '<leader>td', ':tabclose<CR>', { noremap = true, desc = '[T]ab [D]elete' })
vim.keymap.set('n', '<leader>to', ':tabonly<CR>', { noremap = true, desc = '[T]ab [O]nly' })
vim.keymap.set('n', '<leader>tn', ':tabn<CR>', { noremap = true, desc = '[T]ab [N]ext' })
vim.keymap.set('n', '<leader>tp', ':tabp<CR>', { noremap = true, desc = '[T]ab [P]revious' })
-- move current tab to previous position
vim.keymap.set('n', '<leader>tmp', ':-tabmove<CR>', { noremap = true, desc = '[T]ab [M]ove [P]revious' })
-- move current tab to next position
vim.keymap.set('n', '<leader>tmn', ':+tabmove<CR>', { noremap = true, desc = '[T]ab [M]ove [N]ext' })
vim.keymap.set('n', '<leader>tt', function()
  vim.cmd 'tabnew'
  vim.cmd 'terminal'
  vim.cmd 'startinsert'
end, { noremap = true, desc = 'Open [T]erminal [T]ab' })
