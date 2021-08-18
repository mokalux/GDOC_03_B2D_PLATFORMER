--!NEEDS:character_base.lua

Nme_Walker_Boss_A = Core.class(Character_Base)

function Nme_Walker_Boss_A:init()
	-- anims
	if g_currentlevel == 1 then
		Character_Base.createAnim(self, "idle", 9, 9)
		Character_Base.createAnim(self, "run", 1, 16)
		Character_Base.createAnim(self, "jumpup", 1, 16)
		Character_Base.createAnim(self, "jumpdown", 1, 16)
		Character_Base.createAnim(self, "hurt", 17, 24)
		Character_Base.createAnim(self, "death", 25, 51)
		Character_Base.createAnim(self, "climbup", 1, 16)
		Character_Base.createAnim(self, "climbidle", 8, 8)
		Character_Base.createAnim(self, "climbdown", 1, 16)
	elseif g_currentlevel == 2 then
		Character_Base.createAnim(self, "idle", 1, 9)
		Character_Base.createAnim(self, "run", 1, 9)
		Character_Base.createAnim(self, "jumpup", 1, 9)
		Character_Base.createAnim(self, "jumpdown", 1, 9)
		Character_Base.createAnim(self, "hurt", 1, 9)
		Character_Base.createAnim(self, "death", 1, 9)
		Character_Base.createAnim(self, "climbup", 1, 9)
		Character_Base.createAnim(self, "climbidle", 1, 9)
		Character_Base.createAnim(self, "climbdown", 1, 9)
	end
	-- new abilities
	if g_currentlevel == 1 then
		local shape2 = b2.CircleShape.new(0, -self.h/5, self.w*0.15) -- magik XXX
		local fixture2 = self.body:createFixture{
			shape = shape2, density = 0, restitution = 0, friction = 0,
		}
		-- filter data
		local filterData2 = { categoryBits = G_BITENEMY, maskBits = nmecollisions, groupIndex = 0 }
		fixture2:setFilterData(filterData2)
		-- clean
		filterData2 = nil
		fixture2 = nil
		shape2 = nil
	end
	-- nmes see player sensor
	local shapesensor = b2.CircleShape.new(0, 0, self.w * 3) -- (centerx, centery, radius)
	local fixturesensor = self.body:createFixture { shape = shapesensor, friction = 0, isSensor = true }
	local filterDataSensor = { categoryBits = G_BITENEMY, maskBits = G_BITPLAYER, groupIndex = 0 }
	fixturesensor:setFilterData(filterDataSensor)
	filterDataSensor = nil
	fixturesensor = nil
	shapesensor = nil
	-- add to nme list
	self.world.groundnmeskeep[self] = self.body
	-- audio
	self.sndshoot = Sound.new("audio/wood-1.wav")
	self.sndhurt = Sound.new("audio/hit-2.wav")
	self.snddead = Sound.new("audio/wood-5.wav")
	-- joint
--	if g_currentlevel == 2 then self:joint(self.posx, self.posy) end
	-- listeners
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

-- create joint
function Nme_Walker_Boss_A:joint(xposx, xposy)
	local posx, posy = xposx or self.posx, xposy or self.posy
	local ground = self.world:createBody({})
	ground:setPosition(posx, posy)
	local jointDef = b2.createDistanceJointDef(ground, self.body, posx + 0, posy + 96, posx, posy)
	self.body.distanceJoint = self.world:createJoint(jointDef)
	self.body.distanceJoint:setDampingRatio(0.5)
	self.body.distanceJoint:setFrequency(1.2)
end

-- PLAYER LOOP
function Nme_Walker_Boss_A:onEnterFrame(e)
	if self.body.isdirty then
		local sfx = self.sndhurt:play() sfx:setVolume(0.1)
		self.body.isspace = true
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
		local bx, by = self.body:getPosition()
		if ply > by then
			local angle = math.atan2(ply - by, plx - bx)
			local bullet = nil
			if g_currentlevel == 1 then
				bullet = LF_Dynamic_Bullet.new(self.world, {
						posx=posx, posy=posy - 16,
						texpath="gfx/playable/bulletB.png", scalex=0.3, alpha=0.8,
						offsetx=24*self.body.flip, offsety=-28,
						lvx=0.08 * math.cos(angle), lvy=0.08 * math.sin(angle),
						density=0.025, restitution=0, friction=0, fixedrotation=false,
						gravityscale=0.5,
						BIT=G_BITENEMYBULLET, COLBIT=nmebulletcollisions, NAME=G_ENEMY_BULLET
					}
				)
			elseif g_currentlevel == 2 then
				bullet = LF_Dynamic_Bullet.new(self.world, {
						posx=posx, posy=posy - 16,
						texpath="gfx/playable/bulletB.png", scalex=0.4, alpha=0.8,
						offsetx=32*self.body.flip, offsety=-4,
						lvx=0.08 * math.cos(angle), lvy=0.08 * math.sin(angle),
						density=0.02, restitution=0, friction=0, fixedrotation=false,
						gravityscale=0.5,
						BIT=G_BITENEMYBULLET, COLBIT=nmebulletcollisions, NAME=G_ENEMY_BULLET
					}
				)
			end
			self:getParent():addChild(bullet)
		end
		self.body.isspace = false -- android fix here?
	end
	-- DEATH?
	-- *****************
	for k, v in pairs(self.world.groundnmeskeep) do -- k = self, v = body
		if v.isdead then
			local vx, vy = 0.2 * -v.flip, 42 -- -2
			local posx, posy = v:getPosition()
			-- MOVE IT ALL
			v:setLinearVelocity(vx, vy) -- not the best but will do
			k:setPosition(posx, posy)
			self:playAnim(e.deltaTime)
			v.timer -= 0.4 -- can adjust here
			if v.timer <= 0 then
				-- sfx
				local sfx = self.snddead:play() sfx:setVolume(0.1)
				if v.distanceJoint ~= nil then self.world:destroyJoint(v.distanceJoint) end
				self.world:destroyBody(v)
--				k:getParent():removeChild(k)
				k:setAlpha(0.5)
				self.world.groundnmeskeep[k] = nil
				v = nil
				k = nil -- useful???
				self.world.score += 20
				self.world.scoretf:setText(self.world.score)
				self:movieClip()
			end
		end
	end
end

function Nme_Walker_Boss_A:movieClip()
	local mc = MovieClip.new{
		{1, 20, self.world.scoretf, {scale={4, 9, "inOutElastic"}}},
		{20, 30, self.world.scoretf, {scale={9, 4, "inOutElastic"}}}
	}
	mc = nil
end
