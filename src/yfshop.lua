-- TODO:
-- There are TODO's scattered around this project.
-- If you fix one of them, please submit a pull request.

-- The shop currently has limited color configuration.
-- Every background, foreground and whatnot should be configurable.

-- The PayRow should have several types - middle, left and right.

-- The stock screen should have a width too, so I can squeeze in text
-- on either side of the stock screen. Example:
--[[
  |-----------------------------|
  | ME.KST       [concrete] hi  |
  |-----------------------------|
  |Name Stock Price M-name hello| <-- 
  |Hi   2     0.1   hit    world|  Should be doable on either side
  |-----------------------------|
]]

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

function detectResize() -- TODO: Something is HEAVILY wrong with rezising.
  -- I am not precisely sure what it is, but after an resize the monitor renders incorrectly.
  while true do
    local _, _ = os.pullEvent("monitor_resize")
    renderPayRow(monitor)
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    local topbarY2 = topbar.render(monitor)
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    stock.render(monitor, topbarY2, topbar)
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
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