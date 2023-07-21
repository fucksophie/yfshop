local abstractInvLib = require('lib.abstractInvLib')

local stock = {
  ["ids"] = {},
  ["categories"] = {},
  ["inv"] = {},
  ["settings"] = {}
}

function stock.setSettings(settings)
  stock.settings = settings
end

function stock.setCategories(categories)
  stock.categories = categories
end
--monitor, y + 1, rightGap, rawWidth, row
function stock.drawRow(monitor, y, rightGap, width, row)
  local x = 1

  if rightGap ~= nil and rightGap ~= 0 then
    x = rightGap+2
    width = width-rightGap
  end

  local currentW = 1;
  
  monitor.setCursorPos(x, y)
  currentW = math.floor(0.41*width)
  monitor.write(row[1]:sub(0, currentW))
  x = x + currentW

  monitor.setCursorPos(x, y)
  currentW = math.floor(0.21*width)
  monitor.write(row[2]:sub(0, currentW))
  x = x + currentW

  monitor.setCursorPos(x, y)
  currentW = math.floor(0.21*width)
  monitor.write(row[3]:sub(0, currentW))
  x = x + currentW

  monitor.setCursorPos(x, y)
  currentW = math.floor(0.15*width)
  monitor.write(row[4]) 
end

function stock.render(monitor, rawY, topbar)
  local rawWidth, rawHeight = monitor.getSize()
  local rightGap = 0

  if stock.settings then
    if stock.settings.sideText then
      local lines = split(stock.settings.sideText, "\n")
      local widthAlloc = 0
      for k,line in pairs(lines) do
        if #line > widthAlloc then
          widthAlloc = #line
        end
      end
      if stock.settings.side == "left" then
        rawWidth = rawWidth-widthAlloc
      else
        rightGap = widthAlloc
      end
    end
  end

  for cy = rawY + 1, rawHeight - 1 do
    for cx = 1, rawWidth do
      monitor.setCursorPos(cx, cy)
      monitor.write(" ")
    end
  end

  local y = rawY + 1
  monitor.setTextColor(colors.gray)
  stock.drawRow(monitor, y, rightGap, rawWidth, { "Name", "Stock", "Price", "M-name" });

  monitor.setTextColor(colors.white)

  for k, v in pairs(stock.categories[topbar.selected].items) do
    y = y + 1
    local stockValue = "0"
    if stock.ids[v.id] then
      stockValue = tostring(stock.ids[v.id])
    end
    stock.drawRow(monitor, y, rightGap, rawWidth, { v.name, stockValue, v.price .. "\164", k });
  end

  if stock.settings then
    if stock.settings.sideText then
      local lines = split(stock.settings.sideText, "\n")
      for k,line in pairs(lines) do

        if stock.settings.side == "left" then
          monitor.setCursorPos(rawWidth+1, rawY+k)
        else
          monitor.setCursorPos(1, rawY+k)
        end
        monitor.write(line)
      end
    end
  end
  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.white)
end

function stock.buy(metaname, kst) -- returns true if a return is required, or a number of kst needed to be returned. false otherwise
  stock.calculate()               -- good to rerun here incase chest has updated
  -- it is good to be 100% sure about info here

  local turtlename = peripheral.find("modem").getNameLocal()

  local invItem = nil

  for categoryid, category in pairs(stock.categories) do
    for itemid, item in pairs(category.items) do
      if metaname == itemid then
        invItem = item
      end
    end
  end

  if not invItem then
    return true
  end

  local amount = math.floor(kst / invItem.price) -- this is how much a user is buying for
  local availableStock = stock.ids[invItem.id] -- this is how much stock we have

  if not availableStock then
    return true
  end

  local overflow = 0

  if availableStock - amount < 0 then
    -- user is trying to buy too much
    local gottenAmount = amount - availableStock -- this is their overflowed items
    local overflowKst = gottenAmount * invItem.price
    overflow = math.floor(overflowKst)
  end

  local stack = 64 -- TODO: Get stack based on invItem.id, instead of hardcoding it.
  -- This means items such as Ender Pearls will entierly break the whole shop.

  for k, v in pairs(stock.inv.list()) do
    if v.name == invItem.id then
      if amount > 0 then
        local pushed = stock.inv.pushItems(turtlename, k+1, math.min(stack, amount))
        turtle.dropUp(math.min(stack, amount))
        amount = amount - pushed
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
  stock.ids = {}
  stock.inv = abstractInvLib({ peripheral.find("inventory") })

  for slot, item in pairs(stock.inv.list()) do
    if stock.ids[item.name] == nil then
      stock.ids[item.name] = 0
    end

    stock.ids[item.name] = stock.ids[item.name] + item.count
  end
end

return stock
