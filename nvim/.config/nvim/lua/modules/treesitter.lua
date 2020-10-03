require'nvim-treesitter.configs'.setup {
  -- one of "all", "language", or a list of languages
  ensure_installed = {
  "typescript",
  "javascript",
  "html",
  "css",
  "java",
  "php",
  "tsx",
  "markdown",
  "lua"
  },
  highlight = {
    enable = true
  }
}
