-- modified to not update the screen every tick

-- Strafe version 1.0 by CrazedProgrammer
-- This program needs the Surface API 1.5.3 in the strafedata directory.
-- If the Surface API 1.5.3 doesn't exist it will try to download it.
-- You can find info and documentation on these pages:
--
-- You may use this in your ComputerCraft OSes and modify it without asking.
-- However, you may not publish this program under your name without asking me.
-- If you have any suggestions, bug reports or questions then please send an email to:
-- crazedprogrammer@gmail.com

function split(pString, pPattern)
  local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pPattern
  local last_end = 1
  local s, e, cap = pString:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(Table,cap)
    end
    last_end = e+1
    s, e, cap = pString:find(fpat, last_end)
  end
  if last_end <= #pString then
    cap = pString:sub(last_end)
    table.insert(Table, cap)
  end
  return Table
end

function install(game)
  if not fs.isDir(dir.."strafedata/"..game) then
    fs.delete(dir.."strafedata/"..game)
    fs.makeDir(dir.."strafedata/"..game)
  end
  local _d = shell.dir()
  local i = split(online[game].install, "|")
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
  term.setCursorPos(1, 1)
  term.clear()
  shell.run("cd /"..dir.."strafedata/"..game)
  for k,v in pairs(i) do
    shell.run(({v:gsub("?", dir.."strafedata/"..game)})[1])
  end
  shell.run("cd /".._d)
  online[game].banner = online[game].banner:saveString()
  local f = fs.open(dir.."strafedata/"..game..".tab", "w")
  f.write(textutils.serialize(online[game]))
  f.close()
  online[game].banner = surface.loadString(online[game].banner)
  timer = os.startTimer(0)
  updateGames()
  updateOnline()
end

