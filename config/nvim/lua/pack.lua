
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

local function pack_info()
    local plugins = vim.pack.get(nil, { info = true })

    if not plugins or #plugins == 0 then
        print('No plugins installed')
        return
    end

    -- sort the plugins by name
    table.sort(plugins, function(a, b)
        return a.spec.name < b.spec.name
    end)

    -- format the plugins for display in mini.pick
    local home = vim.env.HOME
    local items = {}
    for _, plugin in ipairs(plugins) do
        local name = plugin.spec.name
        local active = plugin.active and '+ active' or '- inactive'
        local rev = plugin.rev and plugin.rev:sub(1, 7) or 'unknown'
        local path = plugin.path and plugin.path or 'unknown'
        -- trim HOME from path
        if home and path:sub(1, #home) == home then
            path = '~' .. path:sub(#home + 1)
        end
        local display = string.format('%-25s %-12s %-10s %s',
                                      name, active, rev, path)
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

vim.api.nvim_create_user_command('PackUpdate', function()
    pack_update()
end, { desc = 'Update all plugins' })

vim.api.nvim_create_user_command('PackDelete', function(opts)
    pack_delete(opts.args)
end, {
    nargs = 1,
    desc = 'Delete a plugin',
    complete = function()
        local plugins = vim.pack.get()
        local names = {}
        for _, plugin in ipairs(plugins) do
            table.insert(names, plugin.spec.name)
        end
        return names
    end,
})

vim.api.nvim_create_user_command('PackInfo', function()
    pack_info()
end, { desc = 'Show plugin info picker' })

