--[[
    Shadowvelleity Loader
    by shadow
    Loads main.luau from GitHub with cache fallback
--]]

local Loadstring = loadstring or (getgenv and getgenv().loadstring) or (getfenv and getfenv().loadstring)
local HttpGet = game.HttpGet

local REPO = "https://raw.githubusercontent.com/olplay/ShadowvelleityScript/main/"
local MAIN_FILE = "main.luau"
local CACHE_FILE = "Shadowvelleity_cache.luau"

local function fetchRemote()
    if not HttpGet then return nil end
    local ok, code = pcall(function()
        return HttpGet(game, REPO .. MAIN_FILE)
    end)
    if ok and type(code) == "string" and #code > 100 then
        if writefile then
            pcall(function() writefile(CACHE_FILE, code) end)
        end
        return code
    end
    return nil
end

local function loadCache()
    if not (isfile and readfile) then return nil end
    local ok, code = pcall(function()
        if isfile(CACHE_FILE) then return readfile(CACHE_FILE) end
    end)
    if ok and type(code) == "string" and #code > 100 then
        return code
    end
    return nil
end

local code = fetchRemote()
if not code then
    code = loadCache()
end

if not code then
    warn("[Shadowvelleity] Could not load script - no internet and no cache")
    return
end

if not Loadstring then
    warn("[Shadowvelleity] loadstring not available in this executor")
    return
end

local fn, err = Loadstring(code)
if not fn then
    warn("[Shadowvelleity] Compile error: " .. tostring(err))
    return
end

fn()
