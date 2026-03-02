vim.g.mapleader = " "

require("options")
require("colorscheme")
require("keymaps")
require("lsp")

local plugins, opts = require("plugins")
require("lazy").setup(plugins, opts)
