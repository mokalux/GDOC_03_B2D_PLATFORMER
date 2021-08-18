-- ***************************************
--[[
   v.3.1
   (c)Oleg Simonenko
	simartinfo.blogspot.com
	github.com/razorback456/gideros_tools
]]
-- ***************************************

ButtonOleg = gideros.class(Sprite)

function ButtonOleg:init(xtex, xcolor, xscalex, xscaley, xalpha)
	self.alpha = xalpha or nil
	self.bmp = Bitmap.new(xtex, true)
--	self.bmp:setTextColor(xcolor or 0x0)
	self.bmp:setScale(xscalex, xscaley)
	self.bmp:setAlpha(self.alpha or 0)
	self:addChild(self.bmp)
	-- listeners
	self:addEventListener(Event.TOUCHES_BEGIN, self.onTouchesBegin, self)
	self:addEventListener(Event.TOUCHES_MOVE, self.onTouchesMove, self)
	self:addEventListener(Event.TOUCHES_END, self.onTouchesEnd, self)
end

function ButtonOleg:onTouchesBegin(e)
	if self:hitTestPoint(e.touch.x, e.touch.y) then
		self:dispatchEvent(Event.new("clickDown"))
		if self.alpha then
			local tempalpha = self.alpha + 0.2
			self.bmp:setAlpha(tempalpha)
		end
	end
end

function ButtonOleg:onTouchesMove(e)
	if self:hitTestPoint(e.touch.x, e.touch.y) then
		self:dispatchEvent(Event.new("clickMove"))
		if self.alpha then
			local tempalpha = self.alpha + 0.2
			self.bmp:setAlpha(tempalpha)
		end
	end
end

function ButtonOleg:onTouchesEnd(e)
	if self:hitTestPoint(e.touch.x, e.touch.y) then
		self:dispatchEvent(Event.new("clickUp"))
		if self.alpha then
			local tempalpha = self.alpha
			self.bmp:setAlpha(tempalpha)
		end
	end
end

-- ************************
-- *** 2 PADS DIRECTION ***
-- ************************
MobileXv1 = Core.class(Sprite)

