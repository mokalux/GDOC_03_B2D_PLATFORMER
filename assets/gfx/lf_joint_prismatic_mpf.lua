Tiled_LF_Joint_Prismatic_Mpf = Core.class(Sprite)

function Tiled_LF_Joint_Prismatic_Mpf:init(xworld, xobj, xobj2, xparams)
	-- params
	local params = xparams or {}
	params.x = xparams.x or nil
	params.y = xparams.y or nil
	params.xaxis = xparams.xaxis or nil
	params.yaxis = xparams.yaxis or nil
	params.lowerlimit = xparams.lowerlimit or nil
	params.upperlimit = xparams.upperlimit or nil
	params.speed = xparams.speed or 1
	-- prismatic joint
	local ground = xworld:createBody({})
	ground:setPosition(params.x, params.y)
	-- jointdef
	local jointDef = b2.createPrismaticJointDef(
			ground, xobj.body,
			params.x, params.y,
			params.xaxis, params.yaxis
		)
	self.pj = xworld:createJoint(jointDef)
	self.pj:setLimits(params.lowerlimit, params.upperlimit)
	self.pj:enableLimit(true)
	self.pj:setMaxMotorForce(params.speed * xobj.body:getMass())
	self.pj:setMotorSpeed(params.speed)
	self.pj:enableMotor(true)
	-- listeners
	self.obj = xobj
	if xobj2 then
		self.obj2 = xobj2
	end
	self.speed = params.speed
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

function Tiled_LF_Joint_Prismatic_Mpf:onEnterFrame()
	local pjll, pjul = self.pj:getLimits()
	if self.pj:getJointTranslation() <= pjll then
		self.pj:setMotorSpeed(self.speed)
	end
	if self.pj:getJointTranslation() >= pjul then
		self.pj:setMotorSpeed(-self.speed)
	end
	self.obj:setPosition(self.obj.body:getPosition())
	if self.obj2 then
		self.obj2:setPosition(self.obj.body:getPosition())
		if self.pj:getJointTranslation() <= pjll then
			self.obj.body:setGravityScale(self.speed / self.obj.body:getMass())
		end
		if self.pj:getJointTranslation() >= pjul then
			self.obj.body:setGravityScale(-self.speed / self.obj.body:getMass())
		end
	end
end
