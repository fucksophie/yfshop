--[[
  You need a new wallet to use for this shop.
  Insert it's privateKey and it's address below.

  Other configuration options should be self-explanatory.
]]

return {
  ["address"] = "khelloworl",
  ["privateKey"] = "MyPrivateKey",
  ["addressRowFgColor"] = colors.white,
  ["addressRowBgColor"] = colors.pink,
  ["topbar"] = {
    ["managedBy"] = "exampleUser",
    ["name"]      = "my shop",
    ["smallText"] = false,
    ["nameFgColor"] = colors.white,
    ["nameBgColor"] = colors.pink,

    ["managedFgColor"] = colors.white,
    ["managedBgColor"] = colors.pink,
    
    ["rowFgColor"] = colors.white,
    ["rowBgColor"] = colors.pink,
  },
  ["stock"] = {
    ["sideText"] = "visit\n3.141.lv\nfor more\ndeals!!",
    ["side"] = "right"
  },
  ["categories"] = {
    ["ores"] = {
      ["color"] = colors.red,
      ["items"] = {
        ["cblstn"] = {
          ["name"] = "cobblestone",
          ["id"] = "minecraft:cobblestone",
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