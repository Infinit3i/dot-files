vim.g.mapleader = " "
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Custom Setup Plugins ----------------------------
local plugins = {
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{
		"nvim-telescope/telescope.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
	},
	{
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    		},
    	lazy = false,
	opts = {
	filesystem = {
		filtered_items = {
			visible = true,
			hide_dotfiles = false,
			hide_gitignored = false,
				},
			},
		},
	},
	{
  "folke/twilight.nvim",
  opts = {
    dimming = {
      alpha = 0.25,
    },
    context = 10,
    treesitter = true,
  },
},
{ 'nvim-mini/mini.nvim', version = '*' },
}
local opts = {}

require("lazy").setup(plugins, opts)

-- Telescope ------------------------------------
local builtin = require("telescope.builtin")
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})

-- Catppuccin ----------------------------------
require("catppuccin").setup({
	transparent_background = true,
})
vim.cmd.colorscheme("catppuccin")

-- Twilight ------------------------------------
vim.keymap.set("n", "<leader>t", ":Twilight<CR>", { desc = "Toggle Twilight" })
