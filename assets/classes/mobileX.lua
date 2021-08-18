-- ***************************************
--[[
   v.3.1
   (c)Oleg Simonenko
	simartinfo.blogspot.com
	github.com/razorback456/gideros_tools
]]
-- ***************************************

ButtonOleg = gideros.class(Sprite)

function ButtonOleg:init(xtext, xcolor, xscalex, xscaley, xalpha)
	self.textalpha = xalpha or nil
	self.text = TextField.new(nil, xtext)
	self.text:setTextColor(xcolor or 0x0)
	self.text:setScale(xscalex, xscaley)
	self.text:setAlpha(self.textalpha or 0)
	self:addChild(self.text)
	-- listeners
	self:addEventListener(Event.TOUCHES_BEGIN, self.onTouchesBegin, self)
	self:addEventListener(Event.TOUCHES_MOVE, self.onTouchesMove, self)
	self:addEventListener(Event.TOUCHES_END, self.onTouchesEnd, self)
end

function ButtonOleg:onTouchesBegin(e)
	if self:hitTestPoint(e.touch.x, e.touch.y) then
		self:dispatchEvent(Event.new("clickDown"))
		if self.textalpha then
			local tempalpha = self.textalpha + 0.2
			self.text:setAlpha(tempalpha)
		end
	end
end

function ButtonOleg:onTouchesMove(e)
	if self:hitTestPoint(e.touch.x, e.touch.y) then
		local clickMove = Event.new("clickMove")
		self:dispatchEvent(clickMove)
		if self.textalpha then
			local tempalpha = self.textalpha + 0.2
			self.text:setAlpha(tempalpha)
		end
	end
end

function ButtonOleg:onTouchesEnd(e)
	if self:hitTestPoint(e.touch.x, e.touch.y) then
		self:dispatchEvent(Event.new("clickUp"))
		if self.textalpha then
			local tempalpha = self.textalpha
			self.text:setAlpha(tempalpha)
		end
	end
end

-- ************************
-- *** 2 PADS DIRECTION ***
-- ************************
MobileXv1 = Core.class(Sprite)

function MobileXv1:init(xhero)
	-- local variables
	local scalex, scaley = 18,14
	local alpha = 0.25 -- 0.15
	-- left pad buttons
	local btnup = ButtonOleg.new("O", 0xffffff, scalex - 2, scaley, alpha) -- UP (B)
	btnup:setPosition(myappleft, myappbot - btnup:getHeight())
	self:addChild(btnup)
	local btndown = ButtonOleg.new("O", 0xffffff, scalex - 2, scaley, alpha) -- DOWN (A)
	btndown:setPosition(myappleft, myappbot)
	self:addChild(btndown)
	local btnX = ButtonOleg.new("X", 0xff0000, scalex - 0, scaley, alpha) -- SPACE (X)
	btnX:setPosition(myappleft + btnX:getWidth(), myappbot - btnX:getHeight() / 2)
	self:addChild(btnX)
	-- buttons CANCELLER -- LEFT PAD
	local btnscanceller1 = ButtonOleg.new("O", 0xffffff, scalex * 4, scaley * 3, nil) -- nil, 1
	btnscanceller1:setPosition(myappleft, myappbot)
	self:addChild(btnscanceller1)

	-- right pad buttons
	local btnleft = ButtonOleg.new("O", 0xffffff, scalex + 5, scaley + 3, alpha) -- LEFT
	btnleft:setPosition(myappright - 2 * btnleft:getWidth() - 8, myappbot)
	self:addChild(btnleft)
	local btnright = ButtonOleg.new("O", 0xffffff, scalex + 5, scaley + 3, alpha) -- RIGHT
	btnright:setPosition(myappright - btnright:getWidth() - 8, myappbot)
	self:addChild(btnright)
	-- buttons CANCELLER -- RIGHT PAD
	local btnscanceller2 = ButtonOleg.new("O", 0xffffff, scalex * 4, scaley * 3, nil) -- nil, 1
	btnscanceller2:setPosition(myappright + myappleft - btnscanceller2:getWidth(), myappbot)
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
		btnup.text:setAlpha(alpha)
		btndown.text:setAlpha(alpha)
		btnX.text:setAlpha(alpha)
	end)
	btnup:addEventListener("clickUp", function(e)
		e:stopPropagation()
		xhero.body.isup = false
		xhero.body.canjump = true
		btnup.text:setAlpha(alpha)
		btndown.text:setAlpha(alpha)
		btnX.text:setAlpha(alpha)
	end)

	btndown:addEventListener("clickDown", function(e) -- DOWN O
		e:stopPropagation()
		xhero.body.isdown = true
	end)
	btndown:addEventListener("clickMove", function(e)
		xhero.body.isdown = true
--		xhero.body.isdown = false
		btnup.text:setAlpha(alpha)
		btndown.text:setAlpha(alpha)
		btnX.text:setAlpha(alpha)
	end)
	btndown:addEventListener("clickUp", function(e)
		e:stopPropagation()
		xhero.body.isdown = false
		btnup.text:setAlpha(alpha)
		btndown.text:setAlpha(alpha)
		btnX.text:setAlpha(alpha)
	end)

	btnX:addEventListener("clickDown", function(e) -- SPACE X
		e:stopPropagation()
		xhero.body.isspace = true
	end)
	btnX:addEventListener("clickMove", function(e)
--		xhero.body.isspace = true
		xhero.body.isspace = false
		btnup.text:setAlpha(alpha)
		btndown.text:setAlpha(alpha)
		btnX.text:setAlpha(alpha)
	end)
	btnX:addEventListener("clickUp", function(e)
		e:stopPropagation()
		xhero.body.isspace = false
		btnup.text:setAlpha(alpha)
		btndown.text:setAlpha(alpha)
		btnX.text:setAlpha(alpha)
	end)

	btnleft:addEventListener("clickDown", function(e) -- LEFT O
		e:stopPropagation()
		xhero.body.isleft = true
	end)
	btnleft:addEventListener("clickMove", function(e)
		xhero.body.isleft = true
		btnleft.text:setAlpha(alpha)
		btnright.text:setAlpha(alpha)
	end)
	btnleft:addEventListener("clickUp", function(e)
		e:stopPropagation()
		xhero.body.isleft = false
		btnleft.text:setAlpha(alpha)
		btnright.text:setAlpha(alpha)
	end)

	btnright:addEventListener("clickDown", function(e) -- RIGHT O
		e:stopPropagation()
		xhero.body.isright = true
	end)
	btnright:addEventListener("clickMove", function(e)
		xhero.body.isright = true
		btnleft.text:setAlpha(alpha)
		btnright.text:setAlpha(alpha)
	end)
	btnright:addEventListener("clickUp", function(e)
		e:stopPropagation()
		xhero.body.isright = false
		btnleft.text:setAlpha(alpha)
		btnright.text:setAlpha(alpha)
	end)
end
