-- Project: Business Sample App
--
-- File name: feed.lua
--
-- Author: Corona Labs
--
-- Abstract: Read an RSS Feed.
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
--

local composer = require( "composer" )
local scene = composer.newScene()

local socket = require( "socket" )
local widget = require( "widget" )
local utf8 = require( "plugin.utf8" )

-- if you have an Atom feed uncomment this and comment out the line after it.
-- local rss = require("atom")
local rss = require( "rss" )
local myApp = require( "myapp" )

widget.setTheme(myApp.theme)


-- forward declarations

local feedName
local feedURL
local displayMode 
local pageTitle 
local icons
local params
local springStart
local needToReload
local spinner

local myList = nil
local stories = {}
local listGroup
local imageList = {}

-- make a quick network connection to your server.. 
-- this requires the site's DNS Name, not a URL, in other words leave off
-- the http:// and no trailing things like /index.php
--
local function testNetworkConnection()
        local netConn = socket.connect('www.google.com', 80)
        if netConn == nil then
             return false
        end
        netConn:close()
        return true
end

--
-- this function gets called when we tap on a row.
--
local onRowTouch = function( event )
    if event.phase == "release" then
        
        local id = event.row.index
        local story = event.target.params.story
        local params = {
            story = story
        }
        local options = {
            effect = "slideLeft",
            time = 250,
            isModal = true,
            params = params
        }
        composer.showOverlay(displayMode, options)
    end
    return true
end

-- 
-- This function is used to draw each row of the tableView
--
    
