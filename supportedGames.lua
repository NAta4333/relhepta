-- supportedGames.lua
return {
    -- Fallen Survival
    {
        gameName = "[UP] Just a baseplate.",
        placeIDs = {123974602339071},  -- Place ID игры
        executors = {                  -- Поддерживаемые инжекторы
            "Synapse X",
            "Script-Ware",
            "KRNL",
            "Fluxus",
            "Electron",
            "Oxygen U",
            "Trigon"
        },
        customMessage = {              -- Сообщения для конкретных инжекторов
            ["Fluxus"] = "Unstable",   -- Fluxus работает нестабильно
            ["Electron"] = "Experimental" -- Electron работает в экспериментальном режиме
        },
        gitPath = "fallensurvival",    -- Папка с игрой в репозитории
        status = "Undetected"          -- Статус игры (Undetected, Detected, Unstable)
    }
}
