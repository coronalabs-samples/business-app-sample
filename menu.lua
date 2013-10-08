-- Project: Business Sample App
--
-- File name: menu.lua
--
-- Author: Corona Labs
--
-- Abstract: A simple menu.
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

--if not myApp.legacy then
--    widget.setTheme(myApp.theme)
--end
widget.setTheme("widget_theme_ios7")

local titleText
local locationtxt
local views = {}


local function ignoreTouch( event )
	return true
end

function scene:createScene(event)
	local group = self.view

	local background = display.newRect(0,0,display.contentWidth, display.contentHeight)
	background:setFillColor(242, 242, 242, 255)
	group:insert(background)
	background:addEventListener("touch", ignoreTouch)

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
    titleText = display.newText( "Corona Labs Menu", 0, 0, myApp.fontBold, 20 )
    titleText:setTextColor( 255, 255, 255 )
    titleText:setReferencePoint( display.CenterReferencePoint )
    titleText.x = display.contentCenterX
    titleText.y = titleBar.height * 0.5 + display.topStatusBarContentHeight
    group:insert(titleText)

    local button1 = widget.newButton({
    	width = 160,
    	height = 40,
    	label = "Corona Blogs",
        labelColor = { default = { 232, 153, 87, 255 }, over = { 202, 123, 77, 255} },
    	labelYOffset = -4, 
    	font = myApp.font,
    	fontSize = 18,
    	emboss = false,
    	onRelease = myApp.showScreen2
    })
    group:insert(button1)
    button1.x = display.contentCenterX
    button1.y = display.contentCenterY - 120


    local button2 = widget.newButton({
    	width = 160,
    	height = 40,
    	label = "Photo Gallery",
        labelColor = { default = { 232, 153, 87, 255 }, over = { 202, 123, 77, 255} },
    	labelYOffset = -4, 
    	font = myApp.font,
    	fontSize = 18,
    	emboss = false,
    	onRelease = myApp.showScreen3
    })
    group:insert(button2)
    button2.x = display.contentCenterX
    button2.y = display.contentCenterY - 40


    local button3 = widget.newButton({
    	width = 160,
    	height = 40,
    	label = "Corona Videos",
        labelColor = { default = { 232, 153, 87, 255 }, over = { 202, 123, 77, 255} },
    	labelYOffset = -4, 
    	font = myApp.font,
    	fontSize = 18,
    	emboss = false,
    	onRelease = myApp.showScreen4
    })
    group:insert(button3)
    button3.x = display.contentCenterX
    button3.y = display.contentCenterY + 40

    local button4 = widget.newButton({
    	width = 160,
    	height = 40,
    	label = "Map",
        labelColor = { default = { 232, 153, 87, 255 }, over = { 202, 123, 77, 255} },
    	labelYOffset = -4, 
    	font = myApp.font,
    	fontSize = 18,
    	emboss = false,
    	onRelease = myApp.showScreen5
    })
    group:insert(button4)
    button4.x = display.contentCenterX
    button4.y = display.contentCenterY + 120

end

function scene:enterScene( event )
	local group = self.view

end

function scene:exitScene( event )
	local group = self.view

	--
	-- Clean up native objects
	--

end

function scene:destroyScene( event )
	local group = self.view
end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

return scene