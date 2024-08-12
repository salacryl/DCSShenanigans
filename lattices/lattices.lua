autoLat = {}
autoLat.numPoints = 6  -- Number of points to distribute
autoLat.points = {}    -- Table to store points on the curve
autoLat.offset = 20000    -- Offset for distributing points on the curve

function autoLat.calculatePoints(startX, startY, endX, endY, startTangentX, startTangentY, endTangentX, endTangentY)
    local calculatedPoints = {}

    for i = 1, autoLat.numPoints do
        local t = (i - 1) / (autoLat.numPoints - 1)  -- Parameter for even distribution
        local mt = 1 - t
        local mt2 = mt * mt
        local t2 = t * t

        local x = mt2 * mt * startX + 3 * mt2 * t * (startX + startTangentX) + 3 * mt * t2 * (endX - endTangentX) + t2 * t * endX
        local y = mt2 * mt * startY + 3 * mt2 * t * (startY + startTangentY) + 3 * mt * t2 * (endY - endTangentY) + t2 * t * endY

        table.insert(calculatedPoints, {x = x, y = y})
    end

    return calculatedPoints
end


function autoLat.drawLattices(coalition, startX, startY, endX, endY, startTangentX, startTangentY, endTangentX, endTangentY)
    local points = autoLat.calculatePoints(startX, startY, endX, endY, startTangentX, startTangentY, endTangentX, endTangentY)
    local color
    if coalition == 1 then
        color = {1, 0, 0, 1}
    end
    if coalition == 2 then
        color = {0, 0, 2, 1}
    end
    for i = 1, #points - 1 do
        local startVec = {x=points[i].x, y=0, z=points[i].y}
        local endVec = {x=points[i + 1].x, y=0, z=points[i + 1].y}
        ID=math.random(10000, 65000)
        trigger.action.lineToAll( -1, ID, startVec, endVec, color, 1 )
    end
end




math.random(); math.random(); math.random()