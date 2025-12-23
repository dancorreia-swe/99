-- luacheck: globals describe it assert
local _99 = require("99")
local test_utils = require("99.test.test_utils")
local eq = assert.are.same
local test_content = require("99.test.test_content")

--- @param content string[]
--- @return _99.test.Provider, number
local function setup(content)
    local p = test_utils.TestProvider.new()
    _99.setup({
        provider = p,
    })

    local buffer = test_utils.create_file(content, "lua", 3, 3)
    return p, buffer
end

--- @param buffer number
--- @return string[]
local function r(buffer)
    return vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
end

describe("implement_function", function()
    it("basic call", function()
        local p, buffer = setup(test_content.function_with_unknown_fn_call)
        _99.implement_fn()
        eq(test_content.function_with_unknown_fn_call, r(buffer))

        p:resolve("success", "function bar()\n  return 42\nend")
        test_utils.next_frame()

        local expected_state = {
            "function some_other_function() end",
            "function bar()",
            "  return 42",
            "end",
            "function foo()",
            "  bar()",
            "end",
            "",
        }
        eq(expected_state, r(buffer))
    end)

    it("should cancel request when stop_all_requests is called", function() end)
end)
