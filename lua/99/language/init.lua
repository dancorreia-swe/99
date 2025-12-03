local Logger = require("99.logger.logger")
local Range = require("99.geo").Range

--- @class _99.LanguageOps
--- @field add_function_spacing fun(lines: number, location: _99.Location): number

--- @class _99.Langauges
--- @field languages table<string, _99.LanguageOps>
local M = {
    languages = {},
}

--- @param _99 _99.State
function M.initialize(_99)
    M.languages = {}
    for _, lang in ipairs(_99.languages) do
        M.languages[lang] = require("99.language." .. lang)
        assert(
            type(M.languages[lang].add_function_spacing) == "function",
            "add_function_spacing not provided by language"
        )
    end
end

--- @param _99 _99.State
--- @param location _99.Location
--- @return number
function M.add_function_spacing(_99, location)
    local lang = M.languages[location.file_type]
    print(
        "language",
        "file_type",
        vim.inspect(location.file_type),
        "lang",
        vim.inspect(lang)
    )
    if not lang then
        Logger:fatal("langauge currently not supported", "lang", lang)
    end

    if type(lang.add_function_spacing) ~= "function" then
        Logger:fatal(
            "language does not support add_function_spacing",
            "lang",
            lang
        )
    end

    if _99.ai_stdout_rows == 0 then
        Logger:debug(
            "ai_stdout_rows is 0, so no ai indicators will be displayed inline"
        )
        return -1
    end

    local end_row = lang.add_function_spacing(_99.ai_stdout_rows, location)
    if end_row == -1 then
        Logger:fatal("add_function_spacing failed", "lang", lang)
    end

    return end_row
end

return M
