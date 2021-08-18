Tiled_Levels = Core.class(Sprite)

function Tiled_Levels:init(xworld, xtiledlevel, xlevelscale)
	self.world = xworld
	self.levelscale = xlevelscale
	self.camera = Sprite.new()
	self.bg = Sprite.new() -- bg deco
	self.mg = Sprite.new() -- mg level + sensors
	self.fg = Sprite.new() -- fg deco
	self.camera:addChild(self.bg)
	self.camera:addChild(self.mg)
	self.camera:addChild(self.fg)
	self:addChild(self.camera)
	-- the tiled map size
	self.mapwidth, self.mapheight = xtiledlevel.width * xtiledlevel.tilewidth, xtiledlevel.height * xtiledlevel.tileheight
	print("map size "..self.mapwidth..", "..self.mapheight, "app size "..myappwidth..", "..myappheight, "all in pixels.")
	-- parse the tiled level
	local layers = xtiledlevel.layers
	local myshape -- shapes from Tiled
	local mytable -- intermediate table for shapes params
	for i = 1, #layers do
		local layer = layers[i]
		-- IMAGE LAYER
		-- ************
		local path = "tiled/levels/"
		if layer.name == "Image Layer 1" then -- your Tiled layer name here!
			local bitmap = Bitmap.new(Texture.new(path..layer.image))
			bitmap:setPosition(layer.offsetx, layer.offsety)
			self.bg:addChild(bitmap)
		elseif layer.name == "Image Layer 2" then -- your Tiled layer name here!
			local bitmap = Bitmap.new(Texture.new(path..layer.image))
			bitmap:setPosition(layer.offsetx, layer.offsety)
			self.bg:addChild(bitmap)
		elseif layer.name == "Image Layer 3" then -- your Tiled layer name here!
			local bitmap = Bitmap.new(Texture.new(path..layer.image))
			bitmap:setPosition(layer.offsetx, layer.offsety)
			self.bg:addChild(bitmap)
		elseif layer.name == "Image Layer 4" then -- your Tiled layer name here!
			local bitmap = Bitmap.new(Texture.new(path..layer.image))
			bitmap:setPosition(layer.offsetx, layer.offsety)
			self.bg:addChild(bitmap)

		-- BG
		-- ***
		elseif layer.name == "grounds" then -- land
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local objectName = object.name
				myshape, mytable = nil, nil
				myshapeL, mytableL = nil, nil -- left part: body, ...
				myshapeR, mytableR = nil, nil -- right part: body, ...
				myshapeB, mytableB = nil, nil -- bottom part: body, ...
				-- SHAPES
				-- ***************
				if objectName == "groundA" then
					mytable = {
						isshape=true,
						shapelinewidth=3, shapelinecolor=0xff0000, shapelinealpha=1,
						density=1, restitution=0, friction=1,
						BIT=G_BITSOLID, COLBIT=solidcollisions, NAME=G_GROUND,
					}
				elseif objectName == "groundB" then
					local color
					if g_currentlevel == 1 then
						color = 0x00FF00
						mytable = {
							isshape=true,
							shapelinewidth=1, shapelinecolor=color, shapelinealpha=1,
						}
						mytableL = {
							isshape=true,
							shapelinewidth=1, shapelinecolor=color, shapelinealpha=1,
						}
						mytableR = {
							isshape=true,
							shapelinewidth=1, shapelinecolor=color, shapelinealpha=1,
						}
						mytableB = {
							isshape=true,
							shapelinewidth=1, shapelinecolor=color, shapelinealpha=1,
						}
					elseif g_currentlevel == 2 then
						color = 0x0000FF
						mytable = {
							isshape=true,
							shapelinewidth=1, shapelinecolor=color, shapelinealpha=1,
						}
						mytableL = {
							isshape=true,
							shapelinewidth=1, shapelinecolor=color, shapelinealpha=1,
						}
						mytableR = {
							isshape=true,
							shapelinewidth=1, shapelinecolor=color, shapelinealpha=1,
						}
						mytableB = {
							isshape=true,
							shapelinewidth=1, shapelinecolor=color, shapelinealpha=1,
						}
					end
				end
				if mytable then
					levelsetup = {
						density=1, restitution=0, friction=1,
						BIT=G_BITSOLID, COLBIT=solidcollisions, NAME=G_GROUND,
					}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					myshape = self:buildShapes(object, levelsetup)
					myshape:setPosition(object.x, object.y)
					self.bg:addChild(myshape)
				end
				if mytableL then
					levelsetup = {
						density=1, restitution=0, friction=0,
						BIT=G_BITSOLID, COLBIT=solidcollisions, NAME=-1,
					}
					for k, v in pairs(mytableL) do levelsetup[k] = v end
					myshapeL = self:buildShapes(object, levelsetup)
					myshapeL:setPosition(object.x - 1, object.y + 1)
					self.bg:addChild(myshapeL)
				end
				if mytableR then
					levelsetup = {
						density=1, restitution=0, friction=0,
						BIT=G_BITSOLID, COLBIT=solidcollisions, NAME=-1,
					}
					for k, v in pairs(mytableR) do levelsetup[k] = v end
					myshapeR = self:buildShapes(object, levelsetup)
					myshapeR:setPosition(object.x + 1, object.y + 1)
					self.bg:addChild(myshapeR)
				end
				if mytableB then
					levelsetup = {
						density=1, restitution=0, friction=0,
						BIT=G_BITSOLID, COLBIT=solidcollisions, NAME=-1,
					}
					for k, v in pairs(mytableB) do levelsetup[k] = v end
					myshapeB = self:buildShapes(object, levelsetup)
					myshapeB:setPosition(object.x, object.y + 1)
					self.bg:addChild(myshapeB)
				end
			end

		-- SENSORS
		-- *******
		elseif layer.name == "sensors" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local objectName = object.name
				myshape, mytable = nil, nil
				-- SHAPES
				-- ******
				if objectName == "ladder" then mytable = {BIT=G_BITSENSOR, COLBIT=nil, NAME=G_LADDER}
				elseif objectName == "exit_block" then mytable = {BIT=G_BITSENSOR, COLBIT=nmecollisions, NAME=G_BLOCK}
				elseif objectName == "exit" then mytable = {BIT=G_BITSENSOR, COLBIT=G_BITPLAYER, NAME=G_EXIT}
				end
				if mytable ~= nil then
					levelsetup = {issensor=true}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					myshape = self:buildShapes(object, levelsetup)
					myshape:setPosition(object.x, object.y)
					self.bg:addChild(myshape)
				end
			end

		-- COLLECTIBLES
		-- ************
		elseif layer.name == "collectibles" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local objectName = object.name
				myshape, mytable = nil, nil
				-- SHAPES
				-- ******
				if objectName == "c01" then -- collectibles are Tiled polygons so I can center them!
					myshape = Collectibles.new(self.world, {
						coords=object.polygon,
						isbmp=true,
						texpath="gfx/collectibles/obj0071.png",
						scalex=0.3,
						density=1, restitution=0, friction=0,
						type=b2.KINEMATIC_BODY,
						BIT=G_BITSENSOR, COLBIT=G_BITPLAYER, NAME=G_COIN,
					})
					self.world.coins[myshape] = myshape.body
					myshape:setPosition(object.x, object.y)
					self.mg:addChild(myshape)
				end
			end

		-- LADDERS
		-- *******
		elseif layer.name == "ladders" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local objectName = object.name
				myshape, mytable = nil, nil
				-- SHAPES
				-- ******
				if objectName == "ladder" then
					mytable = {
						isshape=true,
						texpath="gfx/grounds/ladder02.png",
						shapelinewidth=2, shapelinecolor=0x493c2b, shapelinealpha=0.8,
						isdeco=true,
					}
				else
					mytable = {
						isshape=true,
						shapelinewidth=2, shapelinecolor=0xff0000, shapelinealpha=1,
						isdeco=true,
					}
				end
				if mytable ~= nil then
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					myshape = self:buildShapes(object, levelsetup)
					myshape:setPosition(object.x, object.y)
					self.bg:addChild(myshape)
				end
			end

		-- PASS THROUGH PLATFORMS
		-- ***********************
		elseif layer.name == "ptpfs" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local objectName = object.name
				myshape, mytable = nil, nil
				-- SHAPES
				-- ******
				if objectName == "ptpf" then
					if g_currentlevel == 1 then
						myshape = Tiled_PtPf.new(xworld, {
							x = object.x, y = object.y,
							w = object.width, h = object.height, rotation = object.rotation,
							shapelinewidth=3, shapelinecolor=0x0000ff, isshape=true,
							density=2, restitution=0, friction=1,
							isdeco=true, -- IMPORTANT XXX
							BIT=G_BITPTPF, COLBIT=solidcollisions, NAME=G_PTPLATFORM,
						}, xlevelscale)
					elseif g_currentlevel == 2 then
						myshape = Tiled_PtPf.new(xworld, {
							x = object.x, y = object.y,
							w = object.width, h = object.height, rotation = object.rotation,
--							color=0x7F6A00,
							shapelinewidth=3, shapelinecolor=0x00ff00, isshape=true,
							density=2, restitution=0, friction=1,
							isdeco=true,
							BIT=G_BITPTPF, COLBIT=solidcollisions, NAME=G_PTPLATFORM,
						}, xlevelscale)
					end
				end
				myshape:setPosition(object.x, object.y)
				self.mg:addChild(myshape)
			end

		-- MOVING PLATFORMS
		-- ****************
		elseif layer.name == "mvpfs" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local objectName = object.name
				myshape, mytable = nil, nil
				-- SHAPES
				-- ******
				if objectName:sub(1, 5) == "mvpf_" then
					local direction = objectName:sub(6, 6)
					local distance = tonumber(string.match(objectName, "%d+"))
					if g_currentlevel == 1 then
						myshape = Tiled_MvPf.new(xworld, {
							x = object.x, y = object.y,
							w = object.width, h = object.height, rotation = object.rotation,
							shapelinewidth=3, shapelinecolor=0x00ff00, isshape=true,
							density=2, restitution=0, friction=1,
							type=b2.KINEMATIC_BODY,
							BIT=G_BITSOLID, COLBIT=solidcollisions, NAME=G_MVPLATFORM,
						}, xlevelscale)
					elseif g_currentlevel == 2 then
						myshape = Tiled_MvPf.new(xworld, {
							x = object.x, y = object.y,
							w = object.width, h = object.height, rotation = object.rotation,
							color=0x7F6A00, shapelinewidth=3, shapelinecolor=0x00ff00, isshape=true,
							density=2, restitution=0, friction=1,
							type=b2.KINEMATIC_BODY,
							BIT=G_BITSOLID, COLBIT=solidcollisions, NAME=G_MVPLATFORM,
						}, xlevelscale)
					end
					if direction == "N" then
						myshape.directiony = -1
						myshape.vx, myshape.vy = 0, 1
						myshape.minx, myshape.maxx = object.x, object.x
						myshape.miny, myshape.maxy = object.y - distance, object.y
					elseif direction == "S" then
						myshape.directiony = 1
						myshape.vx, myshape.vy = 0, 1
						myshape.minx, myshape.maxx = object.x, object.x
						myshape.miny, myshape.maxy = object.y, object.y + distance
					elseif direction == "E" then
						myshape.directionx = 1
						myshape.vx, myshape.vy = 1, 0
						myshape.minx, myshape.maxx = object.x, object.x + distance
						myshape.miny, myshape.maxy = object.y, object.y
					elseif direction == "W" then
						myshape.directionx = -1
						myshape.vx, myshape.vy = 1, 0
						myshape.minx, myshape.maxx = object.x - distance, object.x
						myshape.miny, myshape.maxy = object.y - distance, object.y
					end
					myshape:setPosition(object.x, object.y)
					self.mg:addChild(myshape)
				end
			end

		-- PLAYABLE
		-- ********
		elseif layer.name == "playable" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local objectName = object.name
				myshape, mytable = nil, nil
				-- SHAPES
				-- ******
				if objectName == "player1" then
					self.world.player1 = Player.new(self.world, {
						posx=object.x*self.levelscale, posy=object.y*self.levelscale,
						texpath="gfx/playable/y_bot04.png", numtexcols=5, numtexrows=8, scale=0.3,
						animspeed=14, movespeed=8*1.5, jumpspeed=8*1.3, maxnumjump=2,
						offsety=-12, shapescale=4,
						density=1, restitution=0, friction=1,
						BIT=G_BITPLAYER, COLBIT=playercollisions, NAME=G_PLAYER,
					}, self.levelscale)
					self.world.player1.body.nrg = 5
					self.mg:addChild(self.world.player1)

				elseif objectName == "walkerA" then
					if g_currentlevel == 1 then
						Nme_Walker.new(self.world, {
							posx=object.x*self.levelscale, posy=object.y*self.levelscale,
							texpath="gfx/playable/George.png", numtexcols=7, numtexrows=5, scale=0.25,
							animspeed=14, movespeed=math.random(8*1, 8*1.5), jumpspeed=8*1.3, maxnumjump=2,
							offsety=-24, shapescale=4,
							density=1, restitution=0.5, friction=0,
							BIT=G_BITENEMY, COLBIT=nmecollisions, NAME=G_ENEMY01,
							lives=1, nrg=4,
						}, self.levelscale)
					elseif g_currentlevel == 2 then
						Nme_Walker.new(self.world, {
							posx=object.x*self.levelscale, posy=object.y*self.levelscale,
							texpath="gfx/playable/slime03.png", numtexcols=8, numtexrows=2, scale=0.7,
							animspeed=14, movespeed=8*0.5, jumpspeed=8*0.7, maxnumjump=2,
							offsety=-3, shapescale=4,
							density=1, restitution=0.5, friction=0,
							BIT=G_BITENEMY, COLBIT=nmecollisions, NAME=G_ENEMY01,
							lives=1, nrg=4,
						}, self.levelscale)
					end

				elseif objectName == "walkerBossA" then
					if g_currentlevel == 1 then
						Nme_Walker_Boss_A.new(self.world, {
							posx=object.x*self.levelscale, posy=object.y*self.levelscale,
							texpath="gfx/playable/Leela.png", numtexcols=8, numtexrows=7, scale=0.5,
							animspeed=12, movespeed=8*0.3, jumpspeed=8*1.1, maxnumjump=2,
							offsetx=0, offsety=-36, shapescale=4,
							density=4, restitution=0.5, friction=0,
							BIT=G_BITENEMY, COLBIT=nmecollisions, NAME=G_ENEMY01,
							lives=3, nrg=5,
						}, self.levelscale)
					elseif g_currentlevel == 2 then
						Nme_Walker_Boss_A.new(self.world, {
							posx=object.x*self.levelscale, posy=object.y*self.levelscale,
							texpath="gfx/playable/slime01.png", numtexcols=8, numtexrows=2, scale=1.2,
							animspeed=14, movespeed=8*0.4, jumpspeed=8*1, maxnumjump=2,
							offsetx=-0, offsety=-0, shapescale=3,
							density=2, restitution=0.9, friction=0,
							BIT=G_BITENEMY, COLBIT=nmecollisions, NAME=G_ENEMY01,
							lives=2, nrg=4,
						}, self.levelscale)
					end

				elseif objectName == "flyerA" then
					if g_currentlevel == 1 then
						Nme_Flyer.new(self.world, {
							posx=object.x*self.levelscale, posy=object.y*self.levelscale,
							texpath="gfx/playable/Bob.png", numtexcols=1, numtexrows=1, scale=0.3,
							animspeed=14, movespeed=8*0.6, jumpspeed=8*0.5, maxnumjump=2,
							offsety=0, shapescale=4,
							density=1, restitution=0.5, friction=0,
							BIT=G_BITENEMY, COLBIT=nmecollisions, NAME=G_ENEMY01,
							lives=1, nrg=3,
						}, self.levelscale)
					elseif g_currentlevel == 2 then
						Nme_Flyer.new(self.world, {
							posx=object.x*self.levelscale, posy=object.y*self.levelscale,
							texpath="gfx/playable/bat_fly.png", numtexcols=1, numtexrows=9, scale=0.5,
							animspeed=14, movespeed=8*0.5, jumpspeed=8*0.5, maxnumjump=2,
							offsety=0, shapescale=4,
							density=1, restitution=0.5, friction=0,
							BIT=G_BITENEMY, COLBIT=nmecollisions, NAME=G_ENEMY01,
							lives=1, nrg=3,
						}, self.levelscale)
					end

				elseif objectName == "flyerKeepA" then
					if g_currentlevel == 1 then
						Nme_Flyer_Keep.new(self.world, {
							posx=object.x*self.levelscale, posy=object.y*self.levelscale,
							texpath="gfx/playable/Bob.png", numtexcols=1, numtexrows=1, scale=0.3,
							animspeed=14, movespeed=8*0.5, jumpspeed=8*0.5, maxnumjump=2,
							offsety=0, shapescale=4,
							density=1, restitution=0.5, friction=0,
							BIT=G_BITENEMY, COLBIT=nmecollisions, NAME=G_ENEMY01,
							lives=1, nrg=3,
						}, self.levelscale)
					elseif g_currentlevel == 2 then
						Nme_Flyer_Keep.new(self.world, {
							posx=object.x*self.levelscale, posy=object.y*self.levelscale,
							texpath="gfx/playable/bat_fly.png", numtexcols=1, numtexrows=9, scale=0.5,
							animspeed=14, movespeed=8*0.5, jumpspeed=8*0.5, maxnumjump=2,
							offsety=0, shapescale=4,
							density=1, restitution=0.5, friction=0,
							BIT=G_BITENEMY, COLBIT=nmecollisions, NAME=G_ENEMY01,
							lives=1, nrg=3,
						}, self.levelscale)
					end

				elseif objectName == "friendlyflyerA" then
					if g_currentlevel == 1 then
						Nme_Flyer.new(self.world, {
							posx=object.x*self.levelscale, posy=object.y*self.levelscale,
							texpath="gfx/playable/bflyA.png", numtexcols=1, numtexrows=1, scale=0.3,
							animspeed=14, movespeed=8*0.6, jumpspeed=8*0.5, maxnumjump=2,
							offsety=0, shapescale=4,
							density=1, restitution=0.5, friction=0,
							BIT=G_BITENEMY, COLBIT=nmecollisions, NAME=G_ENEMY01,
							lives=1, nrg=3,
						}, self.levelscale)
					elseif g_currentlevel == 2 then
						Nme_Flyer.new(self.world, {
							posx=object.x*self.levelscale, posy=object.y*self.levelscale,
							texpath="gfx/playable/bflyA.png", numtexcols=6, numtexrows=2, scale=0.5,
							animspeed=14, movespeed=8*0.5, jumpspeed=8*0.5, maxnumjump=2,
							offsety=0, shapescale=4,
							density=1, restitution=0.5, friction=0,
							BIT=G_BITENEMY, COLBIT=nmecollisions, NAME=G_ENEMY01,
							lives=1, nrg=3,
						}, self.levelscale)
					end

				elseif objectName == "friendlyflyerB" then
					if g_currentlevel == 1 then
						Nme_Flyer.new(self.world, {
							posx=object.x*self.levelscale, posy=object.y*self.levelscale,
							texpath="gfx/playable/bflyB.png", numtexcols=1, numtexrows=1, scale=0.3,
							animspeed=14, movespeed=8*0.6, jumpspeed=8*0.5, maxnumjump=2,
							offsety=0, shapescale=4,
							density=1, restitution=0.5, friction=0,
							BIT=G_BITENEMY, COLBIT=nmecollisions, NAME=G_ENEMY01,
							lives=1, nrg=3,
						}, self.levelscale)
					elseif g_currentlevel == 2 then
						Nme_Flyer.new(self.world, {
							posx=object.x*self.levelscale, posy=object.y*self.levelscale,
							texpath="gfx/playable/bflyB.png", numtexcols=6, numtexrows=2, scale=0.5,
							animspeed=14, movespeed=8*0.5, jumpspeed=8*0.5, maxnumjump=2,
							offsety=0, shapescale=4,
							density=1, restitution=0.5, friction=0,
							BIT=G_BITENEMY, COLBIT=nmecollisions, NAME=G_ENEMY01,
							lives=1, nrg=3,
						}, self.levelscale)
					end

				elseif objectName == "friendlyflyerAKeepA" then
					if g_currentlevel == 1 then
						Nme_Flyer_Keep.new(self.world, {
							posx=object.x*self.levelscale, posy=object.y*self.levelscale,
							texpath="gfx/playable/Bob.png", numtexcols=1, numtexrows=1, scale=0.3,
							animspeed=14, movespeed=8*0.5, jumpspeed=8*0.5, maxnumjump=2,
							offsety=0, shapescale=4,
							density=1, restitution=0.5, friction=0,
							BIT=G_BITENEMY, COLBIT=nmecollisions, NAME=G_ENEMY01,
							lives=1, nrg=3,
						}, self.levelscale)
					elseif g_currentlevel == 2 then
						Nme_Flyer_Keep.new(self.world, {
							posx=object.x*self.levelscale, posy=object.y*self.levelscale,
							texpath="gfx/playable/bat_fly.png", numtexcols=1, numtexrows=9, scale=0.5,
							animspeed=14, movespeed=8*0.5, jumpspeed=8*0.5, maxnumjump=2,
							offsety=0, shapescale=4,
							density=1, restitution=0.5, friction=0,
							BIT=G_BITENEMY, COLBIT=nmecollisions, NAME=G_ENEMY01,
							lives=1, nrg=3,
						}, self.levelscale)
					end
				end
			end

		-- FG
		-- ***
		elseif layer.name == "fg" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local objectName = object.name
				myshape, mytable = nil, nil
				-- SHAPES
				-- ***************
				if objectName == "xxx" then mytable = {color=0x00ff00, isshape=true}
					mytable = {
						isshape=true,
						color=0x8C4104,
						shapelinewidth=3, shapelinecolor=0xff0000, shapelinealpha=1,
					}
				elseif objectName == "yyy" then
				end
				if mytable ~= nil then
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					myshape = self:buildShapes(object, levelsetup)
					myshape:setPosition(object.x, object.y)
					self.fg:addChild(myshape)
				end
			end

		-- WHAT?!
		-- ******
		else print("WHAT?!", layer.name)
		end
	end
end

function Tiled_Levels:buildShapes(xobject, xlevelsetup)
	local myshape = nil
	local tablebase = {}
	if xobject.shape == "ellipse" then
		tablebase = {
			x = xobject.x * self.levelscale, y = xobject.y * self.levelscale,
			w = xobject.width, h = xobject.height, rotation = xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Ellipse.new(self.world, tablebase, self.levelscale)
	elseif xobject.shape == "polygon" then
		tablebase = {
			x = xobject.x * self.levelscale, y = xobject.y * self.levelscale,
			coords = xobject.polygon, rotation = xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Polygon.new(self.world, tablebase, self.levelscale)
	elseif xobject.shape == "rectangle" then
		tablebase = {
			x = xobject.x * self.levelscale, y = xobject.y * self.levelscale,
			w = xobject.width, h = xobject.height, rotation = xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Rectangle.new(self.world, tablebase, self.levelscale)
	else
		print("*** CANNOT PROCESS THIS SHAPE! ***", xobject.shape, xobject.name)
		return
	end

	return myshape
end
