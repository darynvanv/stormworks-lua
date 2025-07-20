targetHeading = 0
currentHeading = 0
currentSpeed = 0
osbMenu = 0

EL_RPS = 0
EL_CoolantP = 0
EL_CoolantPump = false
EL_FuelP = 0
EL_AirP = 0
EL_Temp = 0
EL_AirM = 1
EL_FuelM = 0.5

wasTouched = false
tick = 0
osbT = ""


function onTick()
	tick = (tick or 0) + 1
	EL_CoolantPump = input.getBool(1)
	EL_AirPump = input.getBool(2)
	EL_FuelPump = input.getBool(3)
	EL_RPS = input.getNumber(1)
	EL_CoolantP = input.getNumber(2)
	EL_FuelP = input.getNumber(3)
	EL_AirP = input.getNumber(4)
	EL_Temp = input.getNumber(5)
	
	output.setNumber(1, EL_AirM)
	output.setNumber(2, EL_FuelM)
end

function onDraw()
	
	drawEngineSystem(10, 10, 10, 20, 30, 40, 50, 60, 70)
	
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

function drawEngineSystem(x, y, fuelP, CoolantP, AirP, FuelM, AirM, Temp, RPS)
	
	if(EL_CoolantPump) then
		sc(100,100,255)
		drawFan(x,y,10)
		
		sc(0,50,255)
		dt(x+9, y-8, "COOLANT ON")
		flashRect(x-1,y+8, 2, 2, 10, true, true)
		flashRect(x-1,y+10, 2, 2, 10, false, true)
		flashRect(x-1,y+12, 2, 2, 10, true, true)
		flashRect(x-1,y+14, 2, 2, 10, false, true)
		flashRect(x-1,y+16, 2, 2, 10, true, true)
		flashRect(x-1,y+18, 2, 2, 10, false, true)
		flashRect(x-1,y+20, 2, 2, 10, true, true)
		flashRect(x-1,y+22, 2, 2, 10, false, true)
		flashRect(x+1,y+22, 2, 2, 10, true, true)
		flashRect(x+3,y+22, 2, 2, 10, false, true)
		flashRect(x+5,y+22, 2, 2, 10, true, true)
		flashRect(x+7,y+22, 2, 2, 10, false, true)
		flashRect(x+9,y+22, 2, 2, 10, true, true)
	else 
		sc(255,100,0)
		dt(x+9, y-8, "COOLANT OFF")
		drawFan(x,y,0)
	end
	
	sc(0,50,255)
	dp(x,y,{0,-3},{-2,4},{1,1},{2,0},{1,-1},{-2,-4})
	
	sc(100,100,100)
	dp(x+1,y+6, {0,16},{9, 0},{0,2},{-9-2, 0},{0,-19})
	
	
	drawEngine(x+5,y+10,EL_RPS)
	
	sc(0,100,255)
	dt(x+65, y, "AIR:\n" .. string.format("%03d", math.floor(EL_AirM * 100)))
	
	sc(100,100,100)
	dp(x+59,y+6, {0, 6},{-18, 0}, {0,2},{20,0},{0,-8})
	
	sc(0,100,255)
	flashRect(x+59, y+6, 2, 2, 10, false, true)
	flashRect(x+59, y+8, 2, 2, 10, true, true)
	flashRect(x+59, y+10, 2, 2, 10, false, true)
	flashRect(x+59, y+12, 2, 2, 10, true, true)
	flashRect(x+57, y+12, 2, 2, 10, false, true)
	flashRect(x+55, y+12, 2, 2, 10, true, true)
	flashRect(x+53, y+12, 2, 2, 10, false, true)
	flashRect(x+51, y+12, 2, 2, 10, true, true)
	flashRect(x+49, y+12, 2, 2, 10, false, true)
	flashRect(x+47, y+12, 2, 2, 10, true, true)
	flashRect(x+45, y+12, 2, 2, 10, false, true)
	flashRect(x+43, y+12, 2, 2, 10, true, true)
	flashRect(x+41, y+12, 2, 2, 10, false, true)
	
end

function drawFan(x,y,speed)
	screen.drawCircle(x,y, 7)
	
	if(speed == 0) then
		dtrF(x,y,x-7,y,x-5,y-5)
		dtrF(x,y,x+7,y,x+5,y-5)
		dtrF(x,y,x-2,y+6,x+2,y+6)
	else
		flashTri(x,y,x-7,y,x-5,y-5,speed,false,true)
		flashTri(x,y,x+7,y,x+5,y-5,speed,false,true)
		flashTri(x,y,x-2,y+6,x+2,y+6,speed,false,true)
		
		flashTri(x,y,x-3,y-6,x+3,y-6,speed,true,true)
		flashTri(x,y,x+6,y+1,x+3,y+6,speed,true,true)
		flashTri(x,y,x-7,y+1,x-3,y+6,speed,true,true)
	end
	sc(0,0,0)
	screen.drawCircleF(x,y, 5)
