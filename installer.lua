print("installing yfshop")
local files = {
    "yfshop.lua",
    "krist.lua",
    "settings-example.lua",
    "stock.lua",
    "topbar.lua",
    "abstractInvLib.lua",
    "Krypton.lua"
}

local commitID = "05e7d1cca541ef45bc1106dea9983338f8ec80f7"
local cdn = "https://raw.githubusercontent.com/yourfriendoss/yfshop/"..commitID.."/src/"

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
print('   writing `shell.run("yfshop/yfshop.lua")` in your `startup.lua` file.')