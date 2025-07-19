label = "MASTER SWITCH"
isActive = false

buttonX = 48
buttonY = 38
buttonRadius = 32

wasButton1Pressed = false
wasButton2Pressed = false

letterWidth = 5

function onTick()
 isPressed1 = input.getBool(1)
 isPressed2 = input.getBool(2)
 
  screenWidth = input.getNumber(1)
  screenHeight = input.getNumber(2)
 
  input1X = input.getNumber(3)
  input1Y = input.getNumber(4)
  input2X = input.getNumber(5)
  input2Y = input.getNumber(6)
  
  if isPressed1 and input1X >= buttonX - buttonRadius and input1X <= buttonX + buttonRadius and input1Y >= buttonY - buttonRadius and input1Y <= buttonY + buttonRadius then
       wasButton1Pressed = true
  elseif isPressed2 and input2X >= buttonX - buttonRadius and input2X <= buttonX + buttonRadius and input2Y >= buttonY - buttonRadius and input2Y <= buttonY + buttonRadius then
       wasButton2Pressed = true
  end
   
  if not isPressed1 and wasButton1Pressed then
      wasButton1Pressed = false
     isActive = not isActive
   end
   
  if not isPressed2 and wasButton2Pressed then
      wasButton2Pressed = false
     isActive = not isActive
   end
   
  output.setBool(1, isActive)
end    
      
function onDraw()
	
	screen.setColor(55,55,55) 
	screen.drawCircleF(buttonX, buttonY, buttonRadius + 4)
		
	if isActive then
    	screen.setColor(0,255,0) 
	else
    	screen.setColor(10,10,10) 
	end
	
	screen.drawCircleF(buttonX, buttonY, buttonRadius)
   
    local x1 = (96 - (string.len(label) * letterWidth)) / 2
	screen.drawText(x1, 82, label)
end
