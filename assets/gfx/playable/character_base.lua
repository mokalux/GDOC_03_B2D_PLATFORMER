Character_Base = Core.class(Sprite)

function Character_Base:init(xworld, xparams, xlevelscale)
	self.world = xworld
	-- the params
	local params = xparams or {}
	params.posx = xparams.posx or 0
	params.posy = xparams.posy or 0
	params.texpath = xparams.texpath or nil
	params.numtexcols = xparams.numtexcols or 1
	params.numtexrows = xparams.numtexrows or 1
	params.scale = xparams.scale or 1
	params.anchorx = xparams.anchorx or 0.5
	params.anchory = xparams.anchory or 0.5
	params.offsetx = xparams.offsetx or 0
	params.offsety = xparams.offsety or 0
	params.shapescale = xparams.shapescale or 1
	params.animspeed = xparams.animspeed or 7
	params.movespeed = xparams.movespeed or 8
	params.jumpspeed = xparams.jumpspeed or nil
	params.maxnumjump = xparams.maxnumjump or 1
	params.density = xparams.density or nil
	params.restitution = xparams.restitution or nil
	params.friction = xparams.friction or nil
	params.BIT = xparams.BIT or nil
	params.COLBIT = xparams.COLBIT or nil
	params.NAME = xparams.NAME or nil
	params.lives = xparams.lives or 3
	params.nrg = xparams.nrg or 4
	-- spritesheet animations
	local spritesheettex = Texture.new(params.texpath)
	self.spritesheetimgs = {} -- table that will hold all the images in the sprite sheet
	self.anims = {} -- table that will hold all our animations ("idle", "run", ...)
	self.posx, self.posy = params.posx, params.posy
	-- 1 retrieve all anims in spritesheet
	self.w, self.h = spritesheettex:getWidth()/params.numtexcols, spritesheettex:getHeight()/params.numtexrows
	local spritesheettexregion = nil
	for r = 1, params.numtexrows do
		for c = 1, params.numtexcols do
			spritesheettexregion = TextureRegion.new(spritesheettex, (c - 1) * self.w, (r - 1) * self.h, self.w, self.h)
			self.spritesheetimgs[#self.spritesheetimgs + 1] = spritesheettexregion
		end
	end
	-- 2 create animations
--	self:createAnim("idle", 11, 18)
	-- 3 we can now create the character
	self.bitmap = Bitmap.new(self.spritesheetimgs[1])
	self.bitmap:setAnchorPoint(params.anchorx, params.anchory)
	self.bitmap:setPosition(params.offsetx, params.offsety)
	print("bmp size before scaling", params.NAME, self.w, self.h)
	self.bitmap:setScale(params.scale)
	self:addChild(self.bitmap)
	-- the body
	self.body = self.world:createBody{type = b2.DYNAMIC_BODY}
	self.body:setFixedRotation(true)
	self.body:setPosition(params.posx * xlevelscale, params.posy * xlevelscale)
	-- the shape
	self.w, self.h = self.bitmap:getWidth()//1, self.bitmap:getHeight()//1
	print("bmp size after scaling", params.NAME, self.w, self.h)
--	local playershape = b2.CircleShape.new(params.offsetx, params.offsety, self.w/params.shapescale) -- (centerx, centery, radius)
	local playershape = b2.CircleShape.new(0, 0, self.w/params.shapescale//1) -- (centerx, centery, radius)
	self.fixture = self.body:createFixture{
		shape = playershape, density = params.density, restitution = params.restitution, friction = params.friction,
	}
	-- filter data
	self.filterData = { categoryBits = params.BIT, maskBits = params.COLBIT, groupIndex = 0 }
	self.fixture:setFilterData(self.filterData)
	-- body vars
	self.body.isleft, self.body.isright, self.body.isup, self.body.isdown = false, false, false, false
	self.body.isspace = false
	self.body.name = params.NAME
	self.body.lives = params.lives
	self.body.currentlives = self.body.lives
	self.body.nrg = params.nrg
	self.body.currentnrg = self.body.nrg
	self.body.currentanim = ""
	self.body.frame = 0
	self.body.animspeed = 1 / params.animspeed
	self.body.animtimer = self.body.animspeed
	self.body.playerscale = self.bitmap:getScale()
	self.body.flip = 1
	self.body.movespeed = params.movespeed * self.body.playerscale
	self.body.jumpspeed = params.jumpspeed * self.body.playerscale
	self.body.maxnumjump = params.maxnumjump
	self.body.numjumpcount = self.body.maxnumjump
	self.body.numfloorcontacts = 0 -- is on floor
	self.body.numladdercontacts = 0 -- is on ladder
	self.body.numptpfcontacts = 0 -- is on passthrough platform
	self.body.nummvpfcontacts = 0 -- is on moving platform
	self.body.canjump = true
	self.body.wasonptpf = false
	self.body.isgoingdownplatform = false
	self.body.isdirty = false
	self.body.isdead = false
	self.body.timer = 0
	self.body.issensor = nil
	self.body.isonnme = nil -- is on nme
	-- LISTENERS
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

-- PLAYER LOOP
function Character_Base:onEnterFrame(e)
	if not self.body.isdead then
		local vx, vy = self.body:getLinearVelocity()
		local desiredVelX, desiredVelY = 0, 0
		self.body:setGravityScale(1)
		self.body.wasonptpf = false

		if self.body.isdirty then
			self.body.currentnrg -= 1
			self.body.currentanim = "hurt"
			self.body.timer = 16 -- magik XXX
		-- IS ON NME?
		-- *********
		elseif self.body.isonnme then
			self.body:applyLinearImpulse(0, -self.body:getMass() * self.body.jumpspeed, self.body:getWorldCenter()) -- 4, magik XXX
		end
		if self.body.currentnrg <= 0 then
			self.body.currentlives -= 1
		end
		if self.body.currentlives <= 0 then -- dead
			self.body.currentanim = "death"
			self.body.timer = 60
			self.body.isdead = true
		end
		-- HURT ANIM = NO CONTROL!
		-- ************************
		if self.body.timer > 0 then -- funny hit anim :-)
--			if self.body.timer <= 0 then self.body.isdirty = false end
			self.body.timer -= 1

		-- CONTROLS
		-- FLOOR ONLY
		-- ***********
		elseif self.body.numfloorcontacts > 0
				and self.body.numladdercontacts <= 0
				and self.body.numptpfcontacts <= 0
				and self.body.nummvpfcontacts <= 0
				then
--			print("FLOOR ONLY", e.deltaTime)
			-- animations
			if vx >= -1 and vx <= 1 then self.body.currentanim = "idle"
			else self.body.currentanim = "run"
			end
			-- controls
			if self.body.isleft and not self.body.isright then desiredVelX = -self.body.movespeed self.body.flip = -1
			elseif self.body.isright and not self.body.isleft then desiredVelX = self.body.movespeed self.body.flip = 1
			end
			if self.body.isup and not self.body.isdown and self.body.canjump and self.body.numjumpcount > 0 then
				desiredVelY = -self.body.jumpspeed
				if vy < -4 then
--					print("aaaaaaaaaa", vy, e.deltaTime)
					desiredVelY = -self.body.jumpspeed * 0.2
				end
				self.body.canjump = false
				self.body.numjumpcount -= 1
--			elseif self.body.isdown and not self.body.isup then
			end

		-- FLOOR & LADDER
		-- ***********
		elseif self.body.numfloorcontacts > 0
				and self.body.numladdercontacts > 0
				and self.body.numptpfcontacts <= 0
				and self.body.nummvpfcontacts <= 0
				then
--			print("FLOOR & LADDER", e.deltaTime)
			-- animations
			if vy <= -1 then self.body.currentanim = "climbup"
			elseif vy >= 1 then self.body.currentanim = "climbdown"
			else self.body.currentanim = "climbidle"
			end
			-- controls
			self.body:setGravityScale(-vy)
			if self.body.isleft and not self.body.isright then desiredVelX = -self.body.movespeed self.body.flip = -1
			elseif self.body.isright and not self.body.isleft then desiredVelX = self.body.movespeed self.body.flip = 1
			end
			if self.body.isup and not self.body.isdown then
				desiredVelY = -self.body.jumpspeed*0.2
			elseif self.body.isdown and not self.body.isup then
				desiredVelY = self.body.jumpspeed*0.2
			end

		-- FLOOR & PTPF
		-- ***********
		elseif self.body.numfloorcontacts > 0
				and self.body.numladdercontacts <= 0
				and self.body.numptpfcontacts > 0
				and self.body.nummvpfcontacts <= 0
				then
	--		print("FLOOR & PTPF", e.deltaTime)
			-- animations
			if vx >= -1 and vx <= 1 then self.body.currentanim = "idle"
			else self.body.currentanim = "run"
			end
			-- controls
			self.body.wasonptpf = true
			if self.body.isleft and not self.body.isright then desiredVelX = -self.body.movespeed self.body.flip = -1
			elseif self.body.isright and not self.body.isleft then desiredVelX = self.body.movespeed self.body.flip = 1
			end
			if self.body.isup and not self.body.isdown and self.body.canjump and self.body.numjumpcount > 0 then
				desiredVelY = -self.body.jumpspeed
				self.body.canjump = false
				self.body.numjumpcount -= 1
			elseif self.body.isdown and not self.body.isup then
				self.body.isgoingdownplatform = true
				desiredVelY = self.body.jumpspeed * 0.1 -- 0.2
			end

		-- FLOOR & MVPF
		-- ***********
		elseif self.body.numfloorcontacts > 0
				and self.body.numladdercontacts <= 0
				and self.body.numptpfcontacts <= 0
				and self.body.nummvpfcontacts > 0
				then
	--		print("floor & mvpf", e.deltaTime)
			-- animations
			if vx >= -1 and vx <= 1 then self.body.currentanim = "idle"
			else self.body.currentanim = "run"
			end
			-- controls
			if self.body.isleft and not self.body.isright then desiredVelX = -self.body.movespeed self.body.flip = -1
			elseif self.body.isright and not self.body.isleft then desiredVelX = self.body.movespeed self.body.flip = 1
			else vx = 0 -- must keep, moves body along with platform
			end
			if self.body.isup and not self.body.isdown and self.body.canjump and self.body.numjumpcount > 0 then
				desiredVelY = -self.body.jumpspeed
				self.body.canjump = false
				self.body.numjumpcount -= 1
			end

		-- FLOOR & LADDER & PTPF
		-- ***********
		elseif self.body.numfloorcontacts > 0
				and self.body.numladdercontacts > 0
				and self.body.numptpfcontacts > 0
				and self.body.nummvpfcontacts <= 0
				then
--			print("FLOOR & LADDER & PTPF", e.deltaTime)
			-- animations
			if vy <= -1 then self.body.currentanim = "climbup"
			elseif vy >= 1 then self.body.currentanim = "climbdown"
			else self.body.currentanim = "climbidle"
			end
			-- controls
			self.body:setGravityScale(-vy)
			if self.body.isleft and not self.body.isright then desiredVelX = -self.body.movespeed*0.5 self.body.flip = -1
			elseif self.body.isright and not self.body.isleft then desiredVelX = self.body.movespeed*0.5 self.body.flip = 1
			end
			if self.body.isup and not self.body.isdown then
				desiredVelY = -self.body.jumpspeed*0.2
				self.body.canjump = false
			elseif self.body.isdown and not self.body.isup then
				self.body.isgoingdownplatform = true
				desiredVelY = self.body.jumpspeed*0.2
			end

		-- FLOOR & LADDER & MVPF
		-- ***********
		elseif self.body.numfloorcontacts > 0
				and self.body.numladdercontacts > 0
				and self.body.numptpfcontacts <= 0
				and self.body.nummvpfcontacts > 0
				then
			print("FLOOR & LADDER & MVPF", e.deltaTime)

		-- FLOOR & LADDER & PTPF & MVPF
		-- ***********
		elseif self.body.numfloorcontacts > 0
				and self.body.numladdercontacts > 0
				and self.body.numptpfcontacts > 0
				and self.body.nummvpfcontacts > 0
				then
			print("FLOOR & LADDER & PTPF & MVPF", e.deltaTime)

		-- FLOOR & PTPF & MVPF
		-- ***********
		elseif self.body.numfloorcontacts > 0
				and self.body.numladdercontacts <= 0
				and self.body.numptpfcontacts > 0
				and self.body.nummvpfcontacts > 0
				then
--			print("FLOOR & PTPF & MVPF", e.deltaTime)
			-- animations
			if vx >= -1 and vx <= 1 then self.body.currentanim = "idle"
			else self.body.currentanim = "run"
			end
			-- controls
			self.body.wasonptpf = true
			if self.body.isleft and not self.body.isright then desiredVelX = -self.body.movespeed self.body.flip = -1
			elseif self.body.isright and not self.body.isleft then desiredVelX = self.body.movespeed self.body.flip = 1
			end
			if self.body.isup and not self.body.isdown and self.body.canjump and self.body.numjumpcount > 0 then
				desiredVelY = -self.body.jumpspeed
				self.body.canjump = false
				self.body.numjumpcount -= 1
			elseif self.body.isdown and not self.body.isup then
				desiredVelY = self.body.jumpspeed
				self.body.isgoingdownplatform = true
			end

		-- LADDER ONLY
		-- ***********
		elseif self.body.numfloorcontacts <= 0
				and self.body.numladdercontacts > 0
				and self.body.numptpfcontacts <= 0
				and self.body.nummvpfcontacts <= 0
				then
--			print("LADDER ONLY", e.deltaTime)
			-- animations
			if vy < -1 then self.body.currentanim = "climbup"
			elseif vy > 1 then self.body.currentanim = "climbdown"
			else self.body.currentanim = "climbidle"
			end
			-- controls
			self.body:setGravityScale(-vy)
			if self.body.isleft and not self.body.isright then desiredVelX = -self.body.movespeed*0.5 self.body.flip = -1
			elseif self.body.isright and not self.body.isleft then desiredVelX = self.body.movespeed*0.5 self.body.flip = 1
			end
			if self.body.isup and not self.body.isdown then desiredVelY = -self.body.jumpspeed*0.2
			elseif self.body.isdown and not self.body.isup then desiredVelY = self.body.jumpspeed*0.2
			end

		-- LADDER & PTPF
		-- ***********
		elseif self.body.numfloorcontacts <= 0
				and self.body.numladdercontacts > 0
				and self.body.numptpfcontacts > 0
				and self.body.nummvpfcontacts <= 0
				then
--			print("LADDER & PTPF", e.deltaTime)
			-- animations
			if vy < -1 then self.body.currentanim = "climbup"
			elseif vy > 1 then self.body.currentanim = "climbdown"
			else self.body.currentanim = "climbidle"
			end
			-- controls
			self.body:setGravityScale(-vy)
			if self.body.isleft and not self.body.isright then desiredVelX = -self.body.movespeed*0.5 self.body.flip = -1
			elseif self.body.isright and not self.body.isleft then desiredVelX = self.body.movespeed*0.5 self.body.flip = 1
			end
			if self.body.isup and not self.body.isdown then desiredVelY = -self.body.jumpspeed*0.1 self.body.canjump = false -- OK
			elseif self.body.isdown and not self.body.isup then desiredVelY = self.body.jumpspeed*0.1 -- OK
			end

		-- LADDER & MVPF
		-- ***********
		elseif self.body.numfloorcontacts <= 0
				and self.body.numladdercontacts > 0
				and self.body.numptpfcontacts <= 0
				and self.body.nummvpfcontacts > 0
				then
			print("LADDER & MVPF", e.deltaTime)

		-- LADDER & PTPF & MVPF
		-- ***********
		elseif self.body.numfloorcontacts <= 0
				and self.body.numladdercontacts > 0
				and self.body.numptpfcontacts > 0
				and self.body.nummvpfcontacts > 0
				then
			print("LADDER & PTPF & MVPF", e.deltaTime)

		-- PTPF ONLY
		-- ***********
		elseif self.body.numfloorcontacts <= 0
				and self.body.numladdercontacts <= 0
				and self.body.numptpfcontacts > 0
				and self.body.nummvpfcontacts <= 0
				then
--			print("PTPF ONLY", e.deltaTime)
			-- animations
			if vx >= -1 and vx <= 1 then self.body.currentanim = "idle"
			else self.body.currentanim = "run"
			end
			-- controls
			self.body.wasonptpf = true
			if self.body.isleft and not self.body.isright then desiredVelX = -self.body.movespeed self.body.flip = -1
			elseif self.body.isright and not self.body.isleft then desiredVelX = self.body.movespeed self.body.flip = 1
			end
			if self.body.isup and self.body.canjump and self.body.numjumpcount > 0 and not self.body.isdown then
				desiredVelY = -self.body.jumpspeed
				self.body.canjump = false
				self.body.numjumpcount -= 1
			elseif self.body.isdown and not self.body.isup then
				self.body.isgoingdownplatform = true
				desiredVelY = self.body.jumpspeed*0.1
			end

		-- PTPF & MVPF
		-- ***********
		elseif self.body.numfloorcontacts <= 0
				and self.body.numladdercontacts <= 0
				and self.body.numptpfcontacts > 0
				and self.body.nummvpfcontacts > 0
				then
			print("PTPF & MVPF", e.deltaTime)

		-- MVPF ONLY
		-- ***********
		elseif self.body.numfloorcontacts <= 0
				and self.body.numladdercontacts <= 0
				and self.body.numptpfcontacts <= 0
				and self.body.nummvpfcontacts > 0
				then
--			print("MVPF ONLY", e.deltaTime)
			-- animations
			if vx >= -1 and vx <= 1 then self.body.currentanim = "idle"
			else self.body.currentanim = "run"
			end
			-- controls
			if self.body.isleft and not self.body.isright then desiredVelX = -self.body.movespeed self.body.flip = -1
			elseif self.body.isright and not self.body.isleft then desiredVelX = self.body.movespeed self.body.flip = 1
			else vx = 0 -- must keep, moves body along with platform
			end
			if self.body.isup and self.body.canjump and self.body.numjumpcount > 0 and not self.body.isdown then
				desiredVelY = -self.body.jumpspeed
				self.body.canjump = false
				self.body.numjumpcount -= 1
			elseif self.body.isdown and not self.body.isup then
				desiredVelY = self.body.jumpspeed*0.1
			else vy = 0 -- can delete!
			end

		-- AIR
		-- ***
		elseif self.body.numfloorcontacts <= 0
				and self.body.numladdercontacts <= 0
				and self.body.numptpfcontacts <= 0
				and self.body.nummvpfcontacts <= 0
				then
	--		print("air only", e.deltaTime)
			-- animations
			if vy >= 0 then self.body.currentanim = "jumpdown"
			else self.body.currentanim = "jumpup"
			end
			-- controls
			if self.body.isleft and not self.body.isright then desiredVelX = -self.body.movespeed self.body.flip = -1
			elseif self.body.isright and not self.body.isleft then desiredVelX = self.body.movespeed self.body.flip = 1
			end
			if self.body.isup and self.body.canjump and self.body.numjumpcount > 0 and not self.body.isdown then
--				if vy < -4 then desiredVelY = -self.body.jumpspeed * 0.4 -- -4, 0.4
				if vy < -4 then desiredVelY = -self.body.jumpspeed * 0.2
				else desiredVelY = -self.body.jumpspeed
				end
--				desiredVelY = -self.body.jumpspeed
				self.body.canjump = false
				self.body.numjumpcount -= 1
			end

		-- error
		else
			print(
				"floor", self.body.numfloorcontacts,
				"ladder", self.body.numladdercontacts,
				"ptpf", self.body.numptpfcontacts,
				"mvpf", self.body.nummvpfcontacts,
				e.deltaTime
			)
		end

		-- debug
--[[
		if self.body.isup or self.body.isdown then
			print(vy, e.deltaTime)
		end
		if self.body.isup or self.body.isdown then
			print(
				"floor", self.body.numfloorcontacts,
				"ladder", self.body.numladdercontacts,
				"ptpf", self.body.numptpfcontacts,
				"mvpf", self.body.nummvpfcontacts,
				e.deltaTime
			)
		end
]]

		-- final movements
		local velChange = desiredVelX - vx
		local impulse = self.body:getMass() * velChange
		self.body:applyLinearImpulse(impulse, desiredVelY, self.body:getWorldCenter())
		-- animations
		self:playAnim(e.deltaTime)
		-- update position
		self:setPosition(self.body:getPosition())
		self.bitmap:setScale(self.body.playerscale * self.body.flip, self.body.playerscale)
	end
end

-- FUNCTIONS
function Character_Base:createAnim(xanimname, xstart, xfinish)
	self.anims[xanimname] = {}
	for i = xstart, xfinish do
		self.anims[xanimname][#self.anims[xanimname] + 1] = self.spritesheetimgs[i]
	end
end
function Character_Base:playAnim(xdt)
	if self.body.currentanim ~= "" then
		self.body.animtimer = self.body.animtimer - xdt
		if self.body.animtimer <= 0 then
			self.body.frame += 1
			self.body.animtimer = self.body.animspeed
			-- for debugging purpose -- comment before release!
--			local result, msg = assert(#self.anims[self.body.currentanim], g_currentlevel..", "..self.body.name..", w="..self.w..", h="..self.h)
--			print(msg)
			-- fx
			if self.body.isdead then
				if self.body.frame > #self.anims[self.body.currentanim] then self.body.frame = #self.anims[self.body.currentanim] end
			else
				if self.body.frame > #self.anims[self.body.currentanim] then self.body.frame = 1 end
			end
			self.bitmap:setTextureRegion(self.anims[self.body.currentanim][self.body.frame])
		end
	end
end
