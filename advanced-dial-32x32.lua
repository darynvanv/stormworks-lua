minIn = 0
maxIn = 5000
Label = "Label"

warnThresh1 = 0.8 -- The 0-1 based % before a warning light comes on
warnThresh2 = 0.9 -- The 0-1 based % before a red warning light comes on
warnThresh3 = 0.95 -- The 0-1 based % before a flashing red warning light comes on
showEndThresholds = true -- If true, the red and orange lines show the 80-90 and 90-100% zones

reverseDial = false

-- Don't Edit Below This Line
letterWidth = 5
tick = 0

function onTick()
    valueIn = input.getNumber(1)
    tick = (tick or 0) + 1
end

function onDraw()
    screen.setColor(255, 255, 255)
    local x1 = (96 - (string.len(Label) * letterWidth)) / 2
    screen.drawText(x1, 5, Label)
    if(reverseDial) then
	    valueOut = map(valueIn, minIn, maxIn, 1, 0)
	else
	    valueOut = map(valueIn, minIn, maxIn, 0, 1)
	end
    
    screen.setColor(0, 255, 255)
    local x2 = (96 - (5 * letterWidth)) / 2
    screen.drawText(x2, 85, string.format("%05d", math.floor(valueIn)))
    
    handleWarning(48, 60, valueOut, warnThresh1, warnThresh2, warnThresh3, "!", "WARN")
    
    if(showEndThresholds) then
    	if(reverseDial) then
		    screen.setColor(255, 50, 0)
		    drawThickArc(48, 48, 28, 2, -193, -168, 10)
		    
		    screen.setColor(255, 0, 0)
		    drawThickArc(48, 48, 28, 2, -220, -193, 10)
		    
	    else 
		    screen.setColor(255, 50, 0)
		    drawThickArc(48, 48, 28, 2, -13, 15, 10)
		    
		    screen.setColor(255, 0, 0)
		    drawThickArc(48, 48, 28, 2, 15, 40, 10)
	    end
    end
    
    drawDial(48, 48,32, valueOut, 0, 1, -220, 40)
    
end

function drawbar(x, y, fill, center, width, height)
	
    local center = center or false
    local barX = x
    local barY = y
    local barWidth = width or 40
    local barHeight = height or 5

    screen.setColor(255, 255, 255)
    screen.drawRect(barX, barY, barWidth, barHeight)

    if center then
	    local centerX = barX + barWidth / 2
	    local fillWidth = (barWidth / 2) * math.abs(fill)
	    
	    if fill > 0 then
	        -- Positive throttle fills to the right
	        screen.setColor(0, 255, 0)
	        screen.drawRectF(centerX, barY, fillWidth, barHeight)
	    elseif fill < 0 then
	        -- Negative throttle fills to the left
	        screen.setColor(255, 0, 0)
	        screen.drawRectF(centerX - fillWidth, barY, fillWidth, barHeight)
    	end
    else 
	    local fillWidth = barWidth * fill
	    screen.setColor(0, 255, 0)
	    screen.drawRectF(barX, barY, fillWidth, barHeight)
    end
end

function drawDial(centerX, centerY, radius, value, minValue, maxValue, minAngle, maxAngle)
  -- Draw dial outline (circle)
  screen.setColor(255, 255, 255)
  screen.drawCircle(centerX, centerY, radius)

  local steps = 20  -- number of intervals (10% steps)
  for i = 0, steps do
      local t = i / steps
      
      local lengthMult = i % 2
      
      local tickValue = minValue + t * (maxValue - minValue)
      local angle = map(tickValue, minValue, maxValue, minAngle, maxAngle)
      local outerX = centerX + math.cos(math.rad(angle)) * radius
      local outerY = centerY + math.sin(math.rad(angle)) * radius
      local innerX = centerX + math.cos(math.rad(angle)) * (radius - 8 + (lengthMult * 5))
      local innerY = centerY + math.sin(math.rad(angle)) * (radius - 8 + (lengthMult * 5))

  if(i == 0) then
      if(reverseDial) then
          screen.setColor(255, 0, 0)
        else
          screen.setColor(0, 255, 0)
        end
      elseif(i == 20) then
      if(reverseDial) then
          screen.setColor(0, 255, 0)
        else
          screen.setColor(255, 0, 0)
        end
      elseif(i == 10) then
        screen.setColor(255, 255, 0)
      else
        screen.setColor(255, 255, 255)
      end
        
      screen.drawLine(innerX, innerY, outerX, outerY)
  end
    

  -- Clamp value
  local clamped = math.max(minValue, math.min(value, maxValue))

  -- Map value to angle
  local angle
	if reverseDial then
	    angle = map(clamped, minValue, maxValue, maxAngle, minAngle)
	else
	    angle = map(clamped, minValue, maxValue, minAngle, maxAngle)
	end

    local needleX = centerX + math.cos(math.rad(angle)) * (radius - 2)
    local needleY = centerY + math.sin(math.rad(angle)) * (radius - 2)
  
    screen.setColor(255, 0, 0)
    screen.drawLine(centerX, centerY, needleX, needleY)
