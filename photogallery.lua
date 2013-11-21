-- Project: Business Sample App
--
-- File name: photogallery.lua
--
-- Author: Corona Labs
--
-- Abstract: Display a gallery of photo thumbnails.
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

local widget = require("widget")
local myApp = require("myapp")

widget.setTheme(myApp.theme)

--local slideView = require( "slideView" )

local photoFiles = {
	"photos/Arch01.jpg",
	"photos/Biloxi05.jpg",
	"photos/Butterfly01.jpg",
	"photos/DSC6722.jpg",
	"photos/DSC_7743.jpg",
	"photos/ElCap.jpg",
	"photos/FlaKeysSunset.jpg",
	"photos/MaimiSkyline.jpg",
	"photos/MtRanier8x10.jpg",
	"photos/Tulip.jpg",
	"photos/WhiteTiger.jpg",
	"photos/Yosemite Valley.jpg",
	"photos/Yosemite2013_Mule_Deer04.jpg",
	"photos/bfly2.jpg",
	"photos/bodieIsland.jpg",
}

local photosThumbnails = {}
local photosThumbGroups = {}

local function showPhoto(event)
	if event.phase == "ended" then
        storyboard.showOverlay("slideView", {time=250, effect="crossFade", params={start=event.target.index, images=photoFiles}})
	end
	return true
end

function scene:createScene( event )
    local group = self.view

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
    titleText = display.newText( "Photo Gallery", 0, 0, myApp.fontBold, 20 )
    if myApp.isGraphics2 then
        titleText:setFillColor(1)
    else
        titleText:setTextColor( 255, 255, 255 )
    end
    titleText.x = display.contentCenterX
    titleText.y = titleBar.height * 0.5 + display.topStatusBarContentHeight
    group:insert(titleText)

    local row = 0
    local col = 0

    local thumbnailMask = graphics.newMask("images/mask-80x80.png")

    local groupOffset = 0
    if tonumber( system.getInfo("build") ) < 2013.2000 then
        groupOffset = 40
    end

    for i = 1, #photoFiles do
    	photosThumbnails[i] = display.newImage(photoFiles[i])
    	local aspectRatio = photosThumbnails[i].width / photosThumbnails[i].height
    	local scale
    	if aspectRatio > 1 then -- landscape photo
    		scale = 80 / photosThumbnails[i].height
    	else
    		scale = 80 / photosThumbnails[i].width
    	end
    	--print(scale, aspectRatio, photosThumbnails[i].width, photosThumbnails[i].width * scale, photosThumbnails[i].height, photosThumbnails[i].height * scale)
   		photosThumbnails[i]:scale(scale,scale)
   		photosThumbGroups[i] = display.newGroup()
   		photosThumbnails[i].x = groupOffset --col * 80 + 40
   		photosThumbnails[i].y = groupOffset --row * 80 + 40 + 70
   		photosThumbGroups[i]:insert(photosThumbnails[i])
		photosThumbGroups[i].x = col * 80 + 40
		photosThumbGroups[i].y = row * 80 + 40 + 70
		photosThumbGroups[i]:setMask(thumbnailMask)
		photosThumbGroups[i].maskX = groupOffset
		photosThumbGroups[i].maskY = groupOffset 
		photosThumbGroups[i].index = i
		photosThumbGroups[i]:addEventListener("touch", showPhoto)
		col = col + 1
		if col > 3 then 
			row = row + 1
			col = 0
		end
		group:insert(photosThumbGroups[i])

    end
    print("Memory", system.getInfo("textureMemoryUsed") / (1024 * 1024))
end

function scene:enterScene( event )
    local group = self.view
    
end

function scene:exitScene( event )
    local group = self.view

    --
    -- Clean up any native objects and Runtime listeners, timers, etc.
    --
    
end

function scene:destoryScene( event )
    local group = self.view
    
end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene
