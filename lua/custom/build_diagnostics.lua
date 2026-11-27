local M = {}
local running = false

function M.search()
  if running then return vim.notify 'A .NET build is already running' end
  local start = vim.api.nvim_buf_get_name(0)
  start = start ~= '' and vim.fs.dirname(start) or vim.fn.getcwd()
  local function find(pattern)
    return vim.fs.find(function(name) return name:match(pattern) ~= nil end, { path = start, upward = true, type = 'file' })[1]
  end
  local target = find '%.slnx?$' or find '%.csproj$'
  if not target then return vim.notify('No .NET solution or C# project found above this file', vim.log.levels.WARN) end
  vim.cmd 'wall'
  running = true
  vim.notify('Building ' .. vim.fs.basename(target) .. '…')
  local ok, err = pcall(
    vim.system,
    {
      'dotnet',
      'build',
      target,
      '--nologo',
      '--verbosity',
      'quiet',
      '-consoleloggerparameters:NoSummary',
      '-p:GenerateFullPaths=true',
    },
    { cwd = vim.fs.dirname(target), text = true, env = { MSBUILDTERMINALLOGGER = 'off' } },
    vim.schedule_wrap(function(result)
      running = false
      local output = (result.stdout or '') .. '\n' .. (result.stderr or '')
      local items = vim.fn.getqflist({
        lines = vim.split(output, '\n'),
        efm = '%E%f(%l\\,%c): error %m,%E%f : error %m,%-G%.%#',
      }).items
      vim.fn.setqflist({}, ' ', { title = 'dotnet build: ' .. vim.fs.basename(target), items = items })
      if #items > 0 then
        require('telescope.builtin').quickfix { prompt_title = '.NET Build Errors' }
      elseif result.code == 0 then
        vim.notify 'Build succeeded'
      else
        vim.notify('Build failed (exit ' .. result.code .. '):\n' .. vim.trim(output), vim.log.levels.ERROR)
      end
    end)
  )
  if not ok then
    running = false
    vim.notify('Could not start dotnet build: ' .. tostring(err), vim.log.levels.ERROR)
  end
end

return M
