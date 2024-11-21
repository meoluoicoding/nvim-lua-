-- Set options
vim.o.mouse = 'a'
vim.o.autoindent = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.wo.number = true
vim.wo.cursorline = true

-- Set leader to comma
vim.g.mapleader = ','

-- Install packer.nvim if not installed
local packer_exists = pcall(vim.cmd, [[packadd packer.nvim]])
if not packer_exists then
    local packer_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    print('Downloading packer.nvim...')
    vim.fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', packer_path})
    vim.cmd('packadd packer.nvim')
end

-- Load packer and start setup
return require('packer').startup(function()
    -- Packer itself
    use 'wbthomason/packer.nvim'

    -- Essential plugins
    use 'nvim-lua/plenary.nvim'
    use 'nvim-telescope/telescope.nvim'
    use 'hrsh7th/nvim-compe'     -- Auto-completion plugin
    use 'nvim-treesitter/nvim-treesitter'
    use 'kyazdani42/nvim-web-devicons'
    use 'tpope/vim-fugitive'      -- Optional: for Git integration

    -- UI plugins
    use 'akinsho/nvim-bufferline.lua'
    use 'kyazdani42/nvim-tree.lua'
    use 'glepnir/galaxyline.nvim'
    use 'hoob3rt/lualine.nvim'

    -- Additional plugins
    use 'folke/which-key.nvim'
    use 'nvim-lua/popup.nvim'
    use 'nvim-lua/lsp-status.nvim'
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'windwp/nvim-autopairs'
    use 'onsails/lspkind-nvim'
    use 'hrsh7th/cmp-buffer'
    use 'shaunsingh/nord.nvim'

    -- Vimwiki plugin
    use 'vimwiki/vimwiki'
    
    -- Markdown Preview 
    use 'iamcco/markdown-preview.nvim'

    -- Load nvim-tree.lua
    require'nvim-tree'.setup {}

    -- Key mappings (optional)
    vim.api.nvim_set_keymap('n', '<Leader>e', ':NvimTreeToggle<CR>', {noremap = true, silent = true})

    -- Configure bufferline
    require("bufferline").setup {
        options = {
            diagnostics = "nvim_lsp",
            separator_style = "thick",
            show_buffer_icons = true,
            show_close_icon = false,
            show_tab_indicators = true,
            persist_buffer_sort = true,
            enforce_regular_tabs = true,
            always_show_bufferline = true,
            offsets = {
                {
                    filetype = "NvimTree",
                    text = "File Explorer",
                    text_align = "center"
                }
            },
            custom_areas = {
                right = function()
                    local result = {}
                    local error = vim.lsp.diagnostic.get_count(0, [[Error]])
                    local warning = vim.lsp.diagnostic.get_count(0, [[Warning]])
                    local info = vim.lsp.diagnostic.get_count(0, [[Information]])
                    local hint = vim.lsp.diagnostic.get_count(0, [[Hint]])

                    if error ~= 0 then
                        table.insert(result, {text = "  " .. error, guifg = "#EC5241"})
                    end

                    if warning ~= 0 then
                        table.insert(result, {text = "  " .. warning, guifg = "#EFB839"})
                    end

                    if hint ~= 0 then
                        table.insert(result, {text = "  " .. hint, guifg = "#A3BA5E"})
                    end

                    if info ~= 0 then
                        table.insert(result, {text = "  " .. info, guifg = "#7EA9A7"})
                    end
                    return result
                end,
            }
        }
    }

    -- Configure lualine
    require('lualine').setup {
        options = {
            theme = 'nord',  -- Set your preferred theme
            icons_enabled = true,
            component_separators = {'', ''},
            section_separators = {'', ''},
            disabled_filetypes = {}
        },
        sections = {
            lualine_a = {'mode'},
            lualine_b = {'branch'},
            lualine_c = {
                {'filename', path = 1},  -- Display relative path of file
                {'diagnostics', sources = {'nvim_lsp'}}
            },
            lualine_x = {'encoding', 'fileformat', 'filetype'},
            lualine_y = {'progress'},
            lualine_z = {'location'}
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {'filename'},
            lualine_x = {'location'},
            lualine_y = {},
            lualine_z = {}
        },
        extensions = {'nvim-tree'}
    }

    -- Configure Vimwiki
    vim.g.vimwiki_list = {
        {
            path = '~/vimwiki/',
            syntax = 'markdown',
            ext = '.md',
        }
    }

    -- Enable markdown preview
    vim.g.mkdp_auto_start = 1

    -- Set default viewer (browser)
    vim.g.mkdp_browser = 'chrome'  -- Change this to your preferred browser

    -- Optional: Customize preview size
    vim.g.mkdp_preview_options = {
        height = 20,
        width = 120,
        toc = 1,  -- Table of contents
        footer = 1,  -- Footer with page count
    }

    -- CoC (Conquer of Completion) setup
    use {
        'neoclide/coc.nvim',
        branch = 'release',
        config = function()
            vim.cmd('source $HOME/.config/nvim/coc-settings.json')
        end
    }

    -- nvim-compe setup for auto-completion (optional, if CoC is used)
    -- require'compe'.setup {
    --     enabled = true;
    --     autocomplete = true;
    --     source = {
    --         path = true;
    --         buffer = true;
    --         calc = true;
    --         nvim_lsp = true;
    --         nvim_lua = true;
    --     };
    -- }

    -- Optional: Keybindings for nvim-compe
    -- vim.api.nvim_set_keymap('i', '<C-Space>', 'compe#complete()', {noremap = true, silent = true, expr = true})
    -- vim.api.nvim_set_keymap('i', '<CR>', 'compe#confirm("<CR>")', {noremap = true, silent = true, expr = true})

    -- Example configuration to run C++ code
    function RunCxx()
        local file = vim.fn.expand('%:p')  -- Get full path of current file
        vim.cmd('split | terminal')        -- Split window and open terminal
        vim.cmd('terminal g++ -o ' .. vim.fn.expand('%:p:r') .. ' ' .. file .. ' && ./' .. vim.fn.expand('%:p:r'))
    end

    -- Map a key to run C++ code (example: <leader>r)
    vim.api.nvim_set_keymap('n', '<leader>r', '<cmd>lua RunCxx()<CR>', {noremap = true, silent = true})

    -- Key mappings (example)
    vim.api.nvim_set_keymap('n', '<Leader>ww', ':VimwikiIndex<CR>', {noremap = true, silent = true})
    vim.api.nvim_set_keymap('n', '<Leader>wt', ':VimwikiTabIndex<CR>', {noremap = true, silent = true})
    vim.api.nvim_set_keymap('n', '<Leader>wd', ':VimwikiDiaryIndex<CR>', {noremap = true, silent = true})

    -- Function to open current Vimwiki file in preview
    function OpenVimwikiPreview()
        -- Replace 'chrome' with your preferred browser command
        vim.cmd('silent !start chrome ' .. vim.fn.expand('%:p'))
    end

    -- Key mapping to open Vimwiki file in preview
    vim.api.nvim_set_keymap('n', '<Leader>mv', '<Cmd>lua OpenVimwikiPreview()<CR>', {noremap = true, silent = true})

    -- Set Nord theme
    vim.cmd('colorscheme nord')
end)
