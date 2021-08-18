Tiled_Shape_Polygon = Core.class(Sprite)

function Tiled_Shape_Polygon:init(xworld, xparams, xlevelscale)
	-- params
	local params = xparams or {}
	params.x = xparams.x or nil
	params.y = xparams.y or nil
	params.coords = xparams.coords or nil
	params.color = xparams.color or nil
	params.texpath = xparams.texpath or nil
	params.isshape = xparams.isshape or nil
	params.shapelinewidth = xparams.shapelinewidth or 0
	params.shapelinecolor = xparams.shapelinecolor or nil
	params.shapelinealpha = xparams.shapelinealpha or 1
	params.isbmp = xparams.isbmp or nil
	params.ispixel = xparams.ispixel or nil
	params.isdeco = xparams.isdeco or not (xparams.isdeco == nil) -- default = false
	params.scalex = xparams.scalex or 1
	params.scaley = xparams.scaley or params.scalex
	params.rotation = xparams.rotation or 0
	params.type = xparams.type or nil -- default = b2.STATIC_BODY
	params.fixedrotation = xparams.fixedrotation or true
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
	-- image
--	if params.issensor then
	if params.BIT == G_BITSENSOR and not params.tex and not params.isshape and not params.isbmp then
		-- no image for sensors
	else
		-- a function
		local pw, ph = 0, 0 -- the polygon dimensions
		local function sizes()
			-- calculate polygon width and height
			local minx, maxx, miny, maxy = 0, 0, 0, 0
			for k, v in pairs(params.coords) do
				--print("polygon coords", k, v.x, v.y)
				if v.x <= minx then minx = v.x end
				if v.y <= miny then miny = v.y end
				if v.x >= maxx then maxx = v.x end
				if v.y >= maxy then maxy = v.y end
			end
			pw, ph = maxx - minx, maxy - miny -- the polygon dimensions
		end
		if params.isshape then
			self.img = Shape.new()
			self.img:setLineStyle(params.shapelinewidth, params.shapelinecolor, params.shapelinealpha) -- (width, color, alpha)
			if params.texpath then
				local tex = Texture.new(params.texpath, false, {wrap = TextureBase.REPEAT})
				local matrix = Matrix.new(params.scalex, 0, 0, params.scaley, 0, 0)
				self.img:setFillStyle(Shape.TEXTURE, tex, matrix)
				tex = nil
			elseif params.color then
				self.img:setFillStyle(Shape.SOLID, params.color)
			else
				self.img:setFillStyle(Shape.NONE)
			end
			self.img:beginPath()
			self.img:moveTo(params.coords[1].x, params.coords[1].y)
			for p = 2, #params.coords do
				self.img:lineTo(params.coords[p].x * self.levelscale, params.coords[p].y * self.levelscale)
			end
			self.img:closePath()
			self.img:endPath()
			self.img:setRotation(params.rotation)
			self.w, self.h = self.img:getWidth(), self.img:getHeight()
		end
		if params.isbmp then
			if not params.texpath then print("!!!YOU MUST PROVIDE A TEXTURE FOR THE BITMAP!!!") return end
			sizes() -- calculate polygon width and height
			local tex = Texture.new(params.texpath, false)
			self.img = Bitmap.new(tex)
			self.img.isbmp = true
			self.img.w, self.img.h = pw, ph
			self.img:setAnchorPoint(0.5, 0.5)
			if params.rotation > 0 then self.img:setAnchorPoint(0, 0.5) end
			if params.rotation < 0 then self.img:setAnchorPoint(0.5, 1) end
			self.img:setScale(params.scalex, params.scaley)
			self.img:setRotation(params.rotation)
			tex = nil
		end
		if params.ispixel then
			if params.texpath then
				sizes() -- calculate polygon width and height
				local tex = Texture.new(params.texpath, false, {wrap = TextureBase.REPEAT})
				self.img = Pixel.new(tex, pw, ph)
				self.img.ispixel = true
				self.img.w, self.img.h = pw, ph
				self.img:setAnchorPoint(0, -0.5) -- 0.5, 0.5
				if params.rotation > 0 then self.img:setAnchorPoint(0, 0.5) end
				if params.rotation < 0 then self.img:setAnchorPoint(0.5, 1) end
				self.img:setScale(params.scalex, params.scaley)
				self.img:setRotation(params.rotation)
				self.img:setTexturePosition(0, 0)
				tex = nil
			else
				-- calculate polygon width and height
				local minx, maxx, miny, maxy = 0, 0, 0, 0
				for k, v in pairs(params.coords) do
					--print("polygon coords", k, v.x, v.y)
					if v.x < minx then minx = v.x end
					if v.y < miny then miny = v.y end
					if v.x > maxx then maxx = v.x end
					if v.y > maxy then maxy = v.y end
				end
				local pw, ph = maxx - minx, maxy - miny -- the polygon dimensions
				self.img = Pixel.new(params.color, 1, pw, ph)
				self.img.ispixel = true
				self.img.w, self.img.h = pw, ph
				self.img:setScale(params.scalex, params.scaley)
				self.img:setRotation(params.rotation)
			end
		end
		-- debug
		if self.img then
			if xworld.isdebug then self.img:setAlpha(0.5) end
			self:addChild(self.img)
		end
	end
	if not params.isdeco then
		-- body b2.STATIC_BODY, b2.KINEMATIC_BODY, b2.DYNAMIC_BODY
		self.body = xworld:createBody {type = params.type}
		self.body:setGravityScale(params.gravityscale)
		self.body.name = params.NAME
		self.body.isdirty = false
		self.body:setFixedRotation(params.fixedrotation)
		self.body:setAngle(^<params.rotation)
		-- the shape
		local shape = b2.ChainShape.new()
		local cs = {}
		for c = 1, #params.coords do
			cs[#cs+1] = params.coords[c].x * self.levelscale
			cs[#cs+1] = params.coords[c].y * self.levelscale
		end
		shape:createLoop(unpack(cs)) -- XXX
		local fixture = self.body:createFixture {
			shape = shape,
			density = params.density, restitution = params.restitution, friction = params.friction
		}
		if params.BIT == G_BITSENSOR then fixture:setSensor(true) end
		local filterData = { categoryBits = params.BIT, maskBits = params.COLBIT, groupIndex = 0 }
		fixture:setFilterData(filterData)
		-- clean up?
		filterData = nil
		fixture = nil
		cs = nil
		shape = nil
	end
	-- sensors
	if params.NAME == G_EXIT then self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
end

function Tiled_Shape_Polygon:onEnterFrame()
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

function Tiled_Shape_Polygon:setPosition(xposx, xposy)
	if self.body then
		self.body:setPosition(xposx * self.levelscale, xposy * self.levelscale)
		if self.img then self.img:setPosition(self.body:getPosition()) end
	else
		if self.img then self.img:setPosition(xposx * self.levelscale, xposy * self.levelscale) end
	end
end

function Tiled_Shape_Polygon:reload()
	scenemanager:changeScene("levelX", 5, transitions[1], easings[1])
end
