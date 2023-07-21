local token = require("token")
local discordia = require('discordia')
local dcmd = require("discordia-commands")
local tools = dcmd.util.tools()
local client = discordia.Client():useApplicationCommands()
local GON = require("lib.GON")
require("lib.rendering")

UserSettings = {}
CurrentInput = {}
Data = {}

local emojis = {
    apple = "<:apple:1121524962025537648>",
    bloodorange = "<:bloodorange:1121524973673136188>",
    cherry = "<:cherry:1121524977267650590>",
    firedragonfruit = "<:firedragonfruit:1121524983227764867>",
    glowcherry = "<:glowcherry:1121524989024276620>",
    goldenraspberry = "<:goldenraspberry:1121524993533157387>",
    grape = "<:grape:1121524998696353813>",
    lemon = "<:lemon:1121525002446049280>",
    melon = "<:melon:1121525009081454603>",
    multiberry = "<:multiberry:1121524967088066610>",
    orange = "<:orange:1121525014366261278>",
    pear = "<:pear:1121525017381969960>",
    raspberry = "<:raspberry:1121525020867432498>",
    waterdragonfruit = "<:waterdragonfruit:1121525030363336795>",
    fig = "<:fig:1124055368889282560>",
    blueberry = "<:blueberry:1124055352569241640>",
    starfruit = "<:starfruit:1124055384999596154>",
    dragonfruit = "<:dragonfruit:1124055357799534722>",
    pineapple = "<:pineapple:1124055379119190076>",
}

local names = {
    apple = "Apple",
    bloodorange = "Blood Orange",
    cherry = "Cherry",
    firedragonfruit = "Fire Dragonfruit",
    glowcherry = "Glowcherry",
    goldenraspberry = "Golden Raspberry",
    grape = "Grape",
    lemon = "Lemon",
    melon = "Melon",
    multiberry = "Multiberry",
    orange = "Orange",
    pear = "Pear",
    raspberry = "Raspberry",
    waterdragonfruit = "Water Dragonfruit",
    fig = "Fig",
    blueberry = "Blueberry",
    starfruit = "Starfruit",
    dragonfruit = "Dragonfruit",
    pineapple = "Pineapple",
}

local colors = {
    apple = { 1, 0, 0 },
    bloodorange = { 1, 0, 0 },
    cherry = { 1, 0, 0 },
    firedragonfruit = { 1, 0, 0 },
    glowcherry = { 0, 1, 1 },
    goldenraspberry = { 1, 1, 0 },
    grape = { 0, 1, 1 },
    lemon = { 1, 1, 0 },
    melon = { 0, 1, 0 },
    multiberry = { 1, 1, 1 },
    orange = { 1, 1, 0 },
    pear = { 0, 1, 0 },
    raspberry = { 1, 0, 1 },
    waterdragonfruit = { 0, 0, 1 },
    fig = { 1, 0, 1 },
    blueberry = { 0, 0, 1 },
    starfruit = { 1, 1, 0 },
    dragonfruit = { 0, 1, 0 },
    pineapple = { 1, 1, 1 },
}

local tiers = {
    apple = 1,
    bloodorange = 4,
    cherry = 2,
    firedragonfruit = 5,
    glowcherry = 4,
    goldenraspberry = 3,
    grape = 2,
    lemon = 3,
    melon = 3,
    multiberry = 4,
    orange = 2,
    pear = 1,
    raspberry = 1,
    waterdragonfruit = 5,
    fig = 2,
    blueberry = 3,
    starfruit = 4,
    dragonfruit = 5,
    pineapple = 6,
}

