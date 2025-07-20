targetHeading = 0
currentHeading = 0
manualRudder = 0
outputRudder = 0
isEngaged = false

headingInput = {"_", "_", "_"}   -- String input from keypad
headingInputPosition = 1
isEditing = false
wasTouched = false
tick = 0

function compassToHeading(compass)
	return (compass * 360 + 360) % 360
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
    manualRudder = input.getNumber(7)   -- Manual rudder [-1 to 1]
    currentHeading = compassToHeading(input.getNumber(8)) -- Compass heading (0 - 360)
    differenceToHeading = getHeadingDifference(currentHeading, targetHeading)
    
    -- If editing, do nothing with autopilot
    if isEditing then
        outputRudder = manualRudder
    elseif(isEngaged) then
        -- Heading hold logic (proportional controller)
        local rudderCommand = math.min(1, math.max(-1, differenceToHeading / 45))  -- 45 degrees = max rudder
        -- Combine with manual input
        outputRudder = rudderCommand + manualRudder
        outputRudder = math.max(-1, math.min(1, outputRudder))
    else
    	outputRudder = manualRudder
    end

    -- Outputs
    output.setNumber(1, outputRudder)
end

function onDraw()
    screen.setColor(255, 255, 255)
    screen.drawText(2, 2, "Heading: " .. string.format("%03d °", math.floor(currentHeading)))
    screen.drawText(2, 10, "Target:  " .. string.format("%03d °", math.floor(targetHeading)))

    -- Simple keypad box
    if isEditing then
    	
    	if(isHeadingInputValid() == -1) then
        	screen.setColor(255, 0, 0)
        	screen.drawText(5, 37, "ERR: INVALID")
        elseif(isHeadingInputValid() == -2) then
        	screen.setColor(255, 0, 0)
        	screen.drawText(5, 37, "ERR: MAX")
    	elseif(isHeadingInputValid() == 1) then
        	screen.setColor(0, 255, 0)
        	screen.drawText(5, 37, "OKA: ACCEPT")
    	end
    	
		screen.drawRect(5, 20, 60, 15)
        screen.drawText(10, 25, "Set: " .. string.format("%s %s %s", headingInput[1], headingInput[2], headingInput[3]))
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
        screen.setColor(255, 255, 255)
		screen.drawRect(5, 20, 60, 15)	
		local b0Pressed = false
		if(getTouch(5,25,65,35)) then
			isEditing = true
		end
        screen.drawText(10, 25, "Tap to Set")
    end
    
    drawKeypad(isEditing)
    
    -- Engage / Disengage
    if(isEngaged) then
    	screen.setColor(255,0,0)
		drawRectButton(70, 5, 20, 10, "DIS", labelOffset)
	
		if(getTouch(50, 5, 50 + 17, 5 + 17)) then
			setHeadingInput("2")
		end
	else
    	screen.setColor(0,255,0)
		drawButton(70, 5, 17, "ENG", labelOffset)
	
		if(getTouch(50, 5, 50 + 17, 5 + 17)) then
			setHeadingInput("2")
		end
	end
    
    
    wasTouched = isPressed1
    print(wasTouched)
end

function getTouch(x1, y1, x2, y2, color)
	local touched = false
	
    if isPressed1 and not wasTouched and input1X >= x1 and input1X <= x2 and input1Y >= y1 and input1Y <= y2 then
        touched = true
    end
    
    if color then
        screen.setColor(table.unpack(color))
        screen.drawRectF(x1, y1, x2 - x1, y2 - y1)
    end

    return touched
end

function drawKeypad(enabled)
	local bs = 19
	local gap = 1
	local labelOffset = 7
	
	if(enabled) then
		screen.setColor(255,255,255)
	
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
	screen.setColor(255,0,0)
	drawButton(b1x, b1y, bs, "X", labelOffset)
	
	if(getTouch(b1x, b1y, b1x + bs, b1y + bs)) then
		headingInput = {"_","_","_"}
	end
	
	b1x = b1x + bs + gap
	b1y = b1y
	screen.setColor(255,255,255)
	drawButton(b1x, b1y, bs, "0", labelOffset)
	
	if(getTouch(b1x, b1y, b1x + bs, b1y + bs)) then
		setHeadingInput("0")
	end
	
	b1x = b1x + bs + gap
	b1y = b1y
	screen.setColor(0,255,0)
	if(isHeadingInputValid() == 1) then
		drawButton(b1x, b1y, bs, "A", labelOffset)
		
		if(getTouch(b1x, b1y, b1x + bs, b1y + bs)) then
			isEditing = false
			targetHeading = tonumber(headingInput[1] .. headingInput[2] .. headingInput[3])
		end
	end
	else
		screen.setColor(25,25,25)
	end
end

function drawButton(x, y, size, label, labelOffset)
	labelOffset = labelOffset or 2
	screen.drawRect(x, y, size, size)	
	screen.drawText(x + labelOffset, y + labelOffset, label)
end

function drawRectButton(x, y, sizeX, sizeY, label, labelOffsetX, labelOffsetY)
	labelOffsetX = labelOffsetX or 2
	labelOffsetY = labelOffsetY or labelOffsetX
	screen.drawRect(x, y, sizeX, sizeY)	
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
