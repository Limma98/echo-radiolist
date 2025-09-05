-- Move mode state
local isMovingRadioList = false
local radioListPosition = { left = 1.0, top = 15.0 } -- Default position in percentage
local moveStep = 1.0 -- Movement step in percentage

-- Load saved position on script start
Citizen.CreateThread(function()
    local savedLeft = GetResourceKvpFloat("echo-radiolist_left")
    local savedTop = GetResourceKvpFloat("echo-radiolist_top")
    if savedLeft and savedTop then
        radioListPosition.left = savedLeft
        radioListPosition.top = savedTop
        UpdateRadioListPosition()
    end
end)

-- Apply saved position when joining a radio channel
RegisterNetEvent('echo-radiolist:Client:SyncRadioChannelPlayers')
AddEventHandler('echo-radiolist:Client:SyncRadioChannelPlayers', function(src, RadioChannelToJoin, PlayersInRadioChannel)
    if RadioChannelToJoin > 0 then
        UpdateRadioListPosition()
    end
end)

-- Register command to toggle move mode
RegisterCommand("moveradiolist", function()
    if not isMovingRadioList then
        isMovingRadioList = true
        SendNUIMessage({ changeVisibility = true, visible = true }) -- Ensure UI is visible
        ShowNotification("~g~Move mode enabled! Use arrow keys to move, Enter to confirm.")
        StartMoveLoop()
    end
end, false)

-- Add command suggestion
TriggerEvent("chat:addSuggestion", "/moveradiolist", "Move the radio list UI using arrow keys (Enter to confirm)")

-- Notification function
function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end

-- Movement loop
function StartMoveLoop()
    Citizen.CreateThread(function()
        while isMovingRadioList do
            Citizen.Wait(0)
            -- Arrow key inputs
            if IsControlJustPressed(0, 172) then -- Up arrow (keycode 172)
                radioListPosition.top = math.max(0, radioListPosition.top - moveStep)
                UpdateRadioListPosition()
            elseif IsControlJustPressed(0, 173) then -- Down arrow (keycode 173)
                radioListPosition.top = math.min(100, radioListPosition.top + moveStep)
                UpdateRadioListPosition()
            elseif IsControlJustPressed(0, 174) then -- Left arrow (keycode 174)
                radioListPosition.left = math.max(0, radioListPosition.left - moveStep)
                UpdateRadioListPosition()
            elseif IsControlJustPressed(0, 175) then -- Right arrow (keycode 175)
                radioListPosition.left = math.min(100, radioListPosition.left + moveStep)
                UpdateRadioListPosition()
            elseif IsControlJustPressed(0, 191) then -- Enter (keycode 191)
                isMovingRadioList = false
                -- Save position
                SetResourceKvpFloat("echo-radiolist_left", radioListPosition.left)
                SetResourceKvpFloat("echo-radiolist_top", radioListPosition.top)
                ShowNotification("~g~Radio list position saved!")
            end
        end
    end)
end

-- Update UI position
function UpdateRadioListPosition()
    SendNUIMessage({
        updatePosition = true,
        left = radioListPosition.left,
        top = radioListPosition.top
    })
end
