FULL = 0
LEFT = 1
RIGHT = 2
TOP = 3
BOTTOM = 4
MIDDLE = 5


local utils = {}

utils.windowSnapTo = function(position)

  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()


  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h

  if position == LEFT then
    f.w = max.w / 2
  elseif position == RIGHT then
    f.w = max.w / 2
    f.x = max.x + max.w / 2
  elseif position == BOTTOM then
    f.h = max.h / 2
    f.y = max.y + max.h/2
  elseif position == TOP then
    f.h = max.h / 2
  elseif position == MIDDLE then
    
    local verticalBuffer = (1 - 0.7)/2 * max.h
    local horizontalBuffer = (1 - 0.7)/2 * max.w
    f.x = horizontalBuffer
    f.y = verticalBuffer
    f.w = max.w - (2 * horizontalBuffer)
    f.h = max.h - (2 * verticalBuffer)
  end
  win:setFrame(f)
end


hs.hotkey.bind({"cmd"}, "Left", function ()
  utils.windowSnapTo(LEFT)
end)

hs.hotkey.bind({"cmd"}, "Right", function ()
  utils.windowSnapTo(RIGHT)
end)

hs.hotkey.bind({"cmd"}, "Up", function ()
  utils.windowSnapTo(TOP)
end)

hs.hotkey.bind({"cmd"}, "Down", function ()
  utils.windowSnapTo(BOTTOM)
end)

hs.hotkey.bind({"cmd", "shift"}, "Up", function ()
  utils.windowSnapTo(FULL)
end)

hs.hotkey.bind({"cmd", "shift"}, "Down", function ()
  utils.windowSnapTo(MIDDLE)
end)

hs.hotkey.bind({"option"}, "q", function () 
  local alacritty = hs.application.find('alacritty')

  if alacritty == nil then
    alacritty = hs.execute("open /Applications/Alacritty.app")
    return
  end
  
  if alacritty:isFrontmost() then
    alacritty:hide()
  else
    hs.application.launchOrFocus("/Applications/Alacritty.app")
  end
end)


