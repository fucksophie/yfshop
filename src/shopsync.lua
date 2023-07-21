local settings = require("settings")

local shopsync = {}

function shopsync.update(stock)
  local modem = peripheral.find("modem")
  local x, y, z = gps.locate(5)
  local items = {}
  for categoryid, category in pairs(settings["categories"]) do
    for itemid, item in pairs(category["items"]) do
      local stockValue = "0"
      if stock.ids[item.id] then
        stockValue = tostring(stock.ids[item.id])
      end

      table.insert(shopsync, {
        prices = {
          {
            value = item["price"],
            currency = "KST",
            address = settings["address"],
            requiredMeta = itemid
          }
        },
        item = {
          name = item["id"],
          nbt = nil,
          displayName = item["name"]
        },
        dynamicPrice = false,
        stock = stockValue,
        madeOnDemand = false,
        requiresInteraction = false
      })
    end
  end

  modem.transmit(9773, os.getComputerID() % 65536, {
      type = "ShopSync",
      info = {
        name = settings["topbar"]["name"],
        owner = settings["topbar"]["managedBy"],
        computerID = os.getComputerID(),
        software = {
          name = "yfshop",
          version = "1"
        },
        location = {
          coordinates = {x, y, z},
        },
      },

      items = items
  })
end
return shopsync