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

local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )
local widgetExtras = require( "widget-extras" )
local myApp = require( "myapp" )

widget.setTheme(myApp.theme)

local titleText
local myMap
local locationtxt
local mapWidth
local mapHeight
local navBar
local addressGroup
local addressLabel
local addressField
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

local function setMode( event )
	if event.phase == "ended" then
		for i = 1, #views do
			views[i]:setFillColor(1, 1, 0.75)
			views[i].label:setFillColor( 0.375, 0.375, 0.375 )
		end
		views[event.target.index]:setFillColor( 1, 1, 0.875 )
		views[event.target.index].label:setFillColor( 0.25, 0.25, 0.25 )
		myMap.mapType = event.target.mode
	end
	return true
end

local function textFieldHandler( textField )
	return function( event )
		if ( "began" == event.phase ) then
			-- This is the "keyboard has appeared" event
			-- In some cases you may want to adjust the interface when the keyboard appears.

		elseif ( "editing" == event.phase ) then
		
		elseif ( "submitted" == event.phase or "ended" == event.phase ) then
			-- This event occurs when the user presses the "return" key (if available) on the onscreen keyboard
	        print( "Final Text: ", event.target.text)
	        navBar:setLabel( event.target.text )
	        myMap:requestLocation( event.target.text, mapLocationHandler )
			-- Hide keyboard
			native.setKeyboardFocus( nil )
		end
	end
end

function scene:create( event )
	local sceneGroup = self.view

	local params = event.params

    local background = display.newRect(0,0,display.contentWidth, display.contentHeight)
    background:setFillColor( 0.95, 0.95, 0.95 )
    background.x = display.contentWidth / 2
    background.y = display.contentHeight / 2

    sceneGroup:insert(background)

    navBar = widget.newNavigationBar({
        title = params.pageTitle,
        backgroundColor = { 0.96, 0.62, 0.34 },
        titleColor = {1, 1, 1},
        font = myApp.fontBold
    })
    sceneGroup:insert(navBar)

    addressGroup = display.newGroup()
    sceneGroup:insert( addressGroup )
    local addressBackground = display.newRect( 0, 0, display.contentWidth, 30 )
    addressGroup:insert( addressBackground )
    addressBackground:setFillColor( 1 )
    addressBackground.anchorX = 0
    addressBackground.anchorY = 0
    addressLabel = display.newText( "Address", 10, 15, myApp.fontBold, 20)
    addressLabel:setFillColor( 0 )
    addressGroup:insert( addressLabel )
    addressLabel.anchorX = 0
    addressLabel.anchorY = 0.5

    addressGroup.x = 0
    addressGroup.y = navBar.y + 65
    --
    -- This serves two purposes.  First, its place holder so we can see where the mapView will be while
    -- working in the simulator.  Secondly, it lets us have something to calculate the positions of the
    -- map's tabs before the map is created.
    --

    mapWidth = display.contentWidth
    -- height of tabBar - height of the navBar - 20px for the buttons.
    mapHeight = display.contentHeight - 50 - navBar.height - 30 - 30 --(address field height defined later)

	local mapbox = display.newRect(0, 0, mapWidth, mapHeight)
	mapbox.x = display.contentCenterX
	mapbox.y = mapHeight / 2 + navBar.height + 30 -- (address field height)
	mapbox:setFillColor( 0.5, 0.5, 0.5 )
	sceneGroup:insert(mapbox)


	local tabWidth = mapWidth / 3

	views[1] = display.newRect(0,0,tabWidth,30)
	views[1].x = display.contentCenterX - tabWidth
	views[1].y = mapbox.y + (mapbox.height / 2) + 12
	views[1]:setFillColor( 1, 1, 0.875)
	views[1]:setStrokeColor( 0.875, 0.875, 0.75)
	views[1].strokeWidth = 1
	views[1].label = display.newText("Standard",0,0,myApp.font, 12 )
	views[1].label.x = views[1].x
	views[1].label.y = views[1].y - 3
	views[1].label:setFillColor( 0.25, 0.25, 0.25 )
	views[1].index = 1
	views[1].mode = "standard"
	sceneGroup:insert(views[1])
	sceneGroup:insert(views[1].label)
	
	views[2] = display.newRect(0,0,tabWidth,30)
	views[2].x = display.contentCenterX 
	views[2].y = mapbox.y + (mapbox.height / 2) + 12
	views[2]:setFillColor( 1, 1, 0.75 )
	views[2]:setStrokeColor(0.875, 0.875, 0.75 )
	views[2].strokeWidth = 1
	views[2].label = display.newText("Satellite",0,0,myApp.font, 12 )
	views[2].label.x = views[2].x
	views[2].label.y = views[2].y - 3
	views[2].label:setFillColor( 0.375, 0.375, 0.375 )
	views[2].index = 2
	views[2].mode = "satellite"
	sceneGroup:insert(views[2])
	sceneGroup:insert(views[2].label)

	views[3] = display.newRect(0,0,tabWidth,30)
	views[3].x = display.contentCenterX + tabWidth
	views[3].y = mapbox.y + (mapbox.height / 2) + 12
	views[3]:setFillColor( 1, 1, 0.75)
	views[3]:setStrokeColor( 0.875, 0.875, 0.75 )
	views[3].strokeWidth = 1
	views[3].label = display.newText("Hybrid",0,0,myApp.font, 12 )
	views[3].label.x = views[3].x
	views[3].label.y = views[3].y - 3
	views[3].label:setFillColor( 0.375, 0.375, 0.375)
	views[3].index = 3
	views[3].mode = "hybrid"
	sceneGroup:insert(views[3])
	sceneGroup:insert(views[3].label)

end

function scene:show( event )
	local sceneGroup = self.view

	if event.phase == "did" then
		-- The text field's native peice starts hidden, we show it after we are on screen.on

		local fieldWidth = display.contentWidth - 120

		addressField = native.newTextField( 110, addressLabel.y, fieldWidth, 30 )
		addressField:addEventListener( "userInput", textFieldHandler( function() return addressField end ) ) 
		addressGroup:insert( addressField)
		addressField.anchorX = 0
		addressField.placeholder = "Address"

		--
		-- Because mapViews's are native objects, the cannot intermix with the OpenGL objects that composer is 
		-- managing.  It's best to create it here and destory it in exitScene.  

		myMap = native.newMapView( 0, 0, mapWidth , mapHeight ) 
		if myMap then
			myMap.mapType = "standard" -- other mapType options are "satellite" or "hybrid"

			-- The MapView is just another Corona display object, and can be moved or rotated, etc.
			myMap.x = display.contentCenterX
			myMap.y = mapHeight / 2 + navBar.height + 30

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
		else
			native.showAlert( "Simulator", "Maps are only avaiable on device.", { "Okay" } )
		end
	end
end

function scene:hide( event )
	local sceneGroup = self.view

	--
	-- Clean up native objects
	--

	if event.phase == "will" then
		-- remove the addressField since it contains a native object.
		addressField:removeSelf()
		addressField = nil
	    -- remove the map since it's a native object.
		if myMap and myMap.removeSelf then
			myMap:removeSelf()
			myMap = nil
		end
	end
end

function scene:destroy( event )
	local sceneGroup = self.view

end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene