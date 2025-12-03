local marks_to_use = "yuiophjklnm"
local mark_index = 0

--- @param buffer number
---@param range Range
---@return string
local function mark_function(buffer, range)
    local start_row, start_col = range.start:to_vim()
    local idx = (mark_index + 1) % #marks_to_use
    local mark = marks_to_use:sub(idx, idx)

    vim.api.nvim_buf_set_mark(buffer, mark, start_row + 1, start_col, {})

    mark_index = idx
    return mark
end

return mark_function
