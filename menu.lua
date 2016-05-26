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

local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )
local widgetExtras = require("widget-extras")
local myApp = require( "myapp" )

widget.setTheme(myApp.theme)

local titleText
local locationtxt
local views = {}


local function ignoreTouch( event )
	return true
end

function scene:create( event )
	local sceneGroup = self.view

	local background = display.newRect(0,0,display.contentWidth, display.contentHeight)
	background:setFillColor( 0.95, 0.95, 0.95 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY
	sceneGroup:insert(background)
	background:addEventListener("touch", ignoreTouch)

    local navBar = widget.newNavigationBar({
        title = "Corona Labs Menu",
        backgroundColor = { 0.96, 0.62, 0.34 },
        titleColor = {1, 1, 1},
        font = myApp.fontBold
    })
    sceneGroup:insert(navBar)


    local button1 = widget.newButton({
    	width = 160,
    	height = 40,
    	label = "Corona Blogs",
        labelColor = { 
            default = { 0.90, 0.60, 0.34 }, 
            over = { 0.79, 0.48, 0.30 } 
        },
    	labelYOffset = -4, 
    	font = myApp.font,
    	fontSize = 18,
    	emboss = false,
    	onRelease = myApp.showScreen2
    })
    sceneGroup:insert(button1)
    button1.x = display.contentCenterX
    button1.y = display.contentCenterY - 120


    local button2 = widget.newButton({
    	width = 160,
    	height = 40,
    	label = "Photo Gallery",
        labelColor = { 
            default = { 0.90, 0.60, 0.34 }, 
            over = { 0.79, 0.48, 0.30 } 
        },
    	labelYOffset = -4, 
    	font = myApp.font,
    	fontSize = 18,
    	emboss = false,
    	onRelease = myApp.showScreen3
    })
    sceneGroup:insert(button2)
    button2.x = display.contentCenterX
    button2.y = display.contentCenterY - 50


    local button3 = widget.newButton({
    	width = 160,
    	height = 40,
    	label = "Corona Videos",
        labelColor = { 
            default = { 0.90, 0.60, 0.34 }, 
            over = { 0.79, 0.48, 0.30 } 
        },
    	labelYOffset = -4, 
    	font = myApp.font,
    	fontSize = 18,
    	emboss = false,
    	onRelease = myApp.showScreen4
    })
    sceneGroup:insert(button3)
    button3.x = display.contentCenterX
    button3.y = display.contentCenterY + 20

    local button4 = widget.newButton({
    	width = 160,
    	height = 40,
    	label = "Map",
        labelColor = { 
            default = { 0.90, 0.60, 0.34 }, 
            over = { 0.79, 0.48, 0.30 } 
        },
    	labelYOffset = -4, 
    	font = myApp.font,
    	fontSize = 18,
    	emboss = false,
    	onRelease = myApp.showScreen5
    })
    sceneGroup:insert(button4)
    button4.x = display.contentCenterX
    button4.y = display.contentCenterY + 90

    local button5 = widget.newButton( {
        width = 160,
        height = 40,
        label = "Data",
        labelColor = { 
            default = { 0.90, 0.60, 0.34 }, 
            over = { 0.79, 0.48, 0.30 } 
        },
        labelYOffset = -4, 
        font = myApp.font,
        fontSize = 18,
        emboss = false,
        onRelease = myApp.showScreen6
    } )
    sceneGroup:insert(button5)
    button5.x = display.contentCenterX
    button5.y = display.contentCenterY + 160

end

function scene:show( event )
	local sceneGroup = self.view

end

function scene:hide( event )
	local sceneGroup = self.view

	--
	-- Clean up native objects
	--

end

function scene:destroy( event )
	local sceneGroup = self.view
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene