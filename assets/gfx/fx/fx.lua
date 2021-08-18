-- *******************************************************************
-- *******************************************************************
Tiled_Flow = Core.class(Sprite)

function Tiled_Flow:init(xworld, xparams)
	-- params
	local params = xparams or {}
	params.tex = xparams.tex or nil
	params.w = xparams.w or 32
	params.h = xparams.h or 32
	params.alpha = xparams.alpha or 1
	params.scalex = xparams.scalex or 1
	params.scaley = xparams.scaley or 1
	params.rotation = xparams.rotation or 0
	params.flowspeedx = xparams.flowspeedx or nil
	params.flowspeedy = xparams.flowspeedy or nil
	params.rotationz = xparams.rotationz or nil
	params.anchorx = xparams.anchorx or 0.5
	params.anchory = xparams.anchory or 0.5
	params.anchorz = xparams.anchorz or 0.5
	-- img
	local tex = Texture.new(params.tex, false, {wrap = TextureBase.REPEAT})
	self.img = Pixel.new(tex, params.w, params.h)
	self.img:setAlpha(params.alpha)
	self.img:setScale(params.scalex, params.scaley)
	self.img:setRotation(params.rotation)
	tex = nil
	-- rotation
	self.m = Matrix.new()
	self.m:setAnchorPosition(params.anchorx, params.anchory, params.anchorz)
	-- debug
	if self.img then
		if xworld.isdebug then self.img:setAlpha(0.5) end
		self:addChild(self.img)
	end
	-- listeners?
	if params.flowspeedx or params.flowspeedy or params.rotationz then
		self.flowx, self.flowy, self.flowz = 0, 0, 0
		self.flowspeedx, self.flowspeedy, self.flowspeedz = params.flowspeedx, params.flowspeedy, params.rotationz
		self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
	end
end

function Tiled_Flow:onEnterFrame(e)
	self.flowx += self.flowspeedx or 0
	self.flowy += self.flowspeedy or 0
	self.flowz += self.flowspeedz or 0
	self.m:setRotationZ(math.cos(self.flowz))
--	self.m:setRotationZ(self.flowz)
	self.img:setTextureMatrix(self.m)
	self.img:setTexturePosition(self.flowx, self.flowy)
end

function Tiled_Flow:setPosition(xposx, xposy)
	if self.img then self.img:setPosition(xposx, xposy) end
end

-- *******************************************************************
-- *******************************************************************
Tiled_WindMill = Core.class(Sprite)

function Tiled_WindMill:init(xworld, xparams)
	-- params
	local params = xparams or {}
	params.tex = xparams.tex or nil
	params.scalex = xparams.scalex or 1
	params.scaley = xparams.scaley or 1
	params.rotationspeed = xparams.rotationspeed or 1
	-- img
	local tex = Texture.new(params.tex, false)
	self.img1 = Bitmap.new(tex)
	self.img1:setAnchorPoint(0.0328, 0.2889)
	self.img1:setScale(params.scalex, params.scaley)
	self.img2 = Bitmap.new(tex)
	self.img2:setAnchorPoint(0.0328, 0.2889)
	self.img2:setScale(params.scalex, params.scaley)
	self.img3 = Bitmap.new(tex)
	self.img3:setAnchorPoint(0.0328, 0.2889)
	self.img3:setScale(params.scalex, params.scaley)
	self.img4 = Bitmap.new(tex)
	self.img4:setAnchorPoint(0.0328, 0.2889)
	self.img4:setScale(params.scalex, params.scaley)
	tex = nil
	-- debug
	if xworld.isdebug then
		self.img1:setAlpha(0.5) self.img2:setAlpha(0.5)
		self.img3:setAlpha(0.5) self.img4:setAlpha(0.5)
	end
	self:addChild(self.img1) self:addChild(self.img2)
	self:addChild(self.img3) self:addChild(self.img4)
	-- listeners
	self.flow = 0
	self.rotationspeed = params.rotationspeed
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

