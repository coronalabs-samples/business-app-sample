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
local myList

local function ignoreTouch( event )
	return true
end

local onRowTouch = function( event )
    if event.phase == "release" then
        
        local id = event.row.index
        local user = event.target.params.user
        local params = {
            user = user
        }
        local options = {
            effect = "slideLeft",
            time = 250,
            isModal = true,
            params = params
        }
        composer.showOverlay("edituser", options)
    end
    return true
end

-- 
-- This function is used to draw each row of the tableView
--
    
local function onRowRender(event)
    --
    -- set up the variables we need that are passed via the event table
    --
    local row = event.row
    local user = event.row.params.user
    local id = row.index

    print( json.prettify( user ) )

    row.bg = display.newRect(0, 0, display.contentWidth, 60)
    row.bg.anchorX = 0
    row.bg.anchorY = 0
    row.bg:setFillColor( 1, 1, 1 )

    row:insert(row.bg)
    
    -- Figure out how long I can make my titles
    --
    row.title = display.newText( user.firstName .. " " .. user.lastName, 12, 0, myApp.fontBold, 18 )
    row.title.anchorX = 0
    row.title.anchorY = 0.5
    row.title:setFillColor( 0 )

    row.title.y = 22
    row.title.x = 42

    
    --
    -- show the publish time in grey below the headline
    --
    row.subtitle = display.newText( user.email, 12, 0, myApp.font, 14)
    row.subtitle.anchorX = 0
    row.subtitle:setFillColor( 0.375, 0.375, 0.375 )
    row.subtitle.y = row.height - 18
    row.subtitle.x = 42

    --
    -- Add a graphical right arrow to the right side to indicate the reader
    -- should touch the row for more information
    --
    row.rightArrow = display.newImageRect(myApp.icons, 15 , 40, 40)
    row.rightArrow.x = display.contentWidth - 20
    row.rightArrow.y = row.height / 2
    -- must insert everything into event.view:
    row:insert(row.title )
    row:insert(row.subtitle)
    row:insert(row.rightArrow)
    return true
end

--
-- load up our tableiew and manage it
--
local function loadTableView()
    print("Calling showTableView()")

    -- 
    -- now the fun part!  loop over the number of stories returned in the feed
    -- and do an insertRow for each table item.  Note that we specify the function 
    -- to do when the row is tapped on and a function to do to render each row.
    local results = db.read( "SELECT * FROM accounts ORDER BY LOWER(lastName), LOWER(firstName), id ASC" )

    for i = 1, #results do
        myList:insertRow{
            rowHeight = 60,
            isCategory = false,
            rowColor = { 1, 1, 1 },
            lineColor = { 0.90, 0.90, 0.90 },
            params = {
                user = results[i]
            }
        }
    end
end

function scene.reloadTable()
	myList:deleteAllRows()
	loadTableView()
end

local function tableViewListener(event)
    print("tableViewListener", event.phase, event.direction, event.limitReached, myList:getContentPosition( ))
    if event.phase == "began" then
        local currentPosition = nil
        if event.target.parent.parent.getContentPosition then 
            currentPosition = event.target.parent.parent:getContentPosition( )
        end
        springStart = currentPosition
        print("springStart", springStart)
        needToReload = false
    elseif event.phase == "moved" then
        local currentPosition = nil
        if event.target.parent.parent.getContentPosition then
            currentPosition = event.target.parent.parent:getContentPosition( )
        end
        if currentPosition and springStart and currentPosition > springStart + 60 then
            needToReload = true
            --print("needToReload", needToReload, myList:getContentPosition( ), springStart + 60)
        end
    elseif event.phase == nil and event.direction == "down" and event.limitReached == true and needToReload then
        --print("reloading Table!")
        needToReload = false
        scene.reloadTable()
    end
    return true
end

local function addButtonListener( event )
	if event.phase == "began" then
		composer.showOverlay("registration", { time = 250, effect = "slideLeft" })
	end
	return true
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
        font = myApp.fontBold,
        rightButton = {
        	label = "Add",
            id = "add",
            onEvent = addButtonListener,
            labelAlign = "right",        	
        }
    })
    sceneGroup:insert(navBar)

    local tWidth = display.contentWidth
    local tHeight = display.contentHeight - navBar.height - myApp.tabBar.height

    myList = widget.newTableView{ 
        top = navBar.height, 
        width = tWidth, 
        height = tHeight, 
        maskFile = maskFile,
        listener = tableViewListener,
        hideBackground = true, 
        onRowRender = onRowRender,
        onRowTouch = onRowTouch 
    }
    --
    -- insert the list into the group
    sceneGroup:insert(myList)
end

function scene:show( event )
	local sceneGroup = self.view

	if event.phase == "will" then
		loadTableView()
	end
end

function scene:hide( event )
	local sceneGroup = self.view

	--
	-- Clean up native objects
	--

	if event.phase == "will" then

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