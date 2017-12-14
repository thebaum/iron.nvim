-- luacheck: globals unpack vim
local strings = require("iron.strings")
local functional = require("iron.util.functional")
local nvim = vim.api
local default_fts = require('iron.fts')
local core = {}

local get_from_memory = function(config, memory, ft)
  return config.memory_management.get(memory, ft)
end

local set_on_memory = function(config, memory, ft, fn)
  return config.memory_management.set(memory, ft, fn)
end

core.get_preferred_repl = function(config, fts, ft)
  local repl = fts[ft]
  local repl_def = config.preferred[ft]
  if repl_def == nil then
    -- TODO Find a better way to select preferred repl
    for k, v in pairs(repl) do
      if os.execute('which ' .. k .. ' > /dev/null') == 0 then
        return v
      end
    end
  end
end

core.create_new_repl = function(config, ft)
  nvim.nvim_command(config.repl_open_cmd .. '| enew | set wfw | startinsert')
  local repl = core.get_preferred_repl(config, default_fts, ft)
  local job_id = nvim.nvim_call_function('termopen', {{repl.command}})
  local buffer_id = nvim.nvim_call_function('bufnr', {'%'})
  return { job = job_id, buffer = buffer_id, definition = repl}
end

core.ensure_repl = function(config, memory, ft)
  local mem = get_from_memory(config, memory, ft)
  if mem == nil then
    core.get_repl(config, memory, ft)
  end
end

core.get_repl = function(config, memory, ft)
  local mem = get_from_memory(config, memory, ft)
  local newfn = function() return core.create_new_repl(config, ft) end
  local showfn = function()
    nvim.nvim_command(config.repl_open_cmd .. '| b ' .. mem.buffer ..' | set wfw | startinsert')
  end
  if mem == nil then
    mem = set_on_memory(config, memory, ft, newfn)
  else
    config.visibility(mem.buffer, newfn, showfn)
  end
  return mem
end

core.send_to_repl = function(config, memory, ft, data)
  local dt

  if type(data) == string then
    dt = strings.split(data, '\n')
  else
    dt = data
  end

  local mem = get_from_memory(config, memory, ft)
  nvim.nvim_call_function('jobsend', {mem.job, mem.definition.format(dt)})
end

return core
