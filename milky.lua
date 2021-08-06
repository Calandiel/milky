-- UI library uwu

-- Package table
-- These are kept for package internals, consider them private for all intentions and purposes
milky = {}
milky.panel = {}
milky.next_id = 0

milky.buttons = {}
milky.tooltips = {}

-- Creates a new panel
function milky.panel:new(milky, parent, label, image)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.id = milky.next_id
	milky.next_id = milky.next_id + 1

	o.button_callback = nil
	o.skin_texture_name = nil
	o.active = true
	o.label = label
	o.image = image
	o.quads = {}
	o.bor = {0, 0, 0, 0}
	o.bor[0] = 0
	if image then
		o.sprite_batch = love.graphics.newSpriteBatch(image, 9, "dynamic")
		o.sprite_batch:add(love.graphics.newQuad(0, 0, image:getWidth(), image:getHeight(), image:getDimensions()))
	end

	o.children = {}
	o.active_children = {}

	if parent then
		o.parent = parent
		o.parent.children[o.id] = o
		o.parent.active_children[o.id] = o
	end

	-- SETTING UP THE RECT
	-- Rect uses absolute screen position
	o.rect = {}
	o.rect.screen_space_x = 0
	o.rect.screen_space_y = 0

	o.rect.x = 0
	o.rect.y = 0
	o.rect.height = 0
	o.rect.width = 0
	o.rect.draw_scale_x = 1
	o.rect.draw_scale_y = 1

	o.rect.pivot_x = 0
	o.rect.pivot_y = 0

	o.rect.anchor_x = 0
	o.rect.anchor_y = 0

	o.rect.stretch_x = false
	o.rect.stretch_y = false

	return o
end
-- Destroys a panel tree recursively
function milky.panel:destroy(milky)
	milky.buttons[self.id] = nil
	milky.tooltips[self.id] = nil

	if self.parent then
		self.parent.children[self.id] = nil
		self.parent.active_children[self.id] = nil
	end
end
-- Draws the panel
function milky.panel:draw()
	local r = self.rect
	if self.sprite_batch then
		--love.graphics.draw(self.image, r.screen_space_x, r.screen_space_y, 0, r.draw_scale_x, r.draw_scale_y)
		love.graphics.draw(self.sprite_batch, r.screen_space_x, r.screen_space_y, 0, r.draw_scale_x, r.draw_scale_y)
	end
	if self.label then love.graphics.print(self.label, self.rect.screen_space_x, self.rect.screen_space_y) end
	for j,k in pairs(self.active_children) do
		k:draw()
	end
end
-- Stops/resumes rendering of a panel
-- Has no effect is panel doesn't have a parent
function milky.panel:setActive(is_active)
	self.active = is_active
	if self.parent then
		if is_active then
			self.parent.active_children[self.id] = self
		else
			self.parent.active_children[self.id] = nil
		end
	end

	return self
