R("99")

function test_function()
    return 42
end

function test_empty() end

function test_body()
    local ts = require("99.editor.treesitter")
    local Point = require("99.geo").Point
    local Lang = require("99.language")
    local cursor = Point:from_cursor()
    local func = ts.containing_function(0, cursor)

end

test_body()