end


function map(value, in_min, in_max, out_min, out_max)
    return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function handleWarning(x, y, value, threshold1, threshold2, threshold3, icon, label)
	if(value >= threshold3) then
		
	    if (tick // 10) % 2 == 0 then
			label = label or ""
			screen.setColor(255, 0, 0)
			screen.drawTriangleF(x - 5, y + 5, x+1, y - 5, x + 7, y + 5)	
			screen.setColor(0, 0, 0)
			screen.drawText(x-1, y-1, icon)
			local x1 = (96 - (string.len(label) * letterWidth)) / 2
			screen.setColor(255, 0, 0)
			screen.drawText(x1, y+7, label)
	    end
		
	elseif(value >= threshold2) then
		label = label or ""
		screen.setColor(255, 0, 0)
		screen.drawTriangleF(x - 5, y + 5, x+1, y - 5, x + 7, y + 5)	
		screen.setColor(0, 0, 0)
		screen.drawText(x-1, y-1, icon)
		local x1 = (96 - (string.len(label) * letterWidth)) / 2
		screen.setColor(255, 0, 0)
		screen.drawText(x1, y+7, label)
		
	elseif(value >= threshold1) then
		label = label or ""
		screen.setColor(255, 50, 0)
		screen.drawTriangleF(x - 5, y + 5, x+1, y - 5, x + 7, y + 5)	
		screen.setColor(0, 0, 0)
		screen.drawText(x-1, y-1, icon)
		local x1 = (96 - (string.len(label) * letterWidth)) / 2
		screen.setColor(255, 50, 0)
		screen.drawText(x1, y+7, label)
	end
end

function drawArc(centerX, centerY, radius, startAngle, endAngle, segments)
    local angleStep = (endAngle - startAngle) / segments
    local prevX = centerX + math.cos(math.rad(startAngle)) * radius
    local prevY = centerY + math.sin(math.rad(startAngle)) * radius

    for i = 1, segments do
        local angle = startAngle + i * angleStep
        local x = centerX + math.cos(math.rad(angle)) * radius
        local y = centerY + math.sin(math.rad(angle)) * radius
        screen.drawLine(prevX, prevY, x, y)
        prevX = x
        prevY = y
    end
end

function drawThickArc(centerX, centerY, radiusOuter, thickness, startAngle, endAngle, segments)
    local angleStep = (endAngle - startAngle) / segments


    for i = 0, segments - 1 do
        local angle1 = math.rad(startAngle + i * angleStep)
        local angle2 = math.rad(startAngle + (i + 1) * angleStep)

        local outerX1 = centerX + math.cos(angle1) * radiusOuter
        local outerY1 = centerY + math.sin(angle1) * radiusOuter
        local outerX2 = centerX + math.cos(angle2) * radiusOuter
        local outerY2 = centerY + math.sin(angle2) * radiusOuter

        local innerX1 = centerX + math.cos(angle1) * (radiusOuter - thickness)
        local innerY1 = centerY + math.sin(angle1) * (radiusOuter - thickness)
        local innerX2 = centerX + math.cos(angle2) * (radiusOuter - thickness)
        local innerY2 = centerY + math.sin(angle2) * (radiusOuter - thickness)

        screen.drawTriangleF(outerX1, outerY1, outerX2, outerY2, innerX1, innerY1)
        screen.drawTriangleF(innerX1, innerY1, outerX2, outerY2, innerX2, innerY2)
    end
end
