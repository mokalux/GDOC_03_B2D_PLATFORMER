Player = Core.class(Character_Base)

function Player:init()
	-- anims
	Character_Base.createAnim(self, "idle", 11, 18)
	Character_Base.createAnim(self, "run", 1, 10)
	Character_Base.createAnim(self, "jumpup", 6, 6)
	Character_Base.createAnim(self, "jumpdown", 7, 7)
	Character_Base.createAnim(self, "hurt", 19, 20)
	Character_Base.createAnim(self, "death", 15, 22)
	Character_Base.createAnim(self, "climbup", 23, 29)
	Character_Base.createAnim(self, "climbidle", 23, 23)
	Character_Base.createAnim(self, "climbdown", 30, 36)
	-- new abilities: add a second shape to the body to make it collision bigger
	local shape2 = b2.CircleShape.new(0, -self.h/3, self.w*0.15) -- magik XXX
	local fixture2 = self.body:createFixture{
		shape = shape2, density = 0, restitution = 0, friction = 0,
	}
	-- filter data
	local filterData2 = { categoryBits = G_BITPLAYER, maskBits = G_BITSOLID + G_BITENEMY + G_BITENEMYBULLET, groupIndex = 0 }
	fixture2:setFilterData(filterData2)
	-- clean
	filterData2 = nil
	fixture2 = nil
	shape2 = nil
	-- audio
	self.sndshoot = Sound.new("audio/shoot.wav")
	self.sndhurt = Sound.new("audio/hit-1.wav")
	-- listeners
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
	self:addEventListener(Event.KEY_DOWN, self.onKeyDown, self)
	self:addEventListener(Event.KEY_UP, self.onKeyUp, self)
end

-- PLAYER LOOP
function Player:onEnterFrame(e)
	if self.body.isdirty then
		local sfx = self.sndhurt:play() sfx:setVolume(0.1)
		self.world.nrgbar:setWidth(self.body.currentnrg * 40) -- magik XXX
		self.body.isdirty = false
	end
	if self.body.currentnrg <= 0 then
		self.world.lives[self.body.currentlives + 1]:setVisible(false)
		self.body.currentnrg = self.body.nrg
		self.world.nrgbar:setWidth(self.body.currentnrg * 40) -- magik XXX
	end
	-- SHOOT
	-- *****************
	if self.body.isspace then
--		if self.world.stones > 0 then
			local sfx = self.sndshoot:play() sfx:setVolume(0.1)
			local tempx, tempy = 0, 0
			self.posx, self.posy = self.body:getPosition()
			if self.body.isup then tempx, tempy = 0.15 * self.body.flip, -0.1 -- magik XXX
			elseif self.body.isdown then tempx, tempy = 0.2 * self.body.flip, 0.05 -- magik XXX
			else tempx, tempy = 0.15 * self.body.flip, -0.05 -- magik XXX
			end
			local bullet = LF_Dynamic_Bullet.new(self.world, {
					posx=self.posx, posy=self.posy,
					texpath="gfx/playable/bulletA.png", scalex=0.2, alpha=0.8,
					offsetx=0, offsety=-12,
					lvx=tempx, lvy=tempy,
					density=0.1, restitution=0, friction=0, fixedrotation=false,
					gravityscale=0.5,
					BIT=G_BITPLAYERBULLET, COLBIT=playerbulletcollisions, NAME=G_PLAYER_BULLET
				}
			)
			self:getParent():addChild(bullet)
			self.body.isspace = false -- android fix here?
--			self.world.stones -= 1
--			self.world.stonetf:setText(self.world.stones)
--		end
	end
	-- DEAD?
	-- *****************
	if self.body.isdead then
		self.world.nrgbar:setWidth(0 * 40) -- magik XXX
		local vx, vy = 0.5 * -self.body.flip, -4 -- magik XXX
		local posx, posy = self.body:getPosition()
		-- MOVE IT ALL
		self.body:setLinearVelocity(vx, vy) -- not the best but will do
		self:setPosition(posx, posy)
		if self:getScale() < 5 then self:setScale(1.01 * self:getScale()) end -- magik XXX
		self.body.animspeed = 1
		self:playAnim(e.deltaTime)
	end
end

-- CONTROLS (keyboard, gamepad)
function Player:onKeyDown(e)
	if e.keyCode == KeyCode.LEFT then self.body.isleft = true end
	if e.keyCode == KeyCode.RIGHT then self.body.isright = true end
	if e.keyCode == KeyCode.UP then self.body.isup = true end
	if e.keyCode == KeyCode.DOWN then self.body.isdown = true end

	if e.keyCode == KeyCode.J then self.body.isleft = true end
	if e.keyCode == KeyCode.L then self.body.isright = true end
	if e.keyCode == KeyCode.I then self.body.isup = true end
	if e.keyCode == KeyCode.K then self.body.isdown = true end

	if e.keyCode == KeyCode.SPACE then self.body.isspace = true end
end

function Player:onKeyUp(e)
	if e.keyCode == KeyCode.LEFT then self.body.isleft = false end
	if e.keyCode == KeyCode.RIGHT then self.body.isright = false end
	if e.keyCode == KeyCode.UP then self.body.isup = false self.body.canjump = true end
	if e.keyCode == KeyCode.DOWN then self.body.isdown = false end

	if e.keyCode == KeyCode.J then self.body.isleft = false end
	if e.keyCode == KeyCode.L then self.body.isright = false end
	if e.keyCode == KeyCode.I then self.body.isup = false self.body.canjump = true end
	if e.keyCode == KeyCode.K then self.body.isdown = false end

	if e.keyCode == KeyCode.SPACE then self.body.isspace = false end
end
