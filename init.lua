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
vim.opt.linebreak = true
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
vim.opt.scrollback = 1000000

vim.opt.list = true

vim.opt.listchars = {
    tab = "|-",
    space = "·",
}

vim.pack.add({
    { src = "https://github.com/Mofiqul/vscode.nvim" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" }, --requires manually running make in plugin directory
    { src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
    { src = "https://github.com/hrsh7th/nvim-cmp" },
    { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
    { src = "https://github.com/hrsh7th/cmp-buffer" },
    { src = "https://github.com/hrsh7th/cmp-path" },
    { src = "https://github.com/L3MON4D3/LuaSnip" },
    { src = "https://github.com/saadparwaiz1/cmp_luasnip" },
    { src = "https://github.com/HiPhish/rainbow-delimiters.nvim" },
    { src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
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

local rainbow_delimiters = require('rainbow-delimiters')

vim.g.rainbow_delimiters = {
    strategy = {
        [''] = rainbow_delimiters.strategy['global'],
    },
    query = {
        [''] = 'rainbow-delimiters',
    },
}

require("ibl").setup({
    indent = {
        char = "┆",
    },
    scope = {
        enabled = true,
    },
})

local telescopeActions = require("telescope.actions")
local telescopeActionState = require("telescope.actions.state")

local function scrollResultsNext(prompt_bufnr)
    telescopeActionState.get_current_picker(prompt_bufnr).previewer:scroll_fn(1)
end

local function scrollResultsPrevious(prompt_bufnr)
    telescopeActionState.get_current_picker(prompt_bufnr).previewer:scroll_fn(-1)
end

require('telescope').setup({
    defaults = {
        layout_strategy = "horizontal",
        layout_config = {
            horizontal = {
                width = 0.9,
                height = 0.9,
                preview_width = 0.4,
                prompt_position = "bottom",
                mirror = false,
            },
        },
        --scroll_strategy = "limit",
        mappings = {
            i = {
                ["<S-Up>"] = telescopeActions.results_scrolling_up,
                ["<S-Down>"] = telescopeActions.results_scrolling_down,

                ["<C-Up>"] = scrollResultsPrevious,
                ["<C-Down>"] = scrollResultsNext,

                ["<C-S-Up>"] = telescopeActions.preview_scrolling_up,
                ["<C-S-Down>"] = telescopeActions.preview_scrolling_down,
            },
            n = {
                ["<S-Up>"] = telescopeActions.results_scrolling_up,
                ["<S-Down>"] = telescopeActions.results_scrolling_down,

                ["<C-Up>"] = scrollResultsPrevious,
                ["<C-Down>"] = scrollResultsNext,

                ["<C-S-Up>"] = telescopeActions.preview_scrolling_up,
                ["<C-S-Down>"] = telescopeActions.preview_scrolling_down,
            },
        },
    },
    extensions = {
        ["fzf"] = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
        ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
        },
    },
})

vim.api.nvim_create_autocmd("User", {
    pattern = "TelescopePreviewerLoaded",
    callback = function()
        vim.wo.wrap = true
        vim.wo.linebreak = true
    end,
})

require('telescope').load_extension("fzf")
require("telescope").load_extension("ui-select")
local telescopeBuiltin = require("telescope.builtin")

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

local luasnip = require("luasnip")
luasnip.add_snippets("cpp", dofile(vim.fn.stdpath("config") .. "/snippets/cpp.lua"))

local cmp = require("cmp")
cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },

    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<Down>"] = cmp.mapping.select_next_item(),
        ["<Up>"] = cmp.mapping.select_prev_item(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),

    sources = cmp.config.sources({
        { name = "path",     priority = 1000 },
        { name = "luasnip",  priority = 750 },
        { name = "nvim_lsp", priority = 500 },
        { name = "buffer",   priority = 250 },
    }),
})

vim.g.mapleader = " "

vim.keymap.set("n", "<Esc>", "a", { noremap = true })

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })

