-- +--------------------------------------------------------+
-- |                                                        |
-- |                      Pipe Mania                        |
-- |                                                        |
-- +--------------------------------------------------------+

local version = "Version 1.0.1"

-- A clone for ComputerCraft, by Jeffrey Alexander, aka Bomb Bloke.
-- Requires an Advanced Computer or better, plus ComputerCraft 1.76+ / Minecraft 1.8+.
-- http://www.computercraft.info/forums2/index.php?/topic/26615-mc18-pipe-mania/

---------------------------------------------
------------Variable Declarations------------
---------------------------------------------

if not blittle then
	if not (fs.exists("blittle") or fs.exists(shell.resolve("blittle"))) then
		shell.run("pastebin get ujchRSnU blittle")
		os.loadAPI(shell.resolve("blittle"))
	else os.loadAPI(fs.exists("blittle") and "blittle" or shell.resolve("blittle")) end
end

local img = {{"770077","770077","000000","000000","770077","770077"},  --  1 Cross pipe.
		{"777777","777777","000000","000000","777777","777777"},  --  2 Horizontal pipe.
		{"770077","770077","770077","770077","770077","770077"},  --  3 Vertical pipe.
		{"770077","770077","770000","777000","777777","777777"},  --  4 Top-right curve.
		{"777777","777777","777000","770000","770077","770077"},  --  5 Bottom-right curve.
		{"777777","777777","000777","000077","770077","770077"},  --  6 Bottom-left curve.
		{"770077","770077","000077","000777","777777","777777"},  --  7 Top-left curve.
		{"777777","787787","778877","778877","787787","777777"},  --  8 No pipe.
		{"777777","7e7777","7eeee7","777e77","77ee77","777777"},  --  9 Explody pipe 1.
		{"eee4ee","e4eee4","e4444e","44e4e4","e444ee","ee44ee"},  -- 10 Explody pipe 2.
		{"777777","747774","777747","474777","777774","747777"}}  -- 11 Explody pipe 3.

local mon, next, grid, level, score = blittle.createWindow(), {}, {}, 1, 0
local dirTemplate, dents = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}}, {{"55", "55"}, {"55", "75"}, {"75", "55"}, {"57", "55"}, {"55", "57"}}
local myEvent, distance, delay, curDelay, floozTimer, xSize, ySize, curX, curY, subX, subY, direction, dirBumpX, dirBumpY, exploding, fast, scores, kiosk
local keyboard = {" ABCDEFGHIJKLMNOPQRSTUVWXYZ ", " abcdefghijklmnopqrstuvwxyz ", " 1234567890 !'$ \001\003\011\012\015 \027 END "}

---------------------------------------------
------------Function Declarations------------
---------------------------------------------

-- Writes regular text at the specified location on the screen.
local function writeAt(text, x , y, fgCol, bgCol)
	if fgCol then term.setTextColour(fgCol) end
	if bgCol then term.setBackgroundColour(bgCol) end
	term.setCursorPos(x, y)
	term.write(text)
end

-- Returns whether one of a given set of keys was pressed.
local function pressedKey(...)
	if myEvent[1] ~= "key" then return false end
	local key = myEvent[2]
	for i=1,#arg do if arg[i] == key then return true end end
	return false
end

-- Returns whether a click was performed at a given location.
-- If one parameter is passed, it checks to see if y is [1].
-- If two parameters are passed, it checks to see if x is [1] and y is [2].
-- If three parameters are passed, it checks to see if x is between [1]/[2] (non-inclusive) and y is [3].
-- If four paramaters are passed, it checks to see if x is between [1]/[2] and y is between [3]/[4] (non-inclusive).
local function clickedAt(...)
	if myEvent[1] ~= "mouse_click" then return false end
	local x, y = myEvent[3], myEvent[4]
	if #arg == 1 then return (arg[1] == y)
	elseif #arg == 2 then return (x == arg[1] and y == arg[2])
	elseif #arg == 3 then return (x > arg[1] and x < arg[2] and y == arg[3])
	else return (x > arg[1] and x < arg[2] and y > arg[3] and y < arg[4]) end
end

-- Draw a section of pipe.
local function drawTile(img, x, y)
	for i = 1, 6 do
		mon.setCursorPos(x, y + i - 1)
		mon.blit("      ", "      ", img[i])
	end
end

-- tostring() with leading zeroes.
local function zeroes(num, length)
	local result = tostring(num)
	return #result < length and (string.rep("0", length - #result) .. result) or result
end

