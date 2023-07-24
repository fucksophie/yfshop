local krist = {}
local split = require("lib.split")

local function has_value(tab, val)
  for index, value in ipairs(tab) do
    if value == val then
      return true
    end
  end

  return false
end

function krist.start(settings, privateKey, stock)
  krist.settings = settings
  krist.stock = stock

  local Krypton = require("lib.Krypton")

  krist.krypton = Krypton.new({
    privateKey = privateKey,
    node = "https://krist.dev/",
    id = "krist",
  })

  krist.ws = krist.krypton:connect()
  krist.ws:subscribe("ownTransactions")
  krist.ws:getSelf()
  print("[kristmanager] started")

end

function krist.eventListener()
  while true do
    local event, transactionEvent = os.pullEvent("transaction")
    if transactionEvent.transaction.from ~= krist.krypton:makev2address(krist.settings.privateKey) then
      local item = ""
      local ret = ""

      if transactionEvent.transaction.metadata then
        if string.find(transactionEvent.transaction.metadata, "return") then
          local splitted = split(transactionEvent.transaction.metadata, ";")
          for _,v in pairs(splitted) do
            if not string.find(v, "=") then
              item = v
            else
              if string.find(v, "return=") then
                ret = string.gsub(v, "return=", "")
              end
            end
          end
        else
          item = transactionEvent.transaction.metadata
          ret = transactionEvent.transaction.from
        end

        local whitelisted = false

        if transactionEvent.transaction.sent_metaname then
          item = transactionEvent.transaction.sent_metaname

          if krist.settings.mnameWhitelist then
            if has_value(krist.settings.mnameWhitelist, item) then
              whitelisted = true
            end
          end
        end

        if not whitelisted then
          local result = krist.stock.buy(item, transactionEvent.transaction.value)

          if type(result) == "number" then
            krist.ws:makeTransaction(ret, result, "You spent too much! Overflowed "..result.."KST.")
          elseif type(result) == "boolean" then
            if result then
              krist.ws:makeTransaction(ret, transactionEvent.transaction.value, "Return (of item "..item..") to address "..ret.."")
            end -- if this is false we do nothing
          end
        end
      else
        krist.ws:makeTransaction(transactionEvent.transaction.from, transactionEvent.transaction.value, ret.." please include a m-name!")
      end
    end
  end
end

function krist.kryptonListener()
  print("[kristmanager] listening")
  krist.ws:listen()
end


return krist