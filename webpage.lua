-- Project: Business Sample App
--
-- File name: webpage.lua
--
-- Author: Corona Labs
--
-- Abstract: Display a web page.
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

local widget = require("widget")
local myApp = require("myapp")

widget.setTheme(myApp.theme)

local playButton
local webView
local backButton
local navBar

local function goBack(event)
    if event.phase == "ended" then
        composer.hideOverlay( "slideRight", 250)
    end
    return true
end

function scene:create( event )
    local sceneGroup = self.view

    local story = event.params.story
        
    --
    -- setup a page background, really not that important, but if we don't
    -- have at least one display object in the view, it will crash.
    --

    print("create scene")
    local background = display.newRect(0,0,display.contentWidth, display.contentHeight)
    background:setFillColor( 0.95, 0.95, 0.95 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    sceneGroup:insert(background)

    local title = story.title
    if title and title:len() > 16 then
        title = title:sub(1,16) .. "..."
    end

    local leftButton = {
        onEvent = goBack,
        width = 59,
        height = 32,
        defaultFile = "images/backbutton7_white.png",
        overFile = "images/backbutton7_white.png"
    }

    navBar = widget.newNavigationBar({
        title = title,
        backgroundColor = { 0.96, 0.62, 0.34 },
        titleColor = {1, 1, 1},
        font = myApp.fontBold,
        leftButton = leftButton,
    })
    sceneGroup:insert(navBar)

end

function scene:show( event )
    local sceneGroup = self.view

    -- load the story data in from global space, was put there in feed.lua
    local story = event.params.story

    if event.phase == "did" then

        local title = story.title
        if title then
            if title:len() > 16 then
                title = title:sub(1,16) .. "..."
            end
        else
            title = "Corona Labs"
        end
        navBar:setLabel( title )

        -- if the reader choses to see the article in the web browser, open it.
        
        local function viewWebPage(event)
            system.openURL( story.link )
        end

        -- now we write out the story body, which likely has HTML code in it to a
        -- temporary file that we will load back in to our web view.
        
        local path = system.pathForFile( "story.html", system.TemporaryDirectory )
     
        -- io.open opens a file at path. returns nil if no file found
        local fh, errStr = io.open( path, "w" )
     
        -- 
        -- Write out the required headers to make sure the content fits into our
        -- window and then dump the body.
        --
        if fh then
            print( "Created file" )
            fh:write("<!doctype html>\n<html>\n<head>\n<meta charset=\"utf-8\">")
            fh:write("<meta name=\"viewport\" content=\"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\"/>\n")
            fh:write("<style type=\"text/css\">\n html { -webkit-text-size-adjust: none; font-family: HelveticaNeue-Light, Helvetica, Droid-Sans, Arial, san-serif; font-size: 1.1em; } h1 {font-size:1.25em;} p {font-size:0.9em; } </style>")
            fh:write("</head>\n<body>\n")
            if story.title then
                fh:write("<h1>" .. story.title .. "</h1>\n")
            end
            if story.content_encoded then
                fh:write( story.content_encoded)
            elseif story.description then
                fh:write(story.description)
            end
            fh:write( "\n</body>\n</html>\n" )
            io.close( fh )
        else
            print( "Create file failed!" )
        end

        --
        -- handler to deal with clicking on any anchor tags in the above HTML.
        --
        local function webListener(event)
            print("showWebPopup callback")
            
            local url = event.url

            if( string.find( url, "http:" ) ~= nil or string.find( url, "mailto:" ) ~= nil ) then
                print("url: ".. url)
                system.openURL(url)
            end

            return true
        end
       
        local isTall = 0
        if myApp.isTall then
            isTall = 88
        end

        -- turn off the activity indicator and show the webview
        --native.setActivityIndicator( false )
    --    local options = { hasBackground=false, baseUrl=system.TemporaryDirectory, urlRequest=listener }
        --local options = { hasBackground=true,  urlRequest=listener }
    --    native.showWebPopup(0, 51 + 60 + 20 + 60, display.contentWidth, 220 + isTall, "story.html", options )

        webView = native.newWebView(0, 71, display.contentWidth, display.contentHeight - 150)
        webView.x = display.contentCenterX
        webView.y = navBar.y + 50 + display.topStatusBarContentHeight
        webView.anchorY  = 0

        webView:request("story.html", system.TemporaryDirectory)

        webView:addEventListener( "urlRequest", webListener )
        -- add a button to see the full article in the web browser
        local play_button = display.newImageRect("images/view_button.png", 300, 32)
        play_button.x = display.contentCenterX
        play_button.y = display.contentHeight - 80
        sceneGroup:insert(play_button)
        play_button:addEventListener("tap", viewWebPage)
    end              
end

function scene:hide( event )
    local sceneGroup = self.view

    --
    -- Clean up any native objects and Runtime listeners, timers, etc.
    --
    if event.phase == "will" then
        if webView and webView.removeSelf then
            webView:removeSelf()
            webView = nil
        end
    end
end

function scene:destroy( event )
    local sceneGroup = self.view
    
end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
