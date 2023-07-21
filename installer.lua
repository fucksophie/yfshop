print("installing yfshop")
local files = {
    -- actual code
    "yfshop.lua",
    "krist.lua",
    "stock.lua",
    "topbar.lua",
    "shopsync.lua",
    -- libs
    "lib/abstractInvLib.lua",
    "lib/Krypton.lua",
    "lib/split.lua"
}
local args = {...}
local commitID = "aa85863638bdfde1a4b8bba415e8ef0abf6326a0"

if args[1] then
    commitID = args[1]
end

local cdn = "https://raw.githubusercontent.com/yourfriendoss/yfshop/"..commitID.."/src/"

if not fs.exists("yfshop/settings.lua") then
    -- downloads example settings if settings.lua is missing
    table.insert(files, "settings-example.lua")
end

for k,v in pairs(files) do
    print("> Downloading file: "..v)

    local file = io.open("yfshop/"..v, "w")
    if file == nil then return end
    file:write(http.get(cdn..v).readAll())
    print("> Downloaded: "..v)
end

print("..")
print("this shop is intended for POWERUSERS.")
print("do NOT except a simple to use interface.")
print("..")
print("1. copy `yfshop/settings-example.lua` to `yfshop/settings.lua`")
print("2. edit `yfshop/settings.lua`")
print("3. start yfshop by `cd yfshop` `yfshop`. you can setup a startup script by")
print('   copying the startup.lua file from the github repository.')
