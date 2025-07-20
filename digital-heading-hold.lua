targetHeading = 0
currentHeading = 0
currentSpeed = 0
currentX = 0
currentY = 0
manualRudder = 0
outputRudder = 0
isEngaged = false

headingInput = {"_", "_", "_"}
headingInputPosition = 1
isEditing = false
wasTouched = false
tick = 0

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
    screen.drawText(2, 2, "HEADING: " .. sf("%03d ", mf(currentHeading)))
    screen.drawText(2, 10, "TARGET:  " .. sf("%03d ", mf(targetHeading)))
    screen.drawText(105, 2, "SPD:  " .. sf("%03d knt", mf(currentSpeed * 1.94385)))
    screen.drawText(110, 12, "GPX:  " .. sf("%07d ", mf(currentX)))
    screen.drawText(115, 22, "GPY:  " .. sf("%07d ", mf(currentY)))

    -- Simple keypad box
    if isEditing then
    	
    	if(isHeadingInputValid() == -1) then
        	sc(255, 0, 0)
        	screen.drawText(5, 37, "ERR: INVALID")
        elseif(isHeadingInputValid() == -2) then
        	sc(255, 0, 0)
        	screen.drawText(5, 37, "ERR: MAX")
    	elseif(isHeadingInputValid() == 1) then
        	sc(0, 255, 0)
        	screen.drawText(5, 37, "OKA: ACCEPT")
    	end
    	
		dr(5, 20, 60, 15)
        screen.drawText(10, 25, "Set: " .. sf("%s %s %s", headingInput[1], headingInput[2], headingInput[3]))
        if(headingInputPosition == 1) then
        	flashText(10, 25,"     -")
    	end
        if(headingInputPosition == 2) then
        	flashText(10, 25,"       -")
    	end
        if(headingInputPosition == 3) then
        	flashText(10, 25,"         -")
    	end
    else
        sc(255, 255, 255)
		dr(1, 20, 70, 15)	
		local b0Pressed = false
		if(getTouch(1,20,70,35)) then
			isEditing = true
		end
        screen.drawText(11, 25, "Tap to Set")
    end
    
    drawKeypad(isEditing)
    
    -- Engage / Disengage
    if(isEngaged) then
    	sc(255,0,0)
		drawRectButton(70, 1, 20, 15, "DIS", 3, 5)
	
		if(getTouch(70, 1, 70 + 20, 1 + 15)) then
			isEngaged = false
		end
	else
    	sc(0,255,0)
		drawRectButton(70, 1, 20, 15, "ENG", 3, 5)
	
		if(getTouch(70, 1, 70 + 20, 1 + 15)) then
			isEngaged = true
		end
    end

	if(not isEditing) then drawRudderBar() end
    
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
	screen.drawText(x + labelOffset, y + labelOffset, label)
end

function drawRectButton(x, y, sizeX, sizeY, label, labelOffsetX, labelOffsetY)
	labelOffsetX = labelOffsetX or 2
	labelOffsetY = labelOffsetY or labelOffsetX
	dr(x, y, sizeX, sizeY)	
	screen.drawText(x + labelOffsetX, y + labelOffsetY, label)
end

function flashText(x, y, label, speed)
	speed = speed or 10
	if (tick // speed) % 2 == 0 then	
		screen.drawText(x, y, label)
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
	local barX = 100
	local barY = 40
	local barWidth = 70
	local barHeight = 15
	
	-- Background
	sc(50, 50, 50)
	dr(barX, barY, barWidth, barHeight)
	screen.drawText(barX, barY + barHeight + 3, "   RUDDER")
	
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
function mf(v)
	return math.floor(v)
end
function sf(f, ...)
	return string.format(f, ...)
end
