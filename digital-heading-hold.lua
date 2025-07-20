-- warning: mapping not found --

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
headingInput = {"_","_","_"}
headingInputPosition = 1
isEditing = false
wasTouched = false
tick = 0
osbT = ""
function compassToHeading(a)
	return (- a * 360 + 360) % 360
end
function getHeadingDifference(b,c)
	local d = (c - b + 180) % 360 - 180
	return d
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
	manualRudder = input.getNumber(7)
	currentHeading = compassToHeading(input.getNumber(8))
	currentSpeed = input.getNumber(9)
	currentX = input.getNumber(10)
	currentY = input.getNumber(11)
	differenceToHeading = getHeadingDifference(currentHeading,targetHeading)
	if isEditing then
		outputRudder = manualRudder
	elseif
isEngaged
	then
local e = math.min(1,math.max(- 1,differenceToHeading / 45))
outputRudder = e + manualRudder
outputRudder = math.max(- 1,math.min(1,outputRudder))	else
outputRudder = manualRudder
	end
	output.setNumber(1,outputRudder)
end
function onDraw()
	sc(255,255,255)
	dt(2,2,"HEADING: " .. sf("%03d ",mf(currentHeading)))
	dt(2,10,"TARGET:  " .. sf("%03d ",mf(targetHeading)))
	if unit == 0 then
		dt(120,2,"SPD:  " .. sf("%03d knt",mf(currentSpeed * 1.94385)))
	end
	if unit == 1 then
		dt(120,2,"SPD:  " .. sf("%03d kph",mf(currentSpeed * 3.6)))
	end
	if unit == 2 then
		dt(120,2,"SPD:  " .. sf("%03d mph",mf(currentSpeed * 2.23694)))
	end
	if unit == 3 then
		dt(120,2,"SPD:  " .. sf("%03d m/s",mf(currentSpeed)))
	end
	dt(120,12,"GPX:  " .. sf("%07d ",mf(currentX)))
	dt(120,22,"GPY:  " .. sf("%07d ",mf(currentY)))
	if isEditing then
		if isHeadingInputValid() == - 1 then
			sc(255,0,0)
			dt(5,37,"ERR: INVALID")
		elseif
isHeadingInputValid() == - 2
		then
sc(255,0,0)
dt(5,37,"ERR: MAX")
		elseif
isHeadingInputValid() == 1
		then
sc(0,255,0)
dt(5,37,"OKA: ACCEPT")
		end
		dr(5,20,60,15)
		dt(10,25,"Set: " .. sf("%s %s %s",headingInput[1],headingInput[2],headingInput[3]))
		if headingInputPosition == 1 then
			flashText(10,25,"     -")
		end
		if headingInputPosition == 2 then
			flashText(10,25,"       -")
		end
		if headingInputPosition == 3 then
			flashText(10,25,"         -")
		end
	end
	drawKeypad(isEditing)
	if isEngaged then
		sc(0,255,0)
		drF(75,1,25,15)
		sc(0,0,0)
		dt(80,6,"ENG")
		sc(255,0,0)
		dr(75,16,25,15)
		dt(80,21,"DIS")	else
sc(255,255,255)
dr(75,1,25,15)
dt(80,6,"ENG")
sc(255,0,0)
drF(75,16,25,15)
sc(0,0,0)
dt(80,21,"DIS")
	end
	
	drawRudderBar()
		
	if osbMenu == 0 then
		if osb(0,"HEADING",{70,70,70}) then
			osbMenu = 1
			osbT = "-- HEADING --"
		end
		if osb(1,"SETTING",{70,70,70}) then
			osbMenu = 2
			osbT = "-- SETTING --"
		end
		wasTouched = isPressed1
	end
	if osbMenu == 1 then
		local f = {70,70,70}
		if isEditing then
			f = {0,180,0}
		end
		if osb(0," SET",f) then
			osbMenu = 1
			isEditing = not isEditing
		end
		if not isEngaged then
			if osb(1,"ENGAGE",{70,70,70}) then
				osbMenu = 1
				isEngaged = true
				isEditing = false
			end		else
if osb(1,"DISENGAGE",{255,50,0}) then
osbMenu = 1
isEngaged = false
isEditing = false
end
		end
		if osb(3," BACK",{70,70,70}) then
			isEditing = false
			osbMenu = 0
			osbT = ""
		end
		wasTouched = isPressed1
	end
	if osbMenu == 2 then
		if osb(0," UNIT",{70,70,70}) then
			unit = unit + 1
			if unit == 4 then
				unit = 0
			end
		end
		if osb(3," BACK",{70,70,70}) then
			osbMenu = 0
			osbT = ""
		end
		wasTouched = isPressed1
	end
	sc(255,255,255)
	local g = 96 - string.len(osbT) * 5 / 2
	dt(g,140,osbT)
	wasTouched = isPressed1
end
function getTouch(h,i,j,k,l)
	local m = false
	if isPressed1 and not wasTouched and input1X >= h and input1X <= j and input1Y >= i and input1Y <= k then
		m = true
	end
	if l then
		sc(table.unpack(l))
		drF(h,i,j - h,k - i)
	end
	return m
