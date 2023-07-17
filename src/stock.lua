local abstractInvLib = require('abstractInvLib')

local stock = {
  ["ids"] = {},
  ["categories"] = {}
}

function stock.setCategories(categories)
  stock.categories = categories
end

function stock.drawRow(monitor, y, row)
  local x = 1;
  monitor.setCursorPos(x, y)
  monitor.write(row[1]:sub(0, 4+12)) -- 4 (Buffer: 14)

  x = x + 4 + 12
  monitor.setCursorPos(x, y)
  monitor.write(row[2]:sub(0, 5+3)) -- 5 (Buffer 3)

  x = x + 5 + 3
  monitor.setCursorPos(x, y)
  monitor.write(row[3]:sub(0, 5+4)) -- 5 (Buffer 2)

  x = x + 5 + 2

  monitor.setCursorPos(x, y)
  monitor.write(row[4]:sub(0, 6))
end

function stock.render(monitor, rawY, topbar)
  local rawWidth,rawHeight = monitor.getSize()
  for cy=rawY+1,rawHeight-1 do
    for cx=1,rawWidth do
      monitor.setCursorPos(cx, cy)
      monitor.write(" ")
    end
  end

  local y = rawY + 1
  monitor.setTextColor(colors.gray)
  stock.drawRow(monitor, y, {"Name", "Stock", "Price", "M-name"});

  monitor.setTextColor(colors.white)
  for k,v in pairs(stock.categories[topbar.selected].items) do
    if stock.ids[v.id] then
      stock.drawRow(monitor, y+1, {v.name, tostring(stock.ids[v.id]), v.price.."\164", k});
    end
  end
end

function stock.buy(metaname, kst) -- returns true if a return is required
  stock.calculate() -- good to rerun here incase chest has updated
                    -- it is good to be 100% sure about info here

  local inv = abstractInvLib({ peripheral.find("inventory") })
  local turtlename = peripheral.find("modem").getNameLocal()

  local invItem = nil

  for categoryid,category in pairs(stock.categories) do
    for itemid,item in pairs(category.items) do
      if metaname == itemid then
        invItem = item
      end
    end
  end

  if not invItem then
    return true
  end

  local amount = math.floor(kst/invItem.price) -- this is how much a user is buying for
  local availableStock = stock.ids[invItem.id] -- this is how much stock we have

  if not availableStock then
    return true
  end

  local overflow = 0

  if availableStock-amount < 0 then
    -- user is trying to buy too much
    local gottenAmount = amount-availableStock -- this is their overflowed items
    local overflowKst = gottenAmount*invItem.price
    overflow = math.floor(overflowKst)
  end

  local stack = 64

  for k, v in pairs(inv.list()) do
    if v.name == invItem.id then
      if amount > 0 then
        inv.pushItems(turtlename, k, math.min(stack, amount))
        turtle.dropUp(math.min(stack, amount))
        amount = amount - stack
      end
    end
  end

  stock.calculate()

  if overflow >= 1 then
    return overflow
  else
    return false
  end
end

function stock.calculate()
  stock.ids = {} -- TODO: maybe only check actually needed items? not sure if it'll improve perf at all though
  local invs = { peripheral.find("inventory") }

  for type, inv in pairs(invs) do
    for slot, item in pairs(inv.list()) do
      if stock.ids[item.name] == nil then
        stock.ids[item.name] = 0
      end

      stock.ids[item.name] = stock.ids[item.name] + item.count
    end
  end
end

return stock