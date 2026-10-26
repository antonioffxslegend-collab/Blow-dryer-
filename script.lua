-- Secadora de Pelo Original (ID: 11719016) + Voo para Trás + Bolhas de Vidro + Som de 1.5s
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService") -- Adicionado para as bolhas
local player = Players.LocalPlayer

local function createHairDryer()
    local backpack = player:WaitForChild("Backpack")
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    -- Eliminar secadora anterior si existe
    for _, item in pairs(backpack:GetChildren()) do
        if item.Name == "SecadoraDePelo" or item.Name == "Hair Dryer" then
            item:Destroy()
        end
    end
    for _, item in pairs(character:GetChildren()) do
        if item.Name == "SecadoraDePelo" or item.Name == "Hair Dryer" then
            item:Destroy()
        end
    end

    -- Carregar a ferramenta ORIGINAL (ID: 11719016)
    local HAIR_DRYER_ID = 11719016
    local success, tool = pcall(function()
        return game:GetObjects("rbxassetid://" .. HAIR_DRYER_ID)[1]
    end)

    if not success or not tool or not tool:IsA("Tool") then
        warn("❌ Falha ao carregar a Hair Dryer original.")
        return
    end

    tool.Name = "Hair Dryer"
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    tool.ToolTip = "Hair Dryer Original 💨"

    -- Remove scripts internos da ferramenta original
    for _, child in ipairs(tool:GetDescendants()) do
        if child:IsA("Script") or child:IsA("LocalScript") then
            child:Destroy()
        end
    end

    -- Coloca na mochila e equipa na mão
    tool.Parent = backpack
    humanoid:EquipTool(tool)

    -- ===== LÓGICA DE USO =====
    local root = character:WaitForChild("HumanoidRootPart")
    local handle = tool:FindFirstChild("Handle") or root
    local canUse = true
    local cooldown = 1.0
    local clickToken = 0

    tool.Activated:Connect(function()
        if not canUse then return end
        
        local char = player.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        
        if not root or not humanoid or humanoid.Health <= 0 then return end
        
        canUse = false
        clickToken = clickToken + 1
        local myToken = clickToken

        -- 1. LIGAR AS BOLHAS DE VIDRO (Seu código do Blow Dryer)
        local startTime = os.clock()
        local emitTimer = 0
        
        local bubbleConnection
        bubbleConnection = RunService.Heartbeat:Connect(function(dt)
            local elapsed = os.clock() - startTime
            
            -- O loop dura 1.5 segundos (igual ao seu som) ou para se você clicar de novo
            if elapsed > 1.5 or not handle or not handle.Parent or myToken ~= clickToken then
                bubbleConnection:Disconnect()
                return
            end

            emitTimer = emitTimer + dt
            if emitTimer >= 0.04 then
                emitTimer = 0

                for i = 1, 3 do
                    local bubble = Instance.new("Part")
                    bubble.Shape = Enum.PartType.Ball
                    bubble.Material = Enum.Material.Glass
                    
                    if math.random(1, 2) == 1 then
                        bubble.Color = Color3.fromRGB(255, 255, 255)
                    else
                        bubble.Color = Color3.fromRGB(173, 216, 230)
                    end

                    local sizeVal = math.random(9, 17) / 10
                    bubble.Size = Vector3.new(sizeVal, sizeVal, sizeVal)
                    bubble.Transparency = 0.25
                    bubble.Reflectance = 0.25
                    bubble.Anchored = false
                    bubble.CanCollide = false
                    bubble.CanTouch = false
                    bubble.CanQuery = false
                    bubble.CastShadow = false

                    bubble.CFrame = handle.CFrame * CFrame.new(math.random(-1.5, 1.5), math.random(-1.5, 1.5), math.random(-2, 0))
                    bubble.Parent = workspace

                    bubble.AssemblyLinearVelocity = Vector3.new(
                        math.random(-40, 40),
                        math.random(-15, 35),
                        math.random(-40, 40)
                    )

                    task.spawn(function()
                        local duration = 0.85
                        local startTick = os.clock()
                        local origSize = bubble.Size

                        while true do
                            local bElapsed = os.clock() - startTick
                            local alpha = bElapsed / duration
                            if alpha >= 1 or not bubble.Parent then
                                bubble:Destroy()
                                break
                            end
                            bubble.Transparency = 0.25 + (0.75 * alpha)
                            bubble.Size = origSize * (1 - (alpha * 0.3))
                            RunService.Heartbeat:Wait()
                        end
                    end)
                end
            end
        end)

        -- 2. LIMPAR IMPULSO ANTIGO
        local oldBoost = root:FindFirstChild("SecadoraBoost")
        if oldBoost then oldBoost:Destroy() end

        -- 3. Impulso para CIMA e para TRÁS
        local camera = workspace.CurrentCamera
        local backwardDir = -Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "SecadoraBoost"
        bodyVelocity.Velocity = Vector3.new(backwardDir.X * 45, 25, backwardDir.Z * 45)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Parent = root
        Debris:AddItem(bodyVelocity, 0.9)

        -- 4. Som da Secadora (Duração de 1.5 Segundos)
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://106593526813937"
        sound.Volume = 1
        sound.PlaybackSpeed = 1
        sound.Parent = root
        sound:Play()
        
        -- Para o som e o destrói após exatamente 1.5 segundos
        task.delay(1.5, function()
            if sound and sound.Parent then
                sound:Stop()
                sound:Destroy()
            end
        end)

        task.wait(cooldown)
        canUse = true
    end)

    print("✅ Hair Dryer Original equipada com as bolhas de vidro!")
end

-- Criar ao executar
createHairDryer()

-- Recriar ao respawnear
player.CharacterAdded:Connect(function()
    task.wait(1.2)
    createHairDryer()
end)