end
function drawKeypad(n)
	local o = 19
	local p = 1
	local q = 7
	if n then
		sc(255,255,255)
		local r = 5
		local s = 45
		drawButton(r,s,o,"1",q)
		if getTouch(r,s,r + o,s + o) then
			setHeadingInput("1")
		end
		r = r + o + p
		s = 45
		drawButton(r,s,o,"2",q)
		if getTouch(r,s,r + o,s + o) then
			setHeadingInput("2")
		end
		r = r + o + p
		s = 45
		drawButton(r,s,o,"3",q)
		if getTouch(r,s,r + o,s + o) then
			setHeadingInput("3")
		end
		r = 5
		s = 45 + o + p
		drawButton(r,s,o,"4",q)
		if getTouch(r,s,r + o,s + o) then
			setHeadingInput("4")
		end
		r = r + o + p
		s = s
		drawButton(r,s,o,"5",q)
		if getTouch(r,s,r + o,s + o) then
			setHeadingInput("5")
		end
		r = r + o + p
		s = s
		drawButton(r,s,o,"6",q)
		if getTouch(r,s,r + o,s + o) then
			setHeadingInput("6")
		end
		r = 5
		s = s + o + p
		drawButton(r,s,o,"7",q)
		if getTouch(r,s,r + o,s + o) then
			setHeadingInput("7")
		end
		r = r + o + p
		s = s
		drawButton(r,s,o,"8",q)
		if getTouch(r,s,r + o,s + o) then
			setHeadingInput("8")
		end
		r = r + o + p
		s = s
		drawButton(r,s,o,"9",q)
		if getTouch(r,s,r + o,s + o) then
			setHeadingInput("9")
		end
		r = 5
		s = s + o + p
		sc(255,0,0)
		drawButton(r,s,o,"X",q)
		if getTouch(r,s,r + o,s + o) then
			headingInput = {"_","_","_"}
			headingInputPosition = 1
		end
		r = r + o + p
		s = s
		sc(255,255,255)
		drawButton(r,s,o,"0",q)
		if getTouch(r,s,r + o,s + o) then
			setHeadingInput("0")
		end
		r = r + o + p
		s = s
		sc(0,255,0)
		if isHeadingInputValid() == 1 then
			drawButton(r,s,o,"A",q)
			if getTouch(r,s,r + o,s + o) then
				isEditing = false
				targetHeading = tonumber(headingInput[1] .. headingInput[2] .. headingInput[3])
			end
		end	else
sc(25,25,25)
	end
end
function drawButton(t,u,v,w,q)
	q = q or 2
	dr(t,u,v,v)
	dt(t + q,u + q,w)
end
function drawRectButton(t,u,x,y,w,z,A)
	z = z or 2
	A = A or z
	dr(t,u,x,y)
	dt(t + z,u + A,w)
end
function flashText(t,u,w,B)
	B = B or 10
	if tick // B % 2 == 0 then
		dt(t,u,w)
	end
end
function setHeadingInput(C)
	headingInput[headingInputPosition] = C
	headingInputPosition = headingInputPosition + 1
	if headingInputPosition == 4 then
		headingInputPosition = 1
	end
end
function isHeadingInputValid()
	local D = ""
	if headingInput[1] == "_" or headingInput[2] == "_" or headingInput[3] == "_" then
		return - 1
	end
	D = headingInput[1] .. headingInput[2] .. headingInput[3]
	D = tonumber(D)
	if D > 359 then
		return - 2
	end
	if D < 0 then
		return - 3
	end
	return 1
end
function drawRudderBar()
	local E = 120
	local F = 50
	local G = 65
	local H = 15
	sc(50,50,50)
	dr(E,F,G,H)
	dt(E,F + H + 3,"   RUDDER")
	local I = E + G / 2
	local J = (outputRudder or 0) * G / 2
	if outputRudder > 0 then
		sc(0,255,0)
		drF(I,F,J,H)
	elseif
outputRudder < 0
	then
sc(255,0,0)
drF(I + J,F,- J,H)
	end
	sc(255,255,255)
	screen.drawLine(I,F,I,F + H)
end
function sc(K,L,M)
	screen.setColor(K,L,M)
end
function dr(t,u,N,O)
	screen.drawRect(t,u,N,O)
end
function drF(t,u,N,O)
	screen.drawRectF(t,u,N,O)
end
function dt(t,u,P)
	screen.drawText(t,u,P)
end
function mf(Q)
	return math.floor(Q)
end
function sf(R,...)
	return string.format(R,...)
end
function osb(S,w,l)
	local T = 12
	local t = 15 + T * S + 35 * S
	local h = t - string.len(w) * 3 / 2
	sc(50,50,50)
	drF(t - 1,160 - 1,T + 2,T + 2)
	sc(table.unpack(l))
	drF(t,160,T,T)
	screen.drawLine(t + T / 2,172,t + T / 2,180)
	dt(h,185,w)
	return getTouch(t,160,t + T,160 + T)
end
