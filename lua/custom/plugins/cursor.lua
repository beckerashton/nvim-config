vim.pack.add {
  'https://github.com/nvim-mini/mini.cursorword',
  'https://github.com/sphamba/smear-cursor.nvim',
  'https://github.com/declancm/cinnamon.nvim',
  { src = 'https://github.com/petertriho/nvim-scrollbar', version = 'refactor/v2' },
}
require('mini.cursorword').setup()
-- require('whisk').setup()
require('smear_cursor').setup {
  stiffness = 0.5,
  trailing_stiffness = 0.5,
  matrix_pixel_threshold = 0.5,
  smear_to_cmd = false,
  scroll_buffer_space = true,
}
local cinnamon = require 'cinnamon'
cinnamon.setup {
  keymaps = {
    basic = true,
    extra = true,
  },
  options = {
    mode = 'window',
    max_delta = {
      time = 200,
    },
  },
}

local function center_jump(motion)
  local count = vim.v.count
  local command = (count > 0 and tostring(count) or '') .. motion .. 'zvzz'
  cinnamon.scroll(function() vim.cmd.normal { command, bang = true } end)
end

for _, motion in ipairs { 'G', 'gg' } do
  vim.keymap.set({ 'n', 'x' }, motion, function()
    if vim.v.count == 0 then
      cinnamon.scroll(motion)
    else
      center_jump(motion)
    end
  end, { desc = 'Go to line and center counted jumps' })
end

-- Keep previous-context and other special mark commands native.
for _, prefix in ipairs { "'", '`', "g'", 'g`' } do
  for mark in ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'):gmatch '.' do
    local motion = prefix .. mark
    vim.keymap.set('n', motion, motion .. 'zvzz', { desc = 'Jump to mark and center' })
  end
end

local scrollbar_colors = require('dracula').colors()
require('scrollbar').setup {
  scrollbar = {
    visibility = 'all',
    thumb = { highlight = { bg = scrollbar_colors.selection } },
  },
  marks = {
    Cursor = { highlight = { fg = scrollbar_colors.fg } },
    Search = { highlight = { fg = scrollbar_colors.orange } },
    Error = { highlight = { fg = scrollbar_colors.red } },
    Warn = { highlight = { fg = scrollbar_colors.yellow } },
    Info = { highlight = { fg = scrollbar_colors.cyan } },
    Hint = { highlight = { fg = scrollbar_colors.purple } },
    Misc = { highlight = { fg = scrollbar_colors.pink } },
    GitAdd = { highlight = { fg = scrollbar_colors.green } },
    GitChange = { highlight = { fg = scrollbar_colors.orange } },
    GitDelete = { text = "┆", highlight = { fg = scrollbar_colors.red } },
  },
  providers = { gitsigns = true, search = { incsearch = true } },
}

-- vim.pack.add { 'https://github.com/y3owk1n/undo-glow.nvim' }
