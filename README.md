# milky
A UI library for Love2D, inspired by Unity game engine

## Examples
#### Loading the library
```lua
local milky = require "milky"
```
#### Spawning and drawing a picture
```lua
function love.init()
  local image_to_draw = love.graphics.newImage("my_image_path.png")
  our_image = milky.panel:new(milky, nil, nil, image_to_draw) -- creates a UI widget that uses image_to_draw for its appearance
    :size(300, 300) -- remember to resize the widget, otherwise the image wont be visible as the default size is 0, 0
end

function love.draw()
  our_image:draw() -- draw the image
end
```

#### Spawning and drawing a text widget
```lua
function love.init()
  our_text_widget = milky.panel:new(milky, nil, "Some text to render", nil)
    :size(300, 300)
end

function love.draw()
  our_text_widget:draw() -- draw the image
end
```

#### Spawning and drawing a panel under a canvas
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
