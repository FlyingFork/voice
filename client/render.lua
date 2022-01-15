local fMinDistance = 5
local fMaxDistance = 25
local mathexp = math.exp
local streamedPlayers = {}
local fDistDiff = fMinDistance - fMaxDistance

local sx, sy = guiGetScreenSize()
local nx, ny = sx/1920, sy/1080

local width = 108 * nx
local height = 180 * ny
local xOffset = 75 * nx
local yOffset = 50 * ny
local halfWidth = width / 2
local halfHeight = height / 2
local icon = dxCreateTexture("assets/icon.png", "dxt5", true, "clamp")

function preRender()
    local x, y, z, lx, ly, lz = getCameraMatrix()
    for player, talking in pairs(streamedPlayers) do
        if player then
            local x1, y1, z1 = getElementPosition(player)
            local fDistance = getDistanceBetweenPoints3D(x, y, z, x1, y1, z1)

            local fVolume
            if (fDistance <= fMinDistance) then
                fVolume = 100
            elseif (fDistance >= fMaxDistance) then
                fVolume = 0.0
            else
                fVolume = mathexp(-(fDistance - fMinDistance) * (5.0 / fDistDiff)) * 100
            end

            local lineOfSightClear = isLineOfSightClear(x, y, z, x1, y1, z1, true, true, false, true, false, true, true, localPlayer)
            if lineOfSightClear then
                setSoundVolume(player, fVolume)
                setSoundEffectEnabled(player, "compressor", false)
				
            else
                setSoundVolume(player, fVolume * 2)
                setSoundEffectEnabled(player, "compressor", true)
            end

            if talking and lineOfSightClear then
                local boneX, boneY, boneZ = getPedBonePosition(player, 8)
                local screenX, screenY = getScreenFromWorldPosition(boneX, boneY, boneZ)
                if screenX and screenY and fDistance < fMaxDistance then
                    fDistance = 1/fDistance
                    screenX, screenY = screenX + xOffset, screenY - yOffset
                    dxDrawImage(screenX - halfWidth * fDistance, screenY - halfHeight * fDistance, width * fDistance, height * fDistance, icon, 0, 0, 0, -1, false)
                end
            end
        end
    end
end
addEventHandler("onClientPreRender", root, preRender)

-- EVENTS

function resourceStart()
    for _, player in ipairs(getElementsByType("player", root, true)) do
        if not streamedPlayers[player] and player ~= localPlayer then
            streamedPlayers[player] = false
        end
    end

    triggerServerEvent("voice:setPlayerBroadcast", resourceRoot, localPlayer, streamedPlayers)
end
addEventHandler("onClientResourceStart", resourceRoot, resourceStart, false)

function streamIn()
    if getElementType(source) == "player" then
        if not streamedPlayers[source] then
            streamedPlayers[source] = false
            triggerServerEvent("voice:addToPlayerBroadcast", resourceRoot, localPlayer, source)
        end
    end
end
addEventHandler("onClientElementStreamIn", root, streamIn)

function playerJoin()
    if getElementType(source) == "player" then
        if not streamedPlayers[source] then
            streamedPlayers[source] = false
            triggerServerEvent("voice:addToPlayerBroadcast", resourceRoot, localPlayer, source)
        end
    end
end
addEventHandler("onClientPlayerJoin", root, playerJoin)

function streamOut()
    if getElementType(source) == "player" then
        if streamedPlayers[source] then
            streamedPlayers[source] = nil
            setSoundVolume(source, 0)

            triggerServerEvent("voice:removePlayerBroadcast", resourceRoot, localPlayer, source)
        end
    end
end
addEventHandler("onClientElementStreamOut", root, streamOut)

function playerQuit()
    if getElementType(source) == "player" then
        if streamedPlayers[source] then
            streamedPlayers[source] = nil
            setSoundVolume(source, 0)

            triggerServerEvent("voice:removePlayerBroadcast", resourceRoot, localPlayer, source)
        end
    end
end
addEventHandler("onClientPlayerQuit", root, playerQuit)

function resourceStop()
    triggerServerEvent("voice:removePlayerBroadcasts", resourceRoot, localPlayer, streamedPlayers)
    streamedPlayers = {}
end
addEventHandler("onClientResourceStop", resourceRoot, resourceStop, false)

function voiceStart()
    streamedPlayers[source] = true
end
addEventHandler("onClientPlayerVoiceStart", root, voiceStart)

function voiceStop()
    streamedPlayers[source] = false
end
addEventHandler("onClientPlayerVoiceStop", root, voiceStop)