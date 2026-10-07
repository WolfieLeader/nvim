-- Run the formatter and linters each repo actually uses, so saving never
-- rewrites files the repo's own tooling would leave alone.
--   * oxfmt config: oxfmt only. It honors .oxfmtrc ignorePatterns even over stdin.
--   * prettier config: prettier with that config.
--   * neither: prettier with the old VSCode settings, for the file types VSCode gave it.
--   * sqlfluff and markdownlint run only where the repo configures them.

-- File types oxfmt formats (checked with `oxfmt --stdin-filepath`).
local oxfmt_fts = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "json",
  "jsonc",
  "markdown",
  "yaml",
  "css",
  "toml",
}

-- File types VSCode sent to prettier. Others (YAML, ...) fall back to their LSP, like VSCode.
local vscode_prettier_fts = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
  json = true,
  jsonc = true,
  markdown = true,
  html = true,
  css = true,
  scss = true,
}

-- Global "prettier.*" settings from VSCode settings.json.
local vscode_prettier_args = {
  "--print-width=120",
  "--bracket-same-line",
  "--end-of-line=auto",
  "--trailing-comma=none",
}

local markers = {
  oxfmt = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" },
  prettier = {
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.json5",
    ".prettierrc.yaml",
    ".prettierrc.yml",
    ".prettierrc.toml",
    ".prettierrc.js",
    ".prettierrc.cjs",
    ".prettierrc.mjs",
    ".prettierrc.ts",
    "prettier.config.js",
    "prettier.config.cjs",
    "prettier.config.mjs",
    "prettier.config.ts",
  },
  sqlfluff = { ".sqlfluff" },
  markdownlint = {
    ".markdownlint.json",
    ".markdownlint.jsonc",
    ".markdownlint.yaml",
    ".markdownlint.yml",
    ".markdownlint-cli2.jsonc",
    ".markdownlint-cli2.yaml",
    ".markdownlint-cli2.cjs",
    ".markdownlint-cli2.mjs",
  },
}

-- Search from the file's folder up to its git root (or $HOME outside a repo).
local function find(names, dir)
  local root = vim.fs.root(dir, ".git")
  local stop = root and vim.fs.dirname(root) or vim.env.HOME
  return vim.fs.find(names, { path = dir, upward = true, stop = stop, limit = math.huge })
end

local function has(kind, dir)
  return #find(markers[kind], dir) > 0
end

local function has_prettier_config(dir)
  if has("prettier", dir) then
    return true
  end
  for _, pkg in ipairs(find({ "package.json" }, dir)) do
    local ok, json = pcall(vim.json.decode, table.concat(vim.fn.readfile(pkg), "\n"))
    if ok and type(json) == "table" and json.prettier ~= nil then
      return true
    end
  end
  return false
end

-- Wrap a formatter's existing condition with an extra check.
local function add_condition(formatter, check)
  local base = formatter.condition
  formatter.condition = function(self, ctx)
    return check(ctx) and (base == nil or base(self, ctx))
  end
  return formatter
end

return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      local f = opts.formatters

      for _, ft in ipairs(oxfmt_fts) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        if not vim.tbl_contains(opts.formatters_by_ft[ft], "oxfmt") then
          table.insert(opts.formatters_by_ft[ft], 1, "oxfmt")
        end
      end
      f.oxfmt = add_condition(f.oxfmt or {}, function(ctx)
        return has("oxfmt", ctx.dirname)
      end)

      f.prettier = add_condition(f.prettier or {}, function(ctx)
        if has("oxfmt", ctx.dirname) then
          return false
        end
        return has_prettier_config(ctx.dirname) or vscode_prettier_fts[vim.bo[ctx.buf].filetype] == true
      end)
      f.prettier.prepend_args = function(_, ctx)
        return has_prettier_config(ctx.dirname) and {} or vscode_prettier_args
      end

      -- LazyVim forces --dialect=ansi; let the repo's .sqlfluff choose.
      f.sqlfluff = add_condition(f.sqlfluff or {}, function(ctx)
        return has("sqlfluff", ctx.dirname)
      end)
      f.sqlfluff.args = { "format", "-" }

      f["markdownlint-cli2"] = add_condition(f["markdownlint-cli2"] or {}, function(ctx)
        return has("markdownlint", ctx.dirname)
      end)
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters = opts.linters or {}
      for name, kind in pairs({ sqlfluff = "sqlfluff", ["markdownlint-cli2"] = "markdownlint" }) do
        opts.linters[name] = opts.linters[name] or {}
        opts.linters[name].condition = function(ctx)
          return has(kind, ctx.dirname)
        end
      end
    end,
  },
}