vim.keymap.set({ "n", "v" }, "<Up>", "gk", { noremap = true })

vim.keymap.set({ "n", "v" }, "<Down>", "gj", { noremap = true })

vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==", { noremap = true, silent = true })
vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", { noremap = true, silent = true })

vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })

vim.keymap.set({ "i", "s" }, "<Tab>", function()
    if luasnip.jumpable(1) then
        luasnip.jump(1)
        return ""
    end
    return "<Tab>"
end, { expr = true, silent = true })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
    if luasnip.jumpable(-1) then
        luasnip.jump(-1)
        return ""
    end
    return "<S-Tab>"
end, { expr = true, silent = true })

vim.keymap.set("n", "<leader>e", ":Ex<CR>", { noremap = true })

vim.keymap.set("n", "<leader>t", ":terminal<CR>", { noremap = true })

vim.keymap.set("n", "<leader>r", function()
    local root = vim.fn.getcwd()
    local scripts = {}
    for _, pattern in ipairs({ "**/*.sh", "**/*.bat" }) do
        local matches = vim.fn.globpath(root, pattern, false, true)
        table.move(matches, 1, #matches, #scripts + 1, scripts)
    end
    vim.ui.select(
        scripts,
        {
            prompt = "Run Script",
            format_item = function(path)
                return path
            end,
        },
        function(choice) if choice then vim.cmd("terminal" .. choice) end end
    )
end, { noremap = true })

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

vim.keymap.set("n", "<leader>w", ":wa<CR>", { noremap = true })

vim.keymap.set("n", "<leader>q", ":q<CR>", { noremap = true })

vim.keymap.set("n", "<leader>b", function()
    local buffers = vim.tbl_filter(function(buf)
        return vim.api.nvim_buf_is_valid(buf)
            and vim.api.nvim_buf_is_loaded(buf)
    end, vim.api.nvim_list_bufs())

    local items = vim.tbl_map(function(buf)
        return {
            buf = buf,
            name = vim.api.nvim_buf_get_name(buf),
        }
    end, buffers)

    vim.ui.select(items, {
        prompt = "Buffer:",
        format_item = function(item)
            return item.name ~= "" and item.name or "[No Name]"
        end,
    }, function(item)
        if not item then
            return
        end

        vim.ui.select({ "Open", "Delete" }, {
            prompt = "Action:",
        }, function(action)
            if action == "Open" then
                vim.api.nvim_set_current_buf(item.buf)
            elseif action == "Delete" then
                vim.api.nvim_buf_delete(item.buf, {})
            end
        end)
    end)
end, { desc = "Buffer menu" })

vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y<CR>', { noremap = true })

vim.keymap.set("n", "<leader>l", function()
    local file = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.")
    local line = vim.fn.line(".")
    local text = string.format("%s:%d", file, line)

    vim.fn.setreg("+", text)
    vim.notify("Copied current location")
end, { noremap = true })

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { noremap = true })

vim.keymap.set("n", "<leader>i", function()
    local enabled = vim.lsp.inlay_hint.is_enabled()
    vim.lsp.inlay_hint.enable(not enabled)
end, { noremap = true })

vim.keymap.set("n", "<Tab>", vim.lsp.buf.hover, { noremap = true })

