-- Debugging.
--
-- Set up so that DAP internals never come up. Open a Python file, press <F9>
-- on a line, press <F5>. The debugger UI opens by itself and closes when the
-- program ends.
--
-- The function keys match VS Code, because that muscle memory is worth keeping
-- and F-keys collide with nothing in Vim:
--
--   <F5>     start / continue          <S-F5>   stop
--   <F9>     toggle breakpoint         <F10>    step over
--   <F11>    step into                 <S-F11>  step out
--
-- The leader keys follow ~/.ideavimrc: <leader>b toggles a breakpoint,
-- <leader>ed starts a debug run, <leader>es stops it, <leader>td shows the
-- debugger. Everything else is under <leader>d.
--
-- Requires debugpy. The Arch package python-debugpy covers the common case; a
-- project virtualenv with debugpy installed is preferred automatically.

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      { "mfussenegger/nvim-dap-python" },
    },

    keys = {
      -- --------------------------------------------------- VS Code keys --
      { "<F5>", function() require("dap").continue() end, desc = "Debug: start / continue" },
      { "<S-F5>", function() require("dap").terminate() end, desc = "Debug: stop" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debug: breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
      { "<S-F11>", function() require("dap").step_out() end, desc = "Debug: step out" },

      -- -------------------------------------------- IdeaVim-shaped keys --
      { "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "Add breakpoint" },
      { "<leader>ed", function() require("dap").continue() end, desc = "Run in debug mode" },
      { "<leader>es", function() require("dap").terminate() end, desc = "Stop" },
      { "<leader>td", function() require("dapui").toggle() end, desc = "Debug window" },

      -- ------------------------------------------------- <leader>d full --
      { "<leader>dc", function() require("dap").continue() end, desc = "Start / continue" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      {
        "<leader>dB",
        function()
          vim.ui.input({ prompt = "Break when this is true: " }, function(cond)
            if cond and cond ~= "" then
              require("dap").set_breakpoint(cond)
            end
          end)
        end,
        desc = "Conditional breakpoint",
      },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dp", function() require("dap").pause() end, desc = "Pause running program" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate session" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Re-run last session" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle debugger UI" },
      {
        "<leader>dv",
        function() require("dapui").eval(nil, { enter = true }) end,
        mode = { "n", "x" },
        desc = "Inspect value under cursor",
      },
      { "<leader>dC", function() require("dap").clear_breakpoints() end, desc = "Clear breakpoints" },

      -- ------------------------------------------------------- Python --
      { "<leader>dm", function() require("dap-python").test_method() end, ft = "python", desc = "Debug test method" },
      { "<leader>dk", function() require("dap-python").test_class() end, ft = "python", desc = "Debug test class" },
      {
        "<leader>ds",
        function() require("dap-python").debug_selection() end,
        mode = "v",
        ft = "python",
        desc = "Debug selected lines",
      },
    },

    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- --------------------------------------------------------- UI --
      dapui.setup({
        layouts = {
          {
            -- Left: what the variables are, and how you got here.
            elements = {
              { id = "scopes", size = 0.35 },
              { id = "stacks", size = 0.30 },
              { id = "breakpoints", size = 0.20 },
              { id = "watches", size = 0.15 },
            },
            size = 45,
            position = "left",
          },
          {
            -- Bottom: program output and an interactive prompt.
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 12,
            position = "bottom",
          },
        },
        floating = { border = "rounded" },
      })

      dap.listeners.after.event_initialized["dapui"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui"] = function()
        dapui.close()
      end

      -- ------------------------------------------------------ signs --
      -- Breakpoint signs are ordinary signs. Only *diagnostic* signs moved
      -- into vim.diagnostic.config() in Neovim 0.12.
      vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "C", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "X", texthl = "DiagnosticHint" })
      vim.fn.sign_define("DapLogPoint", { text = "L", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapStopped", { text = ">", texthl = "DiagnosticOk", linehl = "Visual" })

      -- ----------------------------------------------------- Python --
      -- Prefer a project virtualenv that already has debugpy, otherwise the
      -- system python (Arch package python-debugpy).
      local function debugpy_python()
        local candidates = {}
        local venv = os.getenv("VIRTUAL_ENV")
        if venv then
          table.insert(candidates, venv .. "/bin/python")
        end
        table.insert(candidates, vim.fn.getcwd() .. "/.venv/bin/python")

        for _, python in ipairs(candidates) do
          if vim.fn.executable(python) == 1 then
            vim.fn.system({ python, "-c", "import debugpy" })
            if vim.v.shell_error == 0 then
              return python
            end
          end
        end
        return "python3"
      end

      require("dap-python").setup(debugpy_python())

      -- For C/C++ later: `pacman -S lldb` and register lldb-dap as an adapter
      -- here. The keys above already work for any adapter.
    end,
  },
}
