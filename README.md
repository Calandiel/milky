# milky
A UI library for Love2D, inspired by Unity game engine

## Examples
#### Loading the library
```lua
local milky = require "milky"
```
#### Spawning and drawing a panel
```lua
function love.init()
  main_canvas = milky.panel:new(milky, nil, nil, nil) -- an empty, parentless panel - serves as a conceptual equivalent of Unity's canvas
    :size(1920, 1080) -- assuming screen resolution of 1920 x 1080
  local some_text = milky.panel:new(milky, main_canvas, "This is a text panel", nil) -- create a panel with main_canvas as its parent, it'll render "This is a text panel" at its position when main_canvas is drawn
    :size(300, 300)
end

function love.draw()
  main_canvas:draw() -- draw our ui - it also recursively calls draw on all its children
end
```
Note that while main_canvas wasnt necessary -- we could have drawn some_text directly -- it's recommended you use them as empty containers for all your ui widgets. This is conceptually similar to Unity's canvas and layout groups, and it simplifies UI code.
