-- luacheck: globals describe it assert
local _99 = require("99")
local test_utils = require("99.test.test_utils")
local M = {}
local eq = assert.are.same

--- @param content string[]
--- @return _99.Provider, number
local function setup(content)
    local p = test_utils.TestProvider.new()
    _99.setup({
        provider = p,
    })

    local buffer = test_utils.create_file(content, "lua", 2)
    return p, buffer
end

--- @param buffer number
--- @return string[]
local function r(buffer)
    return vim.api.nvim_buf_get_lines(buffer, 0, -1)
end

describe("fill_in_function", function()
    it("should fill in function that multiple lines", function()
        local p, buffer = setup(M.empty_function_2_lines)
        _99.fill_in_function()

        local expected_state = {
            "",
            "function foo()",
            "",
            "",
            "",
            "end",
            "",
        }
        eq(expected_state, r(buffer))
    end)
end)

M.empty_function_2_lines = {
    "",
    "function foo()",
    "end",
    "",
}

M.empty_function_single_line = {
    "",
    "function foo() end",
    "",
}
