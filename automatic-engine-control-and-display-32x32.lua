label = "ENGINE LEFT"

-- Settings
clutchEngageRate = 0.005 	-- How fast the clutch engages per tick
clutchDisengageRate = 0.05	-- How fast it disengages when RPS is low
safeIdleRPS 	= 5         -- Minimum RPS before disengaging
maxRPS			= 50		-- Max engine RPS
overheatProt	= true		-- Reduce engine throttle if temp exceeds 90 degrees

-- The default screen is a 2x2, but you can this below:
screenAspect = "3x3"		-- Available are "3x3", "5x5", "6x6"


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
        throttleOut = math.max(0.1, throttleOut - clutchDisengageRate)
	else
		throttleOut = math.max(0.1, throttle)
	end

    if rps > safeIdleRPS and throttleOut > 0.1 then
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
	
	local labelX = 0
	local barStartY = 0
	local barLabelStartX = 0
	local barLabelStartY = 0
    local displayWidth = 64 
    local displayHeight = 30 
    local barWidth = 13
    local gap = 3
	
	if(screenAspect == "3x3") then
		labelX = ((96) - (string.len(label) * letterWidth)) / 2
		barStartY = 15
		barLabelStartX = 55
		barLabelStartY = 82
		displayWidth = 64
	    displayHeight = 64
	    barWidth = 20
	    gap = 4
	elseif(screenAspect == "5x5") then
		labelX = ((160) - (string.len(label) * letterWidth)) / 2
		barStartY = 15
		barLabelStartX = 55
		barLabelStartY = 145
		displayWidth = 160
	    displayHeight = 125
	    barWidth = 32
	    gap = 9
	elseif(screenAspect == "6x6") then
		labelX = ((192) - (string.len(label) * letterWidth)) / 2
		barStartY = 15
		barLabelStartX = 55
		barLabelStartY = 175
		displayWidth = 160
	    displayHeight = 155
	    barWidth = 40
	    gap = 9
	end
	
    screen.setColor(255,255,255)
    screen.drawText(labelX, 5, label)
	

    local rpsNormalized = math.min(1, rps / maxRPS)
    local tempNormalized = math.min(1, temp / 140)

    local startX = 2
    
    drawBar(startX, barStartY, barWidth, displayHeight, throttleOut, 0, 255, 0)
    drawBar(startX + (barWidth + gap), barStartY, barWidth, displayHeight, rpsNormalized, 0, 0, 255)
    drawBar(startX + 2 * (barWidth + gap), barStartY, barWidth, displayHeight, clutch, 255, 255, 0)
    
    if(temp > 100) then
    	drawBar(startX + 3 * (barWidth + gap), barStartY, barWidth, displayHeight, tempNormalized, 255, 0, 0)
	elseif(temp > 95) then
    	drawBar(startX + 3 * (barWidth + gap), barStartY, barWidth, displayHeight, tempNormalized, 255, 50, 0)
	elseif(temp > 90) then
    	drawBar(startX + 3 * (barWidth + gap), barStartY, barWidth, displayHeight, tempNormalized, 255, 255, 0)
	else
    	drawBar(startX + 3 * (barWidth + gap), barStartY, barWidth, displayHeight, tempNormalized, 50, 255, 0)
	end
    
	if(screenAspect == "3x3") then
	    screen.setColor(255,255,255)
	    screen.drawText(4, barLabelStartY, "THR")
	    screen.drawText(28, barLabelStartY, "RPS")
	    screen.drawText(48, barLabelStartY, "CLTCH")
	    screen.drawText(77, barLabelStartY, "TMP")
	    
	    screen.setColor(0,255,0)
	    screen.drawText(5, barLabelStartY + 8, string.format("%03d", math.floor(throttleOut * 100)))
	    
	    screen.setColor(0,0,255)
	    screen.drawText(28, barLabelStartY + 8, string.format("%03d", math.floor(rps)))
	    
	    screen.setColor(255,255,0)
	    screen.drawText(53, barLabelStartY + 8, string.format("%03d", math.floor(clutch * 100)))
	    
	    screen.setColor(255,0,0)
	    screen.drawText(77, barLabelStartY + 8, string.format("%03d", math.floor(temp)))
	    
    elseif(screenAspect == "5x5") then
	    screen.setColor(255,255,255)
	    screen.drawText(9, barLabelStartY, "THR")
	    screen.drawText(51, barLabelStartY, "RPS")
	    screen.drawText(88, barLabelStartY, "CLTCH")
	    screen.drawText(135, barLabelStartY, "TMP")
	    
	    screen.setColor(0,255,0)
	    screen.drawText(9, barLabelStartY + 8, string.format("%03d", math.floor(throttleOut * 100)))
	    
	    screen.setColor(0,0,255)
	    screen.drawText(51, barLabelStartY + 8, string.format("%03d", math.floor(rps)))
	    
	    screen.setColor(255,255,0)
	    screen.drawText(94, barLabelStartY + 8, string.format("%03d", math.floor(clutch * 100)))
	    
	    screen.setColor(255,0,0)
	    screen.drawText(135, barLabelStartY + 8, string.format("%03d", math.floor(temp)))
   
    elseif(screenAspect == "6x6") then
	    screen.setColor(255,255,255)
	    screen.drawText(12, barLabelStartY, "THR")
	    screen.drawText(62, barLabelStartY, "RPS")
	    screen.drawText(106, barLabelStartY, "CLTCH")
	    screen.drawText(162, barLabelStartY, "TMP")
	    
	    screen.setColor(0,255,0)
	    screen.drawText(12, barLabelStartY + 8, string.format("%03d", math.floor(throttleOut * 100)))
	    
	    screen.setColor(0,0,255)
	    screen.drawText(62, barLabelStartY + 8, string.format("%03d", math.floor(rps)))
	    
	    screen.setColor(255,255,0)
	    screen.drawText(112, barLabelStartY + 8, string.format("%03d", math.floor(clutch * 100)))
	    
	    screen.setColor(255,0,0)
	    screen.drawText(162, barLabelStartY + 8, string.format("%03d", math.floor(temp)))
    end
end
