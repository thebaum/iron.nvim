-- luacheck: globals insulate setup describe it assert mock
-- luacheck: globals before_each after_each

insulate("About #functional code", function()
  local fn = require('iron.util.functional')

  describe("#keys", function()
    it("Should return the first item", function()
      local dt = {head = "z", second = "y", last = "x"}
      assert.are_same({"last", "second", "head"}, fn.keys(dt))
      end)
  end)

end)

