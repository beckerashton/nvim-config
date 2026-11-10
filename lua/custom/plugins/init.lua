-- Explicit order keeps dependencies and UI overrides predictable.
-- Add new plugin modules here after their dependencies.
require 'custom.plugins.ui'
require 'custom.plugins.telescope'
require 'custom.plugins.lsp'
require 'custom.plugins.formatting'
require 'custom.plugins.completion'
require 'custom.plugins.treesitter'

-- Optional Kickstart modules: uncomment to enable.
-- require 'kickstart.plugins.debug'
-- require 'kickstart.plugins.indent_line'
require 'kickstart.plugins.lint'
-- require 'kickstart.plugins.autopairs'
-- require 'kickstart.plugins.neo-tree'

require 'custom.plugins.files'
require 'custom.plugins.noice'
require 'custom.plugins.tabs'
require 'custom.plugins.statusline'
require 'custom.plugins.cursor'
require 'custom.plugins.highlights'
