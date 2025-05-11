--[[
  Breakout!! for CC
   By EldidiStroyrr
  get with:
   pastebin get LTRYaSKt breakout
   std pb LTRYaSKt breakout

	TODO
	-make cooler
--]]
local level = 1
local lives = 3
local bdepth = 5
local y_clip = 3
local x_clip = 5
local paused = false
local ballslow = 2 --divides ball speed by that
local rigged = false

local titlescreen = {{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,},{1,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,1,},{1,4,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,4,1,},{1,4,16384,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,16384,4,1,},{1,32768,32768,32768,16,16,32768,32768,32768,16,16,32768,32768,32768,32768,16,32768,32768,32768,32768,32768,16,32768,16,16,32768,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,2,16384,4,1,},{1,32768,16384,2,32768,32,32768,32,32,32768,32,32768,32,32,32,32,32768,32,32,32,32768,32,32768,32,32,32768,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,16,2,16384,4,1,},{1,32768,32768,32768,16,32,32768,32768,32768,8192,8192,32768,32768,8192,8192,8192,32768,32768,32768,32768,32768,8192,32768,32768,32768,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,32,16,2,16384,4,1,},{1,32768,16384,2,32768,32,32768,2048,2048,32768,2048,32768,2048,2048,2048,2048,32768,2048,2048,2048,32768,2048,32768,2048,2048,32768,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,8192,32,16,2,16384,4,1,},{1,32768,32768,32768,32768,32,32768,2048,1024,32768,1024,32768,32768,32768,32768,1024,32768,1024,1024,1024,32768,1024,32768,1024,1024,32768,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,2048,8192,32,16,2,16384,4,1,},{1,32768,32768,32768,16,32,32768,2048,1024,32768,1024,32768,32768,32768,32768,1024,32768,1024,1024,1024,32768,1024,32768,1024,1024,32768,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,2048,8192,32,16,2,16384,4,1,},{1,4,16384,2,16,32,8192,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,8192,32,16,2,16384,4,1,},{1,4,16384,2,16,32,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,32768,32768,32768,32768,32768,8192,32768,8192,8192,32768,8192,32768,32768,32768,32768,32768,8192,32768,32768,8192,32768,32768,8192,8192,32,16,2,16384,4,1,},{1,4,16384,2,16,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32768,32,32,32,32768,32,32768,32,32,32768,32,32,32,32768,32,32,32,32768,32768,32,32768,32768,32,32,32,16,2,16384,4,1,},{1,4,16384,2,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,32768,16,16,16,32768,16,32768,16,16,32768,16,16,16,32768,16,16,16,32768,32768,16,32768,32768,16,16,16,16,2,16384,4,1,},{1,4,16384,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,32768,2,2,2,32768,2,32768,2,2,32768,2,2,2,32768,2,2,2,32768,32768,2,32768,32768,2,2,2,2,2,16384,4,1,},{1,4,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,32768,32768,32768,32768,32768,16384,32768,32768,32768,32768,16384,16384,16384,32768,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384,4,1,},{1,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,32768,32768,32768,32768,32768,4,32768,32768,32768,32768,4,4,4,32768,4,4,4,32768,32768,4,32768,32768,4,4,4,4,4,4,4,1,},{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,},{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,},{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,},}

local prevColors = {
	term.getTextColor(),
	term.getBackgroundColor()
}

local scr_x, scr_y = term.getSize()
local board = {
	length = 8,
	x = math.floor(scr_x/2),
	y = scr_y-1,
	bgcolor = colors.white,
	txtcolor = colors.white,
	char = " ",
	dir = 0,
	canMove = true,
}
local ball = {
	x = math.floor(scr_x/2),
	y = scr_y-5,
	xv = 1,
	yv = -1,
	px = 1,
	py = 1,
	txtcolor = colors.white,
	bgcolor = colors.white,
	char = "O",
}
local sr = string.rep
local remakeBricks = function(xclip,yclip,depth)
	local output, entry = {}, 0
	local blitColors = "0123456789abcdef"
	for a = yclip, depth do
		for b = (xclip+1), scr_x-xclip do
			entry = entry + 1
			local d = math.random(1,15)
			local c = string.sub(blitColors,d,d)
			output[entry] = {x = b, y = a, color = {c,c},char="L"}
		end
	end
	return output