end
-- Updates screen_space_x,screen_space_y based on x,y,parent,pivot,width,height
-- Shouldn't be used by the end user
function milky.panel:refresh_rect()
	local rect = self.rect
	local parent_x = 0
	local parent_y = 0
	local parent_width = 0
	local parent_height = 0
	if self.parent then
		parent_x = self.parent.rect.screen_space_x
		parent_y = self.parent.rect.screen_space_y
		parent_width = self.parent.rect.width
		parent_height = self.parent.rect.height
	else
		parent_width = 0
		parent_height = 0
	end
	parent_x = parent_x + parent_width * rect.anchor_x
	parent_y = parent_y + parent_height * rect.anchor_y

	local origin_x = parent_x + rect.x
	local origin_y = parent_y + rect.y

	if not rect.stretch_x then
		rect.screen_space_x = origin_x - rect.pivot_x * rect.width
	else
		rect.screen_space_x = parent_x
		rect.width = parent_width
	end
	if not rect.stretch_y then
		rect.screen_space_y = origin_y - rect.pivot_y * rect.height
	else
		rect.screen_space_y = parent_y
		rect.height = parent_height
	end

	if self.image then
		self.rect.draw_scale_x = self.rect.width / self.image:getWidth()
		self.rect.draw_scale_y = self.rect.height / self.image:getHeight()
	end

	if self.image then
		self.sprite_batch:clear()

		--local im_x = self.image:getWidth()
		--local im_y = self.image:getHeight()
		local im_x = self.image:getWidth()
		local im_y = self.image:getHeight()

		local global_scale = self.bor[0]
		local scale_x = self.rect.draw_scale_x / global_scale
		local scale_y = self.rect.draw_scale_y / global_scale

		local left = self.bor[1] / scale_x
		local top = self.bor[2] / scale_y
		local right = self.bor[3] / scale_x
		local bottom = self.bor[4] / scale_y

		local s_im_x = im_x / scale_x
		local s_im_y = im_y / scale_y

		-- Positions of generated quads
		local center_pos = left
		local middle_pos = top
		local right_pos = (im_x - right)
		local bottom_pos = (im_y - bottom)

		local center_width = im_x - left - right
		local center_height = im_y - top - bottom

		local left_uns = self.bor[1]
		local top_uns = self.bor[2]
		local right_uns = self.bor[3]
		local bottom_uns = self.bor[4]

		local center_s_x = center_width / (im_x - left_uns - right_uns)
		local center_s_y = center_height / (im_y - top_uns - bottom_uns)

		local c_x = im_x * center_s_x
		local c_y = im_y * center_s_y

		--self.sprite_batch:add(love.graphics.newQuad(0, 0, image:getWidth(), image:getHeight(), image:getDimensions()))
		-- top left
		if top > 0 then
			if left > 0 then
				self.sprite_batch:add(love.graphics.newQuad(0, 0, left, top, s_im_x, s_im_y), 0, 0)
			end
			-- top center
			self.sprite_batch:add(love.graphics.newQuad(left_uns * center_s_x, 0, center_width, top, c_x, s_im_y), center_pos, 0)
			if right > 0 then
				-- top right
				self.sprite_batch:add(love.graphics.newQuad(s_im_x - left, 0, right, top, s_im_x, s_im_y), right_pos, 0)
			end
		end
		if left > 0 then
			-- middle left
			self.sprite_batch:add(love.graphics.newQuad(0, top_uns * center_s_y, left, center_height, s_im_x, c_y), 0, middle_pos)
		end
		-- middle center
		self.sprite_batch:add(love.graphics.newQuad(left_uns * center_s_x, top_uns * center_s_y, center_width, center_height, c_x, c_y), center_pos, middle_pos)
		if right > 0 then
			-- middle right
			self.sprite_batch:add(love.graphics.newQuad(s_im_x - left, top_uns * center_s_y, right, center_height, s_im_x, c_y), right_pos, middle_pos)
		end

		if bottom > 0 then
			if left > 0 then
				-- bottom left
				self.sprite_batch:add(love.graphics.newQuad(0, s_im_y - bottom, left, bottom, s_im_x, s_im_y), 0, bottom_pos)
			end
			-- bottom center
			self.sprite_batch:add(love.graphics.newQuad(left_uns * center_s_x, s_im_y - bottom, center_width, bottom, c_x, s_im_y), center_pos, bottom_pos)
			if right > 0 then
				-- bottom right
				self.sprite_batch:add(love.graphics.newQuad(s_im_x - left, s_im_y - bottom, right, bottom, s_im_x, s_im_y), right_pos, bottom_pos)
			end
		end
	end

	for i,j in pairs(self.children) do
		j:refresh_rect()
	end
end
-- Moves the panel, taking its parent and children into account
-- Position is relative to the parent
function milky.panel:position(new_x, new_y)
	self.rect.x = new_x
	self.rect.y = new_y
	self:refresh_rect()

	return self
end
-- Resizes the panel, taking its parent and children into account
-- Inputs in pixels
function milky.panel:size(new_width, new_height)
	self.rect.width = new_width
	self.rect.height = new_height
	self:refresh_rect()

	return self
end
-- The normalized (relative to its parent) position that defines the origin point of this panel
-- Inputs should generally be kept in range (0-1)
function milky.panel:pivot(x, y)
	self.rect.pivot_x = x
	self.rect.pivot_y = y
	self:refresh_rect()

	return self
