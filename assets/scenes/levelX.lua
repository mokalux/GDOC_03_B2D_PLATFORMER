LevelX = Core.class(Sprite)

function LevelX:init()
	-- audio
	local ambientsound
	if g_currentlevel == 1 then ambientsound = Sound.new("audio/Wind howl.wav")
	elseif g_currentlevel == 2 then ambientsound = Sound.new("audio/Wind howl.wav")
	end
	self.channel = ambientsound:play(0, true)
	self.channel:setVolume(0.5)
	-- bg
	application:setBackgroundColor(0x213557)
	local bg = Pixel.new(0xffffff, 1, myappwidth, myappheight)
	if g_currentlevel == 1 then bg:setColor(0x0, 1, 0x980DFD, 1, 90) -- cyber_punked
	elseif g_currentlevel == 2 then bg:setColor(0x0A7AA6, 1, 0x7FBFFF, 1, 90) -- flowers
	end
	self:addChild(bg)
	-- box2d world
	self.world = b2.World.new(0, 2.1*10, true)
	-- lists
	self.world.groundnmes = {}
	self.world.groundnmeskeep = {}
	self.world.airnmes = {}
	self.world.airnmeskeep = {}
	self.world.airfriendlies = {}
	self.world.airfriendlieskeep = {}
	self.world.coins = {}
--	self.world.isdebug = true
	-- the tiled level
	self.tiled_level = Tiled_Levels.new(self.world, tiled_levels[g_currentlevel], 1) -- 1 = tiled level scale
	-- gcam
	self.gcam = GCam.new(self.tiled_level.camera)
	self:addChild(self.gcam)
