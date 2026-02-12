local Debug = {}

local debugMode = false

function Debug.Print(message: string)
    if not debugMode then
        return
    end
    print("[DEBUG]: " .. message .. " SRC : " .. debug.info(2, "sl"))
end

return Debug