end
-- Inputs must be kept in range (0-1).
function milky.panel:anchor(x, y)
	self.rect.anchor_x = x
	self.rect.anchor_y = y
	self:refresh_rect()

	return self
end
-- Inputs must be kept in range (0 - 1)
function milky.panel:orientation(x, y)
	self:anchor(x, y)
	self:pivot(x, y)

	return self
end
function milky.panel:update_label(label)
	self.label = label
end
-- Inputs are booleans
-- Stretching doesn't work if there is no parent!
function milky.panel:stretch(x, y)
	self.rect.stretch_x = x
	self.rect.stretch_y = y
	self:refresh_rect()

	return self
end
-- Inputs are in pixels
function milky.panel:border(left, top, right, bottom, border_scale)
	self.bor[1] = left
	self.bor[2] = top
	self.bor[3] = right
	self.bor[4] = bottom
	if not border_scale then border_scale = 1 end
	self.bor[0] = border_scale

	self:refresh_rect(true)

	return self
end
-- Sets panels parent.
-- If there is a parent, it first correctly removes it from its children
function milky.panel:setParent(parent)
	if self.parent then
		self.parent.children[self.id] = nil
		self.parent.active_children[self.id] = nil
	end
	self.parent = parent
	if parent then
		self.parent.children[self.id] = self
		if self.active then
			self.parent.active_children[self.id] = self
		end
	end
	self:refresh_rect()

	return self
end
-- Creates a parentless copy of this object
function milky.panel:copy(milky)
	local c = milky.panel:new(milky, self.parent, self.label, self.image)
		:pivot(self.rect.pivot_x, self.rect.pivot_y)
		:anchor(self.rect.anchor_x, self.rect.anchor_y)
		:size(self.rect.width, self.rect.height)
		:position(self.rect.x, self.rect.y)
		:border(self.bor[1], self.bor[2], self.bor[3], self.bor[4], self.bor[0])
		:setActive(self.active)
		:stretch(self.rect.stretch_x, self.rect.stretch_y)
	c.skin_texture_name = self.skin_texture_name
	return c
end
-- Creates a copy of the entire panel tree
function milky.panel:deepcopy(milky)
	local c = self:copy(milky)
	for i,j in pairs(self.children) do
		local cc = j:deepcopy(milky)
		cc:setParent(c)
	end
	return c
end
-- Sets skin of this panel
-- skin <- a table with strings as keys and images as values
-- texture_name <- a string
function milky.panel:skin(skin, texture_name)
	self.skin_texture_name = texture_name
	self:reskin(skin)
	return self
end
-- Changes skin of the panel
-- skin <- a table with strings as keys and images as values
function milky.panel:reskin(skin)
	if self.skin_texture_name then
		if skin[self.skin_texture_name] then
			sote.native.Log("BB")
			self.image = skin[self.skin_texture_name]
			self.sprite_batch = love.graphics.newSpriteBatch(self.image, 9, "dynamic")
		else
			error("SKIN DOESNT CONTAIN A TEXTURE: " .. self.skin_texture_name)
		end
	end
	self:refresh_rect()
	for i,j in pairs(self.children) do
		j:reskin(skin)
	end
	return self
end

function milky.panel:button(milky, callback)
	self.button_callback = callback

	if not self.button_callback then
		milky.buttons[self.id] = nil
	else
		milky.buttons[self.id] = self
	end

	return self
end

-- Processes button callbacks
-- mouse_x and mouse_y are in scaled screen pixels
function milky:onClick(mouse_x, mouse_y, button)

	for i,j in pairs(self.buttons) do
		-- Check if we're in bounds, if we are, execute callback
		local x_min = j.rect.screen_space_x
		local y_min = j.rect.screen_space_y
		local x_max = x_min + j.rect.width
		local y_max = y_min + j.rect.height

		if mouse_x > x_min and mouse_x < x_max then
			if mouse_y > y_min and mouse_y < y_max then
				j:button_callback(button)
			end
		end
	end

end


return milky
