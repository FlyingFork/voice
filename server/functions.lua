local broadcasts = {}

function setPlayerBroadcast(thePlayer, players)
    broadcasts[thePlayer] = players
    setPlayerVoiceBroadcastTo(thePlayer, players)
end
addEvent("voice:setPlayerBroadcast", true)
addEventHandler("voice:setPlayerBroadcast", resourceRoot, setPlayerBroadcast)

function addToPlayerBroadcast(thePlayer, player)
    if not broadcasts[thePlayer] then
        broadcasts[thePlayer] = {}
    end

    table.insert(broadcasts[thePlayer], player)
    setPlayerVoiceBroadcastTo(thePlayer, broadcasts[thePlayer])
end
addEvent("voice:addToPlayerBroadcast", true)
addEventHandler("voice:addToPlayerBroadcast", resourceRoot, addToPlayerBroadcast)

function removePlayerBroadcasts(thePlayer, players)
    if not broadcasts[thePlayer] then
        return
    end

    for _, player in ipairs(players) do
        for i, broadcast in pairs(broadcasts[thePlayer]) do
            if player == broadcast then
                broadcasts[thePlayer][i] = nil
            end
        end
    end

    setPlayerVoiceBroadcastTo(thePlayer, broadcasts[thePlayer])
end
addEvent("voice:removePlayerBroadcasts", true)
addEventHandler("voice:removePlayerBroadcasts", resourceRoot, removePlayerBroadcasts)

function removePlayerBroadcast(thePlayer, player)
    if not broadcasts[thePlayer] then
        return
    end

    for i, broadcast in ipairs(broadcasts[thePlayer]) do
        if player == broadcast then
            broadcasts[thePlayer][i] = nil
        end
    end

    setPlayerVoiceBroadcastTo(thePlayer, broadcasts[thePlayer])
end
addEvent("voice:removePlayerBroadcast", true)
addEventHandler("voice:removePlayerBroadcast", resourceRoot, removePlayerBroadcast)