function Tiled_WindMill:onEnterFrame()
	self.flow += self.rotationspeed
	self.img1:setRotation(self.flow + 0)
	self.img2:setRotation(self.flow + 90)
	self.img3:setRotation(self.flow + 180)
	self.img4:setRotation(self.flow + 270)
end

function Tiled_WindMill:setPosition(xposx, xposy)
	self.img1:setPosition(xposx, xposy)
	self.img2:setPosition(xposx, xposy)
	self.img3:setPosition(xposx, xposy)
	self.img4:setPosition(xposx, xposy)
end

-- *******************************************************************
-- *******************************************************************
FX_Gradient = Core.class(Sprite)

function FX_Gradient:init(xworld, xparams)
	-- params
	local params = xparams or {}
	params.tex = xparams.tex or nil
	params.scalex = xparams.scalex or 1
	params.scaley = xparams.scaley or 1
	params.alpha = xparams.alpha or 1
	params.rotation = xparams.rotation or 0
	params.colortransform = xparams.colortransform or nil
	-- img
	local tex = Texture.new(params.tex)
	self.img = Bitmap.new(tex)
	self.img:setAnchorPoint(0.5, 0.5)
	self.img:setScale(params.scalex, params.scaley)
	self.img:setAlpha(params.alpha)
	self.img:setRotation(params.rotation)
--	self.img:setColorTransform(1, 1, 1, 1)
	self.img:setColorTransform(0, 0, 0, 1)
--	self.img:setColorTransform(0.5, 0.1, 0, 1)
--	self.img:setBlendMode(Sprite.ADD)
--	self.img:setBlendMode(Sprite.ALPHA)
--	self.img:setBlendMode(Sprite.NO_ALPHA)
--	self.img:setBlendMode(Sprite.MULTIPLY)
--	self.img:setBlendMode(Sprite.SCREEN)
	tex = nil
	-- debug
	if self.img then
		if xworld.isdebug then self.img:setAlpha(0.5) end
		self:addChild(self.img)
	end
end

function FX_Gradient:setPosition(xposx, xposy)
	if self.img then self.img:setPosition(xposx, xposy) end
end

-- *******************************************************************
-- *******************************************************************
Tiled_GradientPane = Core.class(Sprite)

function Tiled_GradientPane:init(xparams)
	local params = xparams or {}
	params.width = xparams.width or nil
	params.height = xparams.height or nil
	params.type = xparams.type or ""
	params.gradientcolor1 = xparams.gradientcolor1 or nil
	params.gradientcolor1alpha = xparams.gradientcolor1alpha or nil
	params.gradientcolor2 = xparams.gradientcolor2 or nil
	params.gradientcolor2alpha = xparams.gradientcolor2alpha or nil
	params.gradientcolor3 = xparams.gradientcolor3 or nil
	params.gradientcolor3alpha = xparams.gradientcolor3alpha or nil
	params.gradientcolor4 = xparams.gradientcolor4 or nil
	params.gradientcolor4alpha = xparams.gradientcolor4alpha or nil
	params.angle = xparams.angle or 90 -- XXX
	-- uniform or gradient color pane (pixel)
	self.img = nil
	if params.type == "1colorgradient" then
		self.pixel1 = Pixel.new(0xFFFFFF, 1, params.width, params.height)
		self.pixel1:setColor(params.gradientcolor1, params.gradientcolor1alpha,
			params.gradientcolor2, params.gradientcolor2alpha,
			params.angle)
		self:addChild(self.pixel1)
	elseif params.type == "2colorsgradient" then
		self.pixel1 = Pixel.new(0xFFFFFF, 1, params.width/2.5, params.height)
		self.pixel2 = Pixel.new(0xFFFFFF, 1, params.width/2.5, params.height)
		self.pixel2:setX(params.width - self.pixel2:getWidth())
		self.pixel1:setColor(params.gradientcolor1, params.gradientcolor1alpha,
			params.gradientcolor2, params.gradientcolor2alpha,
			params.angle)
		self.pixel2:setColor(params.gradientcolor2, params.gradientcolor2alpha,
			params.gradientcolor1, params.gradientcolor1alpha,
			params.angle)
		self:addChild(self.pixel1)
		self:addChild(self.pixel2)
	elseif params.type == "4colorsgradient" then
		self.pixel1 = Pixel.new(0xFFFFFF, 1, params.width, params.height)
		self.pixel1:setColor(params.gradientcolor1, params.gradientcolor1alpha,
			params.gradientcolor2, params.gradientcolor2alpha,
			params.gradientcolor3, params.gradientcolor3alpha,
			params.gradientcolor4, params.gradientcolor4alpha)
		self:addChild(self.pixel1)
	else -- simple pane
		self.img = Pixel.new(params.gradientcolor1, params.gradientcolor1alpha, params.width, params.height)
		self:addChild(self.img)
	end
