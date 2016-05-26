-- Project: Business Sample App
--
-- File name: registration.lua
--
-- Author: Corona Labs
--
-- Abstract: show how to create a data input form and store it in a database table
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
local json = require( "json" )
local widgetExtras = require( "widget-extras" )
local myApp = require( "myapp" )
local db = require( "database" )

widget.setTheme(myApp.theme)

local titleText
local navBar
local firstNameLabel
local firstNameField
local lastNameLabel
local lastNameField
local emailAddressLabel
local emailAddressField
local submitButton

local function ignoreTouch( event )
	return true
end

local function fieldHandler( textField )
	return function( event )
		if ( "began" == event.phase ) then
			-- This is the "keyboard has appeared" event
			-- In some cases you may want to adjust the interface when the keyboard appears.
		
		elseif ( "ended" == event.phase ) then
			-- This event is called when the user stops editing a field: for example, when they touch a different field
			
		elseif ( "editing" == event.phase ) then
		
		elseif ( "submitted" == event.phase ) then
			-- This event occurs when the user presses the "return" key (if available) on the onscreen keyboard
			print( textField().text )
			
			-- Hide keyboard
			native.setKeyboardFocus( nil )
		end
	end
end


local function submitForm( event )
	local record = {}
	record.firstName = firstNameField.text	
	record.lastName = lastNameField.text	
	record.email = emailAddressField.text
	print( json.prettify( record ) )
	db.create( record )
	composer.hideOverlay()
end

local function leftButtonEvent( event )
    if event.phase == "ended" then
        local currScene = composer.getSceneName( "overlay" )
        if currScene then
            composer.hideOverlay( "fromRight", 250 )
        else
            composer.gotoScene( "registration", { isModal=true, time=250, effect="fromLeft" } )
        end
    end
    return true
end

function scene:create( event )
	local sceneGroup = self.view

    local background = display.newRect(0,0,display.contentWidth, display.contentHeight)
    background:setFillColor( 0.95, 0.95, 0.95 )
    background.x = display.contentWidth / 2
    background.y = display.contentHeight / 2

    sceneGroup:insert(background)

    local leftButton = {
        width = 35,
        height = 35,
        label = "<Back",
        onEvent = leftButtonEvent,
    }

    navBar = widget.newNavigationBar({
        title = "Add new account",
        backgroundColor = { 0.96, 0.62, 0.34 },
        titleColor = {1, 1, 1},
        font = myApp.fontBold, 
        leftButton = leftButton
    })
    sceneGroup:insert(navBar)

    firstNameLabel = display.newText( "First Name", 10, navBar.y + navBar.height + 30, native.systemFont, 18 )
	firstNameLabel:setFillColor( 0.3, 0.3, 0.3 )
	firstNameLabel.anchorX = 0
	sceneGroup:insert( firstNameLabel )

	lastNameLabel = display.newText( "Last Name", 10, firstNameLabel.y + 40, native.systemFont, 18 )
	lastNameLabel:setFillColor( 0.3, 0.3, 0.3 )
	lastNameLabel.anchorX = 0
	sceneGroup:insert( lastNameLabel )

	emailAddressLabel = display.newText( "Email address", 10, lastNameLabel.y + 40, native.systemFont, 18 )
	emailAddressLabel:setFillColor( 0.3, 0.3, 0.3 )
	emailAddressLabel.anchorX = 0
	sceneGroup:insert( emailAddressLabel)
end

function scene:show( event )
	local sceneGroup = self.view

	if event.phase == "did" then
		-- The text field's native peice starts hidden, we show it after we are on screen.on

		-- lets make the fields fit our adaptive screen better
		-- Why 150? The labels are around 120px wide. We want at least a 10px margin on either side of the labels
		-- and fields and we need some space betwen the label and the field. Let's start with 10px each

		local fieldWidth = display.contentWidth - 150
		if fieldWidth > 250 then
			fieldWidth = 250
		end

		firstNameField = native.newTextField( 130, firstNameLabel.y, fieldWidth, 30 )
		firstNameField:addEventListener( "userInput", fieldHandler( function() return firstNameField end ) ) 
		sceneGroup:insert( firstNameField)
		firstNameField.anchorX = 0
		firstNameField.placeholder = "First name"

		lastNameField = native.newTextField( 130, lastNameLabel.y, fieldWidth, 30 )
		lastNameField:addEventListener( "userInput", fieldHandler( function() return lastNameField end ) ) 
		sceneGroup:insert( lastNameField )
		lastNameField.anchorX = 0
		lastNameField.placeholder = "Last name"

		emailAddressField = native.newTextField( 130, emailAddressLabel.y, fieldWidth, 30 )
		emailAddressField.inputType = "email"
		emailAddressField:addEventListener( "userInput", fieldHandler( function() return emailAddressField end ) ) 
		sceneGroup:insert( emailAddressField )
		emailAddressField.anchorX = 0
		emailAddressField.placeholder = "Email address"

	    --
	    -- For sake of keeping this a reasonable sample app, we will not demonstate
	    -- password fields.
	    --
	    -- Passwords should be stored in your database using a one way encryption. This 
	    -- encryption should include the addition of a SALT string being added to make 
	    -- the password more complex than the user provided. 
	    --
	    -- Then when validating the login process (taking the login password and seeing if it
	    -- matches), you re-encrypt the entered password after applying the SALT string and then
	    -- you check if the two encrypted passwords match. This process, while not difficult takes
	    -- the scope of this project beyond what we are trying to demo for you.
	    --
	    -- Please make sure in real world applications of this, you take the time to properly secure
	    -- your apps data.
	    --

	    submitButton = widget.newButton({
	        width = 160,
	        height = 40,
	        label = "Submit",
	        labelColor = { 
	            default = { 0.90, 0.60, 0.34 }, 
	            over = { 0.79, 0.48, 0.30 } 
	        },
	        labelYOffset = -4, 
	        font = myApp.font,
	        fontSize = 18,
	        emboss = false,
	        onRelease = submitForm
	    })
	    submitButton.x = display.contentCenterX
	    submitButton.y = emailAddressField.y + 50
	    sceneGroup:insert( submitButton )
	end
end

function scene:hide( event )
	local sceneGroup = self.view

	--
	-- Clean up native objects
	--

	if event.phase == "will" then
		-- remove the addressField since it contains a native object.
		firstNameField:removeSelf()
		firstNameField = nil
		lastNameField:removeSelf()
		lastNameField = nil
		emailAddressField:removeSelf()
		emailAddressField = nil
		event.parent:reloadTable()
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