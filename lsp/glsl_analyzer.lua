---@brief
---
--- https://github.com/nolanderc/glsl_analyzer
---
--- Language server for GLSL
local caps = vim.lsp.protocol.make_client_capabilities()
caps.textDocument.completion.editsNearCursor = true
caps.textDocument.completion.completionItem.snippetSupport = false
caps.offsetEncoding = { 'utf-8', 'utf-16' }

return {
    cmd = { 'glsl_analyzer' },
    filetypes = { 'glsl', 'vert', 'tesc', 'tese', 'frag', 'geom', 'comp', 'rchit', 'rgen', 'rint', 'rmiss', 'rahit', 'rcall' },
    root_markers = { '.git' },
    capabilities = caps,
}
