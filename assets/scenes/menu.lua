Menu = Core.class(Sprite)

function Menu:init()
	-- audio
	self.sound = Sound.new("audio/DM-CGS-16.ogg")
	self.channel = self.sound:play(0, nil, true)
	-- bg image
	local bg = Bitmap.new(Texture.new("gfx/menu/06_banksy_palestine.jpg"))
	bg:setAnchorPoint(0.5, 0.5)
	bg:setScale(3)
	bg:setColorTransform(128/255, 128/255, 128/255, 1)
	-- app title
	self.mytitle = ButtonMonster.new({
		text="BLOCKED", ttf=font00, textcolorup=0xff5959,
		hover=false,
	})
	self.mytitle:setRotation(-12)
	-- logo
	local logo = ButtonMonster.new({
		textscalexup=1, textscalexdown=1.1,
		text="mokatunprod (c)", ttf=font10, textcolorup=0xffffff, textcolordown=0xffff00,
	})
	-- buttons
	self.selector = 1
	local pixelcolor = 0x3d2e33 -- shared amongst ui buttons
	local pixelalphaup = 0.2 -- shared amongst ui buttons
	local pixelalphadown = 0.5 -- shared amongst ui buttons
	local textcolorup = 0x0009B3 -- shared amongst ui buttons
	local textcolordown = 0x45d1ff -- shared amongst ui buttons
	local mybtn = ButtonMonster.new({
		scalexup=1, scalexdown=1.2,
		pixelcolorup=pixelcolor, pixelalphaup=pixelalphaup, pixelalphadown=pixelalphadown,
		text="    GAME   ", ttf=font01, textcolorup=textcolorup, textcolordown=textcolordown,
		channel=self.channel, sound=self.sound,
	}, 1)
	local mybtn02 = ButtonMonster.new({
		scalexup=1, scalexdown=1.2,
		pixelcolorup=pixelcolor, pixelalphaup=pixelalphaup, pixelalphadown=pixelalphadown,
		text="OPTIONS", ttf=font01, textcolorup=textcolorup, textcolordown=textcolordown,
		channel=self.channel, sound=self.sound,
	}, 2)
	local mybtn03 = ButtonMonster.new({
		scalexup=1, scalexdown=1.2,
		pixelcolorup=pixelcolor, pixelalphaup=pixelalphaup, pixelalphadown=pixelalphadown,
		text="    QUIT    ", ttf=font01, textcolorup=textcolorup, textcolordown=textcolordown,
		channel=self.channel, sound=self.sound,
	}, 3)
	-- positions
	bg:setPosition(myappwidth/2, myappheight/2)
	self.mytitle:setPosition(0.6*myappwidth/2, 3.75*myappheight/10)
	logo:setPosition(0.22*myappwidth/2, 0.97*myappheight)
	mybtn:setPosition(1.5*myappwidth/2, 3.5*myappheight/10)
	mybtn02:setPosition(1.5*myappwidth/2, 5*myappheight/10)
	mybtn03:setPosition(1.5*myappwidth/2, 6.5*myappheight/10)
	-- order
	self:addChild(bg)
	self:addChild(self.mytitle)
	self:addChild(logo)
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
	-- scene listeners
	self:addEventListener("enterBegin", self.onTransitionInBegin, self)
	self:addEventListener("enterEnd", self.onTransitionInEnd, self)
	self:addEventListener("exitBegin", self.onTransitionOutBegin, self)
	self:addEventListener("exitEnd", self.onTransitionOutEnd, self)
end

-- game loop
local timer = 0
function Menu:onEnterFrame(e)
	timer += 0.01
	-- title fx
	self.mytitle:setRotation(8*math.cos(timer))
end

-- EVENT LISTENERS
function Menu:onTransitionInBegin() self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function Menu:onTransitionInEnd() self:myKeysPressed() end
function Menu:onTransitionOutBegin() self:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function Menu:onTransitionOutEnd() end

-- KEYS HANDLER
function Menu:myKeysPressed()
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
function Menu:updateUiVfx()
	for k, v in ipairs(self.btns) do v.iskeyboard = true v:updateVisualState() end
end
function Menu:updateUiSfx()
	for k, v in ipairs(self.btns) do
		if k == self.selector then self.channel = self.sound:play() end
	end
end

-- scenes ui keyboard navigation
function Menu:goto()
	for k, v in ipairs(self.btns) do
		if k == self.selector then
			if v.isdisabled then print("btn disabled!", k)
			elseif k == 1 then scenemanager:changeScene("level_select", 1, transitions[2], easings[2])
			elseif k == 2 then print(k)
			elseif k == 3 then self:back()
			else print("nothing here!", k)
			end
		end
	end
end

function Menu:back()
	application:exit()
end
