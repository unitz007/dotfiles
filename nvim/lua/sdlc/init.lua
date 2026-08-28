local M = {}

local defaults = {
  bin = "sdlc",
  output = "float",
  float_row = 2,
  float_col = nil,
  float_width = 0.88,
  float_height = 0.75,
  terminal_direction = "float",
  terminal_size = 15,
  terminal_width = 80,
  terminal_float_width = 0.88,
  terminal_float_height = 0.5,
  terminal_float_row = 3,
  terminal_float_col = nil,
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

local known_boolean_flags = {
  ["--all"] = true,
  ["-a"] = true,
  ["--dry-run"] = true,
  ["-n"] = true,
  ["--verbose"] = true,
  ["--watch"] = true,
  ["-w"] = true,
  ["--no-color"] = true,
}

local known_value_flags = {
  ["--config"] = true,
  ["-c"] = true,
  ["--debounce"] = true,
  ["--depth"] = true,
  ["-D"] = true,
  ["--dir"] = true,
  ["-d"] = true,
  ["--ignore"] = true,
  ["-i"] = true,
  ["--module"] = true,
  ["-m"] = true,
  ["--parallel"] = true,
  ["-p"] = true,
}

M.options = vim.deepcopy(defaults)
M.last_module = nil
M.last_output = nil
M.watch = { buf = nil, win = nil, job_id = nil, args = nil }

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

local function shell_words(raw)
  local words = {}
  local current = {}
  local quote = nil
  local escaped = false

  for i = 1, #raw do
    local char = raw:sub(i, i)
    if escaped then
      table.insert(current, char)
      escaped = false
    elseif char == "\\" then
      escaped = true
    elseif quote then
      if char == quote then
        quote = nil
      else
        table.insert(current, char)
      end
    elseif char == '"' or char == "'" then
      quote = char
    elseif char:match("%s") then
      if #current > 0 then
        table.insert(words, table.concat(current))
        current = {}
      end
    else
      table.insert(current, char)
    end
  end

  if escaped then
    table.insert(current, "\\")
  end
  if #current > 0 then
    table.insert(words, table.concat(current))
  end

  return words
end

local function parse_user_args(raw)
  local opts = { sdlc_args = {}, extra_args = {} }
  local words = type(raw) == "table" and raw or shell_words(raw or "")
  local extra_only = false
  local i = 1

  while i <= #words do
    local word = words[i]

    if extra_only then
      table.insert(opts.extra_args, word)
    elseif word == "--" then
      extra_only = true
    elseif word == "--float" then
      opts.output = "float"
    elseif word == "--term" or word == "--terminal" then
      opts.output = "terminal"
    elseif word == "--vertical" then
      opts.terminal_direction = "vertical"
    elseif word == "--horizontal" then
      opts.terminal_direction = "horizontal"
    elseif word == "--split" then
      opts.terminal_direction = "horizontal"
    elseif word == "--size" then
      if words[i + 1] then
        opts.terminal_size = tonumber(words[i + 1]) or opts.terminal_size
        opts.terminal_width = tonumber(words[i + 1]) or opts.terminal_width
        i = i + 1
      end
    elseif known_boolean_flags[word] then
      table.insert(opts.sdlc_args, word)
    elseif known_value_flags[word] then
      table.insert(opts.sdlc_args, word)
      if words[i + 1] then
        table.insert(opts.sdlc_args, words[i + 1])
        i = i + 1
      end
    elseif word:match("^%-%-[%w-]+=") then
      local flag = word:match("^(%-%-[%w-]+)=")
      if known_value_flags[flag] then
        table.insert(opts.sdlc_args, word)
      else
        table.insert(opts.extra_args, word)
      end
    else
      table.insert(opts.extra_args, word)
    end

    i = i + 1
  end

  if #opts.sdlc_args == 0 then
    opts.sdlc_args = nil
  end
  if #opts.extra_args == 0 then
    opts.extra_args = nil
  end

  return opts
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

  if opts.sdlc_args then
    for _, arg in ipairs(opts.sdlc_args) do
      if arg ~= "--no-color" then
        table.insert(args, arg)
      end
    end
  end

  if opts.extra_args then
    table.insert(args, "--extra-args")
    table.insert(args, table.concat(opts.extra_args, " "))
  end

  return args
end

local function shell_join(args)
  return table.concat(vim.tbl_map(vim.fn.shellescape, args), " ")
end

local function apply_highlights(buf, highlights)
  for _, item in ipairs(highlights or {}) do
    vim.api.nvim_buf_add_highlight(buf, -1, item.group, item.line, item.start_col or 0, item.end_col or -1)
  end
end

local function show_float(title, lines, highlights)
  lines = lines or { "" }
  if #lines == 0 then
    lines = { "" }
  end

  local width = math.min(math.floor(vim.o.columns * M.options.float_width), 130)
  local height = math.min(math.floor(vim.o.lines * M.options.float_height), math.max(#lines, 10))
  local row = M.options.float_row
  local col = M.options.float_col or math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "sdlc"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  apply_highlights(buf, highlights)

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
  vim.wo[win].cursorline = true
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end

local function append_line(lines, highlights, text, group)
  table.insert(lines, text)
  if group then
    table.insert(highlights, { line = #lines - 1, group = group })
  end
end

local function result_view(action, args, result, output_lines)
  local ok = result.code == 0
  local icon = ok and "✓" or "✗"
  local status = ok and "SUCCESS" or "FAILED"
  local status_group = ok and "DiagnosticOk" or "DiagnosticError"
  local lines = {}
  local highlights = {}

  append_line(lines, highlights, " " .. icon .. " SDLC " .. string.upper(action) .. " · " .. status, status_group)
  append_line(lines, highlights, " " .. string.rep("─", 72), "Comment")
  append_line(lines, highlights, " Command", "Title")
  append_line(lines, highlights, "   " .. shell_join(args), "Comment")
  append_line(lines, highlights, " Exit", "Title")
  append_line(lines, highlights, "   code " .. tostring(result.code), status_group)
  append_line(lines, highlights, "")
  append_line(lines, highlights, " Output", "Title")

  if #output_lines == 0 then
    append_line(lines, highlights, "   No output", "Comment")
  else
    for _, line in ipairs(output_lines) do
      local group = nil
      local lower = line:lower()
      if lower:match("error") or lower:match("fail") or lower:match("panic") then
        group = "DiagnosticError"
      elseif lower:match("warn") or lower:match("skip") then
        group = "DiagnosticWarn"
      elseif lower:match("pass") or lower:match("success") or lower:match("ok%s") then
        group = "DiagnosticOk"
      end
      append_line(lines, highlights, "   " .. line, group)
    end
  end

  append_line(lines, highlights, "")
  append_line(lines, highlights, " q/Esc close · :SdlcRun --terminal for live output", "Comment")

  return lines, highlights
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
      local view_lines, highlights = result_view(action, args, result, output ~= "" and lines or {})
      show_float("sdlc " .. action, view_lines, highlights)
    end)
  end)
end

local function valid_win(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function valid_buf(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

local function terminal_float_config(opts)
  opts = opts or {}
  local width = math.min(math.floor(vim.o.columns * (opts.terminal_float_width or M.options.terminal_float_width)), 130)
  local height = math.min(math.floor(vim.o.lines * (opts.terminal_float_height or M.options.terminal_float_height)), vim.o.lines - 6)
  local row = opts.terminal_float_row or M.options.terminal_float_row
  local col = opts.terminal_float_col or M.options.terminal_float_col or math.floor((vim.o.columns - width) / 2)

  return {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    title = " SDLC watch ",
    title_pos = "center",
    row = row,
    col = col,
    width = width,
    height = math.max(height, 10),
  }
end

local function decorate_terminal_buffer(buf)
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].filetype = "sdlc"
  vim.keymap.set("t", "<esc>", [[<C-\><C-n><cmd>SdlcHide<cr>]], { buffer = buf, silent = true })
  vim.keymap.set("t", "<C-q>", [[<C-\><C-n><cmd>SdlcHide<cr>]], { buffer = buf, silent = true })
  vim.keymap.set("n", "q", "<cmd>SdlcHide<cr>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<esc>", "<cmd>SdlcHide<cr>", { buffer = buf, silent = true })
end

local function open_terminal_window(buf, opts)
  opts = opts or {}
  local direction = opts.terminal_direction or M.options.terminal_direction
  local height = opts.terminal_size or M.options.terminal_size
  local width = opts.terminal_width or M.options.terminal_width

  if direction == "float" then
    return vim.api.nvim_open_win(buf, true, terminal_float_config(opts))
  end

  if direction == "vertical" then
    vim.cmd("botright " .. width .. "vsplit")
  else
    vim.cmd("botright " .. height .. "split")
  end

  vim.api.nvim_win_set_buf(0, buf)
  return vim.api.nvim_get_current_win()
end

local function open_terminal(args, opts)
  opts = opts or {}
  local buf = vim.api.nvim_create_buf(false, false)
  decorate_terminal_buffer(buf)
  open_terminal_window(buf, opts)
  vim.fn.termopen(args)
  vim.cmd("startinsert")
end

local function run_terminal(action, opts)
  opts = opts or {}
  open_terminal(command_args(action, opts), opts)
end

local function ensure_watch_terminal(args, opts)
  opts = opts or {}

  if valid_buf(M.watch.buf) and M.watch.job_id then
    notify("SDLC watch is already running; showing it")
    M.show()
    return
  end

  local buf = vim.api.nvim_create_buf(false, false)
  decorate_terminal_buffer(buf)
  M.watch.buf = buf
  M.watch.args = args
  M.watch.win = open_terminal_window(buf, vim.tbl_extend("force", { terminal_direction = "float" }, opts))
  M.watch.job_id = vim.fn.termopen(args, {
    on_exit = function(_, code)
      M.watch.job_id = nil
      vim.schedule(function()
        notify("SDLC watch exited " .. code, code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
      end)
    end,
  })
  vim.cmd("startinsert")
  notify("SDLC watch started")
end

local function run_with_output(action, opts)
  opts = opts or {}
  local output = opts.output or M.options.output
  if output == "terminal" then
    run_terminal(action, opts)
  else
    run_float(action, opts)
  end
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

local function list_modules(callback, opts)
  opts = opts or {}
  local root = opts.root or project_root()
  local args = { M.options.bin, "list", "--dir", root, "--no-color" }

  if opts.sdlc_args then
    for _, arg in ipairs(opts.sdlc_args) do
      if arg ~= "--no-color" then
        table.insert(args, arg)
      end
    end
  end

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
  run_with_output("run", opts)
end

function M.run_watch(opts)
  opts = vim.tbl_extend("force", { terminal_direction = "float" }, opts or {}, { watch = true })
  ensure_watch_terminal(command_args("run", opts), opts)
end

function M.test(opts)
  run_with_output("test", opts)
end

function M.test_file(opts)
  opts = opts or {}
  local root = project_root()
  local file = current_path()
  local module_dir = vim.fs.dirname(file)
  local rel = vim.fn.fnamemodify(module_dir, ":~:.")

  if vim.startswith(module_dir, root) then
    rel = vim.fn.fnamemodify(module_dir:sub(#root + 2), ":.")
  end

  run_with_output("test", vim.tbl_extend("force", opts, { root = root, module = rel }))
end

function M.build(opts)
  run_with_output("build", opts)
end

function M.install(opts)
  run_with_output("install", opts)
end

function M.clean(opts)
  run_with_output("clean", opts)
end

function M.dry_run(action, opts)
  run_with_output(action or "run", vim.tbl_extend("force", opts or {}, { dry_run = true }))
end

function M.list(opts)
  list_modules(function(_, output)
    show_float("sdlc list", vim.split(vim.trim(output), "\n", { plain = true }))
  end, opts)
end

function M.pick_module(opts)
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
  end, opts)
end

function M.clear_module()
  M.last_module = nil
  notify("Cleared selected module")
end

function M.hide()
  if valid_win(M.watch.win) then
    vim.api.nvim_win_close(M.watch.win, true)
    M.watch.win = nil
    notify("SDLC watch hidden")
  else
    notify("No SDLC watch window to hide", vim.log.levels.WARN)
  end
end

function M.show()
  if not valid_buf(M.watch.buf) then
    notify("No SDLC watch buffer exists", vim.log.levels.WARN)
    return
  end

  if valid_win(M.watch.win) then
    vim.api.nvim_set_current_win(M.watch.win)
  else
    M.watch.win = open_terminal_window(M.watch.buf, { terminal_direction = "float" })
  end
  vim.cmd("startinsert")
end

function M.stop()
  if M.watch.job_id then
    vim.fn.jobstop(M.watch.job_id)
    M.watch.job_id = nil
  end
  if valid_win(M.watch.win) then
    vim.api.nvim_win_close(M.watch.win, true)
  end
  if valid_buf(M.watch.buf) then
    vim.api.nvim_buf_delete(M.watch.buf, { force = true })
  end
  M.watch = { buf = nil, win = nil, job_id = nil, args = nil }
  notify("SDLC watch stopped")
end

function M.command(action, raw_args, opts)
  opts = vim.tbl_extend("force", parse_user_args(raw_args or ""), opts or {})
  if action == "run-watch" then
    M.run_watch(opts)
  elseif action == "test-file" then
    M.test_file(opts)
  elseif action == "dry-run" then
    local dry_action = opts.extra_args and table.remove(opts.extra_args, 1) or "run"
    M.dry_run(dry_action, opts)
  elseif action == "list" then
    M.list(opts)
  elseif action == "pick-module" then
    M.pick_module(opts)
  else
    run_with_output(action, opts)
  end
end

function M.command_line(raw_args)
  local words = shell_words(raw_args or "")
  local action = table.remove(words, 1)
  if not action or action == "" then
    notify("Usage: :Sdlc <action> [sdlc flags] [-- app args]", vim.log.levels.WARN)
    return
  end

  M.command(action, words)
end

function M.prompt_command()
  vim.ui.input({ prompt = "sdlc " }, function(input)
    if input and input ~= "" then
      M.command_line(input)
    end
  end)
end

local function complete_args()
  return {
    "run",
    "test",
    "build",
    "install",
    "clean",
    "list",
    "--",
    "--all",
    "--module",
    "--ignore",
    "--depth",
    "--parallel",
    "--watch",
    "--dry-run",
    "--verbose",
    "--debounce",
    "--config",
    "--terminal",
    "--float",
    "--vertical",
    "--horizontal",
    "--split",
    "--size",
  }
end

local function command_options()
  return { nargs = "*", complete = complete_args }
end

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})

  vim.api.nvim_create_user_command("Sdlc", function(command)
    M.command_line(command.args)
  end, command_options())
  vim.api.nvim_create_user_command("SdlcRun", function(command)
    M.command("run", command.args)
  end, command_options())
  vim.api.nvim_create_user_command("SdlcRunWatch", function(command)
    M.command("run-watch", command.args)
  end, command_options())
  vim.api.nvim_create_user_command("SdlcTest", function(command)
    M.command("test", command.args)
  end, command_options())
  vim.api.nvim_create_user_command("SdlcTestFile", function(command)
    M.command("test-file", command.args)
  end, command_options())
  vim.api.nvim_create_user_command("SdlcBuild", function(command)
    M.command("build", command.args)
  end, command_options())
  vim.api.nvim_create_user_command("SdlcInstall", function(command)
    M.command("install", command.args)
  end, command_options())
  vim.api.nvim_create_user_command("SdlcClean", function(command)
    M.command("clean", command.args)
  end, command_options())
  vim.api.nvim_create_user_command("SdlcList", function(command)
    M.command("list", command.args)
  end, command_options())
  vim.api.nvim_create_user_command("SdlcPickModule", function(command)
    M.command("pick-module", command.args)
  end, command_options())
  vim.api.nvim_create_user_command("SdlcClearModule", function()
    M.clear_module()
  end, {})
  vim.api.nvim_create_user_command("SdlcDryRun", function(command)
    M.command("dry-run", command.args)
  end, command_options())
  vim.api.nvim_create_user_command("SdlcHide", function()
    M.hide()
  end, {})
  vim.api.nvim_create_user_command("SdlcShow", function()
    M.show()
  end, {})
  vim.api.nvim_create_user_command("SdlcStop", function()
    M.stop()
  end, {})
end

M._parse_user_args = parse_user_args
M._command_args = command_args
M._parse_modules = parse_modules

return M
