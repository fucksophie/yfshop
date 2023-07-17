local settings = require("settings")

function renderPayRow(monitor)
  monitor.setTextColor(colors.black)
  monitor.setBackgroundColor(colors.pink)
  local width, height = monitor.getSize()

  local str = "/pay "..settings.address.." <price> <metaname>"

  if string.find(settings.address, "@") then
    str = "/pay <metaname>"..settings.address.." <price>"
  end

  monitor.setCursorPos(1, height);
  monitor.write(str.rep(" ", width))
  monitor.setCursorPos(2, height);
  monitor.write(str)
  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.white)
end

local monitor = peripheral.find("monitor")
local topbar = require("topbar")
local krist = require("krist")
local stock = require("stock")

print("yfshop v1")

topbar.loadSettings(settings.topbar)
topbar.setCategories(settings.categories)
topbar.selected = "ores"
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
    renderPayRow(monitor)
    local topbarY2 = topbar.render(monitor)
    stock.render(monitor, topbarY2, topbar)
  end
end

function periodicUpdate()
  local timer = os.startTimer(5)

  while true do
    local event, tmr = os.pullEvent("timer")
    if tmr == timer then
      timer = os.startTimer(5)
      stock.calculate()
      stock.render(monitor, topbarY, topbar)
    end
  end
end

local startKristManager = true

if startKristManager then
  krist.start(settings, settings.privateKey, stock)

  parallel.waitForAll(krist.eventListener, krist.kryptonListener, topbar.monitorTouch, periodicUpdate, detectResize)
else
  parallel.waitForAll(topbar.monitorTouch, periodicUpdate, detectResize)
end