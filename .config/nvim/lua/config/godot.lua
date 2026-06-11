-- Executable name/path; override per-project with a local .nvim.lua if needed
vim.g.godot_exec = vim.g.godot_exec or 'godot'

local function find_godot_project()
  local f = vim.fn.findfile('project.godot', '.;')
  if f == '' then
    return nil
  end
  return vim.fn.fnamemodify(f, ':p:h')
end

local function register_server(project_dir)
  local godot_dir = project_dir .. '/.godot'
  vim.fn.mkdir(godot_dir, 'p')
  local f = io.open(godot_dir .. '/nvim_server', 'w')
  if f then
    f:write(vim.v.servername)
    f:close()
  end
end

-- Auto-register this instance whenever we're inside a Godot project
vim.api.nvim_create_autocmd({ 'VimEnter', 'DirChanged' }, {
  callback = function()
    -- Defer slightly so v:servername is guaranteed to be populated
    vim.defer_fn(function()
      local dir = find_godot_project()
      if dir then
        register_server(dir)
      end
    end, 50)
  end,
})

-- :Godot [executable]  — launch Godot with the current project
vim.api.nvim_create_user_command('Godot', function(opts)
  local project_dir = find_godot_project()
  if not project_dir then
    vim.notify('[Godot] No project.godot found', vim.log.levels.ERROR)
    return
  end

  register_server(project_dir) -- ensure server address is fresh before Godot reads it

  local exec = (opts.args ~= '' and opts.args) or vim.g.godot_exec
  vim.fn.jobstart({ exec, '--editor', '--path', project_dir }, { detach = true })
  vim.notify('[Godot] Launched → ' .. project_dir)
end, {
  nargs = '?',
  complete = 'file',
  desc = 'Launch Godot with the current project, registering this Neovim as the server',
})

local function godot_bridge(cmd)
  local client = vim.loop.new_tcp()
  client:connect('127.0.0.1', 6666, function(err)
    if err then
      vim.schedule(function()
        vim.notify(
          '[Godot] Editor bridge not reachable — is Godot open with the plugin enabled?',
          vim.log.levels.WARN
        )
      end)
      client:close()
      return
    end
    client:write(cmd, function()
      client:close()
    end)
  end)
end

vim.api.nvim_create_user_command('GodotPlay', function()
  godot_bridge('play')
end, { desc = 'Run main scene in Godot editor' })
vim.api.nvim_create_user_command('GodotPlayScene', function()
  godot_bridge('play_scene')
end, { desc = 'Run current scene in Godot editor' })
vim.api.nvim_create_user_command('GodotStop', function()
  godot_bridge('stop')
end, { desc = 'Stop running scene in Godot editor' })
