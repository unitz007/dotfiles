local M = {}

local defaults = {
  bin = "sdlc",
  output = "float",
  terminal_direction = "horizontal",
  terminal_size = 15,
  keymaps = true,
  root_markers = {
    ".sdlc.json",
    ".sdlc.conf",
    "go.mod",
    "package.json",
    "Cargo.toml",
    "pom.xml",
    "build.gradle",
    "Makefile",
    ".git",
  },
}

M.options = vim.deepcopy(defaults)
M.last_module = nil
M.last_output = nil

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "SDLC" })
end

local function current_path()
  local name = vim.api.nvim_buf_get_name(0)
  if name ~= "" then
    return name
  end
  return vim.uv.cwd()
end

local function project_root()
  local path = current_path()
  local start = vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path)

  local lazy_ok, lazy_util = pcall(require, "lazyvim.util")
  if lazy_ok and lazy_util.root and lazy_util.root.get then
    local ok, root = pcall(lazy_util.root.get)
    if ok and root and root ~= "" then
      return root
    end
  end

  local root = vim.fs.root(start, M.options.root_markers)
  return root or vim.uv.cwd()
end

local function command_args(action, opts)
  opts = opts or {}
  local args = { M.options.bin, action, "--dir", opts.root or project_root(), "--no-color" }

  if opts.watch then
    table.insert(args, "--watch")
  end

  if opts.dry_run then
    table.insert(args, "--dry-run")
  end

  local module = opts.module or M.last_module
  if module and module ~= "" and module ~= "." then
    table.insert(args, "--module")
    table.insert(args, module)
  end

  if opts.extra_args then
    for _, arg in ipairs(opts.extra_args) do
      table.insert(args, arg)
    end
  end

  return args
end

local function shell_join(args)
  return table.concat(vim.tbl_map(vim.fn.shellescape, args), " ")
end

local function show_float(title, lines)
  lines = lines or { "" }
  if #lines == 0 then
    lines = { "" }
  end

  local width = math.min(math.floor(vim.o.columns * 0.85), 120)
  local height = math.min(math.floor(vim.o.lines * 0.75), math.max(#lines, 8))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "sdlc"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
    row = row,
    col = col,
    width = width,
    height = height,
  })

  vim.wo[win].wrap = false
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end

local function run_float(action, opts)
  opts = opts or {}
  local args = command_args(action, opts)
  notify("Running: " .. shell_join(args))

  vim.system(args, { text = true }, function(result)
    local output = vim.trim((result.stdout or "") .. (result.stderr or ""))
    local lines = output ~= "" and vim.split(output, "\n", { plain = true }) or { "No output" }
    M.last_output = lines

    vim.schedule(function()
      local level = result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
      notify(action .. " exited " .. result.code, level)
      show_float("sdlc " .. action, lines)
    end)
  end)
end

local function open_terminal(args)
  local direction = M.options.terminal_direction
  local size = M.options.terminal_size

  if direction == "vertical" then
    vim.cmd("botright " .. size .. "vsplit")
  elseif direction == "float" then
    show_float("sdlc terminal", { shell_join(args) })
    return
  else
    vim.cmd("botright " .. size .. "split")
  end

  vim.cmd("terminal " .. shell_join(args))
  vim.cmd("startinsert")
end

local function run_terminal(action, opts)
  opts = opts or {}
  open_terminal(command_args(action, opts))
end

local function parse_modules(output)
  local modules = {}
  local in_table = false
  for _, line in ipairs(vim.split(output or "", "\n", { plain = true })) do
    local trimmed = vim.trim(line)
    if trimmed:match("^MODULE PATH") then
      in_table = true
    elseif in_table and trimmed:match("module%(s%) detected$") then
      break
    elseif in_table and trimmed ~= "" then
      local path = trimmed:match("^(%S+)%s+%S+%s+")
      if path then
        table.insert(modules, path)
      end
    end
  end
  return modules
end

local function list_modules(callback)
  local root = project_root()
  local args = { M.options.bin, "list", "--dir", root, "--no-color" }

  vim.system(args, { text = true }, function(result)
    local output = (result.stdout or "") .. (result.stderr or "")
    local modules = parse_modules(output)
    vim.schedule(function()
      if result.code ~= 0 then
        notify("sdlc list failed", vim.log.levels.ERROR)
        show_float("sdlc list", vim.split(vim.trim(output), "\n", { plain = true }))
        return
      end
      callback(modules, output, root)
    end)
  end)
end

function M.run(opts)
  run_float("run", opts)
end

function M.run_watch(opts)
  run_terminal("run", vim.tbl_extend("force", opts or {}, { watch = true }))
end

function M.test(opts)
  run_float("test", opts)
end

function M.test_file()
  local root = project_root()
  local file = current_path()
  local module_dir = vim.fs.dirname(file)
  local rel = vim.fn.fnamemodify(module_dir, ":~:.")

  if vim.startswith(module_dir, root) then
    rel = vim.fn.fnamemodify(module_dir:sub(#root + 2), ":.")
  end

  run_float("test", { root = root, module = rel })
end

function M.build(opts)
  run_float("build", opts)
end

function M.install(opts)
  run_float("install", opts)
end

function M.clean(opts)
  run_float("clean", opts)
end

function M.dry_run(action)
  run_float(action or "run", { dry_run = true })
end

function M.list()
  list_modules(function(_, output)
    show_float("sdlc list", vim.split(vim.trim(output), "\n", { plain = true }))
  end)
end

function M.pick_module()
  list_modules(function(modules)
    if #modules == 0 then
      notify("No modules detected", vim.log.levels.WARN)
      return
    end

    vim.ui.select(modules, { prompt = "SDLC module" }, function(choice)
      if choice then
        M.last_module = choice
        notify("Selected module: " .. choice)
      end
    end)
  end)
end

function M.clear_module()
  M.last_module = nil
  notify("Cleared selected module")
end

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})

  vim.api.nvim_create_user_command("SdlcRun", function()
    M.run()
  end, {})
  vim.api.nvim_create_user_command("SdlcRunWatch", function()
    M.run_watch()
  end, {})
  vim.api.nvim_create_user_command("SdlcTest", function()
    M.test()
  end, {})
  vim.api.nvim_create_user_command("SdlcTestFile", function()
    M.test_file()
  end, {})
  vim.api.nvim_create_user_command("SdlcBuild", function()
    M.build()
  end, {})
  vim.api.nvim_create_user_command("SdlcInstall", function()
    M.install()
  end, {})
  vim.api.nvim_create_user_command("SdlcClean", function()
    M.clean()
  end, {})
  vim.api.nvim_create_user_command("SdlcList", function()
    M.list()
  end, {})
  vim.api.nvim_create_user_command("SdlcPickModule", function()
    M.pick_module()
  end, {})
  vim.api.nvim_create_user_command("SdlcClearModule", function()
    M.clear_module()
  end, {})
  vim.api.nvim_create_user_command("SdlcDryRun", function(command)
    M.dry_run(command.args ~= "" and command.args or "run")
  end, { nargs = "?", complete = function()
    return { "run", "test", "build", "install", "clean" }
  end })
end

return M