local upgrades = {
    apple = { amnt = 4, id = "cherry" },
    cherry = { amnt = 6, id = "melon" },
    melon = { amnt = 12, id = "glowcherry" },
    glowcherry = { amnt = 15, id = "waterdragonfruit" },

    pear = { amnt = 4, id = "orange" },
    orange = { amnt = 6, id = "lemon" },
    lemon = { amnt = 12, id = "bloodorange" },
    bloodorange = { amnt = 20, id = "firedragonfruit" },

    raspberry = { amnt = 6, id = "grape" },
    grape = { amnt = 12, id = "goldenraspberry" },
    goldenraspberry = { amnt = 20, id = "multiberry" },

    fig = { amnt = 10, id = "blueberry" },
    blueberry = { amnt = 10, id = "starfruit" },
    starfruit = { amnt = 10, id = "dragonfruit" },
}

function table.copy(v)
    local out = {}
    for i = 1, #v do
        if type(v[i]) ~= "table" then
            out[i] = v[i]
        else
            out[i] = table.copy(v[i])
        end
    end
    return out
end

local function NewFruit(fruitid)
    return { id = fruitid, time = os.time() + 2000 * tiers[fruitid] }
end


local file = io.open("data.gon", "r")
if not file then
    file = io.open("data.gon", "w")
    file:write(GON.encode({}) .. "\n")
    file:close()
else
    Data = GON.decode(file:read())
    file:close()
end

local function SaveData()
    local file = io.open("data.gon", "w")
    file:write(GON.encode(Data) .. "\n")
    file:close()
end

local function Hexify(clr)
    return clr[3] + clr[2] * 256 + clr[1] * 65536
end

local function TakeFruit(user, fruit, amnt)
    for i = 1, #user.fruits do
        if amnt == 0 then
            break
        end

        local v = user.fruits[i]
        if v.id == fruit then
            table.remove(user.fruits, i)
            amnt = amnt - 1
        end
    end
end

