targetHeading = 0
currentHeading = 0
currentSpeed = 0
currentX = 0
currentY = 0
manualRudder = 0
outputRudder = 0
isEngaged = false
osbMenu = 0
unit = 0

headingInput = {"_", "_", "_"}
headingInputPosition = 1
isEditing = false
wasTouched = false
tick = 0
osbT = ""

function compassToHeading(compass)
	return ( ( -compass * 360 + 360 ) % 360 )
end

function getHeadingDifference(current, target)
    local diff = (target - current + 180) % 360 - 180
    return diff
end

function onTick()
    tick = (tick or 0) + 1
    
	isPressed1 = input.getBool(1)
	isPressed2 = input.getBool(2)
	
	screenWidth = input.getNumber(1)
	screenHeight = input.getNumber(2)
	
	input1X = input.getNumber(3)
	input1Y = input.getNumber(4)
	input2X = input.getNumber(5)
	input2Y = input.getNumber(6)
    
    -- Inputs
    manualRudder = input.getNumber(7)
    currentHeading = compassToHeading(input.getNumber(8))
    currentHeading = compassToHeading(input.getNumber(9))
    
    currentX = compassToHeading(input.getNumber(10))
    currentY = compassToHeading(input.getNumber(11))
    
    differenceToHeading = getHeadingDifference(currentHeading, targetHeading)
    
    if isEditing then
        outputRudder = manualRudder
    elseif(isEngaged) then
        local rudderCommand = math.min(1, math.max(-1, differenceToHeading / 45))
        outputRudder = rudderCommand + manualRudder
        outputRudder = math.max(-1, math.min(1, outputRudder))
    else
    	outputRudder = manualRudder
    end

    output.setNumber(1, outputRudder)
end

function onDraw()
    sc(255, 255, 255)
    dt(2, 2, "HEADING: " .. sf("%03d ", mf(currentHeading)))
    dt(2, 10, "TARGET:  " .. sf("%03d ", mf(targetHeading)))
    
    if(unit == 0) then dt(120, 2, "SPD:  " .. sf("%03d knt", mf(currentSpeed * 1.94385))) end
    if(unit == 1) then dt(120, 2, "SPD:  " .. sf("%03d kph", mf(currentSpeed * 3.6))) end
    if(unit == 2) then dt(120, 2, "SPD:  " .. sf("%03d mph", mf(currentSpeed * 2.23694))) end
    if(unit == 3) then dt(120, 2, "SPD:  " .. sf("%03d m/s", mf(currentSpeed))) end
    
    
    dt(120, 12, "GPX:  " .. sf("%07d ", mf(currentX)))
    dt(120, 22, "GPY:  " .. sf("%07d ", mf(currentY)))

    -- Simple keypad box
    if isEditing then
    	
    	if(isHeadingInputValid() == -1) then
        	sc(255, 0, 0)
        	dt(5, 37, "ERR: INVALID")
        elseif(isHeadingInputValid() == -2) then
        	sc(255, 0, 0)
        	dt(5, 37, "ERR: MAX")
    	elseif(isHeadingInputValid() == 1) then
        	sc(0, 255, 0)
        	dt(5, 37, "OKA: ACCEPT")
    	end
    	
		dr(5, 20, 60, 15)
        dt(10, 25, "Set: " .. sf("%s %s %s", headingInput[1], headingInput[2], headingInput[3]))
        if(headingInputPosition == 1) then
        	flashText(10, 25,"     -")
    	end
        if(headingInputPosition == 2) then
        	flashText(10, 25,"       -")
    	end
        if(headingInputPosition == 3) then
        	flashText(10, 25,"         -")
    	end
    end
    
    drawKeypad(isEditing)
    
    -- Engage / Disengage
    if(isEngaged) then
    	sc(0,255,0)
		drF(75, 1, 25, 15)
    	sc(0,0,0)
		dt(80, 6, "ENG")
    	sc(255,0,0)
		dr(75, 16, 25, 15)
		dt(80, 21, "DIS")
	else
    	sc(255,255,255)
		dr(75, 1, 25, 15)
		dt(80, 6, "ENG")
    	sc(255,0,0)
		drF(75, 16, 25, 15)
    	sc(0,0,0)
		dt(80, 21, "DIS")
    end

	if(not isEditing) then drawRudderBar() end
    
    
    if(osbMenu == 0) then
	    if(osb(0, "HEADING", {70,70,70})) then 
	    	osbMenu = 1 
	    	osbT = "-- HEADING --"
    	end
	    if(osb(1, "SETTING", {70,70,70})) then 
	    	osbMenu = 2 
	    	osbT = "-- SETTING --"
    	end
    wasTouched = isPressed1
    end
    
    if(osbMenu == 1) then
    	local setColor = {70,70,70}
    	if(isEditing) then setColor = {0,180,0} end
	    if(osb(0, " SET", setColor)) then 
	    	osbMenu = 1 
	    	isEditing =  not isEditing
    	end
    	if(not isEngaged) then
		    if(osb(1, "ENGAGE", {70,70,70})) then 
		    	osbMenu = 1 
		    	isEngaged = true
	    		isEditing = false
	    	end
    	else
    		if(osb(1, "DISENGAGE", {255,50,0})) then 
		    	osbMenu = 1 
		    	isEngaged = false
	    		isEditing = false
	    	end
    	end
    	if(osb(3, " BACK", {70,70,70})) then 
    		isEditing = false
    		osbMenu = 0 
    		osbT = ""
		end
    	wasTouched = isPressed1
    end

	if(osbMenu == 2) then
		if(osb(0, " UNIT", {70,70,70})) then 
			unit = unit + 1
			if(unit == 4 ) then unit = 0 end
    	end
    	if(osb(3, " BACK", {70,70,70})) then 
    		osbMenu = 0 
    		osbT = ""
		end
    	wasTouched = isPressed1
	end
    
    sc(255,255,255)
    local osbX = 96 - ((string.len(osbT) * 5)) / 2
    dt(osbX, 140, osbT)
    
    wasTouched = isPressed1
