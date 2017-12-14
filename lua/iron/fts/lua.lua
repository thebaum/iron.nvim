local common = require('iron.fts.common')
local repl = {}


repl.lua = common.new("bracketed"){
  command = 'lua'
}

return repl
