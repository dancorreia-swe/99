local geo = require("99.geo")
local Logger = require("99.logger.logger")
local Range = geo.Range

--- @class TSNode
--- @field start fun(self: TSNode): number, number, number
--- @field end_ fun(self: TSNode): number, number, number
--- @field named fun(self: TSNode): boolean
--- @field type fun(self: TSNode): string
--- @field range fun(self: TSNode): number, number, number, number

local M = {}

local function_query = "99-function"
local imports_query = "99-imports"
local identifier_query = "99-identifier"

--- @param buffer number
---@param lang string
local function tree_root(buffer, lang)
    -- Load the parser and the query.
    local ok, parser = pcall(vim.treesitter.get_parser, buffer, lang)
    if not ok then
        return nil
    end

    local tree = parser:parse()[1]
    return tree:root()
end

--- @param buffer number
--- @param cursor Point
--- @return TSNode | nil
function M.identifier(buffer, cursor)
    local lang = vim.bo[buffer].ft
    local root = tree_root(buffer, lang)
    if not root then
        Logger:error(
            "unable to find treeroot, this should never happen",
            "buffer",
            buffer,
            "lang",
            lang
        )
        return nil
    end

    local ok, query = pcall(vim.treesitter.query.get, lang, identifier_query)
    if not ok or query == nil then
        Logger:error(
            "unable to get the identifier_query",
            "lang",
            lang,
            "buffer",
            buffer,
            "ok",
            type(ok),
            "query",
            type(query)
        )
        return nil
    end

    --- likely something that needs to be done with treesitter#get_node
    local found = nil
    for _, match, _ in query:iter_matches(root, buffer, 0, -1, { all = true }) do
        for _, nodes in pairs(match) do
            for _, node in ipairs(nodes) do
                local range = Range:from_ts_node(node, buffer)
                if range:contains(cursor) then
                    found = node
                    goto end_of_loops
                end
            end
        end
    end
    ::end_of_loops::

    Logger:debug("treesitter#identifier", "found", found)

    return found
end

--- @class Scope
--- @field scope TSNode[]
--- @field range Range[]
--- @field buffer number
--- @field cursor Point
local Scope = {}
Scope.__index = Scope

--- @param cursor Point
--- @param buffer number
--- @return Scope
function Scope:new(cursor, buffer)
    return setmetatable({
        scope = {},
        range = {},
        buffer = buffer,
        cursor = cursor,
    }, self)
end

--- @return boolean
function Scope:has_scope()
    return #self.range > 0
end

--- @return TSNode | nil
function Scope:get_inner_scope()
    return self.scope[#self.scope]
end

--- @return Range | nil
function Scope:get_inner_range()
    return self.range[#self.range]
end

--- @param node TSNode
function Scope:push(node)
    local range = Range:from_ts_node(node, self.buffer)
    if not range:contains(self.cursor) then
        return
    end

    table.insert(self.range, range)
    table.insert(self.scope, node)
end

function Scope:finalize()
    assert(#self.range == #self.scope, "range scope mismatch")
    table.sort(self.range, function(a, b)
        return a:contains_range(b)
    end)
end

--- @param cursor Point
--- @param buffer number?
--- @return Scope
function M.function_scopes(cursor, buffer)
    buffer = buffer or vim.api.nvim_get_current_buf()
    local scope = Scope:new(cursor, buffer)

    local lang = vim.bo[buffer].ft
    local root = tree_root(buffer, lang)
    if not root then
        Logger:debug("LSP: could not find tree root")
        return scope
    end

    local ok, query = pcall(vim.treesitter.query.get, lang, function_query)
    if not ok or query == nil then
        Logger:debug(
            "LSP: not ok or query",
            "query",
            vim.inspect(query),
            "lang",
            lang,
            "ok",
            vim.inspect(ok)
        )
        return scope
    end

    for id, node, _ in query:iter_captures(root, buffer, 0, -1, { all = true }) do
        local name = query.captures[id]
        print("cursor query captures", "id", id, "name", name)
        if name == "context.scope" then
            scope:push(node)
        elseif name == "context.body" then
            -- scope:push(node)
        end
    end

    scope:finalize()

    return scope
end

--- @return TSNode[]
function M.imports()
    assert(false, "not implemented")
    local root = tree_root()
    if not root then
        return {}
    end

    local buffer = vim.api.nvim_get_current_buf()
    local ok, query = pcall(vim.treesitter.query.get, vim.bo.ft, imports_query)

    if not ok or query == nil then
        return {}
    end

    local imports = {}
    for _, match, _ in query:iter_matches(root, buffer, 0, -1, { all = true }) do
        for id, nodes in pairs(match) do
            local name = query.captures[id]
            if name == "import.name" then
                for _, node in ipairs(nodes) do
                    table.insert(imports, node)
                end
            end
        end
    end

    return imports
end

return M
