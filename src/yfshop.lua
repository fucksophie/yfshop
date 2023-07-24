-- TODO:
-- Stock buttons should autoarrange (in a grid) themselves and not just be a bunch of lines.

local settings = require("settings")

function renderPayRow(monitor)
  monitor.setTextColor(settings.addressRowFgColor)
  monitor.setBackgroundColor(settings.addressRowBgColor)

  local width, height = monitor.getSize()

  local str = "/pay "..settings.address.." <price> <metaname>"

  if string.find(settings.address, ".kst") then
    str = "/pay <metaname>@"..settings.address.." <price>"
  end

  monitor.setCursorPos(1, height);
  monitor.write(str.rep(" ", width))

  if settings.addressRowPosition == "left" then
    monitor.setCursorPos(1, height);
    monitor.write(str)
  elseif settings.addressRowPosition == "right" then
    monitor.setCursorPos(width-#str, height);
    monitor.write(str)
  elseif settings.addressRowPosition == "center" then
    monitor.setCursorPos(math.ceil((width-#str)/2), height);
    monitor.write(str)
  end

  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.white)
end

local monitor = peripheral.find("monitor")
local topbar = require("topbar")
local krist = require("krist")
local stock = require("stock")
local shopsync = require("shopsync")

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


local modem = peripheral.wrap("left")

if not modem then
  print("Modem was not found. Shopsync will not be enabled.")
  print("Add an **ENDER MODEM** **IN THE 1ST SLOT** and restart yfshop to enable shopsync support.")
else
  modem.open(9773)
end

function shopsyncUpdater()
  if not modem then -- if there is no modem it'll just stop ticking it
    return
  end

  local timer = os.startTimer(30) -- Shopsync updates every 30 seconds.

  while true do
    local event, tmr = os.pullEvent("timer")
    if tmr == timer then
      timer = os.startTimer(30)

      shopsync.update(stock)
    end
  end
end

local startKristManager = true

if startKristManager then
  krist.start(settings, settings.privateKey, stock)

  parallel.waitForAll(krist.eventListener, krist.kryptonListener, topbar.monitorTouch, periodicUpdate, detectResize, shopsyncUpdater)
else
  parallel.waitForAll(topbar.monitorTouch, periodicUpdate, detectResize, shopsyncUpdater)
end