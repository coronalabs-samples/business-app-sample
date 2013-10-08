-- Project: Business Sample App
--
-- File name: mapscene.lua
--
-- Author: Corona Labs
--
-- Abstract: show a map.
--
--
-- Target devices: simulator, device
--
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2013 Corona Labs Inc. All Rights Reserved.
---------------------------------------------------------------------------------------
--[[

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in the
Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so, subject to the
following conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

]]--
---------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )
local myApp = require( "myapp" )

widget.setTheme(myApp.theme)

local titleText
local myMap
local locationtxt
local mapWidth = display.contentWidth - 32
local mapHeight = mapWidth -- * 1.33
local views = {}

local starbucksLocations = {}
starbucksLocations[1] = "1745 E Bayshore Rd, Palo Alto, CA"
starbucksLocations[2] = "2775 Middlefield Rd, Palo Alto, CA"
starbucksLocations[3] = "376 University Ave, Palo Alto, CA"


local function ignoreTouch( event )
	return true
end

local function markerListener( event )
    print("type: ", event.type) -- event type
    print("markerId: ", event.markerId) -- id of the marker that was touched
    print("lat: ", event.latitude) -- latitude of the marker
    print("long: ", event.longitude) -- longitude of the marker
end

local function addStarbucks( event , id )
	local options = { 
		title="Starbucks", 
		subtitle=starbucksLocations[id], 
	    imageFile = 
	    {
    	    filename = "images/starbucks.png",
        	baseDir = system.ResourcesDirectory
    	},
		listener=markerListener 
	}
	myMap:addMarker(event.latitude, event.longitude, options)
end

local function mapLocationHandler(event)
	myMap:setCenter( event.latitude, event.longitude, false )
    myMap:setRegion( event.latitude, event.longitude, 0.25, 0.25, false)
    print("adding office marker")
    local options = { 
    	title="Corona Labs", 
    	subtitle="World HQ", 
	    imageFile = 
	    {
    	    filename = "images/coronamarker.png",
        	baseDir = system.ResourcesDirectory
    	},
       	listener=markerListener 
    }
	result, errorMessage = myMap:addMarker( event.latitude, event.longitude, options )
	if result then
	    print("everything went well")
	else
	    print(errorMessage)
	end
end

local function setMode(event)
	if event.phase == "ended" then
		for i = 1, #views do
			views[i]:setFillColor(255,255,192)
			views[i].label:setTextColor(96, 96, 96)
		end
		views[event.target.index]:setFillColor(255,255,224)
		views[event.target.index].label:setTextColor(64, 64, 64)
		myMap.mapType = event.target.mode
	end
	return true
end

