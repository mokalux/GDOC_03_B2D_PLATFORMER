LF_Dynamic_Bullet = Core.class(Sprite)

function LF_Dynamic_Bullet:init(xworld, xparams)
	-- the params
	local params = xparams or {}
	params.posx = xparams.posx or nil
	params.posy = xparams.posy or nil
	params.texpath = xparams.texpath or nil
	params.scalex = xparams.scalex or 1
	params.scaley = xparams.scaley or params.scalex
	params.alpha = xparams.alpha or 1
	params.offsetx = xparams.offsetx or 0
	params.offsety = xparams.offsety or 0
	params.lvx = xparams.lvx or nil
	params.lvy = xparams.lvy or nil
	params.fixedrotation = xparams.fixedrotation or nil
	params.density = xparams.density or nil
	params.restitution = xparams.restitution or nil
	params.friction = xparams.friction or nil
	params.gravityscale = xparams.gravityscale or nil
	params.BIT = xparams.BIT or nil
	params.COLBIT = xparams.COLBIT or nil
	params.NAME = xparams.NAME or nil
	-- class variables
	self.world = xworld
	-- the image
	local texture = Texture.new(params.texpath, true)
	self.bitmap = Bitmap.new(texture)
	self.bitmap:setAnchorPoint(0.5, 0.5)
	self.bitmap:setScale(params.scalex, params.scaley)
	self.bitmap:setAlpha(params.alpha)
	self:addChild(self.bitmap)
	-- the body
	self.body = xworld:createBody { type = b2.DYNAMIC_BODY }
	self.body.name = params.NAME
	self.body.isdirty = false
	self.body:setGravityScale(params.gravityscale)
	self.body:setPosition(params.posx + params.offsetx, params.posy + params.offsety)
	self.body:setFixedRotation(params.fixedrotation)
	self.shape = b2.CircleShape.new(0, 0, self.bitmap:getWidth() / 2)
	local fixture = self.body:createFixture {
		shape = self.shape, density = params.density, restitution = params.restitution, friction = params.friction
	}
	local filterData = {categoryBits=params.BIT, maskBits=params.COLBIT, groupIndex = 0 }
	fixture:setFilterData(filterData)
	-- move
	self.body:applyLinearImpulse(params.lvx, params.lvy, self.body:getWorldCenter()) -- physics
	-- clean
	filterData = nil
	fixture = nil
	texture = nil
	params = nil
	-- listeners
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

-- game loop
function LF_Dynamic_Bullet:onEnterFrame(e)
	if self.body then
		if self.body.isdirty then
			self.world:destroyBody(self.body)
			self:getParent():removeChild(self)
			self.body = nil
			return
		end
		self.bitmap:setPosition(self.body:getPosition())
		self.bitmap:setRotation(self.body:getAngle() * 180 / math.pi)
	end
end
