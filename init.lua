-- Leaders and editor settings must be configured before plugins.
require 'config.options'
require 'config.keymaps'
require 'config.autocmds'

-- Register build hooks before installing or loading plugins.
require 'config.pack'
require 'custom.plugins'