end

function getTouch(x1, y1, x2, y2, color)
	local touched = false
	
    if isPressed1 and not wasTouched and input1X >= x1 and input1X <= x2 and input1Y >= y1 and input1Y <= y2 then
        touched = true
    end
    
    if color then
        sc(table.unpack(color))
        drF(x1, y1, x2 - x1, y2 - y1)
    end

    return touched
end

function drawKeypad(enabled)
	local bs = 19
	local gap = 1
	local labelOffset = 7
	
	if(enabled) then
		sc(255,255,255)
	
	-- 1 - 3
	
	local b1x = 5
	local b1y = 45
	drawButton(b1x, b1y, bs, "1", labelOffset)
	
	if(getTouch(b1x, b1y, b1x + bs, b1y + bs)) then
		setHeadingInput("1")
	end
	
	b1x = b1x + bs + gap
	b1y = 45
	drawButton(b1x, b1y, bs, "2", labelOffset)

	if(getTouch(b1x, b1y, b1x + bs, b1y + bs)) then
		setHeadingInput("2")
	end
	
	b1x = b1x + bs + gap
	b1y = 45
	drawButton(b1x, b1y, bs, "3", labelOffset)
	
	if(getTouch(b1x, b1y, b1x + bs, b1y + bs)) then
		setHeadingInput("3")
	end
	
	-- 4 - 6
	b1x = 5
	b1y = 45 + bs + gap
	drawButton(b1x, b1y, bs, "4", labelOffset)
	
	if(getTouch(b1x, b1y, b1x + bs, b1y + bs)) then
		setHeadingInput("4")
	end
	
	b1x = b1x + bs + gap
	b1y = b1y
	drawButton(b1x, b1y, bs, "5", labelOffset)
	
	if(getTouch(b1x, b1y, b1x + bs, b1y + bs)) then
		setHeadingInput("5")
	end
	
	b1x = b1x + bs + gap
	b1y = b1y
	drawButton(b1x, b1y, bs, "6", labelOffset)
	
	if(getTouch(b1x, b1y, b1x + bs, b1y + bs)) then
		setHeadingInput("6")
	end
	
	-- 7 - 9
	b1x = 5
	b1y = b1y + bs + gap
	drawButton(b1x, b1y, bs, "7", labelOffset)
	
	if(getTouch(b1x, b1y, b1x + bs, b1y + bs)) then
		setHeadingInput("7")
	end
	
	b1x = b1x + bs + gap
	b1y = b1y
	drawButton(b1x, b1y, bs, "8", labelOffset)
	
	if(getTouch(b1x, b1y, b1x + bs, b1y + bs)) then
		setHeadingInput("8")
	end
	
	b1x = b1x + bs + gap
	b1y = b1y
	drawButton(b1x, b1y, bs, "9", labelOffset)
	
	if(getTouch(b1x, b1y, b1x + bs, b1y + bs)) then
		setHeadingInput("9")
	end
	
	-- X 0 and accept
	b1x = 5
	b1y = b1y + bs + gap
	sc(255,0,0)
	drawButton(b1x, b1y, bs, "X", labelOffset)
	
	if(getTouch(b1x, b1y, b1x + bs, b1y + bs)) then
		headingInput = {"_","_","_"}
		headingInputPosition = 1
	end
	
	b1x = b1x + bs + gap
	b1y = b1y
	sc(255,255,255)
	drawButton(b1x, b1y, bs, "0", labelOffset)
	
	if(getTouch(b1x, b1y, b1x + bs, b1y + bs)) then
		setHeadingInput("0")
	end
	
	b1x = b1x + bs + gap
	b1y = b1y
	sc(0,255,0)
	if(isHeadingInputValid() == 1) then
		drawButton(b1x, b1y, bs, "A", labelOffset)
		
		if(getTouch(b1x, b1y, b1x + bs, b1y + bs)) then
			isEditing = false
			targetHeading = tonumber(headingInput[1] .. headingInput[2] .. headingInput[3])
		end
	end
	else
		sc(25,25,25)
	end
