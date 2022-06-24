--// Setting start time
local startTime = tick()

--// Variables
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

--// Settings
local Settings = {
    Tween_Speed = 100,
    Pathfinding_Speed = 100,
    Sky_Speed = 100,
    Sky_Height = 500,
}

local Module = {}

function Module:Tween_Speed(newValue)
    Settings.Tween_Speed = newValue
end
function Module:Pathfinding_Speed(newValue)
    Settings.Pathfinding_Speed = newValue
end
function Module:Sky_Speed(newValue)
    Settings.Sky_Speed = newValue
end
function Module:Sky_Height(newValue)
    Settings.Sky_Height = newValue
end
function Module:Tween_Teleport(Destinition_Vector3)

    local anchoredCharacterDescendants = {}

    for i, v in pairs(character:GetChildren()) do
        pcall(function()
            if v.Anchored == false and v.Name == "HumanoidRootPart" then
                table.insert(anchoredCharacterDescendants, v)
            end
        end)
    end

    local humanoid_root_part = character:WaitForChild("HumanoidRootPart")
    local currentPosition = humanoid_root_part.Position

    local ValueChanger = Instance.new("Vector3Value")
    ValueChanger.Value = currentPosition

    ValueChanger.Changed:Connect(function()
        if player:DistanceFromCharacter(ValueChanger.Value) >= .05 then
            character:SetPrimaryPartCFrame(CFrame.new(ValueChanger.Value))
        end
    end)

    for i, v in pairs(anchoredCharacterDescendants) do
        --v.Anchored = true
    end

    --local nograv = Instance.new("BodyVelocity", player.Character.HumanoidRootPart)
    --nograv.MaxForce = Vector3.new(9e+09, 9e+09, 9e+09)
    --nograv.Velocity = Vector3.new(0, 0, 0)
    --nograv.P = 1250
    local ograv = workspace.Gravity
    workspace.Gravity = 0
    local temporaryTween = TweenService:Create(ValueChanger, TweenInfo.new( (Destinition_Vector3 - currentPosition).Magnitude / Settings.Tween_Speed, Enum.EasingStyle.Linear), {Value = Destinition_Vector3})
    temporaryTween:Play()
    temporaryTween.Completed:Wait()

    --nograv:Destroy()
    workspace.Gravity = ograv

    for i, v in pairs(anchoredCharacterDescendants) do
        --v.Anchored = false
    end

end
function Module:Pathfinding_Teleport(Destinition_Vector3)
    local humanoid_root_part = character:WaitForChild("HumanoidRootPart")
    local currentPosition = humanoid_root_part.Position

    local tempPath = PathfindingService:CreatePath()
    tempPath:ComputeAsync(currentPosition, Destinition_Vector3)

    local oldSpeed = Settings.Tween_Speed
    Settings.Tween_Speed = Settings.Pathfinding_Speed

    if tempPath.Status.Name == "Success" then
        for i, v in ipairs(tempPath:GetWaypoints()) do
            Module:Tween_Teleport(v.Position + Vector3.new(0, 3, 0))
        end
        Settings.Tween_Speed = oldSpeed
        return
    else
        Settings.Tween_Speed = oldSpeed
        return false
    end
end
function Module:Sky_Teleport(Destinition_Vector3)

    local humanoid_root_part = character:WaitForChild("HumanoidRootPart")
    local currentPosition = humanoid_root_part.Position

    --humanoid_root_part.Anchored = true

    humanoid_root_part.CFrame = CFrame.new(currentPosition.X, Settings.Sky_Height, currentPosition.Z)

    local oldSpeed = Settings.Tween_Speed
    Settings.Tween_Speed = Settings.Sky_Speed

    Module:Tween_Teleport(Vector3.new(Destinition_Vector3.X, Settings.Sky_Height, currentPosition.Z))

    Settings.Tween_Speed = oldSpeed

    --humanoid_root_part.Anchored = true

    humanoid_root_part.CFrame = CFrame.new(Destinition_Vector3)

    --humanoid_root_part.Anchored = false

end
function Module:Instant_Teleport(Destinition_Vector3)
    
    local humanoid_root_part = character:WaitForChild("HumanoidRootPart")
    
    humanoid_root_part.CFrame = CFrame.new(Destinition_Vector3)

end

Module:Sky_Teleport(Vector3.new(0, 25, 0))

local loadTime = tick() - startTime

return Module, Settings, loadTime
