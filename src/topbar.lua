bigfont = require("/rom/modules/main/bigfont")

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local topbar = {
  ["settings"] = {},
  ["categories"] = {},
  ["buttons"] = {}
}

function topbar.loadSettings(settings)
  topbar.settings = settings
end

function topbar.setCategories(categories)
  topbar.categories = categories
end

function topbar.monitorTouch()
  while true do
    local _, monitorPosition, x, y = os.pullEvent("monitor_touch")
    local monitor = peripheral.wrap(monitorPosition)
    local clickedAtCategory = false

    for k, v in pairs(topbar.buttons) do
      if x >= v.x and x < v.x+v.w and v.y == y then
        topbar.selected = v.name
        topbar.renderCategories(monitor)
        clickedAtCategory = true
      end
    end

    if clickedAtCategory and topbar.onClick ~= nil then
      topbar.onClick()
    end
  end
end

function topbar.renderCategories(monitor)
  local width, height = monitor.getSize()

  local categorieIndex = 0

  for k,v in pairs(topbar.categories) do
    categorieIndex = categorieIndex +1
    local text = " "..k.." "

    if k == topbar.selected then
      text = "["..k.."]"
    end

    monitor.setCursorPos(width-#text, categorieIndex+1)
    monitor.setTextColor(v.color)

    monitor.write(text)

    if tablelength(topbar.categories) ~= #topbar.buttons then
      table.insert(topbar.buttons, {
        ["x"] = width-#text,
        ["y"] = categorieIndex+1,
        ["w"] = #text,
        ["h"] = 1,
        ["name"] = k
      })
    end
  end

  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.white)
  return categorieIndex
end

function topbar.render(monitor)

  local width, height = monitor.getSize()

  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.white)
  monitor.clear()
  monitor.setCursorPos(2, 2)

  local calculatedY = 2

  if topbar.settings.smallText then
    monitor.write(topbar.settings.name)
    calculatedY = calculatedY +1
  else
    bigfont.writeOn(monitor, 1, topbar.settings.name, 2, 2)
    calculatedY = calculatedY +3
  end

  if topbar.settings.managedBy then
    monitor.setCursorPos(2, calculatedY)
    monitor.write("Managed by "..topbar.settings.managedBy)

    calculatedY = calculatedY +1
  end

  local categorieIndex = topbar.renderCategories(monitor)

  calculatedY = calculatedY + math.max(1, tablelength(topbar.categories))
  monitor.setCursorPos(1, calculatedY)
  monitor.setBackgroundColor(colors.pink)
  monitor.setTextColor(colors.black)
  monitor.write(string.rep("-", width))

  return calculatedY
end

return topbar