--!NEEDS:../../tiled/tiled_polygon.lua
Collectibles = Core.class(Tiled_Shape_Polygon)

function Collectibles:init()
	self.snd = Sound.new("audio/Collectibles_1.wav")
	self.snd2 = Sound.new("audio/Collectibles_3.wav")
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

function Collectibles:onEnterFrame(e)
	if self.body then
		self.img:setRotation(math.sin(e.time*4)*16)
		if self.body.isdirty then
			self.world:destroyBody(self.body)
			self:getParent():removeChild(self)
			if self.body.name == G_COIN then
				local chanel = self.snd:play() chanel:setVolume(0.01)
--				self.world.score += self.value
				self.world.score += 10
				self.world.scoretf:setText("SCORE: "..self.world.score)
				local mc = MovieClip.new{
					{1, 20, self.world.scoretf, {scale={4, 8, "inOutElastic"}}},
					{20, 30, self.world.scoretf, {scale={8, 4, "inOutElastic"}}}
				}
			elseif self.body.name == G_PEBBLE then
				local chanel = self.snd2:play() chanel:setVolume(0.01)
				self.world.stones += self.value
				self.world.stonetf:setText(self.world.stones)
				local mc = MovieClip.new{
					{1, 30, self.world.stonetf, {scale={1, 3, "inOutElastic"}}},
					{30, 50, self.world.stonetf, {scale={3, 1, "inOutElastic"}}}
				}
			elseif self.body.name == G_EXIT then
--				g_currentlevel += 1
				if g_currentlevel > #tiled_levels then g_currentlevel = 1 end
				scenemanager:changeScene("levelX", 3) -- magik XXX
			end
			self.body = nil
			self.img = nil
			return
		end
	end
end