end
local cprint = function(msg,cy)
	term.setCursorPos((scr_x/2)-math.floor(#msg/2), cy or (scr_y/2))
	print(msg)
end
local waitForEvents = function(...)
        local targ = {...}
        while true do
                local evt = {os.pullEvent()}
                for a = 1, #targ do
                        if evt[1] == targ[a] then
                                return table.unpack(evt)
                        end
                end
        end
end
local titleScreen = function()
	paintutils.drawImage(titlescreen,1,1)
	sleep(0)
	return waitForEvents("key","mouse_click")
end
local clearLines = function(startY,endY)
	local ori = {term.getCursorPos()}
	for a = startY,endY do
		term.setCursorPos(1,a)
		term.clearLine()
	end
	term.setCursorPos(table.unpack(ori))
	return
end
local clearDot = function(x,y)
	local pX,pY = term.getCursorPos()
	term.setCursorPos(x,y)
	term.write(" ")
	term.setCursorPos(pX,pY)
end

local render = function(brd,blocktbl)
	term.setBackgroundColor(colors.black)
	term.setCursorPos(2,1)
	term.write("Lives: "..lives)
	local lvlcount = "Level: "..tostring(level)
	term.setCursorPos(scr_x-#lvlcount,1)
	term.write(lvlcount)
	term.setCursorPos(brd.x,brd.y)
	term.clearLine()
	term.setTextColor(brd.txtcolor)
	term.setBackgroundColor(brd.bgcolor)
	term.write(sr(brd.char,brd.length))
	for k,v in pairs(blocktbl) do
		term.setCursorPos(v.x,v.y)
		term.blit(v.char,v.color[1],v.color[2])
	end
	term.setCursorPos(ball.px,ball.py)
	term.blit(" ","f","f")
	term.setCursorPos(ball.x,ball.y)
	term.setTextColor(ball.txtcolor)
	term.setBackgroundColor(ball.bgcolor)
	term.write(ball.char)
end

local levelComplete = function()
	local txt = "LEVEL COMPLETE!"
	term.setTextColor(colors.gray)
	term.setCursorPos((scr_x/2)-(#txt/2),scr_y/2)
	term.write(txt)
	sleep(0.1)
	term.setTextColor(colors.lightGray)
	term.setCursorPos((scr_x/2)-(#txt/2),scr_y/2)
	term.write(txt)
	sleep(0.1)
	for a = 1, 8 do
		term.setTextColor(colors.white)
		term.setCursorPos((scr_x/2)-(#txt/2),scr_y/2)
		term.write(txt)
		sleep(0.3)
		term.setTextColor(colors.black)
		term.setCursorPos((scr_x/2)-(#txt/2),scr_y/2)
		term.write(txt)
		sleep(0.3)
	end
	sleep(0.3)
	blocks = remakeBricks(x_clip,y_clip,bdepth)
	lives = lives + 2
	level = level + 1
	board.x = math.floor((scr_x/2)-(board.length/2))
	ball.x = math.floor(scr_x/3)
	ball.y = board.y - 3
	ball.xv = 1
	ball.yv = -1
end

local checkCollision = function()
	local good = false
	for a = 1, #blocks do
		if blocks[a] then
			if blocks[a].x == ball.x + ball.xv and blocks[a].y == ball.y then
				ball.xv = -ball.xv
				clearDot(blocks[a].x,blocks[a].y)
				good = true
			end
			if blocks[a].y == ball.y + ball.yv and blocks[a].x == ball.x then
				ball.yv = -ball.yv
				clearDot(blocks[a].x,blocks[a].y)
				good = true
			end
			if good then
				table.remove(blocks,a)
				good = false
			end
		end
	end
end

local animateDeath = function()
	board.dir = 0
	local tbl = {
		{"*","7","0"},
		{"x","7","8"},
		{"X","f","8"},
		{"X","f","7"},
	}
	term.setBackgroundColor(colors.black)
	term.setCursorPos(ball.x,ball.y)
	term.write(" ")
	term.setCursorPos(1,board.y)
	term.clearLine()
	for a = 1, #tbl do
		term.setCursorPos(board.x,board.y)
		local char,txt,bg = tbl[a][1]:rep(board.length),tbl[a][2]:rep(board.length),tbl[a][3]:rep(board.length)
		term.blit(char,txt,bg)
		sleep(0.05)
	end
	term.setCursorPos(board.x,board.y)
	term.setBackgroundColor(colors.black)
	term.clearLine()
	sleep(0.5)
	board.x = (scr_x/2)-(board.length/2)
end

local animateGameOver = function()
	board.canMove = false
	animateDeath()
	local txt = "GAME OVER"
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.black)
	for a = 0, scr_y/2 do
		term.clearLine()
		term.setCursorPos((scr_x/2)-(#txt/2),scr_y-a)
		term.write(txt)
		sleep(0.1)
	end
	sleep(0.5)
	return
end

local togglePauseScreen = function(_paused)
	local txt = "PAUSED ('P' to unpause)"
	term.setBackgroundColor(colors.black)
	if _paused then
		term.setCursorPos((scr_x/2)-(#txt/2),scr_y/2)
		term.blit(txt,sr("7",#txt),sr("f",#txt))
		sleep(0.1)
		term.setCursorPos((scr_x/2)-(#txt/2),scr_y/2)
		term.blit(txt,sr("8",#txt),sr("f",#txt))
		sleep(0.1)
		term.setCursorPos((scr_x/2)-(#txt/2),scr_y/2)
		term.blit(txt,sr("0",#txt),sr("f",#txt))
		sleep(0.1)
	else
		term.setCursorPos((scr_x/2)-(#txt/2),scr_y/2)
		term.blit(txt,sr("8",#txt),sr("f",#txt))
		sleep(0.1)
		term.setCursorPos((scr_x/2)-(#txt/2),scr_y/2)
		term.blit(txt,sr("7",#txt),sr("f",#txt))
		sleep(0.1)
		term.setCursorPos((scr_x/2)-(#txt/2),scr_y/2)
		term.clearLine()
	end
end

local game = function()
	term.setBackgroundColor(colors.black)
	term.clear()
	blocks = remakeBricks(x_clip,y_clip,bdepth)
	local frame = 1
	while true do
		if not paused then
			ball.x = math.floor(ball.x)
			ball.y = math.floor(ball.y)
			if rigged then
				board.x = ball.x-math.floor(board.length/2)
			else
				board.x = board.x + board.dir
			end
			if frame % ballslow == 0 then
				if frame > 40000000 then
					frame = 100
				end
				if frame > 60 then
					ballslow = 1
				end
				if ball.x <= 1 or ball.x >= scr_x then
					ball.xv = ball.xv * -1
				end
				if ball.y <= 1 then
					ball.yv = -ball.yv
				elseif ball.y >= scr_y then
					if lives > 1 then
						board.canMove = false
						animateDeath()
						ball.x = scr_x/2
						ball.y = scr_y-8
						ball.xv = 1
						ball.yv = -1
						lives = lives - 1
						board.canMove = true
					else
						lives = lives - 1
						animateGameOver()
						return "lose"
					end
				end
				ball.px = ball.x
				ball.py = ball.y
				ball.y = math.floor(ball.y + ball.yv)
				term.setBackgroundColor(colors.black)
				checkCollision()
				ball.x = math.floor(ball.x + ball.xv)
				checkCollision()
				if #blocks == 0 then levelComplete() end
				if (ball.y+1 == board.y or ball.y == board.y) and (ball.x >= board.x and ball.x <= board.x+board.length) then
					ball.yv = -ball.yv
					if ball.x < board.x+(board.length/2)-1 then
						ball.xv = -1
					elseif ball.x > board.x+(board.length/2)+1 then
						ball.xv = 1
					end
				end
			end
			sleep(0)
			frame = frame + 1
			render(board,blocks)
		end
		sleep(0)
	end
end

local getInput = function()
	local event, key
	local downKeys = {left = false, right = false}
	while true do
		event, key, mx, my = os.pullEvent()
		if event == "key" then
			if board.canMove and not paused then
				if key == keys.left and board.x > 1 then
					board.dir = -1
					downKeys.left = true
				elseif key == keys.right and board.x < (scr_x+1)-board.length then
					board.dir = 1
					downKeys.right = true
				end
			else board.dir = 0 end
			if key == keys.q then return end
			if key == keys.p then
				if not paused then --this is to fix a rendering problem
					paused = true
					togglePauseScreen(true)
				else
					togglePauseScreen(false)
					paused = false
				end
			end
		elseif event == "key_up" then
			if key == keys.left then
				downKeys.left = false
			elseif key == keys.right then
				downKeys.right = false
			end
			if (downKeys.left == false and downKeys.right == false) or (board.x <= 1 or board.x-board.length >= scr_x) then
				board.dir = 0
			end
		elseif event == "mouse_click" or event == "mouse_drag" then
			if board.canMove and not paused then
				board.x = mx-(board.length/2)
			end
		end
		if board.x < 1 then board.x = 1 board.dir = 0
		elseif board.x > (scr_x+1)-board.length then board.x = (scr_x+1)-board.length board.dir = 0 end
	end
end

local outro = function(txtcolor,bgcolor,result)
	term.setTextColor(txtcolor)
	term.setBackgroundColor(bgcolor)
	term.clear()
	term.setCursorPos(1,1)
	print("Thanks for playing!")
	return result
end

titleScreen()
local startFuncs = {
	game,
	getInput,
}
parallel.waitForAny(table.unpack(startFuncs))
outro(prevColors[1],prevColors[2])
sleep(0)