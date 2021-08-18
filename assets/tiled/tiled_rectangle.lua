Tiled_Shape_Rectangle = Core.class(Sprite)

function Tiled_Shape_Rectangle:init(xworld, xparams, xlevelscale)
	-- params
	local params = xparams or {}
	params.x = xparams.x or nil
	params.y = xparams.y or nil
	params.w = xparams.w or nil
	params.h = xparams.h or nil
	params.color = xparams.color or nil
	params.alpha = xparams.alpha or 1
	params.texpath = xparams.texpath or nil
	params.isdeco = xparams.isdeco or not (xparams.isdeco == nil) -- default = false
	params.isshape = xparams.isshape or nil
	params.shapelinewidth = xparams.shapelinewidth or 0
	params.shapelinecolor = xparams.shapelinecolor or nil
	params.shapelinealpha = xparams.shapelinealpha or 1
	params.isbmp = xparams.isbmp or nil
	params.ispixel = xparams.ispixel or nil
	params.scalex = xparams.scalex or 1
	params.scaley = xparams.scaley or params.scalex
	params.rotation = xparams.rotation or nil
	params.type = xparams.type or nil -- default = b2.STATIC_BODY
	params.fixedrotation = xparams.fixedrotation or nil
	params.density = xparams.density or nil
	params.restitution = xparams.restitution or nil
	params.friction = xparams.friction or nil
	params.gravityscale = xparams.gravityscale or 1
	params.BIT = xparams.BIT or nil
	params.COLBIT = xparams.COLBIT or nil
	params.NAME = xparams.NAME or nil
	-- level scaling
	self.levelscale = xlevelscale or 1
	-- the world
	self.world = xworld
	-- the others
	self.w = params.w
	self.h = params.h
	self.rotation = params.rotation
	self.BIT = params.BIT
	self.COLBIT = params.COLBIT
	-- image
	if params.BIT == G_BITSENSOR and not params.tex and not params.isshape and not params.isbmp then
		-- no image for sensors
	else
		if params.isshape then
			self.img = Shape.new()
			self.img:setLineStyle(params.shapelinewidth, params.shapelinecolor, params.shapelinealpha) -- (width, color, alpha)
			if params.texpath then
				local tex = Texture.new(params.texpath, false, {wrap = Texture.REPEAT})
				local matrix = Matrix.new(params.scalex, 0, 0, params.scaley, 0, 0)
				self.img:setFillStyle(Shape.TEXTURE, tex, matrix)
				tex = nil
			elseif params.color then
				self.img:setFillStyle(Shape.SOLID, params.color)
			else
				self.img:setFillStyle(Shape.NONE)
			end
			self.img:beginPath()
			self.img:moveTo(0, 0)
			self.img:lineTo(params.w * self.levelscale, 0)
			self.img:lineTo(params.w * self.levelscale, params.h * self.levelscale)
			self.img:lineTo(0, params.h * self.levelscale)
			self.img:lineTo(0, 0)
			self.img:endPath()
			self.img:setRotation(params.rotation)
			self.img:setAlpha(params.alpha)
		end
		if params.isbmp then
			if not params.texpath then print("!!!YOU MUST PROVIDE A TEXTURE FOR THE BITMAP!!!") return end
			local tex = Texture.new(params.texpath, false)
			self.img = Bitmap.new(tex)
			self.img.isbmp = true
			self.img.w, self.img.h = params.w, params.h
			if params.rotation < 0 then self.img:setAnchorPoint(0, 0.5) end
--			if params.rotation > 0 then self.img:setAnchorPoint(0, 0.5) end
			self.img:setScale(params.scalex, params.scaley)
			self.img:setRotation(params.rotation)
			self.img:setAlpha(params.alpha)
			tex = nil
		end
		if params.ispixel then
			if params.texpath then
				local tex = Texture.new(params.texpath, false, {wrap = TextureBase.REPEAT})
				self.img = Pixel.new(tex, params.w, params.h)
				self.img.ispixel = true
				self.img.w, self.img.h = params.w, params.h
				self.img:setScale(params.scalex, params.scaley)
				if params.rotation < 0 then self.img:setAnchorPoint(0, -0.5) end
				if params.rotation > 0 then self.img:setAnchorPoint(0, 0.5) end
				self.img:setRotation(params.rotation)
				self.img:setAlpha(params.alpha)
				tex = nil
			else
				self.img = Pixel.new(params.color, 1, params.w, params.h)
				self.img.ispixel = true
				self.img.w, self.img.h = params.w, params.h
				self.img:setScale(params.scalex, params.scaley)
				self.img:setRotation(params.rotation)
				self.img:setAlpha(params.alpha)
			end
		end
		-- debug
		if self.img then
			if xworld.isdebug then self.img:setAlpha(0.5) end
			self:addChild(self.img)
		end
	end
	if not params.isdeco then
		-- body
		self.body = xworld:createBody { type = params.type } -- b2.STATIC_BODY, b2.KINEMATIC_BODY, b2.DYNAMIC_BODY
		self.body:setGravityScale(params.gravityscale)
		self.body.name = params.NAME
		self.body.isdirty = false
		self.body:setFixedRotation(params.fixedrotation)
		self.body:setAngle(^<params.rotation)
		-- the main shape
		local shape = b2.PolygonShape.new()
		shape:setAsBox(
			params.w * self.levelscale / 2, params.h * self.levelscale / 2, -- half w, half h
			params.w * self.levelscale / 2, params.h * self.levelscale / 2, -- centerx, centery
			0) -- rotation
		local fixture = self.body:createFixture {
			shape = shape,
			density = params.density, restitution = params.restitution, friction = params.friction
		}
		-- filter data
		if params.BIT == G_BITSENSOR then fixture:setSensor(true) end
		local filterData = { categoryBits = params.BIT, maskBits = params.COLBIT, groupIndex = 0 }
		fixture:setFilterData(filterData)
		-- clean up?
		filterData = nil
		fixture = nil
		shape = nil
	end
	-- sensors
	if params.NAME == G_EXIT then self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
end

function Tiled_Shape_Rectangle:onEnterFrame()
	if self.body then
		if self.body.isdirty then
			self.world:destroyBody(self.body)
			self:getParent():removeChild(self)
			if self.body.name == G_EXIT then
				g_currentlevel += 1
				if g_currentlevel > #tiled_levels then g_currentlevel = 1 end
				self:reload()
			end
			self.body = nil
		end
	end
end

function Tiled_Shape_Rectangle:setPosition(xposx, xposy)
	if self.body then
		self.body:setPosition(xposx * self.levelscale, xposy * self.levelscale)
		if self.img then self.img:setPosition(self.body:getPosition()) end
	else
		if self.img then self.img:setPosition(xposx * self.levelscale, xposy * self.levelscale) end
	end
end

function Tiled_Shape_Rectangle:reload()
	scenemanager:changeScene("levelX", 5, transitions[1], easings[1])
end
