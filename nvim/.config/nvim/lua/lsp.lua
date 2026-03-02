local ok_mason, mason = pcall(require, "mason")
local ok_mlsp, mlsp   = pcall(require, "mason-lspconfig")
local ok_lsp, lsp     = pcall(require, "lspconfig")

if not (ok_mason and ok_mlsp and ok_lsp) then
  return
end

mason.setup()

mlsp.setup({
  ensure_installed = { "clangd","rust_analyzer","pyright","lua_ls","marksman","html","cssls" },
})

local on_attach = function(_, bufnr)
  local map = function(m, lhs, rhs, desc)
    vim.keymap.set(m, lhs, rhs, { buffer = bufnr, desc = desc })
  end
  map("n","gd",vim.lsp.buf.definition,"LSP: definition")
  map("n","K", vim.lsp.buf.hover,"LSP: hover")
  map("n","gr",vim.lsp.buf.references,"LSP: references")
  map("n","<leader>rn",vim.lsp.buf.rename,"LSP: rename")
  map("n","<leader>ca",vim.lsp.buf.code_action,"LSP: code action")
end

mlsp.setup_handlers({
  function(server)
    lsp[server].setup({ on_attach = on_attach })
  end,
  ["lua_ls"] = function()
    lsp.lua_ls.setup({
      on_attach = on_attach,
      settings = { Lua = { diagnostics = { globals = { "vim" } } } },
    })
  end,
})
