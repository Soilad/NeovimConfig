return {
  {
    'Wansmer/treesj',
    keys = { '<space>m', '<space>j', '<space>s' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' }, -- if you install parsers with `nvim-treesitter`
    config = function()
      local u = require('treesj.langs.utils')

      -- treesj ships no gdscript preset; node names from tree-sitter-gdscript
      local list = u.set_preset_for_list({
        split = { last_separator = true },
        join = { space_in_brackets = false },
      })
      local args = u.set_preset_for_args({
        split = { last_separator = true },
      })
      local holders = { target_nodes = { 'array', 'dictionary', 'arguments' } }

      require('treesj').setup({
        langs = {
          gdscript = {
            array = list,
            dictionary = list,
            enumerator_list = u.set_preset_for_list({
              split = { last_separator = true },
              join = { space_in_brackets = true },
            }),
            arguments = args,
            parameters = args,
            variable_statement = holders,
            expression_statement = holders,
            return_statement = holders,
            call = { target_nodes = { 'arguments' } },
            attribute_call = { target_nodes = { 'arguments' } },
            function_definition = { target_nodes = { 'parameters' } },
            signal_statement = { target_nodes = { 'parameters' } },
            enum_definition = { target_nodes = { 'enumerator_list' } },
          },
        },
      })
    end,
  },
  { "https://github.com/norcalli/nvim-colorizer.lua" }
}
