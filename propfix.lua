-- Utwórz pusty obiekt przechowujący ostatni czas użycia komendy /propfix
local lastPropfixTime = {}

-- Zarejestruj komendę /propfix
RegisterCommand('propfix', function(source, args, rawCommand)
    local playerId = tonumber(source)

    -- Sprawdź, czy minęło co najmniej 10 minut od ostatniego użycia komendy /propfix przez gracza
    if lastPropfixTime[playerId] == nil or os.time() - lastPropfixTime[playerId] >= 600 then
        -- Zapisz czas użycia komendy /propfix przez gracza
        lastPropfixTime[playerId] = os.time()

        -- Pobierz aktualną pozycję gracza
        local playerPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)

        local defaultPlayer = {
            ['position'] = {x = playerCoords.x, y = playerCoords.y, z = playerCoords.z},
            ['items'] = {}
        }

        MySQL.Async.execute('UPDATE users SET position = @position, inventory = @inventory WHERE id = @id', {
            ['@position'] = json.encode(defaultPlayer.position),
            ['@inventory'] = json.encode(defaultPlayer.items),
            ['@id'] = playerId
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerEvent('esx:playerLoaded', playerId, defaultPlayer, true)
                TriggerClientEvent('chat:addMessage', playerId, {args = {'^1SYSTEM', '^0Zresetowałeś postać.'}})
            else
                TriggerClientEvent('chat:addMessage', playerId, {args = {'^1SYSTEM', '^0Wystąpił błąd. Spróbuj ponownie później. Jeśli nie działa, zgłoś, to adminstracji.'}})
            end
        end)
    else
        -- Wypisz informację o braku uprawnień do użycia komendy /propfix
        local remainingTime = 600 - (os.time() - lastPropfixTime[playerId])
        TriggerClientEvent('chat:addMessage', playerId, {args = {'^1SYSTEM', '^0Nie możesz użyć jeszcze przez ' .. remainingTime .. ' sekund.'}})
    end
end, false)