-- (Re)draws displayed labels and so on.
local function drawLabels()
	if not kiosk then writeAt("\215", xSize, 1, colours.white, colours.red) end
	writeAt(" \187 ", 5, 5, fast and colours.red or colours.white, colours.grey)
	writeAt(" P ", 5, 3, colours.white)
	writeAt(" PIPE MANIA ", 20, 1)
	writeAt(" LVL: " .. zeroes(level, 2) .. "  SCORE: " .. zeroes(score, 7) .. " DIST: " .. zeroes(distance, 2) .. " ", 10, 18)
end

-- Prepare the screen and re-init the playing grid for a new level.
local function newLevel()
	delay, exploding, fast = 18 - level, false, false
	if delay < 1 then delay = 1 end
	curDelay = delay
	distance = 13 + math.floor((level + 1) / 2)

	local oldTerm = term.redirect(mon)
	mon.setVisible(false)
	
	term.setBackgroundColour(colours.lightGrey)
	term.clear()
	
	local back = img[8]
	for y = 1, 7 do
		grid[y] = {}
		for x = 1, 10 do drawTile(back, (x - 1) * 6 + 23, (y - 1) * 6 + 7) end
	end
	
	curX, curY, subX, subY, direction = math.random(8) + 1, math.random(5) + 1, 2, 2, math.random(4)
	grid[curY][curX] = 8
	
	local midX, midY = 19 + curX * 6, 3 + curY * 6
	paintutils.drawFilledBox(midX - 2, midY - 2, midX + 3, midY + 3, colours.grey)
	paintutils.drawBox(midX, midY, midX + 1, midY + 1, colours.lime)
	dirBumpX, dirBumpY = dirTemplate[direction][1], dirTemplate[direction][2]
	midX, midY = midX + dirBumpX * 2, midY + dirBumpY * 2
	paintutils.drawBox(midX, midY, midX + 1, midY + 1, colours.white)
	
	paintutils.drawBox( 8, 43, 15, 49, colours.cyan)
	paintutils.drawBox(92,  9, 95, 46, colours.grey)
	paintutils.drawBox(93, 10, 94, 45, colours.lime)
	paintutils.drawBox(22,  6, 83, 49, colours.black)
	paintutils.drawBox( 8, 18, 15, 42)
	paintutils.drawBox(40,  0, 63,  4)
	paintutils.drawBox(18, 51, 87, 55)
	paintutils.drawBox( 8,  6, 15, 10)
	paintutils.drawBox( 8, 12, 15, 16)
	
	for i = 1, 5 do
		next[i] = math.random(7)
		drawTile(img[next[i]], 9, 49 - i * 6)
	end
	
	term.redirect(oldTerm)
	mon.setVisible(true)
	
	drawLabels()

	floozTimer = os.startTimer(0.5)
end

-- Tries to jump flooz to a new pipe segment, returns false if impossible.
local function checkMovement()
	curX, curY = curX + dirBumpX, curY + dirBumpY
	if curX < 1 or curX > 10 or curY < 1 or curY > 7 then return false end
	
	local pipeType = grid[curY][curX]
	
	if not pipeType or pipeType == 8 then return false end
	
	if (pipeType == 2 or pipeType == 3 or pipeType == 9 or pipeType == 10) and direction % 2 ~= pipeType % 2 then return false end
	
	if pipeType > 3 and pipeType < 8 then
		pipeType = (pipeType - direction) % 4
		if pipeType > 1 then return false end
	end
	
	if subX < 1 then subX = 3 elseif subX > 3 then subX = 1 elseif subY < 1 then subY = 3 elseif subY > 3 then subY = 1 end
	
	return true
end

-- Render moving flooz.
local function drawFlooz(pipeType)
	local thisBlob, midX, midY = dents[pipeType and (pipeType - 2) or 1], curX * 6 + subX * 2 + 15, curY * 6 + subY * 2 - 1
	
	mon.setCursorPos(midX, midY)
	mon.blit("  ", "  ", thisBlob[1])
	mon.setCursorPos(midX, midY + 1)
	mon.blit("  ", "  ", thisBlob[2])
end

-- Press a key to continue (or exit).
local function pressAnyKey()
	while true do
		myEvent = {coroutine.yield()}

		if (clickedAt(xSize, 1) or pressedKey(keys.x, keys.q) or myEvent[1] == "terminate") and not kiosk then
			if myEvent[1] == "key" then os.pullEvent("char") end
			return false
		
		elseif myEvent[1] == "key" or myEvent[1] == "mouse_click" then
			return true
		end
	end
end

