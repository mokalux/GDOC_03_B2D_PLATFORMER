Tiled_Shape_Ellipse = Core.class(Sprite)

function Tiled_Shape_Ellipse:init(xworld, xparams, xlevelscale)
	-- params
	local params = xparams or {}
	params.x = xparams.x or nil
	params.y = xparams.y or nil
	params.w = xparams.w or 32
	params.h = xparams.h or 32
	params.steps = xparams.steps or 16 -- 24
	params.color = xparams.color or nil
	params.texpath = xparams.texpath or nil
	params.isdeco = xparams.isdeco or not (xparams.isdeco == nil) -- default = false
	params.isshape = xparams.isshape or nil
	params.shapelinewidth = xparams.shapelinewidth or nil
	params.shapelinecolor = xparams.shapelinecolor or nil
	params.shapelinealpha = xparams.shapelinealpha or 1
	params.isbmp = xparams.isbmp or nil
	params.ispixel = xparams.ispixel or nil
	params.scalex = xparams.scalex or 1
	params.scaley = xparams.scaley or params.scalex
	params.rotation = xparams.rotation or 0
	params.type = xparams.type or nil -- default = b2.STATIC_BODY
	params.fixedrotation = xparams.fixedrotation or nil
	params.density = xparams.density or 0
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
	-- image
--	if params.issensor then
	if params.BIT == G_BITSENSOR and not params.tex and not params.isshape and not params.isbmp then
		-- no image for sensors
	else
		local sin, cos, d2r = math.sin, math.cos, math.pi / 180
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
			for i = 0, 360, 360 / params.steps  do
				self.img:lineTo(
					(params.w * self.levelscale / 2) + params.w * self.levelscale / 2 * cos(i * d2r),
					(params.h * self.levelscale / 2) + params.h * self.levelscale / 2 * sin(i * d2r)
				)
			end
			self.img:endPath()
			self.img:setRotation(params.rotation)
		end
		if params.isbmp then
			if not params.texpath then print("!!!YOU MUST PROVIDE A TEXTURE FOR THE BITMAP!!!") return end
			local tex = Texture.new(params.texpath, false)
			self.img = Bitmap.new(tex)
			self.img:setAnchorPoint(0.5, 0.5)
			self.img:setScale(params.scalex, params.scaley)
			self.img:setRotation(params.rotation)
			params.w, params.h = self.img:getWidth(), self.img:getHeight()
--			print("bmp", params.w, params.h, params.rotation)
			tex = nil
		end
		if params.ispixel then
			if params.texpath then
				local tex = Texture.new(params.texpath, false, {wrap = TextureBase.REPEAT})
				self.img = Pixel.new(tex, params.w, params.h)
				self.img.ispixel = true
--				self.img.w, self.img.h = params.w, params.h
				self.img:setScale(params.scalex, params.scaley)
				self.img:setRotation(params.rotation)
--				print("pixel", params.w, params.h, params.rotation)
				tex = nil
			else
				self.img = Pixel.new(0xff0000, 1, params.w, params.h)
				self.img.ispixel = true
--				self.img.w, self.img.h = params.w, params.h
				self.img:setScale(params.scalex, params.scaley)
				self.img:setRotation(params.rotation)
--				print("pixel", params.w, params.h, params.rotation)
			end
		end
		-- debug
		if self.img then
			if self.world.isdebug then self.img:setAlpha(0.5) end
			self:addChild(self.img)
		end
	end
	if not params.isdeco then
		-- body
		self.body = self.world:createBody { type = params.type } -- b2.STATIC_BODY, b2.KINEMATIC_BODY, b2.DYNAMIC_BODY
		self.body:setGravityScale(params.gravityscale)
		self.body.name = params.NAME
		self.body.isdirty = false
--		self.body:setFixedRotation(params.fixedrotation)
		self.body:setAngle(^<params.rotation)
		-- the shape
		if params.w ~= params.h then -- oval
	--		print("oval")
			local sin, cos, d2r = math.sin, math.cos, math.pi / 180
			local cs = {}
			for i = 0, 360, 360 / params.steps  do
				cs[#cs + 1] = (params.w * self.levelscale / 2) + params.w * self.levelscale / 2 * cos(i * d2r)
				cs[#cs + 1] = (params.h * self.levelscale / 2) + params.h * self.levelscale / 2 * sin(i * d2r)
			end
			local shape = b2.ChainShape.new()
			shape:createLoop(unpack(cs))
			local fixture = self.body:createFixture {
				shape = shape,
				density = params.density * 0.25, restitution = params.restitution, friction = params.friction
			}
			if params.BIT == G_BITSENSOR then fixture:setSensor(true) end
			local filterData = { categoryBits = params.BIT, maskBits = params.COLBIT, groupIndex = 0 }
			fixture:setFilterData(filterData)
		else -- circle
	--		print("circle")
--			local shape = b2.CircleShape.new(params.w * self.levelscale / 2, params.h * self.levelscale / 2, params.w * self.levelscale / 2) -- (centerx, centery, radius)
			local shape = b2.CircleShape.new(params.w * params.scalex * self.levelscale / 2,
				params.h * params.scaley * self.levelscale / 2, params.w * self.levelscale / 2) -- (centerx, centery, radius)
			local fixture = self.body:createFixture {
				shape = shape,
				density = params.density, restitution = params.restitution, friction = params.friction
			}
			if params.BIT == G_BITSENSOR then fixture:setSensor(true) end
			local filterData = { categoryBits = params.BIT, maskBits = params.COLBIT, groupIndex = 0 }
			fixture:setFilterData(filterData)
		end
		-- clean up?
		filterData = nil
		fixture = nil
		shape = nil
	end
	-- sensors
	if params.NAME == G_EXIT then self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
end

function Tiled_Shape_Ellipse:onEnterFrame()
	if self.body then
		if self.body.isdirty then
			self.world:destroyBody(self.body)
			self:getParent():removeChild(self)
			if self.body.name == G_EXIT then
--				g_currentlevel += 1
				if g_currentlevel > #tiled_levels then g_currentlevel = 1 end
				self:reload()
			end
			self.body = nil
		end
	end
end

function Tiled_Shape_Ellipse:setPosition(xposx, xposy)
	if self.body then
		self.body:setPosition(xposx * self.levelscale, xposy * self.levelscale)
		if self.img then
			self.img:setPosition(self.body:getPosition())
			self.img:setRotation(self.body:getAngle() + 0 * 180 / math.pi)
		end
	else
		if self.img then
			self.img:setPosition(xposx * self.levelscale, xposy * self.levelscale)
			self.img:setRotation(self.img:getRotation() + 0 * 180 / math.pi)
		end
	end
end

function Tiled_Shape_Ellipse:reload()
	scenemanager:changeScene("levelX", 5, transitions[1], easings[1])
end
