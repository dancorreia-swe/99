local Context = require("99.ops.context")
local Location = require("99.editor.location")
local Logger = require("99.logger.logger")
local Request = require("99.request")
local editor = require("99.editor")
local geo = require("99.geo")
local Range = geo.Range
local Point = geo.Point

local function update_code(request, ok, res)
    if not ok then
        error("unable to implement function.  check logger for more details")
    end
    Logger:fatal("not implemented yet")
end

--- @param _99 _99.State
--- @return _99.Request
local function implement_fn(_99)
    local ts = editor.treesitter
    local cursor = Point:from_cursor()
    local scopes = ts.function_scopes(cursor)

    local range = scopes:get_inner_scope()

    local context = Context.new(_99)
    local request = Request.new({
        on_complete = update_code,
        model = _99.model,
        context = context,
    })
    local ts = editor.treesitter
    local ident = ts.identifier(request.buffer, request.cursor)

    print_ident(ident)

    if not ident then
        Logger:error(
            "implement_fn was called but cursor was not on a function call",
            "cursor",
            request.cursor
        )
        return nil
    end

    Range:from_ts_node(ident, request.buffer)

    return request
end

return implement_fn