-- High-score board.
local function scoreboard(level, score)
	if not scores and (fs.exists(shell.resolve("pipemania.dat")) or fs.exists("pipemania.dat")) then
		local input = fs.open(fs.exists(shell.resolve("pipemania.dat")) and shell.resolve("pipemania.dat") or "pipemania.dat", "r")
		scores = textutils.unserialise(input.readAll())
		input.close()
	end
	
	if type(scores) ~= "table" then
		scores = {{10, 10000, "APE"},
			{   9,  9000, "BAT"},
			{   8,  8000, "CAT"},
			{   7,  7000, "DOG"},
			{   6,  6000, "EEL"},
			{   5,  5000, "NAZ"},
			{   4,  4000, "CAC"},
			{   3,  3000, "ORP"},
			{   2,  2000, "ORA"},
			{   1,  1000, "TIO"}}
	end
	
	local newScore = false
	for i = 1, 10 do if score > scores[i][2] then
		table.insert(scores, i, {level, score, ""})
		scores[11], newScore = nil, i
		break
	end end
	
	local oldTerm = term.redirect(mon)
	mon.setVisible(false)
	term.setBackgroundColour(colours.lightGrey)
	term.clear()
	paintutils.drawFilledBox(17,  7, 84, 42, colours.grey)
	paintutils.drawBox(16,  6, 85, 43, colours.black)
	paintutils.drawBox(40,  0, 65,  4)
	paintutils.drawLine(16, 11, 85, 11)
	term.redirect(oldTerm)
	mon.setVisible(true)
	
	if not kiosk then writeAt("\215", xSize, 1, colours.white, colours.red) end
	writeAt(" High Scores ", 20, 1, colours.white, colours.grey)
	writeAt(" Level        Name         Score  ", 9, 3)
	
	for i = 1, 10 do
		term.setTextColour(i == newScore and colours.orange or colours.white)
		local thisScore = scores[i]
		writeAt(zeroes(thisScore[1], 2), 12, 4 + i)
		writeAt(thisScore[3], 16 + math.floor((18 - #thisScore[3]) / 2), 4 + i)
		writeAt(zeroes(thisScore[2], 7), 35, 4 + i)
	end
	
	if newScore then
		term.redirect(mon)
		paintutils.drawBox(22,  45, 79, 55, colours.black)
		term.redirect(oldTerm)
		
		for i = 1, 3 do writeAt(keyboard[i], 12, 15 + i, colours.white, colours.grey) end
		
		term.setTextColour(colours.orange)
		term.setCursorPos(16, 4 + newScore)
		term.setCursorBlink(true)
		
		local name, curPos = "", 1
		
		-- Name entry:
		while true do
			myEvent = {coroutine.yield()}
			
			if (clickedAt(xSize, 1) or myEvent[1] == "terminate") and not kiosk then
				if myEvent[1] == "key" then os.pullEvent("char") end
				term.setCursorBlink(false)
				return false
			
			elseif myEvent[1] == "char" and #name < 18 then 
				name = name:sub(1, curPos - 1) .. myEvent[2] .. name:sub(curPos)
				curPos = curPos + 1
				writeAt(name, 16, 4 + newScore)
				term.setCursorPos(16 + curPos - 1, 4 + newScore)
			
			elseif (clickedAt(34, 18) or pressedKey(keys.backspace)) and curPos > 1 then
				name = name:sub(1, curPos - 2) .. name:sub(curPos)
				curPos = curPos - 1
				writeAt(name .. " ", 16, 4 + newScore)
				term.setCursorPos(16 + curPos - 1, 4 + newScore)
			
			elseif pressedKey(keys.left) and curPos > 1 then
				curPos = curPos - 1
				term.setCursorPos(16 + curPos - 1, 4 + newScore)
			
			elseif pressedKey(keys.right) and curPos < 19 and curPos < #name + 1 then
				curPos = curPos + 1
				term.setCursorPos(16 + curPos - 1, 4 + newScore)
			
			elseif clickedAt(35, 39, 18) or pressedKey(keys.enter) then
				break
			
			elseif clickedAt(12, 39, 15, 19) and not clickedAt(33, 39, 18) and #name < 18 then
				local x = myEvent[3] - 11
				name = name:sub(1, curPos - 1) .. keyboard[myEvent[4] - 15]:sub(x, x) .. name:sub(curPos)
				curPos = curPos + 1
				writeAt(name, 16, 4 + newScore)
				term.setCursorPos(16 + curPos - 1, 4 + newScore)
			
			end
		end
		
		term.setCursorBlink(false)
		
		if name == "" then name = "---" end
		scores[newScore][3] = name
		writeAt(string.rep(" ", 18), 16, 4 + newScore)
		writeAt(name, 16 + math.floor((18 - #name) / 2), 4 + newScore)
		
		local output = fs.open(shell.resolve("pipemania.dat"), "w") or fs.open("pipemania.dat", "w")
		
		if output then
			output.writeLine(textutils.serialise(scores))
			output.close()
		end
	else
		writeAt("You:", 24, 17, colours.black, colours.lightGrey)
		writeAt("Level - " .. zeroes(level, 2) .. "  Score - " .. zeroes(score, 7), 13, 18, colours.black, colours.lightGrey)
	end
	
	return pressAnyKey()
end

---------------------------------------------
------------         Init        ------------
---------------------------------------------

-- Check display capabilities:
if term.current().setTextScale then
	local curScale = 5
	
	repeat
		term.current().setTextScale(curScale)
		xSize, ySize = term.getSize()
		if xSize > 49 and ySize > 17 then break end
		curScale = curScale - 0.5
	until curScale == 0
else xSize, ySize = term.getSize() end
	
if xSize < 50 or ySize < 18 then error("Sorry, a larger display is required.") end
if not term.isColour() then error("Sorry, a colour display is required.") end

-- Kiosk mode?
do
	local arg = {...}
	for i = 1, #arg do if arg[i]:lower() == "-k" then kiosk = true end end
end

-- Splash screen:
mon.setVisible(false)
for y = 0, 9 do for x = 0, 16 do drawTile(img[math.random(7)], x * 6 + 1, y * 6 + 1) end end
mon.setVisible(true)
writeAt(" PIPE MANIA ", 20, 9, colours.red, colours.black)
writeAt(" " .. version .. " ", math.floor((51 - #version - 2) / 2) + 1, 10, colours.yellow)
repeat myEvent = {coroutine.yield()} until myEvent[1] == "key" or myEvent[1] == "mouse_click"

-- Prepare new game:
level, score = 1, 0
newLevel()

---------------------------------------------
------------  Main Program Loop  ------------
---------------------------------------------

while true do
	myEvent = {coroutine.yield()}
	
	-- Attempt to place tile:
	if clickedAt(11, 42, 2, 17) and not exploding then
		local x, y = math.floor((myEvent[3] - 12) / 3) + 1, math.floor((myEvent[4] - 3) / 2) + 1
		
		-- Empty tile, place pipe:
		if not grid[y][x] then
			grid[y][x] = table.remove(next, 1)
			next[5] = math.random(7)
			for i = 1, 5 do drawTile(img[next[i]], 9, 49 - i * 6) end
			drawTile(img[grid[y][x]], (x - 1) * 6 + 23, (y - 1) * 6 + 7)
		
		-- Filled tile, explode pipe:
		elseif grid[y][x] < 8 and not (curX == x and curY == y) then
			grid[y][x] = 8
			drawTile(img[9], (x - 1) * 6 + 23, (y - 1) * 6 + 7)
			exploding = {x, y, os.startTimer(0.4), 1}
		end
	
	-- Pause:
	elseif clickedAt(4, 8, 3) or pressedKey(keys.p) then
		local blank = string.rep(" ", 30)
		term.setTextColour(colours.white)
		term.setBackgroundColour(colours.black)
		for i = 1, 14 do writeAt(blank, 12, 2 + i) end
		
		local blink1, blink2 = os.startTimer(0), os.startTimer(1)
		
		while true do
			myEvent = {coroutine.yield()}
			
			if (clickedAt(xSize, 1) or pressedKey(keys.x, keys.q) or myEvent[1] == "terminate") and not kiosk then
				if myEvent[1] == "key" then os.pullEvent("char") end
				blank = false
				break
			elseif clickedAt(4, 8, 3) or pressedKey(keys.p) then
				break
			elseif myEvent[1] == "timer" and myEvent[2] == blink1 then
				writeAt("PAUSED", 24, 9)
				blink1 = os.startTimer(2)
			elseif myEvent[1] == "timer" and myEvent[2] == blink2 then
				writeAt("      ", 24, 9)
				blink2 = os.startTimer(2)
			end
		end
		
		if not blank then break end
		
		mon.redraw()
		drawLabels()
		floozTimer = os.startTimer(0)
	
	-- Toggle speed:
	elseif clickedAt(4, 8, 5) or pressedKey(keys.f) then
		fast = not fast
		writeAt(" \187 ", 5, 5, fast and colours.red or colours.white, colours.grey)
		
	-- Timers:
	elseif myEvent[1] == "timer" then
		
		-- Explosion animation timer:
		if exploding and myEvent[2] == exploding[3] then
			exploding[4] = exploding[4] + 1

			-- Finished exploding, replace pipe:
			if exploding[4] > 3 then
				local x, y = exploding[1], exploding[2]
				grid[y][x] = table.remove(next, 1)
				next[5], exploding, score = math.random(7), false, score > 49 and (score - 50) or 0
				for i = 1, 5 do drawTile(img[next[i]], 9, 49 - i * 6) end
				drawTile(img[grid[y][x]], (x - 1) * 6 + 23, (y - 1) * 6 + 7)
				writeAt(zeroes(score, 7), 27, 18, colours.white, colours.grey)

			-- Continue exploding animation:
			else
				exploding[3] = os.startTimer(0.4)
				drawTile(img[8 + exploding[4]], (exploding[1] - 1) * 6 + 23, (exploding[2] - 1) * 6 + 7)
			end

		-- Flooz timer:
		elseif myEvent[2] == floozTimer then
			
			-- Flooz hasn't started yet, update progress bar to the right:
			if curDelay > 0 then
				local top = 35 - math.floor(curDelay / delay * 35)
				curDelay = fast and 0 or (curDelay - 0.5)
				local bottom = 35 - math.floor(curDelay / delay * 35)
				
				mon.setBackgroundColour(colours.black)
				for i = top, bottom do
					mon.setCursorPos(93, i + 10)
					mon.write("  ")
				end
				
				floozTimer = os.startTimer(fast and 0 or 0.5)
				
			-- Flooz is moving:
			else
				subX, subY = subX + dirBumpX, subY + dirBumpY
				
				local pipeType = grid[curY][curX]
				
				if subX == 2 and subY == 2 then
					
					-- Middle of a corner changes direction:
					if pipeType > 3 and pipeType < 8 then
						direction = direction + ((pipeType + direction) % 2 == 1 and (-1) or 1)
						if direction > 4 then direction = 1 elseif direction < 1 then direction = 4 end
						dirBumpX, dirBumpY = dirTemplate[direction][1], dirTemplate[direction][2]

						drawFlooz(pipeType)
						
					-- Middle of a junction gives a bonus:
					else
						if pipeType > 8 then
							score = score + 500
							writeAt(zeroes(score, 7), 27, 18, colours.white, colours.grey)
						end

						drawFlooz()
					end
					
				-- Jump to a new pipe tile:
				elseif subX < 1 or subX > 3 or subY < 1 or subY > 3 then
					
					if pipeType < 8 then grid[curY][curX] = (pipeType == 1) and (direction % 2 == 0 and 9 or 10) or 8 end
					
					if pipeType ~= 8 then
						if distance > 0 then distance, score = distance - 1, score + (fast and 100 or 50) else score = score + (fast and 200 or 100) end
						writeAt(zeroes(score, 7), 27, 18, colours.white, colours.grey)
						writeAt(zeroes(distance, 2), 41, 18, colours.white, colours.grey)
					end
					
					-- Move success:
					if checkMovement() then
						drawFlooz()
					
					-- Flooz spilled!
					else
						-- Explode unused pipe:
						for y = 1, 7 do for x = 1, 10 do
							local thisPipe = grid[y][x]
							if thisPipe and thisPipe < 8 then
								for i = 1, 3 do
									drawTile(img[8 + i], (x - 1) * 6 + 23, (y - 1) * 6 + 7)
									sleep(0.1)
								end
								
								drawTile(img[8], (x - 1) * 6 + 23, (y - 1) * 6 + 7)
								score = score > 99 and (score - 100) or 0
								writeAt(zeroes(score, 7), 27, 18, colours.white, colours.grey)
							end
						end end
						
						-- Next level:
						if distance == 0 then
							writeAt(" LEVEL COMPLETE ", 18, 9, colours.yellow, colours.black)
							if not pressAnyKey() then break end
							level = level + 1
							newLevel()
							
						-- Game Over!
						else
							writeAt(" GAME OVER ", 21, 9, colours.red, colours.black)
							if not (pressAnyKey() and scoreboard(level, score)) then break end
							level, score = 1, 0
							newLevel()
						end
					end
					
				-- Regular mid-pipe movement:
				else drawFlooz() end
				
				floozTimer = os.startTimer(fast and 0.1 or 1)
			end
		end
	
	-- Bail:
	elseif (clickedAt(xSize, 1) or pressedKey(keys.x, keys.q) or myEvent[1] == "terminate") and not kiosk then
		if myEvent[1] == "key" then os.pullEvent("char") end
		break
	end
end

term.setBackgroundColour(colours.black)
term.clear()
writeAt("Thanks for playing Pipe Mania!", 1 , 1, colours.white)
term.setCursorPos(1, 3)