end

-- *******************************************************************
-- *******************************************************************
function effectExplode(s, scale, x, y, r, speed, texture, nbparticles)
	local p = Particles.new()
	p:setPosition(x, y)
	p:setTexture(texture)
	p:setScale(scale)
	s:addChild(p)
	local parts = {}
	for i = 1, nbparticles or 32 do
		local a = math.random() * 6.3
		local dx, dy = math.sin(a), math.cos(a)
		local sr = math.random() * r
		local px, py = dx * sr, dy * sr
		local ss = (speed or 1) * (1 + math.random())
		table.insert(parts,
			{
				x = px, y = py,
				speedX = dx * ss,
				speedY = dy * ss,
				speedAngular = math.random() * 4 - 0, -- math.random() * 4 - 2,
				decayAlpha = 0.95 + math.random() *0.04,
				ttl = 16, -- 1000
				size = 10 + math.random() * 20
			}
		)
	end
	p:addParticles(parts)
	Core.yield(1) -- 2
	p:removeFromParent()
end

-- *******************************************************************
-- *******************************************************************
--[[
function effectLava(s, scale, x, y, r, speed, texture, nbparticles)
	local p = Particles.new()
	p:setPosition(x, y)
	p:setTexture(texture)
	p:setScale(scale)
	s:getParent():addChild(p)
	local parts = {}
	for i = 1, nbparticles or 32 do
--		local a = math.random() * 6.3
		local a = s.body.flip
		local dx, dy = math.sin(a), math.cos(a)
		local sr = math.random() * r
		local px, py = dx * sr, dy * sr
		local ss = (speed or 1) * (1 + math.random())
		table.insert(parts,
			{
				x = px, y = py,
				speedX = -dx * ss / 10,
				speedY = dy * ss,
				speedAngular = math.random() * 4 - 0, -- math.random() * 4 - 2,
				decayAlpha = 0.95 + math.random() *0.04,
--				decayAlpha = 0.8 + math.random() *0.03,
				ttl = 1800, -- 1000
--				size = 10 + math.random() * 20
				size = 2 + math.random() * 20
			}
		)
	end
	p:addParticles(parts)
	Core.yield(1.5) -- 1, 2 -- related to ttl
	p:removeFromParent()
end
]]
function effectLava(s, scale, x, y, r, speed, texture, nbparticles, xangle)
	local p = Particles.new()
	p:setPosition(x, y)
	p:setTexture(texture)
	p:setScale(scale)
	s:getParent():addChild(p)
	local parts = {}
	for i = 1, nbparticles or 8 do
--		local a = xangle * -s.body.flip
		local a = xangle
--		local dx, dy = math.sin(a), math.cos(a)
		local dx, dy = math.cos(a), math.sin(a)
		local px, py = dx * r, dy * r
		local ss = (speed or 1) * (0.75 + math.random())
		table.insert(parts,
			{
				x = px, y = py,
				speedX = dx * ss,
				speedY = dy * ss,
				speedAngular = math.random() * 6, -- math.random() * 4 - 2,
				decayAlpha = 0.95 + math.random() *0.04,
--				decayAlpha = 0.9 + math.random() *0.02,
				ttl = 1000, -- 1000
--				size = 10 + math.random() * 20
				size = 3 + math.random() * 20
			}
		)
	end
	p:addParticles(parts)
	Core.yield(1) -- 1, 2 -- related to ttl
	p:removeFromParent()
end