function scene:createScene(event)
	local group = self.view

	local params = event.params

    local background = display.newRect(0,0,display.contentWidth, display.contentHeight)
    background:setFillColor(242, 242, 242, 255)
    background.x = display.contentWidth / 2
    background.y = display.contentHeight / 2

    group:insert(background)

    local statusBarBackground = display.newImageRect(myApp.topBarBg, display.contentWidth, display.topStatusBarContentHeight)
    statusBarBackground.x = display.contentCenterX
    statusBarBackground.y = display.topStatusBarContentHeight * 0.5
    group:insert(statusBarBackground)
    --
    -- Create the other UI elements
    -- create toolbar to go at the top of the screen
    local titleBar = display.newImageRect(myApp.topBarBg, display.contentWidth, 50)
    titleBar.x = display.contentCenterX
    titleBar.y = 25 + display.topStatusBarContentHeight
    group:insert(titleBar)
    --
    -- set up the text for the title bar, will be changed based on what page
    -- the viewer is on

    -- create embossed text to go above toolbar
    titleText = display.newText( params.pageTitle, 0, 0, myApp.fontBold, 20 )
    titleText:setTextColor( 255, 255, 255 )
    titleText:setReferencePoint( display.CenterReferencePoint )
    titleText.x = display.contentCenterX
    titleText.y = titleBar.height * 0.5 + display.topStatusBarContentHeight
    group:insert(titleText)

    --
    -- This serves two purposes.  First, its place holder so we can see where the mapView will be while
    -- working in the simulator.  Secondly, it lets us have something to calculate the positions of the
    -- map's tabs before the map is created.
    --

	local mapbox = display.newRect(16, 16, mapWidth, mapHeight)
	mapbox.x = display.contentCenterX
	mapbox.y = display.contentCenterY
	mapbox:setFillColor(128, 128, 128)
	group:insert(mapbox)


	local tabWidth = mapWidth / 3

	views[1] = display.newRect(0,0,tabWidth,20)
	views[1].x = display.contentCenterX - tabWidth
	views[1].y = mapbox.y + (mapbox.height / 2) + 12
	views[1]:setFillColor(255,255,224)
	views[1]:setStrokeColor(224,224,192)
	views[1].strokeWidth = 1
	views[1].label = display.newText("Standard",0,0,myApp.font, 12 )
	views[1].label.x = views[1].x
	views[1].label.y = views[1].y - 3
	views[1].label:setTextColor(64, 64, 64)
	views[1].index = 1
	views[1].mode = "standard"
	group:insert(views[1])
	group:insert(views[1].label)
	
	views[2] = display.newRect(0,0,tabWidth,20)
	views[2].x = display.contentCenterX 
	views[2].y = mapbox.y + (mapbox.height / 2) + 12
	views[2]:setFillColor(255,255,192)
	views[2]:setStrokeColor(224,224,192)
	views[2].strokeWidth = 1
	views[2].label = display.newText("Satellite",0,0,myApp.font, 12 )
	views[2].label.x = views[2].x
	views[2].label.y = views[2].y - 3
	views[2].label:setTextColor(96, 96, 96)
	views[2].index = 2
	views[2].mode = "satellite"
	group:insert(views[2])
	group:insert(views[2].label)

	views[3] = display.newRect(0,0,tabWidth,20)
	views[3].x = display.contentCenterX + tabWidth
	views[3].y = mapbox.y + (mapbox.height / 2) + 12
	views[3]:setFillColor(255,255,192)
	views[3]:setStrokeColor(224,224,192)
	views[3].strokeWidth = 1
	views[3].label = display.newText("Hybrid",0,0,myApp.font, 12 )
	views[3].label.x = views[3].x
	views[3].label.y = views[3].y - 3
	views[3].label:setTextColor(96, 96, 96)
	views[3].index = 3
	views[3].mode = "hybrid"
	group:insert(views[3])
	group:insert(views[3].label)


end

function scene:enterScene( event )
	local group = self.view

	--
	-- Because mapViews's are native objects, the cannot intermix with the OpenGL objects that storyboard is 
	-- managing.  It's best to create it here and destory it in exitScene.  

	myMap = native.newMapView( 0, 0, mapWidth , mapHeight ) -- make it square
	myMap.mapType = "standard" -- other mapType options are "satellite" or "hybrid"

	-- The MapView is just another Corona display object, and can be moved or rotated, etc.
	myMap.x = display.contentCenterX
	myMap.y = display.contentCenterY 

	--
	-- Let's add some additional points of interest around our location
	--
	-- The event structure returned by requestLocation doesn't contain a reference to the data that
	-- can be used to look up information to populate the marker's bubble or pass on to a more complex information
	-- system (phone number, URL, etc.)
	--
	-- Let's use a Lua Closure (anonymous function) that will take the event table returned by the call and then
	-- call our real function using the index of the table as an ID for the marker
	--

	for i = 1, #starbucksLocations do
		myMap:requestLocation(starbucksLocations[i], function(event) addStarbucks(event, i); end)
	end

	myMap:requestLocation( "1900 Embarcadero Road, Palo Alto, CA", mapLocationHandler )


	views[1]:addEventListener("touch", setMode)
	views[2]:addEventListener("touch", setMode)
	views[3]:addEventListener("touch", setMode)

end

function scene:exitScene( event )
	local group = self.view

	--
	-- Clean up native objects
	--

	if myMap and myMap.removeSelf then
		myMap:removeSelf()
		myMap = nil
	end

end

function scene:destroyScene( event )
	local group = self.view
end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

return scene