return {
  "goolord/alpha-nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },

  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.startify")

    dashboard.section.header.val = {
      [[             ,----------------,              ,---------,              ]],
      [[        ,-----------------------,          ,"        ,"|              ]],
      [[      ,"                      ,"|        ,"        ,"  |              ]],
      [[     +-----------------------+  |      ,"        ,"    |              ]],
      [[     |  .-----------------.  |  |     +---------+      |              ]],
      [[     |  |hscheric$        |  |  |     | -==----'|      |              ]],
      [[     |  |                 |  |  |     |         |      |              ]],
      [[     |  |                 |  |  |/----|`---=    |      |              ]],
      [[     |  |                 |  |  |   ,/|==== ooo |      ;              ]],
      [[     |  |                 |  |  |  // |(((( [33]|    ,"               ]],
      [[     |  `-----------------'  |," .;'| |((((     |  ,"                 ]],
      [[     +-----------------------+  ;;  | |         |,"                   ]],
      [[        /_)______________(_/  //'   | +---------+                     ]],
      [[   ___________________________/___  `,                                ]],
      [[  /  oooooooooooooooo  .o.  oooo /,   \,"-----------                  ]],
      [[ / ==ooooooooooooooo==.o.  ooo= //   ,`\--{)B     ,"                  ]],
      [[/_==__==========__==_ooo__ooo=_/'   /___________,"                    ]],
    }

    alpha.setup(dashboard.opts)
  end,
}

