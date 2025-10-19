vim.loader.enable()
vim.opt.rtp:append(vim.fn.stdpath("config") .. "/lua")

vim.opt.nu = true
vim.opt.relativenumber = false
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.undodir"
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.colorcolumn = ""
vim.opt.winborder = "rounded"

vim.pack.add({
    { src = "https://github.com/Mofiqul/vscode.nvim" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-telescope/telescope.nvim",            dependencies = { 'nvim-lua/plenary.nvim' } },
    { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim", build = 'make' },
    { src = "https://github.com/Saghen/blink.cmp",                         build = 'cargo build --release' },
})

require("nvim-treesitter.configs").setup({
    ensure_installed = { "cpp", "lua", "cmake", "glsl", "python" },
    highlight = { enable = true }
})
require('telescope').setup {
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        }
    }
}
require('telescope').load_extension('fzf')
require('blink.cmp').setup({
    completion = {
        accept = {
            auto_brackets = {
                enabled = true
            },
        },
        list = {
            selection = {
                preselect = true,
                auto_insert = false
            }
        },
    },
    keymap = {
        ['<C-space>'] = { 'show', 'show_documentation', 'fallback' },
        ['<Tab>'] = { 'select_and_accept', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback'},
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<Esc>'] = { 'hide', 'fallback' },
        --['<C-Up>'] = { 'scroll_documentation_up' },
        --['<C-Down>'] = { 'scroll_documentation_down' },
        --['<S-Up>'] = { 'snippet_forward' },
        --['<S-Down>'] = { 'snippet_backward' },
        --['<C-k>'] = { 'show_signature', 'hide_signature' },
    },
    appearance = {
        nerd_font_variant = 'mono',
    },
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
            lsp = {
                name = "lsp",
                enabled = true,
                module = "blink.cmp.sources.lsp",
                min_keyword_length = 0,
                score_offset = 50,
                opts = {
                    transform_items = function(items)
                        local function sanitize(val)
                            if val == vim.NIL then
                                return nil
                            elseif type(val) == "userdata" then
                                return tostring(val)
                            elseif type(val) == "table" then
                                local clean = {}
                                for k, v in pairs(val) do
                                    clean[k] = sanitize(v)
                                end
                                return clean
                            else
                                return val
                            end
                        end

                        for i, item in ipairs(items) do
                            items[i] = sanitize(item)
                        end

                        return items
                    end,
                },
            },
            path = {
                name = "Path",
                module = "blink.cmp.sources.path",
                score_offset = 10000,
                fallbacks = { "snippets", "buffer" },
                min_keyword_length = 0,
                opts = {
                    trailing_slash = false,
                    label_trailing_slash = true,
                    get_cwd = function(context)
                        return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
                    end,
                    show_hidden_files_by_default = true,
                },
            },
            buffer = {
                name = "Buffer",
                enabled = true,
                max_items = 3,
                module = "blink.cmp.sources.buffer",
                min_keyword_length = 2,
                score_offset = 20,
            },
            snippets = {
                name = "snippets",
                enabled = true,
                max_items = 15,
                min_keyword_length = 2,
                module = "blink.cmp.sources.snippets",
                score_offset = 30,
            },
            vimtex = {
                name = "vimtex",
                min_keyword_length = 2,
                module = "blink.compat.source",
                score_offset = 25,
            },
        },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
})

vim.lsp.config('*', {
    capabilities = require('blink.cmp').get_lsp_capabilities(),
})

vim.lsp.enable({ "clangd", "lua_ls", "cmake", "pyright" --[["glsl_analyzer"]] })

vim.g.mapleader = " "

vim.keymap.set("n", "<leader>e", ":Ex<CR>")
vim.keymap.set("n", "<leader>w", ":write<CR>")
vim.keymap.set("n", "<leader>q", ":quit<CR>")
vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>")
vim.keymap.set("n", "<leader>f", function()
    local filetypes = { c = true, cpp = true, h = true, hpp = true, objc = true, objcpp = true, cuda = true, }
    local ft = vim.bo.filetype
    if filetypes[ft] then
        vim.cmd("write")
        vim.cmd("!clang-format -i %")
        vim.cmd("edit")
    else
        vim.lsp.buf.format({ async = true })
    end
end)
vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y<CR>')
vim.keymap.set("n", "K", "")
vim.keymap.set("n", "<Tab>", vim.lsp.buf.hover)
--vim.keymap.set("n", "<C-x>", vim.lsp.buf.signature_help)
vim.keymap.set("n", "<leader>g", require("telescope.builtin").lsp_document_symbols, { desc = "Find Symbols" })
vim.keymap.set("n", "<leader>m", require("telescope.builtin").live_grep, { desc = "Search in Buffers" })
vim.keymap.set("n", "<leader>s", function()
    require("telescope.builtin").find_files({
        hidden = true,
        --no_ignore = true,
    })
end, { desc = "Search Files" })
vim.keymap.set("n", "<leader>b", function()
    vim.fn.jobstart(
        {
            "xfce4-terminal", "-e",
            "bash -c 'cmake -S ~/Dev/DVL -B ~/Dev/DVL/build; cmake --build ~/Dev/DVL/build --verbose -- -j$(nproc); ~/Dev/DVL/build/DVL; echo; echo \"Press any key to close...\"; read -n 1 -s'",
        },
        { detach = true }
    )
end, { noremap = true })
vim.keymap.set('n', '<leader>d', require('telescope.builtin').diagnostics, {})
vim.keymap.set('n', '<CR>', function()
    require('telescope.builtin').lsp_references({
        include_declaration = true,
    })
end, { buffer = bufnr, silent = true })
vim.keymap.set('n', '<leader><space>', vim.diagnostic.open_float)

vim.cmd("colorscheme vscode")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

--[[vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end
})
vim.cmd("set completeopt+=noselect")]]
