return {
  'neovim/nvim-lspconfig',
  version = '*',
  dependencies = {
    { 'j-hui/fidget.nvim', opts = {} }, -- LSP progress notifications
    { 'folke/neodev.nvim', opts = {} }, -- Neovim development support
  },
  config = function()
    -- ===================================================================
    -- NATIVE LSP CONFIGURATION FOR NEOVIM 0.11+
    -- ===================================================================
    --
    -- This configuration uses vim.lsp.start() directly with filetype autocommands
    -- to ensure proper server attachment. lspconfig is used only for extracting
    -- server configurations as recommended.
    -- ===================================================================

    -- Create filetype autocommands to start LSP servers for specific filetypes
    local lsp_group = vim.api.nvim_create_augroup('LspAutoStart', { clear = true })

    -- ===================================================================
    -- UTILITY FUNCTIONS
    -- ===================================================================

    -- Check if a command is executable on the system
    local function is_executable(command)
      return vim.fn.executable(command) == 1
    end

    -- Safely wrap LSP root_dir functions to prevent errors
    local function safe_root_dir(root_dir_func)
      return function(fname)
        local ok, result = pcall(root_dir_func, fname)
        if ok then
          return result
        else
          return vim.fs.root(fname, { '.git', '.svn' }) or vim.fn.getcwd()
        end
      end
    end

    -- ===================================================================
    -- LSP BUFFER MANAGEMENT
    -- ===================================================================

    -- Start an LSP server for a specific buffer using the native API
    local function start_lsp_for_buffer(bufnr, server_name, config)
      local filename = vim.api.nvim_buf_get_name(bufnr)
      local root_dir = config.root_dir and config.root_dir(filename) or vim.fn.getcwd()

      vim.lsp.start({
        name = server_name,
        cmd = config.cmd,                   -- Command to start the LSP server
        root_dir = root_dir,                -- Project root directory
        capabilities = config.capabilities, -- Server capabilities
        settings = config.settings,         -- Server-specific settings
        on_attach = config.on_attach,       -- Callback when server attaches
      }, {
        bufnr = bufnr,                      -- Target buffer
      })
    end

    -- Create filetype autocommands to automatically start LSP servers
    local function setup_lsp_for_filetype(server_name, config, filetypes)
      for _, ft in ipairs(filetypes) do
        vim.api.nvim_create_autocmd('FileType', {
          group = lsp_group,
          pattern = ft,
          callback = function(args)
            start_lsp_for_buffer(args.buf, server_name, config)
          end,
        })
      end
    end

    -- ===================================================================
    -- LSP ATTACHMENT AND KEYBINDINGS
    -- ===================================================================

    -- Set up keybindings and functionality when an LSP server attaches
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Navigation keybindings
        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- Code actions and utilities
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')

        -- Document highlighting for references
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })

          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end
      end,
    })

    -- ===================================================================
    -- LSP CAPABILITIES AND CONFIGURATION
    -- ===================================================================

    -- Enhanced capabilities with completion support
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    local lspconfig = require 'lspconfig'

    -- List of LSP servers to configure
    local servers = {
      'html',                            -- HTML language server
      'tailwindcss',                     -- Tailwind CSS language server
      'cssls',                           -- CSS language server
      'yamlls',                          -- YAML language server
      'docker_compose_language_service', -- Docker Compose language server
      'astro',                           -- Astro framework language server
      'vtsls',                           -- TypeScript language server
      'ruby_lsp',                        -- Ruby language server
      -- 'stimulus_ls',              -- Stimulus language server (commented out)
      -- 'standardrb',               -- Ruby standardrb linter (commented out)
    }

    -- ===================================================================
    -- BASIC LSP SERVER CONFIGURATION
    -- ===================================================================

    -- Configure standard LSP servers with default settings
    for _, server in ipairs(servers) do
      local lspconfig_config = lspconfig[server].document_config.default_config

      if not lspconfig_config or not lspconfig_config.cmd then
        print(string.format('Warning: Could not get configuration for %s', server))
        goto continue
      end

      local executable = lspconfig_config.cmd[1]
      if not is_executable(executable) then
        print(string.format('Warning: %s executable not found. LSP for %s may not work.', executable, server))
      end

      local server_config = {
        cmd = lspconfig_config.cmd,                          -- Server command
        root_dir = safe_root_dir(lspconfig_config.root_dir), -- Root detection
        settings = lspconfig_config.settings,                -- Server settings
        capabilities = capabilities,                         -- Enhanced capabilities
      }

      if lspconfig_config.filetypes then
        setup_lsp_for_filetype(server, server_config, lspconfig_config.filetypes)
      end

      ::continue::
    end

    -- ===================================================================
    -- SPECIALIZED LSP SERVER CONFIGURATION
    -- ===================================================================

    -- Lua Language Server with Neovim development support
    local lua_config = lspconfig.lua_ls.document_config.default_config
    local lua_server_config = {
      cmd = lua_config.cmd,
      root_dir = safe_root_dir(lua_config.root_dir),
      capabilities = capabilities,
      -- Enhanced on_attach for Neovim configuration files
      on_attach = function(client, bufnr)
        local path = client.workspace_folders[1] and client.workspace_folders[1].name or vim.fn.getcwd()
        -- Respect existing configuration files
        if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
          return
        end

        -- Configure for Neovim development
        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = { version = 'LuaJIT' },
          workspace = {
            checkThirdParty = false,
            library = { vim.env.VIMRUNTIME }
          }
        })
      end,
      settings = {
        Lua = {
          completion = { callSnippet = 'Replace' },
          diagnostics = { globals = { 'vim' } },      -- Recognize 'vim' as global
          workspace = {
            library = { [vim.env.VIMRUNTIME] = true } -- Include Neovim runtime
          }
        },
      },
    }
    setup_lsp_for_filetype('lua_ls', lua_server_config, lua_config.filetypes)

    -- ESLint with auto-fix on save
    local eslint_config = lspconfig.eslint.document_config.default_config
    local eslint_server_config = {
      cmd = eslint_config.cmd,
      root_dir = safe_root_dir(eslint_config.root_dir),
      capabilities = capabilities,
      -- Auto-fix on save
      on_attach = function(_, bufnr)
        vim.api.nvim_create_autocmd('BufWritePre', {
          buffer = bufnr,
          command = 'EslintFixAll',
        })
      end,
    }
    setup_lsp_for_filetype('eslint', eslint_server_config, eslint_config.filetypes)

    -- CSS Language Server with custom linting rules
    local cssls_config = lspconfig.cssls.document_config.default_config
    local cssls_server_config = {
      cmd = cssls_config.cmd,
      root_dir = safe_root_dir(cssls_config.root_dir),
      capabilities = capabilities,
      settings = {
        css = {
          lint = {
            unknownAtRules = 'ignore', -- Ignore Tailwind CSS at-rules
          },
        },
      },
    }
    setup_lsp_for_filetype('cssls', cssls_server_config, cssls_config.filetypes)
  end,
}