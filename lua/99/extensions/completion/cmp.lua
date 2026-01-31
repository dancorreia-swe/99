local base = require("99.extensions.completion.base")
local SOURCE = "99"

--- @class CmpSource
--- @field items _99.Extensions.CompletionItem[]
local CmpSource = {}
CmpSource.__index = CmpSource

--- @param _99 _99.State
function CmpSource.new(_99)
  return setmetatable({
    items = base.build_items(_99),
  }, CmpSource)
end

function CmpSource.is_available()
  return true
end

function CmpSource.get_debug_name()
  return SOURCE
end

function CmpSource.get_keyword_pattern()
  return [[@\k\+]]
end

function CmpSource.get_trigger_characters()
  return { "@" }
end

--- @param _ table
--- @param callback fun(result: table): nil
function CmpSource:complete(_, callback)
  local items = base.to_lsp_items(self.items)

  callback({
    items = items,
    isIncomplete = false,
  })
end

--- @type CmpSource | nil
local source = nil

--- @param _ _99.State
local function init_for_buffer(_)
  local cmp = require("cmp")
  cmp.setup.buffer({
    sources = {
      { name = SOURCE },
    },
    window = {
      completion = {
        zindex = 1001,
      },
      documentation = {
        zindex = 1001,
      },
    },
  })
end

--- @param _99 _99.State
local function init(_99)
  assert(
    source == nil,
    "the source must be nil when calling init on a completer"
  )

  local cmp = require("cmp")
  source = CmpSource.new(_99)
  cmp.register_source(SOURCE, source)
end

--- @param _99 _99.State
local function refresh_state(_99)
  if not source then
    return
  end
  source.items = base.build_items(_99)
end

--- @type _99.Extensions.Source
local source_wrapper = {
  init_for_buffer = init_for_buffer,
  init = init,
  refresh_state = refresh_state,
}
return source_wrapper