local function GiveFruit(user, fruit, amnt)
    user.fruits = user.fruits or {}
    for _ = 1, (amnt or 1) do
        user.fruits[#user.fruits + 1] = fruit
    end
end

local function UpgradeFruit(user, fruitid)
    if user.fruits then
        if (fruitid ~= "firedragonfruit") and (fruitid ~= "waterdragonfruit") and (fruitid ~= "dragonfruit") then
            local amnt = 0
            for i = 1, #user.fruits do
                local v = user.fruits[i]
                if v.id == fruitid then
                    amnt = amnt + 1
                end
            end
            if upgrades[fruitid] then
                if amnt >= upgrades[fruitid].amnt then
                    TakeFruit(user, fruitid, upgrades[fruitid].amnt)
                    GiveFruit(user, NewFruit(upgrades[fruitid].id), 1)
                    return "Your **" ..
                        upgrades[fruitid].amnt .. emojis[fruitid] ..
                        "** have been upgraded to **1** " .. emojis[upgrades[fruitid].id] .. "!"
                end
                return "You need **" ..
                    upgrades[fruitid].amnt - amnt .. " more " .. emojis[fruitid] .. "** to upgrade to the next tier!"
            elseif emojis[fruitid] then
                if fruitid ~= "pineapple" then
                    return "This " ..
                        emojis[fruitid] .. " fruit currently can't be upgraded!"
                elseif amnt == 1 then
                    return "This " ..
                        emojis[fruitid] .. " fruit currently can't be upgraded! Now go touch some grass :)"
                elseif amnt >= 2 then
                    return
                    "Why do you have so many? You're never gonna need this many why are you even trying to merge them how does that make sense??"
                end
            else
                return "This fruit doesn't exist!"
            end
        else
            local famnt = 0
            local wamnt = 0
            local damnt = 0
            for i = 1, #user.fruits do
                local v = user.fruits[i]
                if v.id == "firedragonfruit" then
                    famnt = famnt + 1
                elseif v.id == "waterdragonfruit" then
                    wamnt = wamnt + 1
                elseif v.id == "dragonfruit" then
                    damnt = damnt + 1
                end
            end
            if (famnt < 10) or (wamnt < 10) or (damnt < 10) then
                return "You need **" ..
                    10 - famnt ..
                    " more** " ..
                    emojis["firedragonfruit"] ..
                    ", **" ..
                    10 - wamnt ..
                    " more** " ..
                    emojis["waterdragonfruit"] ..
                    " and **" .. 10 - damnt .. " more** " .. emojis["dragonfruit"] .. " to upgrade to the next tier!"
            end
            TakeFruit(user, "firedragonfruit", 10)
            TakeFruit(user, "waterdragonfruit", 10)
            TakeFruit(user, "dragonfruit", 10)
            GiveFruit(user, NewFruit("pineapple"), 1)
            return "Your **10**" ..
                emojis["firedragonfruit"] ..
                ", **10**" ..
                emojis["waterdragonfruit"] ..
                " and **10**" ..
                emojis["dragonfruit"] .. " have been merged into **1**" .. emojis["pineapple"] .. "!"
        end
    end
    return "You don't have a starter fruit yet, so there's nothing to harvest. use `/starter` to get a starter fruit!"
end

local function UpgradeAllFruit(user, fruitid)
    if user.fruits then
        local amnt = 0
        for i = 1, #user.fruits do
            local v = user.fruits[i]
            if v.id == fruitid then
                amnt = amnt + 1
            end
        end
        if upgrades[fruitid] then
            local newamnt = math.floor(amnt / upgrades[fruitid].amnt)
            local oldamnt = newamnt * upgrades[fruitid].amnt
            TakeFruit(user, fruitid, oldamnt)
            GiveFruit(user, NewFruit(upgrades[fruitid].id), newamnt)
            if amnt >= upgrades[fruitid].amnt then
                return "Your **" ..
                    oldamnt .. emojis[fruitid] ..
                    "** have been upgraded to **" ..
                    newamnt .. "**" .. emojis[upgrades[fruitid].id] .. "!"
            else
                return "You need **" ..
                    upgrades[fruitid].amnt - amnt ..
                    " more " .. emojis[fruitid] .. "** to be able to upgrade to the next tier!"
            end
        elseif emojis[fruitid] then
            return "This fruit currently can't be upgraded!"
        end
    end
    return "You don't have a starter fruit yet, so there's nothing to harvest. use `/starter` to get a starter fruit!"
end

local function IsFruitReady(fruit)
    if os.time() >= fruit.time then
        return true
    end
    return false
end

local function AverageFruitColor(fruits)
    local amnt = #fruits
    local out = { 0, 0, 0 }
    local v
    for i = 1, #fruits do
        v = fruits[i]
        out[1] = out[1] + colors[v.id][1] * 255
        out[2] = out[2] + colors[v.id][2] * 255
        out[3] = out[3] + colors[v.id][3] * 255
    end
    for i = 1, 3 do
        out[i] = math.floor((out[i] / amnt) + 0.5)
    end
    return out
end

local function UpgradeAllFruitAll(user)
    local id = {}
    if user.fruits then
        for _, w in ipairs(user.fruits) do
            if not id[w.id] then
                id[w.id] = true
                UpgradeAllFruit(user, w.id) -- todo
            end
        end
        return "Command has been ran!"
    end
    return "You don't have a starter fruit yet, so there's nothing to harvest. use `/starter` to get a starter fruit!"
end

local function CalculateFruitLoot(fruitid)
    math.randomseed(os.time())
    local out = {}
    if fruitid ~= "fig" and fruitid ~= "blueberry" then
        for i, v in pairs(tiers) do
            if i ~= "blueberry" and i ~= "starfruit" and i ~= "dragonfruit" then
                if v < tiers[fruitid] then
                    local camnt = 0
                    for j = 1, 3 do
                        if colors[i][j] == 1 and colors[fruitid][j] == 1 then
                            camnt = camnt + 1
                        end
                    end
                    local amount = math.floor(math.floor(camnt / 2 + 0.5))
                    for _ = 1, amount do
                        out[#out + 1] = NewFruit(i)
                    end
                end
            end
        end
    end
    return out
end

local function Harvest(userid)
    local user = Data[userid]
    if user then
        if user.fruits then
            local outmsg = "All fruit harvested! You got:"
            local fruitamnt = {}
            local fr = false
            for i = 1, #user.fruits do
                if IsFruitReady(user.fruits[i]) then
                    fr = true
                    user.fruits[i].time = os.time() + 2000 * tiers[user.fruits[i].id]
                    local v
                    for j = 1, #CalculateFruitLoot(user.fruits[i].id) do
                        v = CalculateFruitLoot(user.fruits[i].id)[j]
                        GiveFruit(user, v)
                        fruitamnt[v.id] = (fruitamnt[v.id] or 0) + 1
                    end
                end
            end
            SaveData()
            if not fr then
                local lowtwb = ""
                for i = 1, #user.fruits do
                    lowtwb = lowtwb ..
                        emojis[user.fruits[i].id] ..
                        "<t:" .. user.fruits[i].time .. ":R>\n"
                end
                outmsg = "None of your fruit are ready to harvest. Here's when they will be:\n" .. lowtwb
            else
                for k, v in pairs(fruitamnt) do
                    outmsg = outmsg .. "\n**" .. tostring(v) .. "** " .. emojis[k]
                end
            end
            return outmsg
        end
        return "You don't have a starter fruit yet, so there's nothing to harvest. use `/starter` to get a starter fruit!"
    else
        return "You don't have a garden yet, so you don't have any fruit. Use `/claim` to claim a garden!"
    end
end

local function InvToString(user)
    local amnts = {}
    local fruits = user.fruits
    local out = {}
    for i = 1, #fruits do
        amnts[fruits[i].id] = (amnts[fruits[i].id] or 0) + 1
    end
    for k, v in pairs(amnts) do
        out[#out + 1] = { name = emojis[k] .. names[k] .. "\t", value = v, inline = true }
    end
    return out
end

client:on('ready', function()
    print('Logged in as ' .. client.user.name)

    local cmds = {
        ["claim"] = {
            desc = "Claims a garden for you."
        },
        ["starter"] = {
            desc = "Gives you a starter fruit. One time use!",
            options = {
                fruit = {
                    desc = "The fruit you will start you adventure with. Pick carefully!",
                    req = true,
                    choices = {
                        ["Grape"] = { id = "grape" },
                        ["Cherry"] = { id = "cherry" },
                        ["Orange"] = { id = "orange" },
                    }
                }
            }
        },
        ["harvest"] = {
            desc = "Harvest all your fruit's fruit. Might be fruitful."
        },
        ["merge"] = {
            desc = "Takes some of your fruit and merges them into a better one.",
            options = {
                fruit = {
                    desc = "The fruit to merge.",
                    req = true,
                },
            }
        },
        ["inventory"] = {
            desc = "Shows your inventory.",
            options = {
                username = {
                    desc = "The user's username. Make sure it's correct.",
                    req = false
                },
            }
        },
        ["reset"] = {
            desc = "Resets your data. Only use in emergencies!",
        },
        ["mergeall"] = {
            desc = "Takes all of your fruit and merges them into a better one.",
            options = {
                fruit = {
                    desc = "The fruit to merge.",
                    req = true,
                },
            }
        },
        ["supermerge"] = {
            desc = "Merges all possible fruit (might need to run it a couple times)."
        }
    }

    for k, v in pairs(cmds) do
        local slashCommand = tools.slashCommand(k, v.desc)
        if v.options then
            for i, j in pairs(v.options) do
                local option = tools.string(i, j.desc)
                if j.choices then
                    for x, y in pairs(j.choices) do
                        option = option:addChoice(tools.choice(x, y.id))
                    end
                end
                option = option:setRequired(j.req)
                slashCommand = slashCommand:addOption(option)
            end
        end
        client:createGlobalApplicationCommand(slashCommand)
    end
    client:info("Ready!")
end)

client:on("slashCommand", function(ia, cmd, args)
    print(cmd.name)
    if cmd.name == "claim" then
        if not Data[ia.member.user.id] then
            Data[ia.member.user.id] = {}
            SaveData()
            ia:reply("Your garden has been claimed!")
        else
            ia:reply("You already have a garden, pick a starter fruit by using `/starter`!")
        end
    elseif cmd.name == "starter" then
        local user = Data[ia.member.user.id]
        if not user then
            ia:reply(
                "Before picking a starter fruit, you have to claim a garden using `/claim`!")
            return
        end
        if user.fruits == nil then
            user.fruits = {}
            GiveFruit(user, NewFruit(args.fruit))
            SaveData()
            ia:reply("You've chosen " ..
                emojis[args.fruit] .. " **" .. names[args.fruit] .. "** as your starter fruit. Have fun!")
        else
            ia:reply("You already picked. No more starter fruit!")
        end
    elseif cmd.name == "harvest" then
        ia:reply(Harvest(ia.member.user.id))
    elseif cmd.name == "merge" then
        local user = Data[ia.member.user.id]
        if user then
            ia:reply(UpgradeFruit(user))
            SaveData()
        else
            ia:reply("You don't have a garden yet, so you don't have any fruit. Use `/claim` to claim a garden!")
        end
    elseif cmd.name == "mergeall" then
        local user = Data[ia.member.user.id]
        if user then
            ia:reply(UpgradeAllFruit(user, args.fruit))
            SaveData()
        else
            ia:reply("You don't have a garden yet, so you don't have any fruit. Use `/claim` to claim a garden!")
        end
    elseif cmd.name == "inventory" then
        local userid = ia.member.user.id
        if args then
            userid = ia.guild:getMember(args.username)
        end
        local user = Data[userid]
        if user then
            if user.fruits then
                -- ia:reply(InvToString(userid))
                ia:reply
                {
                    embed = {
                        title = ia.guild:getMember(userid).user.name .. "'s Inventory:",
                        fields = InvToString(user),
                        footer = {
                            text = "Total fruit: " .. #user.fruits
                        },
                        color = Hexify(AverageFruitColor(user.fruits)) -- hex color code
                    }
                }
            end
        end
    elseif cmd.name == "reset" then
        Data[ia.member.user.id] = nil
        SaveData()
        ia:reply("Your data has been reset. Please re-claim a garden.")
    elseif cmd.name == "supermerge" then
        local user = Data[ia.member.user.id]
        if user then
            ia:reply(UpgradeAllFruitAll(user))
            SaveData()
        else
            return "You don't have a garden yet, so you don't have any fruit. Use `/claim` to claim a garden!"
        end
    end
end)

client:on('messageCreate', function(message)
    if message.content:find("<@1120788389311025323>") then
        message:reply("I have awakened.")
    end
    -- if message.content ~= "" then
    --     local lrm = message.content
    --     local lbc = 0
    --     for i = 1, #lrm do
    --         if lrm:sub(i, i) == "\n" then
    --             lbc = lbc + 1
    --         end
    --     end
    --     if (lbc >= 5) or (#lrm >= 200) then
    --         lrm = lrm:sub(1, 75) .. " (+ " .. #lrm - 75 .. " more)"
    --     end
    --     local rtidk = "\n     "
    --     for _ = 1, #message.author.name do
    --         rtidk = rtidk .. " "
    --     end
    --     lrm = lrm:gsub("\n", rtidk)
    --     RenderText({ { "< " .. message.author.name .. " > ", Colors.bright_cyan }, { lrm },
    --         { " ( " .. os.date("%c", os.time()) .. " )\n", Colors.gray } })
    -- else
    --     RenderText({ { "< " .. message.author.name .. " > ", Colors.bright_cyan },
    --         { "Joint File",                                Colors.bright_yellow },
    --         { " ( " .. os.date("%c", os.time()) .. " )\n", Colors.gray } })
    -- end
    -- if message.content:find("daddy") then
    --     for _ = 1, 5 do
    --         GiveFruit("534806202698432514", NewFruit("grape"))
    --     end
    -- end
end)

client:run("Bot " .. token)
