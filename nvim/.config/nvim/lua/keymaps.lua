-- lua/keymaps.lua

-- Telescope
local ok_telescope, builtin = pcall(require, "telescope.builtin")
if ok_telescope then
  vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files (Telescope)" })
  vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep (Telescope)" })
else
  -- Optional: notify once if telescope isn't available yet
  vim.schedule(function()
    vim.notify("telescope.builtin not available (plugin not loaded yet)", vim.log.levels.WARN)
  end)
end

-- Twilight
vim.keymap.set("n", "<leader>t", "<cmd>Twilight<CR>", { desc = "Toggle Twilight" })
