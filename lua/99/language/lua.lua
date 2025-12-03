local M = {}

--- @param lines number
--- @param location _99.Location
--- @return number
function M.add_function_spacing(lines, location)
    local buffer = location.buffer
    local range = location.range
    local end_row, end_col = range.end_:to_vim()
    local start_row, _ = range.start:to_vim()
    local start_new_line_col = math.max(0, end_col - 4)
    local new_lines = {}

    for _ = 1, lines do
        table.insert(new_lines, "")
    end
    if start_row == end_row then
        table.insert(new_lines, "")
    end
    table.insert(new_lines, "end")

    vim.api.nvim_buf_set_text(
        buffer,
        end_row,
        start_new_line_col,
        end_row,
        end_col,
        new_lines
    )
    return end_row
end

return M