function updateGames()
  games = { }
  for k,v in pairs(fs.list(dir.."strafedata")) do
    if v:sub(#v - 3, #v) == ".tab" then
      local name = v:sub(1, #v - 4)
      local f = fs.open(dir.."strafedata/"..v, "r")
      games[name] = textutils.unserialize(f.readAll())
      games[name]["banner"] = surface.loadString(games[name]["banner"])
      f.close()
    end
  end
end

function updateOnline()
  http.request("http://pastebin.com/raw.php?i=m9YK1tke")
end

function updateSize()
  width, height = term.getSize()
  rows = math.floor((width - 1) / 25)
  offset = math.floor((width - rows * 25 + 1) / 2)
  surf = surface.create(width, height)
end

function update()
  draw()
end

function draw()
  surf:clear(nil, colors.white, colors.black)
  if state == 1 then
    drawGames()
  elseif state == 2 then
    drawOnline()
  end
  surf:drawLine(1, 1, width, 1, " ", colors.lightGray, colors.black)
  if width >= 43 then
    surf:drawText(1, 1, "Strafe")
    surf:drawText(9, 1, "Installed Games  Download Games", nil, colors.blue)
  else
    surf:drawText(1, 1, "Installed  Download", nil, colors.blue)
  end
  surf:drawPixel(width, 1, "X", colors.red, colors.white)
  surf:drawPixel(width, 2, "^")
  surf:drawPixel(width, height, "v")
  surf:render()
end

function drawGames()
  local i = 0
  for k,v in pairs(games) do
    surf:drawSurface((i % rows) * 25 + 1 + offset, math.floor(i / rows) * 6 + 3 - gamesOffset, v.banner)
    surf:drawText((i % rows) * 25 + 1 + offset, math.floor(i / rows) * 6 + 7 - gamesOffset, "Play Delete", colors.black, colors.white)
    i = i + 1
  end
end

function drawOnline()
  local i = 0
  for k,v in pairs(online) do
    surf:drawSurface((i % rows) * 25 + 1 + offset, math.floor(i / rows) * 6 + 3 - onlineOffset, v.banner)
    local str = "Download"
    if games[k] then
      if games[k].version == v.version then
        str = "Installed"
      else
        str = "Update"
      end
    end
    surf:drawText((i % rows) * 25 + 1 + offset, math.floor(i / rows) * 6 + 7 - onlineOffset, str, colors.black, colors.white)
    i = i + 1
  end
end

function onClick(x, y)
  if y == 1 then
    if x == width then
      term.setTextColor(colors.white)
      term.setBackgroundColor(colors.black)
      term.setCursorPos(1, 1)
      term.clear()
      running = false
    elseif width >= 43 then
      if x >= 9 and x <= 23 then
        updateGames()
        state = 1
      elseif x >= 26 and x <= 39 then
        updateOnline()
        state = 2
      end
    else
      if x >= 1 and x <= 9 then
        updateGames()
        state = 1
      elseif x >= 12 and x <= 19 then
        updateOnline()
        state = 2
      end
    end
  elseif x == width and y == 2 then
    if state == 1 and gamesOffset > 0 then
      gamesOffset = gamesOffset - 6
    elseif onlineOffset > 0 then
      onlineOffset = onlineOffset - 6
    end
  elseif x == width and y == height then
    if state == 1 then
      gamesOffset = gamesOffset + 6
    else
      onlineOffset = onlineOffset + 6
    end
  elseif y > 1 and state == 1 then
    local id = math.floor((y + gamesOffset - 2) / 6) * rows
    if x - offset + 1 <= rows * 25 then
      id = id + math.floor((x - offset) / 25)
    end
    local xx = (x - offset) % 25
    local yy = (y - 2) % 6
    local i = 0
    for k,v in pairs(games) do
      if id == i then
        if xx >= 1 and xx <= 4 and yy == 5 then
          local d = shell.dir()
          shell.run("cd /"..dir.."strafedata/"..k.."/"..v.launchdir)
          term.setTextColor(colors.white)
          term.setBackgroundColor(colors.black)
          term.setCursorPos(1, 1)
          term.clear()
          shell.run(v.launch)
          shell.run("cd /"..d)
          timer = os.startTimer(0)
          updateSize()
        elseif xx >= 6 and xx <= 11 and yy == 5 then
          fs.delete(dir.."strafedata/"..k)
          fs.delete(dir.."strafedata/"..k..".tab")
          updateGames()
        end
      end
      i = i + 1
    end
  elseif y > 1 and state == 2 then
    local id = math.floor((y + onlineOffset - 2) / 6) * rows
    if x - offset + 1 <= rows * 25 then
      id = id + math.floor((x - offset) / 25)
    end
    local xx = (x - offset) % 25
    local yy = (y - 2) % 6
    local i = 0
    for k,v in pairs(online) do
      if id == i then
        if xx >= 1 and xx <= 8 and yy == 5 and not games[k] then
          install(k)
        elseif xx >= 1 and xx <= 6 and yy == 5 and games[k] then
          if games[k].version ~= v.version then
            fs.delete(dir.."strafedata/"..k)
            fs.delete(dir.."strafedata/"..k..".tab")
            install(k)
          end
        end
      end
      i = i + 1
    end
  end
end

dir = fs.getDir(shell.getRunningProgram()).."/"
if not fs.isDir(dir.."strafedata") then
  fs.delete(dir.."strafedata")
  fs.makeDir(dir.."strafedata")
end
if not fs.exists(dir.."strafedata/surface") or fs.isDir(dir.."strafedata/surface") then
  fs.delete(dir.."strafedata/surface")
  local d = shell.dir()
  shell.run("cd /"..dir.."strafedata")
  shell.run("pastebin get J2Y288mW surface")
  shell.run("cd /"..d)
end
os.loadAPI(dir.."strafedata/surface")
updateSize()
local _off = math.floor(width / 2) surf:drawText(1, 1, "Made by CrazedProgrammer") local cp = surface.loadString("_00100010208f208f208f208f208f208f208f208f208f208f208f208f208f208f208f208f208f20ff20ff20ff20ff20ff20ff20ff20ff20ff20ff20ff20ff20ff20ff207f208f20ff20ff200f200f20ff200f200f20ff20ff20ff20ff20ff20ff20ff207f208f20ff200f20ff20ff20ff200f20ff200f20ff20ff20ff20ff20ff20ff207f208f20ff200f20ff20ff20ff200f200f20ff20ff20ff20ff20ff20ff20ff207f208f20ff200f20ff20ff20ff200f20ff20ff20ff20ff20ff20ff20ff20ff207f208f20ff20ff200f200f20ff200f20ff20ff20ff200f200f200f20ff20ff207f208f20ff20ff20ff20ff20ff20ff20ff20ff20ff20ff20ff20ff20ff20ff207f208f207f207f207f207f207f207f207f207f207f207f207f207f207f207f207f20_720_720_720_720_720_720_72077207720_720_720_720_720_720_720_720_720_720_720_720_720_7207720772077207720_720_720_720_720_720_720872087208720872087208720872087208720872087208720872087208720872087208720872087208720872087208720872087208720872087208720872077208720772077207720772077208720772077208720772077208720b72087207720872087208720872087208720872087208720872087208720872087208720772077207720772077207720772077207720772077207720772077207720772077") for i=1,16,1 do local surf2 = surface.create(i, i) surf2:drawSurfaceScaled(1, 1, i, i, cp) surf:fillRect(1, 2, width, height, nil, colors.black) surf:drawSurfaceRotated(_off, 10, i / 2, i / 2, 4 - i / 4, surf2) surf:render() os.sleep(0) end for i=1,4,1 do surf:fillRect(1, 2, width, height, nil, colors.black) surf:drawSurface(_off - 7, 3, cp) surf:drawLine(_off - 7, i * 4, _off + i * 4 - 11, 3, nil, colors.white) surf:drawLine(_off - 7, 1 + i * 4, _off + i * 4 - 10, 3, nil, colors.white) surf:drawLine(_off - 7, 2 + i * 4, _off + i * 4 - 9, 3, nil, colors.white) surf:render() os.sleep(0) end for i=1,4,1 do surf:fillRect(1, 2, width, height, nil, colors.black) surf:drawSurface(_off - 7, 3, cp) surf:drawLine(_off + i * 4 - 11, 18, _off + 8, i * 4, nil, colors.white) surf:drawLine(_off + i * 4 - 10, 18, _off + 8, 1 + i * 4, nil, colors.white) surf:drawLine(_off + i * 4 - 9, 18, _off + 8, 2 + i * 4, nil, colors.white) surf:render() os.sleep(0) end
games = { }
online = { }
updateGames()
state = 1
gamesOffset = 0
onlineOffset = 0
running = true
timer = os.startTimer(0)
while running do
  local e = {os.pullEvent()}
  if e[1] == "timer" and e[2] == timer then
    --timer = os.startTimer(0)
    update()
  elseif e[1] == "mouse_click" then
    onClick(e[3], e[4])
    timer = os.startTimer(0)
  elseif e[1] == "mouse_scroll"then
    if e[2] == -1 then
      if state == 1 and gamesOffset + e[2] * 6 >= 0 then
        gamesOffset = gamesOffset + e[2] * 6
      elseif state == 2 and onlineOffset > 0 then
        onlineOffset = onlineOffset + e[2] * 6
      end
    else
      if state == 1 then
        gamesOffset = gamesOffset + e[2] * 6
      else
        onlineOffset = onlineOffset + e[2] * 6
      end
    end
    timer = os.startTimer(0)
  elseif e[1] == "term_resize" then
    updateSize()
    timer = os.startTimer(0)
  elseif e[1] == "http_success" and e[2] == "http://pastebin.com/raw.php?i=m9YK1tke" then
    online = textutils.unserialize(e[3].readAll())
    e[3].close()
    for k,v in pairs(online) do
      v.banner = surface.loadString(v.banner)
    end
    timer = os.startTimer(0)
  end
end