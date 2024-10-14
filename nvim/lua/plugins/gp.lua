return {
  'robitx/gp.nvim',
  config = function()
    local conf = {
      providers = {
        openai = {
          disable = true,
          -- endpoint = 'https://api.openai.com/v1/chat/completions',
        },
        anthropic = {
          endpoint = 'https://api.anthropic.com/v1/messages',
        },
      },
      agents = {
        {
          provider = 'anthropic',
          name = 'ChatClaude-3-5-Sonnet',
          chat = true,
          command = true,
          model = { model = 'claude-3-5-sonnet-20240620', temperature = 0.8, top_p = 1 },
          -- model = { model = 'claude-3-5-sonnet-20240620' },
          system_prompt = require('gp.defaults').chat_system_prompt,
        },
      },
      hooks = {
        -- GpImplement rewrites the provided selection/range based on comments in it
        Implement = function(gp, params)
          local template = 'Having following from {{filename}}:\n\n'
            .. '```{{filetype}}\n{{selection}}\n```\n\n'
            .. 'Please rewrite this according to the contained instructions.'
            .. '\n\nRespond exclusively with the snippet that should replace the selection above.'
            .. '\n\nNothing else. No introductory comment, no instructions and no markdown markup.'

          local agent = gp.get_command_agent()
          gp.logger.info('Implementing selection with agent: ' .. agent.name)

          gp.Prompt(
            params,
            gp.Target.rewrite,
            agent,
            template,
            nil, -- command will run directly without any prompting for user input
            nil -- no predefined instructions (e.g. speech-to-text from Whisper)
          )
        end,

        Explain = function(gp, params)
          local template = 'I have the following code from {{filename}}:\n\n'
            .. '```{{filetype}}\n{{selection}}\n```\n\n'
            .. 'Please respond by explaining the code above.'
          local agent = gp.get_chat_agent()
          gp.Prompt(params, gp.Target.vnew, agent, template)
        end,

        CodeReview = function(gp, params)
          local template = 'I have the following code from {{filename}}:\n\n'
            .. '```{{filetype}}\n{{selection}}\n```\n\n'
            .. 'Please analyze for code smells and suggest improvements.'
          local agent = gp.get_chat_agent()
          gp.Prompt(params, gp.Target.vnew 'markdown', agent, template)
        end,
      },
    }
    require('gp').setup(conf)

    -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
  end,
}