--[[
	-- debug draw
	local debugDraw = b2.DebugDraw.new()
	debugDraw:setFlags(
		b2.DebugDraw.SHAPE_BIT
		+ b2.DebugDraw.JOINT_BIT
--		+ b2.DebugDraw.AABB_BIT
		+ b2.DebugDraw.PAIR_BIT
		+ b2.DebugDraw.CENTER_OF_MASS_BIT
	)
	self.world:setDebugDraw(debugDraw)
	self.tiled_level.camera:addChild(debugDraw)
]]
	-- ui lives
	self.ui = Sprite.new()
	self.world.lives = {}
	for i = 1, self.world.player1.body.currentlives do
		local life = Bitmap.new(Texture.new("gfx/ui/item3.png"))
		self.world.lives[#self.world.lives + 1] = life
		life:setPosition((i-1) * 52, 8)
		self.ui:addChild(life)
	end
	self:addChild(self.ui)
	-- ui nrg
	self.world.nrgbar = Pixel.new(0x00ff00, 1, self.world.player1.body.currentnrg * 40, 32)
	self.world.nrgbar:setPosition(16, 64)
	self:addChild(self.world.nrgbar)
	-- ui score
	self.world.score = 0
	self.world.scoretf = TextField.new(nil, "SCORE: "..self.world.score)
	self.world.scoretf:setScale(4)
	self.world.scoretf:setPosition(180, 50)
	self.world.scoretf:setTextColor(0x00ffff)
	self:addChild(self.world.scoretf)
	-- setup
--	self.gcam:setDebug(true)
	self.gcam:setFollow(self.world.player1.body)
	self.gcam:setAutoSize(true)
	if g_currentlevel == 1 then
		self.gcam:setBounds(16*11, 0, self.tiled_level.mapwidth - 16*16.5, self.tiled_level.mapheight - 16*8)
		self.gcam:setAnchor(0.4, 0.47)
		self.gcam:zoom(1.9)
	elseif g_currentlevel == 2 then
		self.gcam:setBounds(16*9.25, 0, self.tiled_level.mapwidth - 16*17.2, self.tiled_level.mapheight - 16*13.4)
		self.gcam:setAnchor(0.35, 0.5)
		self.gcam:zoom(2)
	end
	-- nmes lists
	for k, v in pairs(self.world.groundnmes) do
		self.tiled_level.mg:addChild(k)
	end
	for k, v in pairs(self.world.groundnmeskeep) do
		self.tiled_level.mg:addChild(k)
	end
	for k, v in pairs(self.world.airnmes) do
		self.tiled_level.mg:addChild(k)
	end
	for k, v in pairs(self.world.airnmeskeep) do
		self.tiled_level.mg:addChild(k)
	end
	-- mobile controls
--	if application:getDeviceInfo() == "Android" or application:getDeviceInfo() == "Web" then
		local mobile = MobileXv1.new(self.world.player1)
		self:addChild(mobile)
--	end
	-- gideros particles
	local particleGFX = Texture.new("gfx/fx/smoke.png")
	self.stars = Particles.new()
	self.stars:setTexture(particleGFX)
	self.tiled_level.bg:addChild(self.stars)
	-- PLAYER1 LISTENERS
	self:addEventListener(Event.KEY_DOWN, self.world.player1.onKeyDown, self.world.player1)
	self:addEventListener(Event.KEY_UP, self.world.player1.onKeyUp, self.world.player1)
	-- BOX2D LISTENERS
	self.world:addEventListener(Event.BEGIN_CONTACT, self.onBeginContact, self)
	self.world:addEventListener(Event.END_CONTACT, self.onEndContact, self)
	self.world:addEventListener(Event.PRE_SOLVE, self.onPreSolveContact, self)
	self.world:addEventListener(Event.POST_SOLVE, self.onPostSolveContact, self)
	-- LISTENERS
	self.ispaused = false
	self:addEventListener("enterBegin", self.onTransitionInBegin, self)
	self:addEventListener("enterEnd", self.onTransitionInEnd, self)
	self:addEventListener("exitBegin", self.onTransitionOutBegin, self)
	self:addEventListener("exitEnd", self.onTransitionOutEnd, self)
end

-- GAME LOOP
local timer = 0
local posx, posy
function LevelX:onEnterFrame(e)
	if self.ispaused then return end
	if self.world.player1.body.isdead then self:reload() end
	-- timer
	timer += 1
	-- nme AI
	posx, posy = self.world.player1.body:getPosition()
--[[
	-- particles
	if application:getDeviceInfo() == "Android" or application:getDeviceInfo() == "Web" then
		if timer % 4 == 0 then
			self.stars:addParticles({
				{
					x=math.random(self.tiled_level.mapwidth),
					y=math.random(self.tiled_level.mapheight * 0.5),
					size=196,angle=math.random(360),
					color=0xffffff,alpha=0.2,
					ttl=16*64,
					speedX=0.01,speedY=0.01,speedAngular=0.15,
					speedGrowth=0.5,
				},
				{
					x=math.random(self.tiled_level.mapwidth),
					y=math.random(self.tiled_level.mapheight),
					size=64,angle=math.random(360/2),
					color=0x0,alpha=0.2,
					ttl=8*64,
					speedX=0.01,speedY=0.01,speedAngular=0.015,
					speedGrowth=0.5,
					decayAngular=0.5,
				},
			})
		end
	else -- pc
		if timer % 2 == 0 then
			self.stars:addParticles({
				{
					x=math.random(self.tiled_level.mapwidth),
					y=math.random(self.tiled_level.mapheight * 0.5),
					size=196,angle=math.random(360),
					color=0xffffff,alpha=0.2,
					ttl=16*64,
					speedX=0.01,speedY=0.01,speedAngular=0.15,
					speedGrowth=0.5,
				},
				{
					x=math.random(self.tiled_level.mapwidth),
					y=math.random(self.tiled_level.mapheight),
					size=64,angle=math.random(360/2),
					color=0x0,alpha=0.2,
					ttl=8*64,
					speedX=0.01,speedY=0.01,speedAngular=0.015,
					speedGrowth=0.5,
		--			decay=1.001,
					decayAngular=0.5,
		--			decayGrowth=1, -- 4
		--			decayAlpha=1,
				},
			})
		end
	end
]]
	-- liquidfun
	self.world:step(e.deltaTime, 9, 2) -- e.deltaTime 1/60, 8, 3
	self.gcam:update(e.deltaTime) -- e.deltaTime 1/60
	-- nmes lists
	for k, v in pairs(self.world.groundnmes) do
		if self.world.player1.body.isdirty then -- dirty
			k.body.isright = not k.body.isright k.body.isleft = not k.body.isleft
		elseif v.isdirty then -- dirty
			k.body.isright = not k.body.isright k.body.isleft = not k.body.isleft
		elseif v.issensor then -- attack
			local x1, y1 = v:getPosition()
			if x1 > posx + 64 then -- magik XXX
				k.body.isleft = true k.body.isright = false
			elseif x1 < posx - 64 then -- magik XXX
				k.body.isright = true k.body.isleft = false
			end
			if y1 > posy then
				if timer % (2 * 64) == 0 then
					k.body:applyLinearImpulse(0, -k.body:getMass(), k.body:getWorldCenter())
					k.body.isup = true
				end
			end
			if timer % (3 * 64) == 0 then k.body.isspace = true end
			if timer % (2 * 64) == 0 then k.body.isup = true end
--			if timer % (8 * 64) == 0 then if v.distanceJoint ~= nil then self.world:destroyJoint(v.distanceJoint) v.distanceJoint = nil end end
--			if timer % (3 * 64) == 0 then if not v.distanceJoint then k:joint() end end
		else -- roaming
			if timer % (2 * 64) == 0 then k.body.isright = true k.body.isleft = false end
			if timer % (4 * 64) == 0 then k.body.isright = false k.body.isleft = true end
		end
	end
	for k, v in pairs(self.world.groundnmeskeep) do
		if self.world.player1.body.isdirty then -- dirty
			k.body.isright = not k.body.isright k.body.isleft = not k.body.isleft
		elseif v.isdirty then -- dirty
			k.body.isright = not k.body.isright k.body.isleft = not k.body.isleft
		elseif v.issensor then -- attack
			local x1, y1 = v:getPosition()
			if x1 > posx + 64 then -- magik XXX
				k.body.isleft = true k.body.isright = false
			elseif x1 < posx - 64 then -- magik XXX
				k.body.isright = true k.body.isleft = false
			end
			if y1 > posy then
				k.body:applyLinearImpulse(0, -k.body:getMass(), k.body:getWorldCenter())
			end
			if timer % (3 * 64) == 0 then k.body.isspace = true end
			if timer % (2 * 64) == 0 then k.body.isup = true end
--			if timer % (8 * 64) == 0 then if v.distanceJoint ~= nil then self.world:destroyJoint(v.distanceJoint) v.distanceJoint = nil end end
--			if timer % (3 * 64) == 0 then if not v.distanceJoint then k:joint() end end
		else -- roaming
			if timer % (2 * 64) == 0 then k.body.isright = true k.body.isleft = false end
			if timer % (4 * 64) == 0 then k.body.isright = false k.body.isleft = true end
		end
	end
	for k, v in pairs(self.world.airnmes) do
		if self.world.player1.body.isdirty then -- dirty
			k.body.isright = not k.body.isright k.body.isleft = not k.body.isleft
		elseif v.isdirty then -- dirty
			k.body.isright = not k.body.isright k.body.isleft = not k.body.isleft
		elseif v.issensor then -- attack
			local x1, y1 = v:getPosition()
			if x1 > posx + 16 then -- magik XXX
				k.body.isleft = true k.body.isright = false
			elseif x1 < posx - 16 then -- magik XXX
				k.body.isright = true k.body.isleft = false
			end
			if y1 > posy then
				k.body:applyLinearImpulse(0, -k.body:getMass(), k.body:getWorldCenter())
			end
			if timer % (1 * 64) == 0 then k.body.isspace = true end
		else -- roaming
			if timer % (2 * 64) == 0 then k.body.isright = true k.body.isleft = false end
			if timer % (4 * 64) == 0 then k.body.isright = false k.body.isleft = true end
		end
	end
	for k, v in pairs(self.world.airnmeskeep) do
		if self.world.player1.body.isdirty then -- dirty
			k.body.isright = not k.body.isright k.body.isleft = not k.body.isleft
		elseif v.isdirty then -- dirty
			k.body.isright = not k.body.isright k.body.isleft = not k.body.isleft
		elseif v.issensor then -- attack
			local x1, y1 = v:getPosition()
			if x1 > posx + 16 then -- magik XXX
				k.body.isleft = true k.body.isright = false
			elseif x1 < posx - 16 then -- magik XXX
				k.body.isright = true k.body.isleft = false
			end
			if y1 > posy then
				k.body:applyLinearImpulse(0, -k.body:getMass(), k.body:getWorldCenter())
			end
			if timer % (1 * 256) == 0 then k.body.isspace = true end
		else -- roaming
			if timer % (2 * 64) == 0 then k.body.isright = true k.body.isleft = false end
			if timer % (4 * 64) == 0 then k.body.isright = false k.body.isleft = true end
		end
	end
	-- player1
	if self.world.player1.body.isdirty then self.gcam:shake(3, 24) end
end

-- BOX2D
function LevelX:onBeginContact(e)
	local fixtureA, fixtureB = e.fixtureA, e.fixtureB
	local bodyA, bodyB = fixtureA:getBody(), fixtureB:getBody()
	-- PLAYER1
	if (bodyA.name == G_PLAYER and bodyB.name == G_GROUND) or (bodyA.name == G_GROUND and bodyB.name == G_PLAYER) then
		if bodyA.name == G_PLAYER then bodyA.numfloorcontacts += 1  bodyA.numjumpcount = bodyA.maxnumjump
		else bodyB.numfloorcontacts += 1 bodyB.numjumpcount = bodyB.maxnumjump
		end
	end
	if (bodyA.name == G_PLAYER and bodyB.name == G_LADDER) or (bodyA.name == G_LADDER and bodyB.name == G_PLAYER) then
		if bodyA.name == G_PLAYER then bodyA.numladdercontacts += 1 bodyA.numjumpcount = bodyA.maxnumjump
		else bodyB.numladdercontacts += 1 bodyB.numjumpcount = bodyB.maxnumjump
		end
	end
	if (bodyA.name == G_PLAYER and bodyB.name == G_PTPLATFORM) or (bodyA.name == G_PTPLATFORM and bodyB.name == G_PLAYER) then
		if bodyA.name == G_PLAYER then
			bodyA.numptpfcontacts += 1 bodyA.numjumpcount = bodyA.maxnumjump
			if bodyA.isdown then bodyA.isgoingdownplatform = true
			else bodyA.isgoingdownplatform = false
			end
		else
			bodyB.numptpfcontacts += 1 bodyB.numjumpcount = bodyB.maxnumjump
			if bodyB.isdown then bodyB.isgoingdownplatform = true
			else bodyB.isgoingdownplatform = false
			end
		end
	end
	if (bodyA.name == G_PLAYER and bodyB.name == G_MVPLATFORM) or (bodyA.name == G_MVPLATFORM and bodyB.name == G_PLAYER) then
		if bodyA.name == G_PLAYER then bodyA.nummvpfcontacts += 1 bodyA.numjumpcount = bodyA.maxnumjump
		else bodyB.nummvpfcontacts += 1 bodyB.numjumpcount = bodyB.maxnumjump
		end
	end
	if (bodyA.name == G_PLAYER and bodyB.name == G_COIN) or (bodyA.name == G_COIN and bodyB.name == G_PLAYER) then
		if bodyA.name == G_COIN then bodyA.isdirty = true
		else bodyB.isdirty = true
		end
	end
	if (bodyA.name == G_PLAYER and bodyB.name == G_EXIT) or (bodyA.name == G_EXIT and bodyB.name == G_PLAYER) then
		if bodyA.name == G_PLAYER then bodyB.isdirty = true
		else bodyA.isdirty = true
		end
	end
	-- NME
	if (bodyA.name == G_ENEMY01 and bodyB.name == G_PLAYER) or (bodyA.name == G_PLAYER and bodyB.name == G_ENEMY01) then
		if bodyA.name == G_ENEMY01 then
--			bodyA:setSleepingAllowed(false)
			bodyA.issensor = true
			if not fixtureA:isSensor() and not fixtureB:isSensor() then
--				print("isonnme")
				local _, vy = bodyB:getLinearVelocity()
				if vy > 1 then bodyA.isdirty = true bodyB.isonnme = true -- magik XXX
				else bodyB.isdirty = true
				end
			end
		else
--			bodyB:setSleepingAllowed(false)
			bodyB.issensor = true
			if not fixtureB:isSensor() and not fixtureA:isSensor() then
--				print("isonnme")
				local _, vy = bodyA:getLinearVelocity()
				if vy > 1 then bodyB.isdirty = true bodyA.isonnme = true -- magik XXX
				else bodyA.isdirty = true
				end
			end
		end
	end
	if (bodyA.name == G_ENEMY01 and bodyB.name == G_GROUND) or (bodyA.name == G_GROUND and bodyB.name == G_ENEMY01) then
		if bodyA.name == G_ENEMY01 then bodyA.numfloorcontacts += 1  bodyA.numjumpcount = bodyA.maxnumjump
		else bodyB.numfloorcontacts += 1 bodyB.numjumpcount = bodyB.maxnumjump
		end
	end
	if (bodyA.name == G_ENEMY01 and bodyB.name == G_LADDER) or (bodyA.name == G_LADDER and bodyB.name == G_ENEMY01) then
		if bodyA.name == G_ENEMY01 then bodyA.numladdercontacts += 1 bodyA.numjumpcount = bodyA.maxnumjump
		else bodyB.numladdercontacts += 1 bodyB.numjumpcount = bodyB.maxnumjump
		end
	end
	if (bodyA.name == G_ENEMY01 and bodyB.name == G_PTPLATFORM) or (bodyA.name == G_PTPLATFORM and bodyB.name == G_ENEMY01) then
		if bodyA.name == G_ENEMY01 then
			bodyA.numptpfcontacts += 1 bodyA.numjumpcount = bodyA.maxnumjump
			if bodyA.isdown then bodyA.isgoingdownplatform = true
			else bodyA.isgoingdownplatform = false
			end
		else
			bodyB.numptpfcontacts += 1 bodyB.numjumpcount = bodyB.maxnumjump
			if bodyB.isdown then bodyB.isgoingdownplatform = true
			else bodyB.isgoingdownplatform = false
			end
		end
	end
	if (bodyA.name == G_ENEMY01 and bodyB.name == G_MVPLATFORM) or (bodyA.name == G_MVPLATFORM and bodyB.name == G_ENEMY01) then
		if bodyA.name == G_ENEMY01 then bodyA.nummvpfcontacts += 1 bodyA.numjumpcount = bodyA.maxnumjump
		else bodyB.nummvpfcontacts += 1 bodyB.numjumpcount = bodyB.maxnumjump
		end
	end
	if (bodyA.name == G_ENEMY01 and bodyB.name == G_BLOCK) or (bodyA.name == G_BLOCK and bodyB.name == G_ENEMY01) then
		if bodyA.name == G_ENEMY01 then bodyA.isleft = not bodyA.isleft bodyA.isright = not bodyA.isright
		else bodyB.isleft = not bodyB.isleft bodyB.isright = not bodyB.isright
		end
	end
	-- BULLETS
	if bodyA.name == G_PLAYER_BULLET or bodyB.name == G_PLAYER_BULLET then
		bodyA.isdirty = true bodyB.isdirty = true
	end
	if bodyA.name == G_ENEMY_BULLET or bodyB.name == G_ENEMY_BULLET then
		bodyA.isdirty = true bodyB.isdirty = true
	end
end

function LevelX:onEndContact(e)
	local fixtureA, fixtureB = e.fixtureA, e.fixtureB
	local bodyA, bodyB = fixtureA:getBody(), fixtureB:getBody()
	-- PLAYER1
	if (bodyA.name == G_PLAYER and bodyB.name == G_GROUND) or (bodyA.name == G_GROUND and bodyB.name == G_PLAYER) then
		if bodyA.name == G_PLAYER then bodyA.numfloorcontacts -= 1
		else bodyB.numfloorcontacts -= 1
		end
	end
	if (bodyA.name == G_PLAYER and bodyB.name == G_LADDER) or (bodyA.name == G_LADDER and bodyB.name == G_PLAYER) then
		if bodyA.name == G_PLAYER then bodyA.numladdercontacts -= 1
		else bodyB.numladdercontacts -= 1
		end
	end
	if (bodyA.name == G_PLAYER and bodyB.name == G_PTPLATFORM) or (bodyA.name == G_PTPLATFORM and bodyB.name == G_PLAYER) then
		if bodyA.name == G_PLAYER then bodyA.numptpfcontacts -= 1
			if bodyA.wasonptpf then bodyA.isdown = false end
		else bodyB.numptpfcontacts -= 1
			if bodyB.wasonptpf then bodyB.isdown = false end
		end
	end
	if (bodyA.name == G_PLAYER and bodyB.name == G_MVPLATFORM) or (bodyA.name == G_MVPLATFORM and bodyB.name == G_PLAYER) then
		if bodyA.name == G_PLAYER then bodyA.nummvpfcontacts -= 1
		else bodyB.nummvpfcontacts -= 1
		end
	end
	-- NME
	if (bodyA.name == G_ENEMY01 and bodyB.name == G_PLAYER) or (bodyA.name == G_PLAYER and bodyB.name == G_ENEMY01) then
		if bodyA.name == G_ENEMY01 then
--			bodyA:setSleepingAllowed(true)
			bodyA.issensor = false bodyB.isonnme = false
		else
--			bodyB:setSleepingAllowed(true)
			bodyB.issensor = false bodyA.isonnme = false
		end
	end
	if (bodyA.name == G_ENEMY01 and bodyB.name == G_GROUND) or (bodyA.name == G_GROUND and bodyB.name == G_ENEMY01) then
		if bodyA.name == G_ENEMY01 then bodyA.numfloorcontacts -= 1
		else bodyB.numfloorcontacts -= 1
		end
	end
	if (bodyA.name == G_ENEMY01 and bodyB.name == G_LADDER) or (bodyA.name == G_LADDER and bodyB.name == G_ENEMY01) then
		if bodyA.name == G_ENEMY01 then bodyA.numladdercontacts -= 1
		else bodyB.numladdercontacts -= 1
		end
	end
	if (bodyA.name == G_ENEMY01 and bodyB.name == G_PTPLATFORM) or (bodyA.name == G_PTPLATFORM and bodyB.name == G_ENEMY01) then
		if bodyA.name == G_ENEMY01 then bodyA.numptpfcontacts -= 1
		else bodyB.numptpfcontacts -= 1
		end
	end
	if (bodyA.name == G_ENEMY01 and bodyB.name == G_MVPLATFORM) or (bodyA.name == G_MVPLATFORM and bodyB.name == G_ENEMY01) then
		if bodyA.name == G_ENEMY01 then bodyA.nummvpfcontacts -= 1
		else bodyB.nummvpfcontacts -= 1
		end
	end
end

function LevelX:onPreSolveContact(e)
	local bodyA = e.fixtureA:getBody()
	local bodyB = e.fixtureB:getBody()
	local platform, playable
	if bodyA.name == G_PTPLATFORM then platform = bodyA playable = bodyB
	elseif bodyB.name == G_PTPLATFORM then platform = bodyB playable = bodyA
	end
	if not platform then return end
	-- playable
	if playable.isgoingdownplatform then
		e.contact:setEnabled(false)
		return
	end
	-- pass through platform
	local _, vy = playable:getLinearVelocity()
	if vy < 0 then -- going up = no collision, -1 otherwise wiggles
		e.contact:setEnabled(false)
	end
end

function LevelX:onPostSolveContact(e)
end

-- EVENT LISTENERS
function LevelX:onTransitionInBegin() self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function LevelX:onTransitionInEnd() self:myKeysPressed() end
function LevelX:onTransitionOutBegin() self:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function LevelX:onTransitionOutEnd() end

-- KEYS HANDLER
function LevelX:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e)
		-- for mobiles and desktops
		if e.keyCode == KeyCode.BACK or e.keyCode == KeyCode.ESC then
			scenemanager:changeScene("level_select", 1, transitions[2], easings[2])
		end
		if e.keyCode == KeyCode.F then isfullscreen = not isfullscreen setFullScreen(isfullscreen) end
		if e.keyCode == KeyCode.P then self.ispaused = not self.ispaused end
	end)
end

function LevelX:reload()
	scenemanager:changeScene("levelX", 5, transitions[1], easings[1])
end
