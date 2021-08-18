Level_Select = Core.class(Sprite)

function Level_Select:init()
	-- sound
	local ambientsound = Sound.new("audio/Wind howl.wav")
	self.channel = ambientsound:play(0, true)
	self.channel:setVolume(0.5)
	self.sound = Sound.new("audio/DM-CGS-16.ogg")
--	self.channel = self.sound:play(0, nil, true)
	-- bg
	local bg = Pixel.new(0xffffff, 1, myappwidth, myappheight)
	bg:setColor(0x0700FA, 1, 0x980DFD, 1, 90)
	-- level select
	self.mytitle = ButtonMonster.new({
		text="SELECT LEVEL", ttf=font00, textcolorup=0xff5959,
		hover=false,
	})
	-- buttons
	self.selector = 1
	local pixelcolor = 0x3d2e33 -- shared amongst ui buttons
	local pixelalphaup = 0.2 -- shared amongst ui buttons
	local pixelalphadown = 0.5 -- shared amongst ui buttons
	local textcolorup = 0x0009B3 -- shared amongst ui buttons
	local textcolordown = 0x45d1ff -- shared amongst ui buttons
	local mybtn = ButtonMonster.new({
		btnscalexup=1.5, btnscalexdown=1.7,
		imguppath="tiled/levels/cyberpunked/obj0006_result.png", imgpaddingx=128, imgpaddingy=96,
		text="LEVEL 1", ttf=font02, textcolorup=textcolorup, textcolordown=textcolordown,
		channel=self.channel, sound=self.sound,
	}, 1)
	local mybtn02 = ButtonMonster.new({
		btnscalexup=1.5, btnscalexdown=1.7,
		imguppath="tiled/levels/flowers/obj0012.png", imgpaddingx=144, imgpaddingy=112,
		text="LEVEL 2", ttf=font02, textcolorup=textcolorup, textcolordown=textcolordown,
		channel=self.channel, sound=self.sound,
	}, 2)
	local mybtn03 = ButtonMonster.new({
		btnscalexup=1.3, btnscalexdown=1.5,
		pixelcolorup=pixelcolor, pixelalphaup=pixelalphaup, pixelalphadown=pixelalphadown,
		text="MENU", ttf=font02, textcolorup=textcolorup, textcolordown=textcolordown,
		channel=self.channel, sound=self.sound,
	}, 3)
	-- positions
	self.mytitle:setPosition(myappwidth/2, 0.75*myappheight/10)
	mybtn:setPosition(0.5*myappwidth/2, 3.5*myappheight/10)
	mybtn02:setPosition(1.5*myappwidth/2, 3.5*myappheight/10)
	mybtn03:setPosition(myappwidth - mybtn03:getWidth(), myappheight - mybtn03:getHeight())
	-- order
	self:addChild(bg)
	self:addChild(self.mytitle)
	self:addChild(mybtn)
	self:addChild(mybtn02)
	self:addChild(mybtn03)
	-- btns table
	self.btns = {}
	self.btns[#self.btns + 1] = mybtn
	self.btns[#self.btns + 1] = mybtn02
	self.btns[#self.btns + 1] = mybtn03
	-- btns listeners
	for k, v in ipairs(self.btns) do
		v:addEventListener("clicked", function() self:goto() end) -- click event
		v.btns = self.btns -- ui navigation update
	end
	-- let's go!
	self:updateUiVfx()
	-- LISTENERS
	self:addEventListener("enterBegin", self.onTransitionInBegin, self)
	self:addEventListener("enterEnd", self.onTransitionInEnd, self)
	self:addEventListener("exitBegin", self.onTransitionOutBegin, self)
	self:addEventListener("exitEnd", self.onTransitionOutEnd, self)
end

-- GAME LOOP
local timer = 0
function Level_Select:onEnterFrame(e)
end

-- EVENT LISTENERS
function Level_Select:onTransitionInBegin() self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function Level_Select:onTransitionInEnd() self:myKeysPressed() end
function Level_Select:onTransitionOutBegin() self:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function Level_Select:onTransitionOutEnd() end

-- KEYS HANDLER
function Level_Select:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e)
		-- for mobiles and desktops
		if e.keyCode == KeyCode.BACK or e.keyCode == KeyCode.ESC then self:back() end
		-- keyboard
		if e.keyCode == KeyCode.I or e.keyCode == KeyCode.UP or e.keyCode == KeyCode.J or e.keyCode == KeyCode.LEFT then
			self.selector -= 1 if self.selector < 1 then self.selector = #self.btns end
			self:updateUiVfx() self:updateUiSfx()
		elseif e.keyCode == KeyCode.K or e.keyCode == KeyCode.DOWN or e.keyCode == KeyCode.L or e.keyCode == KeyCode.RIGHT then
			self.selector += 1 if self.selector > #self.btns then self.selector = 1 end
			self:updateUiVfx() self:updateUiSfx()
		end
		if e.keyCode == KeyCode.ENTER then self:goto() end
		if e.keyCode == KeyCode.F then isfullscreen = not isfullscreen setFullScreen(isfullscreen) end
	end)
end

-- fx
function Level_Select:updateUiVfx()
	for k, v in ipairs(self.btns) do v.iskeyboard = true v:updateVisualState() end
end
function Level_Select:updateUiSfx()
	for k, v in ipairs(self.btns) do
		if k == self.selector then self.channel = self.sound:play() end
	end
end

-- scenes ui keyboard navigation
function Level_Select:goto()
	for k, v in ipairs(self.btns) do
		if k == self.selector then
			if v.isdisabled then print("btn disabled!", k)
			elseif k == 1 then g_currentlevel = k scenemanager:changeScene("levelX", 1, transitions[2], easings[2])
			elseif k == 2 then g_currentlevel = k scenemanager:changeScene("levelX", 1, transitions[2], easings[2])
			elseif k == 3 then self:back()
			else print("nothing here!", k)
			end
		end
	end
end

function Level_Select:back()
	scenemanager:changeScene("menu", 3, transitions[1], easings[1])
end