end

function drawButton(x, y, size, label, labelOffset)
	labelOffset = labelOffset or 2
	dr(x, y, size, size)	
	dt(x + labelOffset, y + labelOffset, label)
end

function drawRectButton(x, y, sizeX, sizeY, label, labelOffsetX, labelOffsetY)
	labelOffsetX = labelOffsetX or 2
	labelOffsetY = labelOffsetY or labelOffsetX
	dr(x, y, sizeX, sizeY)	
	dt(x + labelOffsetX, y + labelOffsetY, label)
end

function flashText(x, y, label, speed)
	speed = speed or 10
	if (tick // speed) % 2 == 0 then	
		dt(x, y, label)
	end
end

function setHeadingInput(number)
	headingInput[headingInputPosition] = number
	headingInputPosition = headingInputPosition + 1
	if(headingInputPosition == 4) then
		headingInputPosition = 1
	end
end

function isHeadingInputValid()
	local tempHeading = ""
	if(headingInput[1] == "_") or (headingInput[2] == "_") or (headingInput[3] == "_") then return -1 end
	
	tempHeading = headingInput[1] .. headingInput[2] .. headingInput[3]
	tempHeading = tonumber(tempHeading)
	if(tempHeading > 359) then return -2 end
	if(tempHeading < 0) then return -3 end
	
	return 1
end
	
function drawRudderBar() 
		-- Rudder Output Bar
	local barX = 120
	local barY = 50
	local barWidth = 65
	local barHeight = 15
	
	-- Background
	sc(50, 50, 50)
	dr(barX, barY, barWidth, barHeight)
	dt(barX, barY + barHeight + 3, "   RUDDER")
	
	-- Output Rudder Bar (centered)
	local centerX = barX + barWidth / 2
	local rudderBarLength = (outputRudder or 0) * (barWidth / 2)
	
	if outputRudder > 0 then
	    -- Right
	    sc(0, 255, 0)
	    drF(centerX, barY, rudderBarLength, barHeight)
	elseif outputRudder < 0 then
	    -- Left
	    sc(255, 0, 0)
	    drF(centerX + rudderBarLength, barY, -rudderBarLength, barHeight)
	end
	
	-- Center Line
	sc(255, 255, 255)
	screen.drawLine(centerX, barY, centerX, barY + barHeight)
end


function sc(r,g,b)
	screen.setColor(r,g,b)
end
function dr(x,y,w,h)
	screen.drawRect(x,y,w,h)	
end
function drF(x,y,w,h)
	screen.drawRectF(x,y,w,h)
end
function dt(x,y,t)
	screen.drawText(x,y,t)
end
function mf(v)
	return math.floor(v)
end
function sf(f, ...)
	return string.format(f, ...)
end

function osb(pos, label, color)
	local s = 16
	local x = 15 + (s * pos) + (40 * pos)
    local x1 = x - (((string.len(label) * 3)) / 2)
	sc(50,50,50)
	drF(x-1, 160-1, s+2, s+2)
	sc(table.unpack(color))
	drF(x, 160, s, s)
	screen.drawLine(x + (s/2), 178, x + (s/2), 182)
	dt(x1, 185, label)
	return getTouch(x, 160, x+s, 160 +s)
end
