local M = {
    name = 'minuet',
    plug = {
        'https://github.com/milanglacier/minuet-ai.nvim',
    },
    depends = {
        'https://github.com/nvim-lua/plenary.nvim',
    },
    priority = 60,
}

M.opts = {
    -- Talk to a locally-running Ollama using the OpenAI-compatible FIM
    -- (fill-in-the-middle) endpoint. qwen2.5-coder supports FIM natively.
    provider = 'openai_fim_compatible',
    n_completions = 1,     -- FIM: NUMBER OF REQUESTS sent. 1 = one round-trip
    context_window = 2048, -- biggest latency lever; smaller = faster prefill
    context_ratio = 0.75,  -- bias context toward before-cursor
    request_timeout = 2,   -- short timeout returns partials faster
    throttle = 300,        -- min ms between requests
    debounce = 100,        -- fire sooner after you stop typing

    provider_options = {
        openai_fim_compatible = {
            -- Ollama needs no API key, but minuet still wants the *name* of
            -- an env var that exists. $TERM is always set, so it's the
            -- standard dummy.
            api_key = 'TERM',
            name = 'Ollama',
            end_point = 'http://localhost:11434/v1/completions',
            model = 'qwen2.5-coder:7b',
            stream = true,
            optional = {
                max_tokens = 256,
                top_p = 0.9,
                stop = { "\n\n" },
            },
        },
    },

    -- No virtual text: every completion is routed through blink.cmp instead.
    -- (See the 'minuet' provider in lua/plugins/blink.lua.)
    virtualtext = {
        auto_trigger_ft = {},
        keymap = {
            accept = nil,
            accept_line = nil,
            accept_n_lines = nil,
            next = nil,
            prev = nil,
            dismiss = nil,
        },
    },
}

return M
