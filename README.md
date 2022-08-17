# milky
An immediate mode UI library for Love2D, used by Songs of The Eons.
It uses EmmyLua notation on most of its functions so it's recommended you use an IDE with a plugin that supports it.

## Basic usage
### Loading the library
```lua
local milky = require "milky"
```
### Necessary setup
Milky needs to be passed all inputs and have draw frames finalized, like this:
```lua
function love.init()
	local font_size = milky.font_size(12)
	local font_to_use = love.graphics.newFont("font/to/path.otf", font_size)
	love.graphics.setFont(font_to_use)
end

function love.draw()
	-- At the end of love.draw:
	milky.finalize_frame()
end

function love.keypressed(key)
	ui.on_keypressed(key)
end

function love.keyreleased(key)
	ui.on_keyreleased(key)
end

function love.mousepressed(x, y, button, istouch, presses)
	ui.on_mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
	ui.on_mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
	ui.on_mousemoved(x, y, dx, dy, istouch)
end

function love.wheelmoved(x, y)
	ui.on_wheelmoved(x, y)
end
```
### Drawing a picture
```lua
function love.init()
 	IMAGE_TO_DRAW = love.graphics.newImage("my_image_path.png")
end

function love.draw()
	local rect = milky.rect(x_position, y_position, width, height)
	milky.image(IMAGE_TO_DRAW, rect)
	milky.finalize_frame()
end
```
### Drawing text
A simple text panel:
```lua
function love.draw()
	local rect = milky.rect(x_position, y_position, width, height)
	milky.text_pane("Text to draw", rect)
end
```
Just text, with custom align modes:
```lua
milky.text("Text to draw", rect, "center", "center")
```
The last and second to last arguments take in "align modes", similar to those from Love2D.
There are simpler functions you can use instead of you often rely on left/right/centered text rendering:
```lua
milky.centered_text("Text to draw", rect)
milky.left_text("Text to draw", rect)
milky.right_text("Text to draw", rect)
```
### Backgrounds
```lua
function love.draw()
	milky.background(background_image)
end
```
### Panels
```lua
function love.draw()
	milky.panel(rect)	
end
```
### Tooltips
Things like buttons can take in tooltips as arguments, but you can also create a standalone tooltip zone:
```lua
milky.tooltip("Tooltip text", rect)
```
### Buttons
```lua
if milky.icon_button(image, rect, "tooltip text or nil/skipped") then
	-- do stuff when the button is pressed
end
if milky.text_button("text to draw on the button", rect, "tooltip text or nil/skipped") then
	-- do stuff when the button is pressed
end
if milky.invisible_button(rect) then
	-- do stuff when the button is pressed
end
```
### On hover / triggers
```lua
if milky.trigger(rect) then
	-- This code will be executed if mouse is within the provided rect
	-- Functionally, it operates similar to OnHover in many feature rich engines.
end
```
### On click
Milky doesn't provide separate on click entries on most widgets in order to keep the API simple but it can easily be added with the exposed UI primitives:
```lua
milky.image(image, rect)
if milky.invisible_button(rect) then
	-- this will be executed if the above image is clicked (because it uses the same rect as the invisible button)
end
```
In most cases, it's suggested to instead rely on buttons. If you need custom behaviour, it's suggested you wrap these constructs in higher level function.
### Input
Milky tracks key presses and mouse movements to expose a (hopefully) simpler API for dealing with Love's input events:
```lua
milky.is_key_pressed(key)
milky.is_key_held(key)
milky.is_key_released(key)
milky.is_mouse_pressed(button)
milky.is_mouse_held(button)
milky.is_mouse_released(button)
```
`key` and `button` follow Love's KeyConstant and mouse button id's.
There are also functions for dealing with mouse in more detail:
```lua
local x, y = milky.mouse_position()
local delta = milky.mouse_wheel()
local x, y = milky.mouse_press_position(button) -- nil if there is no press
```
## Advanced usage
### Reading and setting reference resolution
```lua
local width, height = milky.get_reference_screen_dimensions()
milky.get_reference_screen_dimensions(width, height)
```
If you change reference resolution remember to also reload the font using `milky.font_size` to get the right size.
### Hot loading
Hot loading milky naively will likely result in dangling nils. You can cache library state as follows:
```lua
local cache =milky.ui.cache_input_state()
hotload()
(require "milky").load_input_state_from_cache(cache)
```
## Undocumented
- rect manipulation
- sliders
- checkboxes
- scrollviews
- layouts
- graphs
