return {
    'jakobkhansen/journal.nvim',
    opts = {
        root = '/Volumes/work/notes/Journal',
        filetype = 'md',
        journal = {
            entries = {
                day = {
                    format = '%Y-%m-%d',
                    template = '\n# %a %m/%d/%Y\n\n',
                },
                week = {
                    format = '%Y-w%W',
                    -- template = '\n# %Y (w%W)\n\n',
                    template = function(date)
                        local sunday = date:relative({ day = 6 })
                        local end_date = os.date('%m/%d', os.time(sunday.date))
                        return '\n# %Y %m/%d-' .. end_date .. ' (w%W)\n\n'
                    end,
                },
                month = {
                    format = '%Y-%m',
                    template = '\n# %Y-%m (%b)\n\n',
                },
                year = {
                    format = '%Y',
                    template = '\n# %Y\n\n',
                },
            },
        },
    },
}
