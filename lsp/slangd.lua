---@brief
---
--- https://github.com/shader-slang/slang
---
--- The `slangd` binary can be downloaded as part of [slang releases](https://github.com/shader-slang/slang/releases) or
--- by [building `slang` from source](https://github.com/shader-slang/slang/blob/master/docs/building.md).
---
--- The server can be configured by passing a "settings" object to vim.lsp.config('slangd'):
---
--- ```lua
--- vim.lsp.config('slangd', {
---   settings = {
---     slang = {
---       predefinedMacros = {"MY_VALUE_MACRO=1"},
---       inlayHints = {
---         deducedTypes = true,
---         parameterNames = true,
---       }
---     }
---   }
--- })
--- ```
--- Available options are documented [here](https://github.com/shader-slang/slang-vscode-extension/tree/main?tab=readme-ov-file#configurations)
--- or in more detail [here](https://github.com/shader-slang/slang-vscode-extension/blob/main/package.json#L70).

local function set_dotted(tbl, key, value)
    local parts = vim.split(key, '.', { plain = true })
    for i = 1, #parts - 1 do
        tbl[parts[i]] = tbl[parts[i]] or {}
        tbl = tbl[parts[i]]
    end
    tbl[parts[#parts]] = value
end

local function load_slangdconfig(root)
    local f = io.open(root .. '/slangdconfig.json', 'r')
    if not f then return nil end
    local ok, json = pcall(vim.json.decode, f:read('*a'))
    f:close()
    if not ok or type(json) ~= 'table' then return nil end

    local settings = {}
    for key, value in pairs(json) do set_dotted(settings, key, value) end

    local paths = settings.slang and settings.slang.additionalSearchPaths
    if paths then
        for i, p in ipairs(paths) do
            if not p:match('^/') then paths[i] = vim.fs.normalize(root .. '/' .. p) end
        end
    end
    return settings
end

local bin_name = 'slangd'

if vim.fn.has 'win32' == 1 then
    bin_name = 'slangd.exe'
end

return {
    cmd = { bin_name },
    filetypes = { 'hlsl', 'shaderslang', 'slang', 'shader' },
    root_markers = { 'slangdconfig.json', '.git' },
    on_init = function(client)
        local settings = client.root_dir and load_slangdconfig(client.root_dir)
        if not settings then return end
        client.settings = vim.tbl_deep_extend('force', client.settings or {}, settings)
        client.config.settings = client.settings
        client:notify('workspace/didChangeConfiguration', { settings = client.settings })
    end,

}
