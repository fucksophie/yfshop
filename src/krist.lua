local krist = {}

function split (inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function krist.start(settings, privateKey, stock)
  krist.settings = settings
  krist.stock = stock

  local Krypton = require("Krypton")

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
    if transactionEvent.transaction.from ~= krist.settings.address then
      local item = ""
      local ret = ""

      if string.find(transactionEvent.transaction.metadata, "return") then
        local split = split(transactionEvent.transaction.metadata, ";")
        for _,v in pairs(split) do
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

      local result = krist.stock.buy(item, transactionEvent.transaction.value)

      if type(result) == "number" then
        krist.ws:makeTransaction(ret, result, "You spent too much! Overflowed "..result.."KST.")
      elseif type(result) == "boolean" then
        if result then
          krist.ws:makeTransaction(ret, transactionEvent.transaction.value, "Return (of item "..item..") to address "..ret.."")
        end -- if this is false we do nothing
      end

    end
  end
end

function krist.kryptonListener()
  print("[kristmanager] listening")
  krist.ws:listen()
end


return krist