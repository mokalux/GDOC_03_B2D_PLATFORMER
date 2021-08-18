--!NEEDS:character_base.lua

Nme_Walker = Core.class(Character_Base)

function Nme_Walker:init()
	-- anims
	if g_currentlevel == 1 then
		Character_Base.createAnim(self, "idle", 26, 33)
		Character_Base.createAnim(self, "run", 1, 25)
		Character_Base.createAnim(self, "jumpup", 3, 3)
		Character_Base.createAnim(self, "jumpdown", 3, 3)
		Character_Base.createAnim(self, "hurt", 3, 3)
		Character_Base.createAnim(self, "death", 3, 3)
		Character_Base.createAnim(self, "climbup", 3, 3)
		Character_Base.createAnim(self, "climbidle", 3, 3)
		Character_Base.createAnim(self, "climbdown", 3, 3)
	elseif g_currentlevel == 2 then
		Character_Base.createAnim(self, "idle", 1, 13)
		Character_Base.createAnim(self, "run", 1, 13)
		Character_Base.createAnim(self, "jumpup", 1, 13)
		Character_Base.createAnim(self, "jumpdown", 1, 13)
		Character_Base.createAnim(self, "hurt", 1, 13)
		Character_Base.createAnim(self, "death", 1, 13)
		Character_Base.createAnim(self, "climbup", 1, 13)
		Character_Base.createAnim(self, "climbidle", 1, 13)
		Character_Base.createAnim(self, "climbdown", 1, 13)
	end
	-- new abilities
	local shape2, fixture2 = nil, nil
	if g_currentlevel == 1 then
		shape2 = b2.CircleShape.new(0, -self.h/3, self.w*0.15) -- magik XXX
		fixture2 = self.body:createFixture{
			shape = shape2, density = 0, restitution = 0, friction = 0,
		}
	elseif g_currentlevel == 2 then
		shape2 = b2.CircleShape.new(0, -self.h/3, self.w*0.15) -- magik XXX
		fixture2 = self.body:createFixture{
			shape = shape2, density = 0, restitution = 0, friction = 0,
		}
	end
	-- filter data
	local filterData2 = { categoryBits = G_BITENEMY, maskBits = G_BITSOLID + G_BITPLAYER + G_BITPLAYERBULLET + G_BITENEMY, groupIndex = 0 }
	fixture2:setFilterData(filterData2)
	-- clean
	filterData2 = nil
	fixture2 = nil
	shape2 = nil
	-- nmes see player sensor
	local shapesensor, fixturesensor, filterDataSensor = nil, nil, nil
	if g_currentlevel == 1 then
		shapesensor = b2.CircleShape.new(0, 0, self.w * 2.7) -- (centerx, centery, radius)
		fixturesensor = self.body:createFixture { shape = shapesensor, friction = 0, isSensor = true }
		filterDataSensor = { categoryBits = xBIT, maskBits = G_BITPLAYER, groupIndex = 0 }
	elseif g_currentlevel == 2 then
		shapesensor = b2.CircleShape.new(0, 0, self.w * 3) -- (centerx, centery, radius)
		fixturesensor = self.body:createFixture { shape = shapesensor, friction = 0, isSensor = true }
		filterDataSensor = { categoryBits = xBIT, maskBits = G_BITPLAYER, groupIndex = 0 }
	end
	fixturesensor:setFilterData(filterDataSensor)
	filterDataSensor = nil
	fixturesensor = nil
	shapesensor = nil
	-- list
	self.world.groundnmes[self] = self.body
	-- audio
	self.sndshoot = Sound.new("audio/wood-1.wav")
	self.sndhurt = Sound.new("audio/hit-2.wav")
	self.snddead = Sound.new("audio/wood-5.wav")
	-- listeners
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

-- LOOP
function Nme_Walker:onEnterFrame(e)
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
		local bx, by = self.body:getPosition()
		local angle = math.atan2(ply - by, plx - bx)
		local bullet = nil
		if g_currentlevel == 1 then
			bullet = LF_Dynamic_Bullet.new(self.world, {
					posx=posx, posy=posy,
					texpath="gfx/playable/bulletB.png", scalex=0.2, alpha=0.8,
					offsetx=0, offsety=-32,
					lvx=0.08 * math.cos(angle), lvy=0.08 * math.sin(angle),
					density=0.04, restitution=0, friction=0, fixedrotation=false,
					gravityscale=0.5,
					BIT=G_BITENEMYBULLET, COLBIT=nmebulletcollisions, NAME=G_ENEMY_BULLET
				}
			)
		elseif g_currentlevel == 2 then
			bullet = LF_Dynamic_Bullet.new(self.world, {
					posx=posx, posy=posy,
					texpath="gfx/playable/bulletB.png", scalex=0.2, alpha=0.8,
					offsetx=-8, offsety=-8,
					lvx=0.02 * math.cos(angle), lvy=1.05 * math.sin(angle),
					density=0.02, restitution=0, friction=0, fixedrotation=false,
					gravityscale=1.5,
					BIT=G_BITENEMYBULLET, COLBIT=nmebulletcollisions, NAME=G_ENEMY_BULLET
				}
			)
		end
		self:getParent():addChild(bullet)
		self.body.isspace = false -- android fix here?
	end
	-- DEATH?
	-- *****************
	for k, v in pairs(self.world.groundnmes) do -- k = self, v = body
		if v.isdead then
			local vx, vy = 0.2 * -v.flip, 0 -- -2
			local posx, posy = v:getPosition()
			-- MOVE IT ALL
			v:setLinearVelocity(vx, vy) -- not the best but will do
			k:setPosition(posx, posy)
			self:playAnim(e.deltaTime)
			v.timer -= 0.5 -- can adjust here
			if v.timer <= 0 then
				-- sfx
				local sfx = self.snddead:play() sfx:setVolume(0.1)
				-- particles
				local dtex
--				if v.breed == 1 then dtex = Texture.new("gfx/fx/bat-1-part.png", true)
--				elseif v.breed == 2 then dtex = Texture.new("gfx/fx/bat-2-part.png", true)
--				else dtex = Texture.new("gfx/fx/bat-1-part.png", true)
--				end
				dtex = Texture.new("gfx/fx/bat-1-part.png", true)
				Core.asyncCall(effectExplode, k:getParent(), 2, posx, posy, 8, 2, dtex, 8)
				self.world:destroyBody(v)
				k:getParent():removeChild(k)
				self.world.groundnmes[k] = nil
				v = nil
				k = nil -- useful???
				self.world.score += 20
				self.world.scoretf:setText(self.world.score)
				self:movieClip()
			end
		end
	end
end

function Nme_Walker:movieClip()
	local mc = MovieClip.new{
		{1, 20, self.world.scoretf, {scale={4, 9, "inOutElastic"}}},
		{20, 30, self.world.scoretf, {scale={9, 4, "inOutElastic"}}}
	}
	mc = nil
end
