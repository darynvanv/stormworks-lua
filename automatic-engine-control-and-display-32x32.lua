label = "ENGINE LEFT"

-- Settings
clutchEngageRate = 0.01 	-- How fast the clutch engages per tick
clutchDisengageRate = 0.05	-- How fast it disengages when RPS is low
safeIdleRPS = 3         	-- Minimum RPS before disengaging
maxRPS = 50					-- Max engine RPS
overheatProt = true			-- Reduce engine throttle if temp exceeds 90 degrees


-- Don't Edit Below This Line
clutch = 0
throttle = 0
throttleOut = 0
rps = 0
temp = 0
letterWidth = 5

function onTick()
    throttle = input.getNumber(1)
    rps = input.getNumber(2)
    temp = input.getNumber(3)
    
    if(overheatProt and temp > 90) then
        throttleOut = math.max(0.02, throttleOut - clutchDisengageRate)
	else
		throttleOut = throttle
	end

    if rps > safeIdleRPS and throttleOut > 0.05 then
        clutch = math.min(1, clutch + clutchEngageRate)
    else
        clutch = math.max(0, clutch - clutchDisengageRate)
    end

    output.setNumber(1, throttleOut)
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
    local barWidth = 20
    local gap = 4

    local rpsNormalized = math.min(1, rps / maxRPS)
    local tempNormalized = math.min(1, temp / 120)

    local startX = 2
    drawBar(startX, 20, barWidth, displayHeight, throttleOut, 0, 255, 0)
    drawBar(startX + (barWidth + gap), 20, barWidth, displayHeight, rpsNormalized, 0, 0, 255)
    drawBar(startX + 2 * (barWidth + gap), 20, barWidth, displayHeight, clutch, 255, 255, 0)
    
    if(temp > 90) then
    	drawBar(startX + 3 * (barWidth + gap), 20, barWidth, displayHeight, tempNormalized, 255, 0, 0)
	elseif(temp > 80) then
    	drawBar(startX + 3 * (barWidth + gap), 20, barWidth, displayHeight, tempNormalized, 255, 50, 0)
	elseif(temp > 70) then
    	drawBar(startX + 3 * (barWidth + gap), 20, barWidth, displayHeight, tempNormalized, 255, 255, 0)
	else
    	drawBar(startX + 3 * (barWidth + gap), 20, barWidth, displayHeight, tempNormalized, 50, 255, 0)
	end
    
    screen.setColor(255,255,255)
    screen.drawText(4, 82, "THR")
    screen.drawText(28, 82, "RPS")
    screen.drawText(48, 82, "CLTCH")
    screen.drawText(77, 82, "TMP")
    
    screen.setColor(0,255,0)
    screen.drawText(5, 90, string.format("%03d", math.floor(throttleOut * 100)))
    
    screen.setColor(0,0,255)
    screen.drawText(28, 90, string.format("%03d", math.floor(rps)))
    
    screen.setColor(255,255,0)
    screen.drawText(53, 90, string.format("%03d", math.floor(clutch)))
    
    screen.setColor(255,0,0)
    screen.drawText(77, 90, string.format("%03d", math.floor(temp)))
end

