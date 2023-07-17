--[[
  You need a new wallet to use for this shop.
  Insert it's privateKey and it's address below.

  Other configuration options should be self-explanatory.
]]

return {
  ["address"] = "khelloworl",
  ["privateKey"] = "MyPrivateKey",
  ["topbar"] = {
    ["managedBy"] = "exampleUser",
    ["name"]      = "my shop",
    ["smallText"] = false,
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