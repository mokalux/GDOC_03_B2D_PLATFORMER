--!NEEDS:tiled_rectangle.lua

Tiled_PtPf = Core.class(Tiled_Shape_Rectangle)

function Tiled_PtPf:init()
	-- here we build a special body with a 0 pixel height to solve accumulating acceleration?
	self.body = self.world:createBody { type = b2.STATIC_BODY } -- b2.STATIC_BODY, b2.KINEMATIC_BODY, b2.DYNAMIC_BODY
	self.body.name = G_PTPLATFORM
	self.body:setAngle(^<self.rotation)
	-- the main shape
	local shape = b2.PolygonShape.new()
	shape:setAsBox(
		self.w * self.levelscale / 2, 0, -- half w, half h
		self.w * self.levelscale / 2, 0, -- centerx, centery
		0) -- rotation
	local fixture = self.body:createFixture {
		shape = shape, density = 2, restitution = 0, friction = 1
	}
	-- filter data
	local filterData = { categoryBits = self.BIT, maskBits = self.COLBIT, groupIndex = 0 }
	fixture:setFilterData(filterData)
	-- clean up?
	filterData = nil
	fixture = nil
	shape = nil
end
