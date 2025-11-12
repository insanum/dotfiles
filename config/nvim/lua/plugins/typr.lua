local M = {}

M.setup = function(add)
    add({
        source = 'nvzone/typr',
        depends = {
            'nvzone/volt',
        },
    })

    require('typr').setup()
end

return M
