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
vim.g.netrw_liststyle = 4
vim.g.netrw_sort_sequence = [[[/]$,*,\(\.bak\|\~\|\.o\|\.h\|\.hpp\|\.c\|\.cpp\|\.info\|\.swp\|\.obj\)[*@]\=$]]
vim.opt.virtualedit = "all"

vim.opt.list = true

vim.opt.listchars = {
    tab = "»·",
    space = "·",
}

vim.pack.add({
    { src = "https://github.com/Mofiqul/vscode.nvim" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" }, --requires manually running make in plugin directory
    { src = "https://github.com/hrsh7th/nvim-cmp" },
    { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
    { src = "https://github.com/hrsh7th/cmp-buffer" },
    { src = "https://github.com/hrsh7th/cmp-path" },
    { src = "https://github.com/L3MON4D3/LuaSnip" },
    { src = "https://github.com/HiPhish/rainbow-delimiters.nvim" },
})

local treesitter_filetypes = {
    "cpp", "c", "lua", "python", "json", "css", "html", "markdown", "cmake", "glsl", "slang"
}

require("nvim-treesitter").setup({})

require("nvim-treesitter").install(treesitter_filetypes)

vim.api.nvim_create_autocmd("FileType", {
    pattern = treesitter_filetypes,
    callback = function()
        vim.treesitter.start()
    end,
})

vim.filetype.add({
    extension = {
        hxx = "cpp",
        ipp = "cpp",
        tpp = "cpp",
        inl = "cpp",
        inc = "cpp",
        def = "cpp",
    },
})

local rainbow_delimiters = require 'rainbow-delimiters'

vim.g.rainbow_delimiters = {
    strategy = {
        [''] = rainbow_delimiters.strategy['global'],
    },
    query = {
        [''] = 'rainbow-delimiters',
    },
}

require('telescope').setup({
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        }
    }
})

require('telescope').load_extension('fzf')

vim.lsp.enable({
    "clangd",
    "lua_ls",
    "cmake",
    "pyright",
    "jsonls",
    "cssls",
    "html",
    "slangd",
    "glsl_analyzer"
})

local cmp = require("cmp")
cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<Tab>"] = cmp.mapping.confirm({ select = true }),
        ["<Down>"] = cmp.mapping.select_next_item(),
        ["<Up>"] = cmp.mapping.select_prev_item(),
    }),

    sources = {
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path" },
    },
})

vim.g.mapleader = " "

vim.keymap.set("n", "<Esc>", "a", { noremap = true })

vim.keymap.set({ "n", "v" }, "<Up>", "gk", { noremap = true })

vim.keymap.set({ "n", "v" }, "<Down>", "gj", { noremap = true })

vim.keymap.set("n", "<leader>e", ":Ex<CR>", { noremap = true })

vim.keymap.set("n", "<leader>t", ":terminal<CR>", { noremap = true })

vim.keymap.set("n", "<leader>w", ":write<CR>", { noremap = true })

vim.keymap.set("n", "<leader>q", ":quit<CR>", { noremap = true })

--vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>", { noremap = true })

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })

vim.keymap.set("n", "<leader>i", function()
    local enabled = vim.lsp.inlay_hint.is_enabled()
    vim.lsp.inlay_hint.enable(not enabled)
end, { noremap = true })

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { noremap = true })

vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y<CR>', { noremap = true })

vim.keymap.set("n", "<Tab>", vim.lsp.buf.hover, { noremap = true })

--vim.keymap.set("n", "<C-x>", vim.lsp.buf.signature_help)
vim.keymap.set("n", "<leader>+", vim.lsp.buf.code_action, { noremap = true })

vim.keymap.set("n", "<leader>g", require("telescope.builtin").lsp_document_symbols,
    { desc = "Find Symbols", noremap = true })

vim.keymap.set("n", "<leader>b", require("telescope.builtin").buffers, { desc = "Find Buffers", noremap = true })

vim.keymap.set("n", "<leader>z", function()
    if vim.bo.buftype ~= "terminal" then
        return
    end
    local cur = vim.api.nvim_get_current_buf()
    local prev = vim.fn.bufnr("#")
    if prev > 0 and vim.api.nvim_buf_is_loaded(prev) then
        vim.cmd("buffer " .. prev)
    else
        vim.cmd("bprevious")
    end
    if cur ~= vim.api.nvim_get_current_buf() then
        vim.cmd("bdelete! " .. cur)
    end
end)

vim.keymap.set("n", "<leader>m", require("telescope.builtin").live_grep, { desc = "Search in Buffers", noremap = true })

vim.keymap.set("n", "<leader>s", function()
    require("telescope.builtin").find_files({
        hidden = true,
        --no_ignore = true,
    })
end, { desc = "Search Files", noremap = true })

vim.keymap.set("n", "<leader>d", function()
    vim.cmd("terminal ./build_debug.sh")
end, { noremap = true })

vim.keymap.set("n", "<leader>r", function()
    vim.cmd("terminal ./build_release.sh")
end, { noremap = true })

vim.keymap.set("n", "<leader>c", function()
    vim.cmd("terminal ./debug_core_file.sh")
end, { noremap = true })

vim.keymap.set('n', '<leader>o', require('telescope.builtin').diagnostics, { noremap = true })

vim.keymap.set('n', '<CR>', function()
    require('telescope.builtin').lsp_references({
        include_declaration = true,
    })
end, { buffer = bufnr, silent = true, noremap = true })

vim.keymap.set('n', '<leader><space>', vim.diagnostic.open_float, { noremap = true })

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