local function onRowRender(event)
    print("row render")
    --
    -- set up the variables we need that are passed via the event table
    --
    local row = event.row
    local story = event.row.params.story
    local id = row.index
    --
    -- boundry check to make sure we are not trying to access a story that
    -- doesnt exist.
    --
    if id > #stories then return true end

    row.bg = display.newRect(0, 0, display.contentWidth, 60)
    row.bg.anchorX = 0
    row.bg.anchorY = 0
    row.bg:setFillColor( 1, 1, 1 )
    row:insert(row.bg)
    
    --
    -- attempt to get an enclosure to render in the row
    --

    --
    -- display.loadRemoteImage creates a display object, but you can only access it in the event call back
    -- so we need a function to handle rendering the row.
    --
    local function thumbListener( event )
        if ( event.isError ) then
            print ( "Network error - download failed" )
        else
            print ("got image")
            
            event.target.alpha = 0
            --
            -- This is scaling code.  I have no idea how big the downloaded image was.  
            -- Divide the desired height of the image by the real height and that gives us a number we
            -- can feed to the scale() method to keep the image's aspect ratio and controlling the height.
            -- If you need to furhter control the width, you could do a second pass kind of like this:
            --
            -- if w * s > maxWidth then s = maxWidth / w end
            --
            -- and feed the new s value to the scale() method.
            --
            local w = event.target.width
            local h = event.target.height
            local s = itemIcon.height / h
            event.target:scale(s,s)
            event.target.anchorX = 0
            event.target.anchorY = 0
            event.target.x = 2
            event.target.y = 4
            --
            -- put the image into the row
            --
            row:insert(event.target)
            transition.to( event.target, {time=100, alpha = 1.0 } )
        end
        print ( "RESPONSE: " .. event.response )
    end


    -- check to see if I'm using embedded icons or showing something fixed.
    if icons == "embedded" then
        --
        -- lets check to see if we have any enclosures.  The entry must not be nil and there has to be at least one entry
        -- (it is possible for enclosures to have an empty table that wouldn't be nil)
        if story.enclosures and #story.enclosures > 0 then
            -- check to see if it's an image.
            -- an entry can have multiple enclosures.  They may not all be something we can display (audio, etc.) so loop 
            -- over the enclosures and look for anything that is a type we can suppport.   This is case sensitive and I don't
            -- know if every feed sends them in lower case.
            --
            local found = false
            local j = 0
            while j < #story.enclosures and not found do
                j = j + 1
                local e = story.enclosures[j]
                if e.type == "image/jpeg" or e.type == "image/jpg" or e.type == "image/png" then
                    --
                    -- Ah Ha! we have a potentially displayable image
                    -- create a local filename.  I suppose I could parse it out of the URL, but it really doesn't matter
                    -- so make up one, but I do need to parse the extension off of the type.
                    local filename = string.format("image_%3d.%s",id, string.sub(e.type, string.find(e.type,"/") + 1))
                    --
                    -- Now make Corona SDK do all the heavy lifting for me.  This little gem will fetch the URL, 
                    -- store it in the Caches directory (to make Apple happy) and when complete it will call a function that
                    -- will shove it into our row for us.  If the image is bad, or doesn't exist, then it won't display anything
                    -- though it should drop a message into the console log.
                    --
                    display.loadRemoteImage( e.url, "GET", thumbListener, filename, system.CachesDirectory, 0, 0 )
                end
            end
        end

    else
        --
        -- If you want an icon on the left side of the table view, define it here
        -- it uses the table above to get all the information we need
        --
        row.icon = display.newImageRect(myApp.icons, 12 , 40, 40 )
        row.icon.x = 20
        row.icon.y = row.height / 2
        row:insert(row.icon)

    end
    --
    -- Figure out how long I can make my titles
    --
    local titleLength = math.floor(display.contentWidth / 11) - 3
    --
    -- Now create the first line of text in the table view with the headline
    -- of the story item.
    --
    local myTitle = story.title
    if utf8.len(myTitle) > titleLength then
        myTitle = utf8.sub(myTitle, 1, titleLength) .. "..."
    end
    row.title = display.newText( myTitle, 12, 0, myApp.fontBold, 18 )
    row.title.anchorX = 0
    row.title.anchorY = 0.5
    row.title:setFillColor( 0 )

    row.title.y = 22
    row.title.x = 42

    
    --
    -- show the publish time in grey below the headline
    --
    local timeStamp = string.match(story.pubDate,"%w+, %d+ %w+ %w+ %w+:%w+")
    row.subtitle = display.newText( timeStamp, 12, 0, myApp.font, 14)
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
local function showTableView()
    print("Calling showTableView()")

    -- 
    -- now the fun part!  loop over the number of stories returned in the feed
    -- and do an insertRow for each table item.  Note that we specify the function 
    -- to do when the row is tapped on and a function to do to render each row.
    

    for i = 1, #stories do

        print("insert row:  " .. i .. " [" .. stories[i].title .. "]")
        
        myList:insertRow{
            rowHeight = 60,
            isCategory = false,
            rowColor = { 1, 1, 1 },
            lineColor = { 0.90, 0.90, 0.90 },
            params = {
                story = stories[i]
            }
        }
    end
    -- cancel the busy indicator
    --native.setActivityIndicator( false )
end

--
-- since we are basically re-entering the same scene over and over, we have to
-- dump the tableView and rebuild it each time so that it functions correctly
--
local function purgeList(list)
    list:deleteAllRows()
end

--
-- function to fetch the feed, parse it and setup the display
--
-- This has to be read kind of backwards based on the flow of things.  
-- 
-- First, we need to check for network avaialbility.  That will trigger a
-- call back function, that will start the download.  Once the download is 
-- donn, another call back will trigger the parsing of the RSS feed, then when
-- that is done, the tableView is loaded up with entries and displayed.
-- if the network is  unavialable or if the downloas fails we will try to use
-- the cached version of the file.  
--
-- I should point out that this system supports both RSS2.0 and Atom feeds.
-- Both are RSS feeds, but they are slightly different and enough that the same
-- parser won't deal with both feeds.  So you can substitude 
function displayFeed(feedName, feedURL)
    native.setActivityIndicator(true)
    print("entering displayFeed", feedName, feedURL)

    -- 
    -- this will process the file and return a table with the feed information
    -- a member of that table, named items, is a table with each story returned
    -- from the feed.  
    -- Then we initialize the tableView.
    --
    local function processRSSFeed(file, path)
        native.setActivityIndicator(false)
        print("Parsing the feed")
        local story = {}
        local feed = rss.feed(file, path)
        
        stories = feed.items
        print("Num stories: " .. #stories)
        print("Got ", #stories, " stories, now show the tableView")
        purgeList(myList)
        showTableView()
    end
    
    local function onAlertComplete( event )
        return true
    end
    
    --
    -- Ah ha, our download is finished.  Maybe.  If it is, process the feed.
    
    local networkListener = function( event )
       
        if ( event.isError ) then
            local alert = native.showAlert( "CoronaSDK", "Feed temporarily unavaialble.", 
                                        { "OK" }, onAlertComplete )
        else
            print("calling processRSSFeed because the feed is avaialble")
            processRSSFeed(feedName, system.CachesDirectory)
        end
        return true
    end
    
    --
    -- cool we can reach the network, now request the file.  If the network can't
    -- be reached, then check for the cached version of the file.  
    --
    
    local isReachable = testNetworkConnection()
    if isReachable then
        -- download the latest file
        -- show some indicator that we are busy

        --native.setActivityIndicator( true )
        -- uncomment the line above if you want an activity indicator but it causes
        -- the display to flash if it downloads the file too quickly
        -- likewise if you do, you have to uncomment the other setActivityIndicator
        -- above.

        network.download(feedURL, "GET", networkListener, feedName, system.CachesDirectory)
    else
        print("not reachable")
        -- look for an existing copy
       
        local path = system.pathForFile(feedName, system.CachesDirectory)
        
        local fh, errStr = io.open( path, "r" )
        if fh then
            io.close(fh)
            print("calling processRSSfeed because the network isn't reachable")
            processRSSFeed(feedName, system.CachesDirectory)
        else
            local alert = native.showAlert( "CoronaSDK", "Feed temporarily unavaialble.", 
                                        { "OK" }, onAlertComplete )
        end
    end
    return true
   
end

local function reloadTable()
    --
    -- check the URL and see if it has a query string, if not add one, if it does just add 
    -- our cache buster string
    -- 
    local cacheBustedURL = feedURL
    if string.find(cacheBustedURL,"%?") then
        -- we have a query string
        cacheBustedURL = cacheBustedURL .. "&cacheBust=" .. tonumber(os.time())
    else
        cacheBustedURL = cacheBustedURL .. "?cacheBust=" .. tonumber(os.time())
    end
    displayFeed(feedName, cacheBustedURL )
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
        if not spinner.isVisible then
            spinner.isVisible = true
            spinner:start()
        end
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
        spinner:stop()
        spinner.isVisible = false
        reloadTable()
    end
    return true
end

--
-- Start the composer event handlers
--

function scene:create( event )
    local sceneGroup = self.view

    params = event.params
        
    --
    -- setup a page background, really not that important though composer
    -- crashes out if there isn't a display object in the view.
    --

    print("create scene")
    local background = display.newRect(0,0,display.contentWidth, display.contentHeight)
    background:setFillColor( 0.95, 0.95, 0.95 )
    background.x = display.contentWidth / 2
    background.y = display.contentHeight / 2

    sceneGroup:insert(background)

    local navBar = widget.newNavigationBar({
        title = "Corona Labs",
        backgroundColor = { 0.96, 0.62, 0.34 },
        titleColor = {1, 1, 1},
        font = myApp.fontBold
    })
    sceneGroup:insert(navBar)

    --
    -- Create an invisible button to reload our table over top of the status bar
    --

    local reloadBar = display.newRect(display.contentCenterX, display.topStatusBarContentHeight * 0.5, display.contentWidth, display.topStatusBarContentHeight)
    reloadBar.isVisible = false
    reloadBar.isHitTestable = true
    reloadBar:addEventListener( "tap", reloadTable )


    local box = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight - navBar.height - 50)
    box:setFillColor( 0.8, 0.8, 0.8 )
    box.anchorY = 0
    box.y = navBar.height
    sceneGroup:insert(box)

    spinner = widget.newSpinner({ 
        width = 32, 
        height = 32, 
    })
    sceneGroup:insert(spinner)
    spinner.x = display.contentCenterX
    spinner.y = navBar.height + 20
    spinner.isVisible = false

    --
    -- Create the table view.  After the height of the top bar, the bottom tabBar
    -- and room for the ad, we have room for a 320x320 area to hold the table view.
    -- Since we are not using the whole screen we will need a mask file.
    --

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

    
    params = event.params

    print("enter scene")
 
    -- fetch the parameters from the composer table for this view
    
    feedName = params.feedName
    feedURL = params.feedURL
    displayMode = params.displayMode
    pageTitle = params.pageTitle
    icons = params.icons

    --
    -- go fetch the feed
    --
    if event.phase == "did" then
        print("show", feedName,feedURL)
        displayFeed(feedName, feedURL)
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    
    -- get out of here.
    -- dump the table entries
    --
    if event.phase == "will" then
        print("exit scene")
        purgeList(myList)
    end

end

function scene:destroy( event )
    local sceneGroup = self.view
    
    print("destroy scene")
end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "create", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "show", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "hide", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- composer.purgeScene() or composer.removeScene().
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
