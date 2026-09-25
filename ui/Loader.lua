-- UilibAKiralite / Loader.lua
-- Modular Loader for AkiraLite

shared = shared or _G

local function loadModule(relPath)
    if isfile and isfile(relPath) and readfile then
        local content = readfile(relPath)
        local func, err = loadstring(content, relPath)
        if func then
            return func()
        else
            warn("[Loader] Error compiling " .. relPath .. ": " .. tostring(err))
        end
    end
    if loadfile then
        local ok, res = pcall(function()
            local f = loadfile(relPath)
            if f then return f() end
        end)
        if ok and res then return res end
    end
    error("[Loader] Unable to load module: " .. tostring(relPath))
end

-- 1. Ensure folders exist
if isfolder then
    for _, d in ipairs({ "AkiraLite", "AkiraLite/Config", "AkiraLite/Library", "AkiraLite/Fonts", "UilibAKiralite" }) do
        if not isfolder(d) and makefolder then
            makefolder(d)
        end
    end
end

-- 2. Clean up previous instance if running
if shared.AkiraLite and type(shared.AkiraLite.Uninject) == "function" then
    pcall(function() shared.AkiraLite:Uninject() end)
    task.wait(0.1)
end

-- 3. Load Entity and Prediction modules
local entModule = nil
pcall(function()
    entModule = loadModule("UilibAKiralite/Entity.lua")
end)

local predModule = nil
pcall(function()
    predModule = loadModule("UilibAKiralite/Prediction.lua")
end)

shared.AkiraLiteFile = {
    loadfile = function(path)
        if (path == "AkiraLite/Library/Entity.lua" or path:find("Entity")) and entModule then
            return entModule
        elseif (path == "AkiraLite/Library/Prediction.lua" or path:find("Prediction")) and predModule then
            return predModule
        end
        return loadModule(path)
    end,
    downloadfile = function(path)
        return path
    end
}

-- 4. Load UI Library
print("[UilibAKiralite] Loading Library.lua...")
local libCreator = loadModule("UilibAKiralite/Library.lua")
local ui = (type(libCreator) == "function" and libCreator()) or (type(libCreator) == "table" and libCreator.Init and libCreator.Init()) or libCreator
shared.AkiraLite = ui

-- 5. Load Universal features
pcall(function()
    print("[UilibAKiralite] Loading Universal features...")
    loadModule("UilibAKiralite/Universal.lua")
end)

-- 6. Autoload
task.spawn(function()
    task.wait(0.2)
    pcall(function()
        if shared.AkiraLite and shared.AkiraLite.Autoload then
            shared.AkiraLite:Autoload()
        end
    end)
end)

print("[UilibAKiralite] Successfully loaded AkiraLite!")
return shared.AkiraLite
