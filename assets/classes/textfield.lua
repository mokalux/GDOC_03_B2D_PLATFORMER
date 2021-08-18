TextFieldX = Core.class(Sprite)

function TextFieldX:init(xparams)
	local dparams = xparams or nil
	local params = dparams or {}
	params.font = xparams.font or nil
	params.text = xparams.text or ""
	params.x = xparams.x or 0
	params.y = xparams.y or 0
	params.scalex = xparams.scalex or 1
	params.scaley = xparams.scaley or 1
	params.color = xparams.color or 0xffffff
	self.tf = TextField.new(params.font, params.text)
	self.tf:setAnchorPoint(0.5, 0.5)
	self.tf:setScale(params.scalex, params.scaley)
	self.tf:setPosition(params.x, params.y)
	self.tf:setTextColor(params.color)
	self:addChild(self.tf)
end

-- ****************************************************
TextIconX = Core.class(Sprite)

function TextIconX:init(xparams)
	local params = xparams or {}
	params.tex = xparams.tex or nil
	params.x = xparams.x or 0
	params.y = xparams.y or 0
	params.scalex = xparams.scalex or 1
	params.scaley = xparams.scaley or 1
	params.font = xparams.font or nil
	params.text = xparams.text or "xxx"
	params.color = xparams.color or 0xff0000
	--
	self.tf = TextField.new(params.font, params.text)
	self.tf:setLayout({flags=FontBase.TLF_CENTER})
	self.tf:setTextColor(params.color)
	if params.tex then
		local ico = Bitmap.new(Texture.new(params.tex))
		ico:setAnchorPoint(0.5, 0.5)
		ico:setScale(params.scalex, params.scaley)
		ico:setPosition(params.x, params.y)
		self:addChild(ico)
		self.tf:setPosition(params.x, params.y + self.tf:getHeight() / 2)
	end
	self:addChild(self.tf)
end