vim.keymap.set('n', '<leader>s', function()
    vim.ui.select(
        {
            { "Files",                 function() telescopeBuiltin.find_files({ hidden = true, follow = true }) end },
            { "Grep",                  function() telescopeBuiltin.live_grep({ hidden = true, follow = true }) end },
            { "Grep Current Buffer",   function() telescopeBuiltin.current_buffer_fuzzy_find({ case_mode = "smart_case" }) end },
            { "Recent Files",          function() telescopeBuiltin.oldfiles({ cwd_only = true }) end },

            { "LSP Symbols",           telescopeBuiltin.lsp_document_symbols },
            { "LSP Workspace Symbols", telescopeBuiltin.lsp_dynamic_workspace_symbols },

            { "Git Files",             function() telescopeBuiltin.git_files({ show_untracked = true }) end },
            { "Git Commits",           telescopeBuiltin.git_commits },
            { "Git BCommits",          telescopeBuiltin.git_bcommits },
            { "Git Status",            telescopeBuiltin.git_status },
            { "Git Branches",          telescopeBuiltin.git_branches },

            { "Diagnostics",           function() telescopeBuiltin.diagnostics({ bufnr = 0 }) end },
            { "Workspace Diagnostics", telescopeBuiltin.diagnostics },
            { "Quickfix",              telescopeBuiltin.quickfix },
            { "Location List",         telescopeBuiltin.loclist },

            { "Keymaps",               telescopeBuiltin.keymaps },
            { "Commands",              telescopeBuiltin.commands },
            { "Help",                  telescopeBuiltin.help_tags },
            { "Man Pages",             telescopeBuiltin.man_pages },
            { "Colorschemes",          telescopeBuiltin.colorscheme },
            { "Marks",                 telescopeBuiltin.marks },
            { "Jumplist",              telescopeBuiltin.jumplist },
            { "Registers",             telescopeBuiltin.registers },
            { "Autocommands",          telescopeBuiltin.autocommands },
            { "Options",               telescopeBuiltin.vim_options },

            { "Treesitter Symbols",    telescopeBuiltin.treesitter },
            { "Resume Last Telescope", telescopeBuiltin.resume },
            { "Pickers",               telescopeBuiltin.builtin },
        },
        {
            prompt = "Search Actions",
            format_item = function(item) return item[1] end,
        },
        function(choice) if choice then choice[2]() end end
    )
end, { noremap = true })

vim.keymap.set('n', '<leader><space>', vim.diagnostic.open_float, { noremap = true })

vim.keymap.set('n', '<leader>o', telescopeBuiltin.diagnostics, { noremap = true })

vim.keymap.set('n', '<CR>', function()
    vim.ui.select(
        {
            { "Code Actions",          vim.lsp.buf.code_action },
            { "Definitions", function()
                telescopeBuiltin.lsp_definitions({
                    jump_type = "never",
                })
            end, },
            { "References", function()
                telescopeBuiltin.lsp_references({
                    include_declaration = true,
                    include_current_line = true,
                    jump_type = "never",
                })
            end },
            { "Rename",                vim.lsp.buf.rename },
            { "Go to Definition",      vim.lsp.buf.definition },
            { "Go to Declaration",     vim.lsp.buf.declaration },
            { "Go to Type Definition", vim.lsp.buf.type_definition },
            { "Go to Implementation",  vim.lsp.buf.implementation },
            { "Incoming Calls",        vim.lsp.buf.incoming_calls },
            { "Outgoing Calls",        vim.lsp.buf.outgoing_calls },
            { "Signature Help",        vim.lsp.buf.signature_help },
        },
        {
            prompt = "LSP Symbol Actions",
            format_item = function(item) return item[1] end,
        },
        function(choice) if choice then choice[2]() end end
    )
end, { silent = true, noremap = true })

vim.keymap.set("n", "<leader>lll", function()
    local path = vim.fn.getcwd() .. "/LICENSE.md"
    local lines = vim.fn.readfile(path)
    if vim.v.shell_error ~= 0 or #lines == 0 then
        vim.notify("Could not read LICENCE.md", vim.log.levels.ERROR)
        return
    end
    local output = {}
    table.insert(output, "/*")
    for _, line in ipairs(lines) do
        table.insert(output, " * " .. line)
    end
    table.insert(output, " */")
    vim.api.nvim_put(output, "c", false, true)
end, { noremap = true, silent = true, desc = "Paste custom text" })

vim.cmd("colorscheme vscode")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
