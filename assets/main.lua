-- plugins
require "scenemanager"
require "easing"
require "liquidfun"
-- global vars
myappleft, myapptop, myappright, myappbot = application:getLogicalBounds()
myappwidth, myappheight = myappright - myappleft, myappbot - myapptop
if application:getDeviceInfo() == "Windows" and not application:isPlayerMode() then
--if application:getDeviceInfo() == "Windows" then
	application:set("windowPosition", 0.25 * myappwidth, 96)
	application:set("windowColor", 0, 0, 0)
	application:set("windowTitle", "My lovely window title")
end
-- fonts (see also composite font)
font00 = TTFont.new("fonts/Cabin-Regular-TTF.ttf", (12*10)//1)
font01 = TTFont.new("fonts/Cabin-Regular-TTF.ttf", (12*5.2)//1)
font02 = TTFont.new("fonts/Cabin-Regular-TTF.ttf", (12*4)//1)
font10 = TTFont.new("fonts/Cabin-Regular-TTF.ttf", (12*3)//1)
-- global functions
isfullscreen = false
function setFullScreen(xbool) application:setFullScreen(xbool) end
--...
-- LIQUID FUN: here we store all possible contact TYPE = NAME -- NO LIMIT :-)
local x = 0
G_GROUND = 2^x -- solids...
x += 1
G_MVPLATFORM = 2^x
x += 1
G_PTPLATFORM = 2^x
x += 1
G_PLAYER = 2^x -- player...
x += 1
G_PLAYER_BULLET = 2^x
x += 1
G_ENEMY01 = 2^x
x += 1
G_ENEMY_BULLET = 2^x
x += 1
G_FRIENDLY = 2^x
x += 1
G_EXIT = 2^x -- sensors...
x += 1
G_DEAD = 2^x
x += 1
G_CAM_ZOOM = 2^x
x += 1
G_LADDER = 2^x
x += 1
G_COIN = 2^x
x += 1
G_BLOCK = 2^x
x += 1
G_BUMP = 2^x
x += 1
G_MOVEABLE = 2^x
x += 1
G_WATER = 2^x
x += 1
G_PEBBLE = 2^x
x += 1
G_SOUND = 2^x
-- LIQUID FUN: here we define some category BITS (that is those objects can collide) -- 2^15 = MAX
x = 0
G_BITSOLID = 2^x
x += 1
G_BITPTPF = 2^x
x += 1
G_BITPLAYER = 2^x
x += 1
G_BITPLAYERBULLET = 2^x
x += 1
G_BITENEMY = 2^x
x += 1
G_BITENEMYBULLET = 2^x
x += 1
G_BITFRIENDLY = 2^x
x += 1
G_BITSENSOR = 2^x
x += 1
G_BITMOVEABLE = 2^x
-- and their appropriate masks (that is what can collide with what)
solidcollisions = G_BITPLAYER + G_BITPLAYERBULLET + G_BITENEMY + G_BITENEMYBULLET + G_BITFRIENDLY + G_BITMOVEABLE
playercollisions = G_BITSOLID + G_BITPTPF + G_BITENEMY + G_BITENEMYBULLET + G_BITSENSOR + G_BITMOVEABLE
playerbulletcollisions = G_BITSOLID + G_BITENEMY + G_BITENEMYBULLET + G_BITFRIENDLY
nmecollisions = G_BITSOLID + G_BITPTPF + G_BITPLAYER + G_BITPLAYERBULLET + G_BITENEMY + G_BITSENSOR
nmebulletcollisions = G_BITSOLID + G_BITPLAYER + G_BITPLAYERBULLET
friendlycollisions = G_BITSOLID + G_BITPTPF + G_BITPLAYERBULLET
moveablecollisions = G_BITSOLID + G_BITPTPF + G_BITPLAYER + G_BITMOVEABLE
-- tiled levels
tiled_levels = {}
tiled_levels[1] = loadfile("tiled/levels/cyberpunked.lua")()
tiled_levels[2] = loadfile("tiled/levels/flowers.lua")()
--tiled_levels[3] = loadfile("tiled/levels/castle.lua")()
-- level info
g_currentlevel = 2 -- 1, 2, 3
-- prefs
g_configfilepath = "|D|GDOC_03_B2D_PLATFORMER.txt"
g_language = application:getLanguage()
g_difficulty = "normal"
g_level = g_currentlevel
function myLoadPrefs(xconfigfilepath)
	local mydata = getData(xconfigfilepath) -- try to read information from file
	if not mydata then -- if no prefs file, create it
		mydata = {}
		-- set prefs
		mydata.g_language = g_language
		mydata.g_difficulty = g_difficulty
		mydata.g_level = g_level
		-- save prefs
		saveData(g_configfilepath, mydata) -- create file and save datas
	else -- prefs file exists, use it!
		-- set prefs
		g_language = mydata.g_language
		g_difficulty = mydata.g_difficulty
		g_level = mydata.g_level
	end
end
-- save prefs
function mySavePrefs(xconfigfilepath)
	local mydata = {} -- clear the table
	-- set prefs
	mydata.g_language = g_language
	mydata.g_difficulty = g_difficulty
	mydata.g_level = g_level
	-- save prefs
	saveData(xconfigfilepath, mydata) -- save new data
end
-- let's load
myLoadPrefs(g_configfilepath) -- load prefs
-- scene manager
scenemanager = SceneManager.new{
	["menu"] = Menu,
	["level_select"] = Level_Select,
	["levelX"] = LevelX,
--	["game_over"] = GameOver,
}
scenemanager:changeScene("menu")
stage:addChild(scenemanager)
-- scenemanager transitions table
transitions = {
	SceneManager.moveFromRight, -- 1
	SceneManager.moveFromLeft, -- 2
	SceneManager.moveFromBottom, -- 3
	SceneManager.moveFromTop, -- 4
	SceneManager.moveFromRightWithFade, -- 5
	SceneManager.moveFromLeftWithFade, -- 6
	SceneManager.moveFromBottomWithFade, -- 7
	SceneManager.moveFromTopWithFade, -- 8
	SceneManager.overFromRight, -- 9
	SceneManager.overFromLeft, -- 10
	SceneManager.overFromBottom, -- 11
	SceneManager.overFromTop, -- 12
	SceneManager.overFromRightWithFade, -- 13
	SceneManager.overFromLeftWithFade, -- 14
	SceneManager.overFromBottomWithFade, -- 15
	SceneManager.overFromTopWithFade, -- 16
	SceneManager.fade, -- 17
	SceneManager.crossFade, -- 18
	SceneManager.flip, -- 19
	SceneManager.flipWithFade, -- 20
	SceneManager.flipWithShade, -- 21
}

-- easings table
easings = {
	easing.inBack, -- 1
	easing.outBack, -- 2
	easing.inOutBack, -- 3
	easing.inBounce, -- 4
	easing.outBounce, -- 5
	easing.inOutBounce, -- 6
	easing.inCircular, -- 7
	easing.outCircular, -- 8
	easing.inOutCircular, -- 9
	easing.inCubic, -- 10
	easing.outCubic, -- 11
	easing.inOutCubic, -- 12
	easing.inElastic, -- 13
	easing.outElastic, -- 14
	easing.inOutElastic, -- 15
	easing.inExponential, -- 16
	easing.outExponential, -- 17
	easing.inOutExponential, -- 18
	easing.linear, -- 19
	easing.inQuadratic, -- 20
	easing.outQuadratic, -- 21
	easing.inOutQuadratic, -- 22
	easing.inQuartic, -- 23
	easing.outQuartic, -- 24
	easing.inOutQuartic, -- 25
	easing.inQuintic, -- 26
	easing.outQuintic, -- 27
	easing.inOutQuintic, -- 28
	easing.inSine, -- 29
	easing.outSine, -- 30
	easing.inOutSine, -- 31
}