end

function drawEngine(x, y, rps)
	sc(100,100,100)
	dp(x+5,y+10,
		{0,0},{0,20}, {10,0}, {0,-5},{20, 0},{0,5},{5,0},{0,-20},{-5,0},
		{0,-1},{1,0},{0,-9},{-5,0},{0,9},{1,0},{0,1},
		{-4,0},{0,-1},{1,0},{0,-9},{-5,0},{0,9},{1,0},{0,1},
		{-4,0},{0,-1},{1,0},{0,-9},{-5,0},{0,9},{1,0},{0,1},
		{-4,0},{0,-1},{1,0},{0,-9},{-5,0},{0,9},{1,0},{0,1},
		{-6,0}
	)
	sc(0,0,0)
	drF(x,y+17,45,5)
	sc(255,255,255)
	dr(x,y+17,45,5)
	local flashSpeed = (60 - rps) / 6
	
	if(rps == 0) then
		flashSpeed = 999999
	end
	local pistonX = x - 5
	local pistonY = y - 5
	flashRect(pistonX+15, pistonY+10, 5, 2, flashSpeed, false, true)
	flashRect(pistonX+17, pistonY+12, 1, 10, flashSpeed, false, true)
	flashRect(pistonX+15, pistonY+5, 5, 2, flashSpeed, true, true)
	flashRect(pistonX+17, pistonY+7, 1, 15, flashSpeed, true, true)
	
	flashRect(pistonX+22, pistonY+10, 5, 2, flashSpeed, true, true)
	flashRect(pistonX+24, pistonY+12, 1, 10, flashSpeed, true, true )
	flashRect(pistonX+22, pistonY+5, 5, 2, flashSpeed, false, true)
	flashRect(pistonX+24, pistonY+7, 1, 15, flashSpeed, false, true)
	
	flashRect(pistonX+29, pistonY+10, 5, 2, flashSpeed, false, true)
	flashRect(pistonX+31, pistonY+12, 1, 10, flashSpeed, false, true)
	flashRect(pistonX+29, pistonY+5, 5, 2, flashSpeed, true, true)
	flashRect(pistonX+31, pistonY+7, 1, 15, flashSpeed, true, true )
	
	flashRect(pistonX+36, pistonY+10, 5, 2, flashSpeed, true, true) 
	flashRect(pistonX+38, pistonY+12, 1, 10, flashSpeed, true, true)
	flashRect(pistonX+36, pistonY+5, 5, 2, flashSpeed, false, true )
	flashRect(pistonX+38, pistonY+7, 1, 15, flashSpeed, false, true)

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

function flashText(t,u,w,B,i)
	B = B or 10
	i = i or false
	if(i) then
		if tick // B % 2 == 0 then
			dt(t,u,w)
		end
	else
		if tick // B % 2 ~= 0 then
			dt(t,u,w)
		end
	end
end
function flashRect(x,y,w,h,s,i,f,o)
	B = B or 10
	f = f or false
	o = o or 2
	if(i) then
		if tick // s % o == 0 then
			if(f) then drF(x,y,w,h) else dr(x,y,w,h) end
		end
	else
		if tick // s % o ~= 0 then
			if(f) then drF(x,y,w,h) else dr(x,y,w,h) end
		end
	end
end
function flashTri(x1,y1,x2,y2,x3,y3,s,i,f)
	s = s or 10
	i = i or false
	f = f or false
	if(i) then
		if tick // s % 2 == 0 then
			if(f) then dtrF(x1,y1,x2,y2,x3,y3) else dtr(x1,y1,x2,y2,x3,y3) end
		end
	else
		if tick // s % 2 ~= 0 then
			if(f) then dtrF(x1,y1,x2,y2,x3,y3) else dtr(x1,y1,x2,y2,x3,y3) end
		end
	end
end
function sc(K,L,M)
	screen.setColor(K,L,M)
end
function dr(t,u,N,O)
	screen.drawRect(t,u,N,O)
end
function dtr(x1, y1, x2, y2, x3, y3)
	screen.drawTriangle(x1, y1, x2, y2, x3, y3)
end
function dtrF(x1, y1, x2, y2, x3, y3)
	screen.drawTriangleF(x1, y1, x2, y2, x3, y3)
end
function drF(t,u,N,O)
	screen.drawRectF(t,u,N,O)
end
function dt(t,u,P)
	screen.drawText(t,u,P)
end
function dp(x, y, ...)
	local curX = x or 0
	local curY = y or 0
	local y = {...}
	for	i, value in ipairs(y) do
		dl(curX, curY, curX + value[1], curY + value[2])	
		curX = curX + value[1]
		curY = curY + value[2]
	end
end
function mf(Q)
	return math.floor(Q)
end
function sf(R,...)
	return string.format(R,...)
end
function dl(x1, y1, x2, y2)
	screen.drawLine(x1,y1,x2,y2)
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
