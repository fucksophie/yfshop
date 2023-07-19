--[[
  You need a new wallet to use for this shop.
  Insert it's privateKey and it's address below.
]]

return {
  ["address"] = "khelloworl", -- Imput your address here. You can also use a name (TODO however this is untested! DM yourfriend if you want to help out :)) (such as @me.kst)
  ["privateKey"] = "MyPrivateKey", -- Input your private key here
  ["addressRowFgColor"] = colors.white,
  ["addressRowBgColor"] = colors.pink,
  ["adressRowPosition"] = "left", -- Options: "left", "right", "center"
  ["topbar"] = {
    ["managedBy"] = "exampleUser", -- Optional setting
    ["name"]      = "my shop", 
    ["smallText"] = false, -- `false` renders text normally, `true` renders text with bigfont. Requires bigfont library in sc3 directory
    ["nameFgColor"] = colors.white,
    ["nameBgColor"] = colors.pink,

    ["managedFgColor"] = colors.white,
    ["managedBgColor"] = colors.pink,
    
    ["rowFgColor"] = colors.white,
    ["rowBgColor"] = colors.pink,
  },
  ["stock"] = { -- "stock" is optional.
    ["sideText"] = "visit\n3.141.lv\nfor more\ndeals!!", -- Shows a text on the side of the stock
    ["side"] = "right" -- Which side do you want the text to show up on?
  },
  ["categories"] = { -- Categories.
    ["ores"] = {
      ["color"] = colors.red,
      ["items"] = {
        ["cblstn"] = { -- The `cblstn` here is the metaname/item name. 
          ["name"] = "cobblestone",
          ["id"] = "minecraft:cobblestone", -- The `id` here supports ANY mod.
          ["price"] = "0.015"
        }
      }
    },
    ["dyes"] = {
      ["color"] = colors.green,
      ["items"] = {
        ["pdye"] = {
          ["name"] = "pink dye",
          ["id"] = "minecraft:pink_dye",
          ["price"] = "1"
        }
      }
    }
  }
}