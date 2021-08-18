--!NEEDS:character_base.lua

Nme_Flyer_Keep = Core.class(Character_Base)

function Nme_Flyer_Keep:init()
	-- anims
	if g_currentlevel == 1 then
		Character_Base.createAnim(self, "idle", 1, 1)
		Character_Base.createAnim(self, "run", 1, 1)
		Character_Base.createAnim(self, "attack01", 1, 1)
		Character_Base.createAnim(self, "jumpup", 1, 1)
		Character_Base.createAnim(self, "jumpdown", 1, 1)
		Character_Base.createAnim(self, "wall", 1, 1)
		Character_Base.createAnim(self, "wallidle", 1, 1)
		Character_Base.createAnim(self, "climbup", 1, 1)
		Character_Base.createAnim(self, "climbidle", 1, 1)
		Character_Base.createAnim(self, "climbup", 1, 1)
		Character_Base.createAnim(self, "climbdown", 1, 1)
		Character_Base.createAnim(self, "hurt", 1, 1)
		Character_Base.createAnim(self, "death", 1, 1)
	elseif g_currentlevel == 2 then
		Character_Base.createAnim(self, "idle", 1, 9)
		Character_Base.createAnim(self, "run", 1, 9)
		Character_Base.createAnim(self, "attack01", 1, 9)
		Character_Base.createAnim(self, "jumpup", 1, 9)
		Character_Base.createAnim(self, "jumpdown", 1, 9)
		Character_Base.createAnim(self, "wall", 1, 9)
		Character_Base.createAnim(self, "wallidle", 1, 9)
		Character_Base.createAnim(self, "climbup", 1, 9)
		Character_Base.createAnim(self, "climbidle", 1, 9)
		Character_Base.createAnim(self, "climbup", 1, 9)
		Character_Base.createAnim(self, "climbdown", 1, 9)
		Character_Base.createAnim(self, "hurt", 1, 9)
		Character_Base.createAnim(self, "death", 1, 9)
	end
	-- new abilities
	-- nme sees player sensor
	local shapesensor = b2.CircleShape.new(0, 0, self.w * 2) -- (centerx, centery, radius)
	local fixturesensor = self.body:createFixture { shape = shapesensor, friction = 0, isSensor = true }
	local filterDataSensor = { categoryBits = G_BITENEMY, maskBits = G_BITPLAYER, groupIndex = 0 }
	fixturesensor:setFilterData(filterDataSensor)
	filterDataSensor = nil
	fixturesensor = nil
	shapesensor = nil
	-- add to nme list
	self.world.airnmeskeep[self] = self.body -- k = self, v = body
	-- audio
	self.sndshoot = Sound.new("audio/wood-1.wav")
	self.sndhurt = Sound.new("audio/hit-2.wav")
	self.snddead = Sound.new("audio/wood-5.wav")
	-- joint
	self:joint(self.posx, self.posy)
	-- listeners
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

-- create joint
function Nme_Flyer_Keep:joint(xposx, xposy)
	self.body.ground = self.world:createBody({})
	if g_currentlevel == 1 then
		self.body.ground:setPosition(xposx, xposy)
		local jointDef = b2.createDistanceJointDef(self.body.ground, self.body, xposx, xposy - 128, xposx, xposy)
		self.body.distanceJoint = self.world:createJoint(jointDef)
		self.body.distanceJoint:setDampingRatio(0.5)
		self.body.distanceJoint:setFrequency(1.2)
	elseif g_currentlevel == 2 then
		self.body.ground:setPosition(xposx, xposy)
		local jointDef = b2.createDistanceJointDef(self.body.ground, self.body, xposx + 0, xposy - 64, xposx, xposy)
		self.body.distanceJoint = self.world:createJoint(jointDef)
		self.body.distanceJoint:setDampingRatio(0.5)
		self.body.distanceJoint:setFrequency(1.2)
	end
end

-- game loop
function Nme_Flyer_Keep:onEnterFrame(e)
	if self.body.isdirty then
		local sfx = self.sndhurt:play() sfx:setVolume(0.1)
		self.body.isdirty = false
	end
	if self.body.currentnrg <= 0 then
		self.body.currentnrg = self.body.nrg
	end
	-- SHOOT
	-- *****************
	if self.body.isspace then
		local sfx = self.sndshoot:play() sfx:setVolume(0.1)
		local posx, posy = self.body:getPosition()
		local plx, ply = self.world.player1.body:getPosition()
		local angle = math.atan2(ply - self.posy, plx - self.posx)
		local bullet = LF_Dynamic_Bullet.new(self.world, {
				posx=posx, posy=posy,
				texpath="gfx/playable/bulletB.png", scalex=0.12, alpha=0.8,
				offsetx=0, offsety=0,
				lvx=0.04 * math.cos(angle), lvy=0.04 * math.sin(angle),
				density=0.08, restitution=0, friction=0, fixedrotation=false,
				gravityscale=2,
				BIT=G_BITENEMYBULLET, COLBIT=nmebulletcollisions, NAME=G_ENEMY_BULLET
			}
		)
		self:getParent():addChild(bullet)
		bullet = nil
		self.body.isspace = false -- android fix here?
	end
	-- DEATH
	-- *****************
	for k, v in pairs(self.world.airnmeskeep) do
		if v.isdead then
			local vx, vy = 0.2 * -v.flip, 32 -- -2
			local posx, posy = v:getPosition()
			-- MOVE IT ALL
			v:setLinearVelocity(vx, vy) -- not the best but will do
			k:setPosition(posx, posy)
			self:playAnim(e.deltaTime)
			v.timer -= 0.3 -- can adjust here
			if v.timer <= 0 then
				-- sfx
				local sfx = self.snddead:play() sfx:setVolume(0.1)
				if v.ground then self.world:destroyBody(v.ground) end
				self.world:destroyBody(v)
				--k:getParent():removeChild(k)
				k:setAlpha(0.5)
				self.world.airnmeskeep[k] = nil
				v = nil
				k = nil -- useful???
				self.world.score += 20
				self.world.scoretf:setText(self.world.score)
				self:movieClip()
			end
			vx, vy = nil, nil
			posx, posy = nil, nil
		end
	end
end

function Nme_Flyer_Keep:movieClip()
	local mc = MovieClip.new{
		{1, 20, self.world.scoretf, {scale={4, 9, "inOutElastic"}}},
		{20, 30, self.world.scoretf, {scale={9, 4, "inOutElastic"}}}
	}
	mc = nil
end
