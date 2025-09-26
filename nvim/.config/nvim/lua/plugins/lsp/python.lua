-- Python LSP 설정 (pyright가 conda 환경 동적으로 인식)
return {
  -- venv-selector가 conda 환경을 찾도록 설정
  {
    "linux-cultist/venv-selector.nvim",
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = true,
          -- conda 환경 경로
          anaconda_envs_path = "/usr/local/Caskroom/miniconda/base/envs",
          anaconda_base_path = "/usr/local/Caskroom/miniconda/base",
        },
      },
    },
  },
  -- pyright 동적 Python 경로 설정
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Python 경로 자동 감지 (우선순위: CONDA_PREFIX > VIRTUAL_ENV > 프로젝트 venv > system)
      local function get_python_path()
        -- 1. CONDA_PREFIX (conda 환경)
        local conda_prefix = vim.fn.getenv("CONDA_PREFIX")
        if conda_prefix ~= vim.NIL and conda_prefix ~= "" then
          local conda_python = conda_prefix .. "/bin/python"
          if vim.fn.executable(conda_python) == 1 then
            return conda_python
          end
        end

        -- 2. VIRTUAL_ENV (일반 venv)
        local venv = vim.fn.getenv("VIRTUAL_ENV")
        if venv ~= vim.NIL and venv ~= "" then
          local venv_python = venv .. "/bin/python"
          if vim.fn.executable(venv_python) == 1 then
            return venv_python
          end
        end

        -- 3. 프로젝트 로컬 venv
        local cwd = vim.fn.getcwd()
        local venv_paths = {
          cwd .. "/venv/bin/python",
          cwd .. "/.venv/bin/python",
          cwd .. "/env/bin/python",
          cwd .. "/../venv/bin/python", -- 상위 디렉터리 venv
        }
        for _, path in ipairs(venv_paths) do
          if vim.fn.executable(path) == 1 then
            return path
          end
        end

        -- 4. 시스템 Python
        return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
      end

      opts.servers = opts.servers or {}
      opts.servers.pyright = vim.tbl_deep_extend("force", opts.servers.pyright or {}, {
        on_init = function(client)
          -- LSP 시작 시 Python 경로 동적 설정
          client.config.settings.python.pythonPath = get_python_path()
        end,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "openFilesOnly",
              useLibraryCodeForTypes = true,
              typeCheckingMode = "basic",
            },
          },
        },
      })

      return opts
    end,
  },
}
