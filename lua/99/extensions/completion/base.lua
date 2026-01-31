local Agents = require("99.extensions.agents")
local Helpers = require("99.extensions.agents.helpers")

local M = {}

-- LSP CompletionItemKind.File
M.KIND_FILE = 17

--- @class _99.Extensions.CompletionItem
--- @field rule _99.Agents.Rule
--- @field docs string

--- @param _99 _99.State
--- @return _99.Extensions.CompletionItem[]
function M.build_items(_99)
  local rules = Agents.rules_to_items(_99.rules)
  local out = {}
  for _, rule in ipairs(rules) do
    table.insert(out, {
      rule = rule,
      docs = Helpers.head(rule.path),
    })
  end
  return out
end

--- @param items _99.Extensions.CompletionItem[]
--- @param kind number?
--- @return table[]
function M.to_lsp_items(items, kind)
  kind = kind or M.KIND_FILE
  local out = {}
  for _, item in ipairs(items) do
    table.insert(out, {
      label = item.rule.name,
      insertText = item.rule.name,
      filterText = "@" .. item.rule.name,
      kind = kind,
      documentation = {
        kind = "markdown",
        value = item.docs,
      },
      detail = item.rule.path,
    })
  end
  return out
end

return M