function MobileXv1:init(xhero)
	-- local variables
	local scalex, scaley = 6,4
	local alpha = 0.25 -- 0.15
	local texbtnup = Texture.new("gfx/ui/GUI_Items_0089.png")
	local texbtndown = Texture.new("gfx/ui/GUI_Items_0090.png")
	local texbtnleft = Texture.new("gfx/ui/GUI_Items_0087.png")
	local texbtnright = Texture.new("gfx/ui/GUI_Items_0088.png")
	local texbtnX = Texture.new("gfx/ui/GUI_Items_0125_Round-Rect.png")
	local texbtncanceller = Texture.new("gfx/ui/trp.png")
	-- left pad buttons
	local btnup = ButtonOleg.new(texbtnup, 0xffffff, scalex - 1, scaley, alpha) -- UP (B)
	btnup:setPosition(myappleft, myappbot - 2 * btnup:getHeight() - 4 * 1)
	self:addChild(btnup)
	local btndown = ButtonOleg.new(texbtndown, 0xffffff, scalex - 1, scaley, alpha) -- DOWN (A)
	btndown:setPosition(myappleft, myappbot - 1 * btndown:getHeight() - 4 * 0)
	self:addChild(btndown)
	local btnX = ButtonOleg.new(texbtnX, 0xff0000, scalex - 3.5, scaley - 1.5, alpha) -- SPACE (X)
	btnX:setPosition(myappleft + 1.2 * btnX:getWidth(), myappbot - 1.1 * btnX:getHeight())
	self:addChild(btnX)
	-- buttons CANCELLER -- LEFT PAD
	local btnscanceller1 = ButtonOleg.new(texbtncanceller, 0xffffff, scalex * 1.4, scaley * 2, nil) -- nil, 1
	btnscanceller1:setPosition(myappleft, myappbot - btnscanceller1:getHeight())
	self:addChild(btnscanceller1)

	-- right pad buttons
	local btnleft = ButtonOleg.new(texbtnleft, 0xffffff, scalex - 1, scaley + 1, alpha) -- LEFT
	btnleft:setPosition(myappright - 2 * btnleft:getWidth(), myappbot - 1 * btnleft:getHeight())
	self:addChild(btnleft)
	local btnright = ButtonOleg.new(texbtnright, 0xffffff, scalex - 1, scaley + 1, alpha) -- RIGHT
	btnright:setPosition(myappright - btnright:getWidth(), myappbot - 1 * btnright:getHeight())
	self:addChild(btnright)
	-- buttons CANCELLER -- RIGHT PAD
	local btnscanceller2 = ButtonOleg.new(texbtncanceller, 0xffffff, scalex * 1.4, scaley * 2, nil) -- nil, 1
	btnscanceller2:setPosition(myappright + myappleft - btnscanceller2:getWidth(), myappbot - btnscanceller2:getHeight())
	self:addChild(btnscanceller2)

	-- listeners
	-- CANCELLERS
	btnscanceller1:addEventListener("clickMove", function(e) -- BUTTON CANCELLER 1
--		e:stopPropagation()
		xhero.body.isup = false
		xhero.body.isdown = false
		xhero.body.isspace = false
	end)
	btnscanceller2:addEventListener("clickMove", function(e) -- BUTTON CANCELLER 2
--		e:stopPropagation()
		xhero.body.isright = false
		xhero.body.isleft = false
	end)

	-- BUTTONS
	btnup:addEventListener("clickDown", function(e) -- UP O
		e:stopPropagation()
		xhero.body.isup = true
	end)
	btnup:addEventListener("clickMove", function(e)
		xhero.body.isup = true
--		xhero.body.isup = false
		btnup.bmp:setAlpha(alpha)
		btndown.bmp:setAlpha(alpha)
		btnX.bmp:setAlpha(alpha)
	end)
	btnup:addEventListener("clickUp", function(e)
		e:stopPropagation()
		xhero.body.isup = false
		xhero.body.canjump = true
		btnup.bmp:setAlpha(alpha)
		btndown.bmp:setAlpha(alpha)
		btnX.bmp:setAlpha(alpha)
	end)

	btndown:addEventListener("clickDown", function(e) -- DOWN O
		e:stopPropagation()
		xhero.body.isdown = true
	end)
	btndown:addEventListener("clickMove", function(e)
		xhero.body.isdown = true
--		xhero.body.isdown = false
		btnup.bmp:setAlpha(alpha)
		btndown.bmp:setAlpha(alpha)
		btnX.bmp:setAlpha(alpha)
	end)
	btndown:addEventListener("clickUp", function(e)
		e:stopPropagation()
		xhero.body.isdown = false
		btnup.bmp:setAlpha(alpha)
		btndown.bmp:setAlpha(alpha)
		btnX.bmp:setAlpha(alpha)
	end)

	btnX:addEventListener("clickDown", function(e) -- SPACE X
		e:stopPropagation()
		xhero.body.isspace = true
	end)
	btnX:addEventListener("clickMove", function(e)
--		xhero.body.isspace = true
		xhero.body.isspace = false
		btnup.bmp:setAlpha(alpha)
		btndown.bmp:setAlpha(alpha)
		btnX.bmp:setAlpha(alpha)
	end)
	btnX:addEventListener("clickUp", function(e)
		e:stopPropagation()
		xhero.body.isspace = false
		btnup.bmp:setAlpha(alpha)
		btndown.bmp:setAlpha(alpha)
		btnX.bmp:setAlpha(alpha)
	end)

	btnleft:addEventListener("clickDown", function(e) -- LEFT O
		e:stopPropagation()
		xhero.body.isleft = true
	end)
	btnleft:addEventListener("clickMove", function(e)
		xhero.body.isleft = true
		btnleft.bmp:setAlpha(alpha)
		btnright.bmp:setAlpha(alpha)
	end)
	btnleft:addEventListener("clickUp", function(e)
		e:stopPropagation()
		xhero.body.isleft = false
		btnleft.bmp:setAlpha(alpha)
		btnright.bmp:setAlpha(alpha)
	end)

	btnright:addEventListener("clickDown", function(e) -- RIGHT O
		e:stopPropagation()
		xhero.body.isright = true
	end)
	btnright:addEventListener("clickMove", function(e)
		xhero.body.isright = true
		btnleft.bmp:setAlpha(alpha)
		btnright.bmp:setAlpha(alpha)
	end)
	btnright:addEventListener("clickUp", function(e)
		e:stopPropagation()
		xhero.body.isright = false
		btnleft.bmp:setAlpha(alpha)
		btnright.bmp:setAlpha(alpha)
	end)
end
