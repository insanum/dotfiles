
-- extract the git repo name from a plugin spec
-- spec.plug is always a table; first entry is either a string (git url)
-- or a table with a 'src' attribute (git url)
local function get_repo_name(spec)
    local plugin_entry = spec.plug[1]
    local git_url = (type(plugin_entry) == 'string') and
                    plugin_entry or plugin_entry.src
    if not git_url then return nil end
    -- extract just the repo name (e.g., 'user/repo' -> 'repo')
    local repo_name = git_url:match('/([^/]+)$') or git_url
    -- remove .git suffix if present
    return repo_name:gsub('%.git$', '')
end

-- Load all plugin specs from 'lua/plugins' directory
local plugs_path = vim.fn.stdpath('config') .. '/lua/plugins'
local plugs = {}
local plugs_by_name = {} -- for lookup by plugin name

-- load all plugins specs under 'lua/plugins' into a table
for name, ftype in vim.fs.dir(plugs_path) do
    if (ftype == 'file' or ftype == 'link') and name:match('%.lua$') then
        local m = require('plugins.' .. name:gsub('%.lua$', ''))
        if not m.disabled then
            table.insert(plugs, m)
            local repo_name = get_repo_name(m)
            if repo_name then
                plugs_by_name[repo_name] = m
            end
        end
    end
end

-- sort plugins by priority (lower value = higher priority), then by name
table.sort(plugs, function(a, b)
    local priority_a = a.priority or 100
    local priority_b = b.priority or 100
    if priority_a == priority_b then
        return a.name < b.name
    end
    return priority_a < priority_b
end)

--[[
Setup a plugin spec by doing the following:
  - call the 'pre_pack_add()' function if defined
  - add the dependencies to vim.pack if the 'depends' field is defined
  - add the plugin to vim.pack
  - if the 'setup' field is true (default), call the plugin's 'setup()'
    function passing it the 'opts' field (if defined else an empty table)
  - call the 'post_setup()' function if defined
--]]
local function pack_setup_plugin(spec)
    if spec.pre_pack_add then spec.pre_pack_add() end
    if spec.depends then vim.pack.add(spec.depends) end
    vim.pack.add(spec.plug)

    if spec.setup ~= false then
        local ok, plugin = pcall(require, spec.name)
        if ok and plugin.setup then
            pcall(plugin.setup, spec.opts or {})
        end
    end

    if spec.post_setup then spec.post_setup() end
end

-- load all plugins (already sorted, iterates in priority order)
for _, m in ipairs(plugs) do
    pack_setup_plugin(m)
end

local function pack_update()
    print('Updating all plugins...')
    vim.pack.update()
    print('Done!')
end

local function pack_delete(name)
    if not name or name == '' then
        print('Usage: :PackDelete <plugin_name>')
        return
    end

    local ok, err = pcall(vim.pack.del, { name })
    if ok then
        print('Deleted plugin: ' .. name)
    else
        print('Error: ' .. tostring(err))
    end
end

local function pack_reload(name)
    if not name or name == '' then
        print('Usage: :PackReload <plugin_name>')
        return
    end

    -- find the plugin spec by repo name
    local spec = plugs_by_name[name]
    if not spec then
        print('Plugin not found: ' .. name)
        return
    end

    -- clear the plugin from the package cache
    package.loaded[spec.name] = nil

    -- re-setup the plugin
    pack_setup_plugin(spec)
    print('Reloaded plugin: ' .. name)
end

local function pack_info()
    local plugins = vim.pack.get(nil, { info = true })

    if not plugins or #plugins == 0 then
        print('No plugins installed')
        return
    end

    -- sort plugins by priority (lower value = higher priority), then by name
    table.sort(plugins, function(a, b)
        local spec_a = plugs_by_name[a.spec.name]
        local spec_b = plugs_by_name[b.spec.name]
        local priority_a = (spec_a and spec_a.priority) or 100
        local priority_b = (spec_b and spec_b.priority) or 100
        if priority_a == priority_b then
            return a.spec.name < b.spec.name
        end
        return priority_a < priority_b
    end)

    -- format the plugins for display in mini.pick
    local home = vim.env.HOME
    local items = {}
    for _, plugin in ipairs(plugins) do
        local name = plugin.spec.name
        local spec = plugs_by_name[name]
        local priority = (spec and spec.priority) or 100
        local active = plugin.active and '+ active' or '- inactive'
        local rev = plugin.rev and plugin.rev:sub(1, 7) or 'unknown'
        local path = plugin.path and plugin.path or 'unknown'
        -- trim HOME from path
        if home and path:sub(1, #home) == home then
            path = '~' .. path:sub(#home + 1)
        end
        local display = string.format('%-25s [%3d] %-12s %-10s %s',
                                      name, priority, active, rev, path)
        table.insert(items, display)
    end

    local pick = require('mini.pick')
    pick.start({
        source = {
            items = items,
            name = 'Plugin Info',
            choose = function() end, -- do nothing on selection
        },
    })
end

local function complete_plugin_names()
    local plugins = vim.pack.get()
    local names = {}
    for _, plugin in ipairs(plugins) do
        table.insert(names, plugin.spec.name)
    end
    return names
end

vim.api.nvim_create_user_command('PackUpdate', function()
    pack_update()
end, { desc = 'Update all plugins' })

vim.api.nvim_create_user_command('PackDelete', function(opts)
    pack_delete(opts.args)
end, {
    nargs = 1,
    desc = 'Delete a plugin',
    complete = complete_plugin_names,
})

vim.api.nvim_create_user_command('PackInfo', function()
    pack_info()
end, { desc = 'Show plugin info' })

vim.api.nvim_create_user_command('PackReload', function(opts)
    pack_reload(opts.args)
end, {
    nargs = 1,
    desc = 'Reload a plugin',
    complete = complete_plugin_names,
})

-- export the reload function for programmatic use
return {
    reload = pack_reload,
}

