label = "ENGINE LEFT"
maxRPS = 50

-- Settings
clutchEngageRate = 0.01    -- How fast the clutch engages per tick
clutchDisengageRate = 0.05 -- How fast it disengages when RPS is low
safeIdleRPS = 3            -- Minimum RPS before disengaging


-- Don't Edit Below This Line
clutch = 0
throttle = 0
rps = 0
letterWidth = 5

function onTick()
    throttle = input.getNumber(1)
    rps = input.getNumber(2)

    if rps > safeIdleRPS and throttle > 0.05 then
        clutch = math.min(1, clutch + clutchEngageRate)
    else
        clutch = math.max(0, clutch - clutchDisengageRate)
    end

    output.setNumber(1, throttle)
    output.setNumber(2, clutch)
end

function drawBar(x, y, width, height, value, colorR, colorG, colorB)
    local fillHeight = value * height
    screen.setColor(colorR, colorG, colorB)
    screen.drawRectF(x, y + height - fillHeight, width, fillHeight)
    screen.setColor(255, 255, 255)
    screen.drawRect(x, y, width, height)
end

function onDraw()
	
    local x1 = (96 - (string.len(label) * letterWidth)) / 2
    screen.setColor(255,255,255)
    screen.drawText(x1, 5, label)
	
    local displayWidth = 96
    local displayHeight = 60
    local barWidth = 27
    local gap = 6

    local rpsNormalized = math.min(1, rps / maxRPS)

    local startX = 2
    drawBar(startX, 20, barWidth, displayHeight, throttle, 0, 255, 0)
    drawBar(startX + (barWidth + gap), 20, barWidth, displayHeight, rpsNormalized, 0, 0, 255)
    drawBar(startX + 2 * (barWidth + gap), 20, barWidth, displayHeight, clutch, 255, 0, 0)
    
    screen.setColor(255,255,255)
    screen.drawText(0, 82, " THR    RPS   CLTCH")
    
    screen.setColor(0,255,0)
    screen.drawText(5, 90, string.format("%03d", math.floor(throttle * 100)))
    
    screen.setColor(0,0,255)
    screen.drawText(40, 90, string.format("%03d", math.floor(rps)))
    
    screen.setColor(255,0,0)
    screen.drawText(77, 90, string.format("%03d", math.floor(clutch * 100)))
end

