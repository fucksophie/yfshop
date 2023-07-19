-- TODO:
-- There are TODO's scattered around this project.
-- If you fix one of them, please submit a pull request.

-- The PayRow should have several types - middle, left and right.

-- Stock buttons should autoarrange (in a grid) themselves and not just be a bunch of lines.

local settings = require("settings")

function renderPayRow(monitor)
  monitor.setTextColor(settings.addressRowFgColor)
  monitor.setBackgroundColor(settings.addressRowBgColor)

  local width, height = monitor.getSize()

  local str = "/pay "..settings.address.." <price> <metaname>"

  if string.find(settings.address, "@") then
    str = "/pay <metaname>"..settings.address.." <price>"
  end

  monitor.setCursorPos(1, height);
  monitor.write(str.rep(" ", width))
  monitor.setCursorPos(1, height);
  monitor.write(str)

  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.white)
end

local monitor = peripheral.find("monitor")
local topbar = require("topbar")
local krist = require("krist")
local stock = require("stock")

print("yfshop v1")

stock.setSettings(settings.stock)
topbar.loadSettings(settings.topbar)
topbar.setCategories(settings.categories)

for k,v in pairs(settings.categories) do 
  topbar.selected = k;
  break
end

topbar.calculateButtons(monitor)
local topbarY = topbar.render(monitor)

renderPayRow(monitor)

stock.setCategories(settings.categories)

stock.calculate()

stock.render(monitor, topbarY, topbar)

function topbar.onClick()
  stock.render(monitor, topbarY, topbar)
end

function detectResize()
  while true do
    local _, _ = os.pullEvent("monitor_resize")
    topbar.calculateButtons(monitor)
    local topbarY2 = topbar.render(monitor)
    stock.render(monitor, topbarY2, topbar)
    renderPayRow(monitor)
  end
end

function periodicUpdate()
  local timer = os.startTimer(5) -- TODO: I should figure out how
  -- to update stock automatically, not through a updater like this one

  while true do
    local event, tmr = os.pullEvent("timer")
    if tmr == timer then
      timer = os.startTimer(5)
      stock.calculate()
      stock.render(monitor, topbarY, topbar)
      for k, side in pairs(redstone.getSides()) do
        if redstone.getOutput(side) then      
          redstone.setOutput(side, false)
        else
          redstone.setOutput(side, true)
        end
      end
    end
  end
end

local startKristManager = false

if startKristManager then
  krist.start(settings, settings.privateKey, stock)

  parallel.waitForAll(krist.eventListener, krist.kryptonListener, topbar.monitorTouch, periodicUpdate, detectResize)
else
  parallel.waitForAll(topbar.monitorTouch, periodicUpdate, detectResize)
end