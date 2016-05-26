-- Project: Business Sample App
--
-- File name: main.lua
--
-- Author: Corona Labs
--
-- Abstract: Main entry point.
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
--display.setStatusBar( display.HiddenStatusBar )

--
-- load in composer
--
local composer = require ( "composer" )
local widget = require( "widget" )
local json = require( "json" )
local myApp = require( "myapp" ) 

if (display.pixelHeight/display.pixelWidth) > 1.5 then
    myApp.isTall = true
end

if display.contentWidth > 320 then
    myApp.is_iPad = true
end

math.randomseed(os.time())

--
-- Initialize database
-- 
local db = require( "database" )
local myScheme = {}
myScheme["__tableName"] = "accounts"
myScheme["firstName"] = "text"
myScheme["lastName"] = "text"
myScheme["email"] = "text"


--
-- Create the database
-- store the object handle in our faux global myApp table
--
db.init( "mydatabase.db", myScheme )


-- NOTE: In a real app you should do a one way encryption on the password field and never store it in clear text.
-- It's always best to encrypt it, and compare it to the encryptied value in the database. 
-- MD5 hash's are easy encrytption for passwwords, bt most hackers have already gotten MD5 password hashes for most
-- common passwords anyway.

--
-- Load our fonts and define our styles
--

local tabBarBackgroundFile = "images/tabBarBg7.png"
local tabBarLeft = "images/tabBar_tabSelectedLeft7.png"
local tabBarMiddle = "images/tabBar_tabSelectedMiddle7.png"
local tabBarRight = "images/tabBar_tabSelectedRight7.png"

myApp.topBarBg = "images/topBarBg7.png"

local iconInfo = {
    width = 40,
    height = 40,
    numFrames = 20,
    sheetContentWidth = 200,
    sheetContentHeight = 160
}

myApp.icons = graphics.newImageSheet("images/ios7icons.png", iconInfo)
myApp.font = "fonts/Roboto-Light.ttf"
myApp.fontBold = "fonts/Roboto-Regular.ttf"
myApp.fontItalic = "fonts/Roboto-LightItalic.ttf"
myApp.fontBoldItalic = "fonts/Roboto-Italic.ttf"

myApp.theme = "widget_theme_ios7"

if system.getInfo("platformName") == "Android" then
    myApp.topBarBg = "images/topBarBg7.png"

else
    local coronaBuild = system.getInfo("build")
    if tonumber(coronaBuild:sub(6,12)) < 1206 then
        myApp.theme = "widget_theme_ios"
    end

end
widget.setTheme(myApp.theme)
--
-- These next functions, showScreen1 - showScreen4 are the functions that are
-- triggered when the user taps the buttons in the bottom tabView
--
--
-- These should be pretty straight forward.  You need to provide a local file 
-- name to download the feed to (feedName), the URL to fetch from, displayMode
-- can be either "podcaset" or "webpage", which tells the module how to handle
-- the story body.
-- pageTitle is the thing that shows at the top of the list view.
--
--
-- The variable "composer" is just a Lua table that is returned from the 
-- require("composer" above.  As such, I can freely add members/attributes/entries
-- to the table.  By using this technique, I can quickly pass data between 
-- composer scenes.  It's like making them global without the penalties of 
-- making them global.  There is one catch... Corona Labs could come along and 
-- add theor own "displayMode" member (or any of them) later and trump yours
-- but the risk is minmal.
--

myApp.tabBar = {}

function myApp.showScreen1()
    myApp.tabBar:setSelected(1)
    composer.removeHidden()
    composer.gotoScene("menu", {time=250, effect="crossFade"})
    return true
end

function myApp.showScreen2(event)
    myApp.tabBar:setSelected(2)
    local options = {
        feedName = "corona.rss",
        feedURL = "https://www.coronalabs.com/feed/",
        icons = "fixed",
        displayMode = "webpage",
        pageTitle = "Corona Labs"
    }
    composer.removeHidden()
    composer.gotoScene("feed", {time=250, effect="crossFade", params = options})
    return true
end

function myApp.showScreen3()
    myApp.tabBar:setSelected(3)
    composer.removeHidden()
    composer.gotoScene("photogallery", {time=250, effect="crossFade"})
    return true
end

function myApp.showScreen4()
    myApp.tabBar:setSelected(4)
    local options = {
        feedName = "video.rss",
        feedURL = "https://www.youtube.com/feeds/videos.xml?user=CoronaLabs",
        icons = "fixed",
        displayMode = "videoviewer",
        pageTitle = "Corona Videos"
    }
    composer.removeHidden()
    composer.gotoScene("feed2", {time=250, effect="crossFade", params = options})
    return true
end

function myApp.showScreen5()
    myApp.tabBar:setSelected(5)
    local options = {

        pageTitle = "Corona Headquarters"
    }
    composer.removeHidden()
    composer.gotoScene("mapscene", {time=250, effect="crossFade", params = options})
    return true
end

function myApp.showScreen6()
    myApp.tabBar:setSelected(6)
    local options = {

        pageTitle = "Data Table"
    }
    composer.removeHidden()
    composer.gotoScene("datatable", {time=250, effect="crossFade", params = options})
    return true
end
--
-- build the top bar which is a tab bar without buttons
--

--Create a group that contains the screens beneath the tab bar
-- each button has a label which shows on the buttons.  You need an up-state
-- graphic (non-selected buttons, a down-state button (the currently selected
-- tab) selected will mark which button starts as active, and the onPress calls
-- the function above to actually show each tab.

local tabButtons = {
    {
        label = "Menu",
        defaultFile = "images/tabbaricon.png",
        overFile = "images/tabbaricon-down.png",
        labelColor = { 
            default = { 0.25, 0.25, 0.25 }, 
            over = { 0.768, 0.516, 0.25 }
        },
        width = 32,
        height = 32,
        onPress = myApp.showScreen1,
        selected = true,
    },
    {
        label = "Blogs",
        defaultFile = "images/tabbaricon.png",
        overFile = "images/tabbaricon-down.png",
        labelColor = { 
            default = { 0.25, 0.25, 0.25 }, 
            over = { 0.768, 0.516, 0.25 }
        },
        width = 32,
        height = 32,
        onPress = myApp.showScreen2,
    },
    {
        label = "Pics",
        defaultFile = "images/tabbaricon.png",
        overFile = "images/tabbaricon-down.png",
        labelColor = { 
            default = { 0.25, 0.25, 0.25 }, 
            over = { 0.768, 0.516, 0.25 }
        },
        width = 32,
        height = 32,
        onPress = myApp.showScreen3,
    },
    {
        label = "Video",
        defaultFile = "images/tabbaricon.png",
        overFile = "images/tabbaricon-down.png",
        labelColor = { 
            default = { 0.25, 0.25, 0.25 }, 
            over = { 0.768, 0.516, 0.25 }
        },
        width = 32,
        height = 32,
        onPress = myApp.showScreen4,
    },
    {
        label = "Map",
        defaultFile = "images/tabbaricon.png",
        overFile = "images/tabbaricon-down.png",
        labelColor = { 
            default = { 0.25, 0.25, 0.25 }, 
            over = { 0.768, 0.516, 0.25 }
        },
        width = 32,
        height = 32,
        onPress = myApp.showScreen5,
    },
    {
        label = "Data",
        defaultFile = "images/tabbaricon.png",
        overFile = "images/tabbaricon-down.png",
        labelColor = { 
            default = { 0.25, 0.25, 0.25 }, 
            over = { 0.768, 0.516, 0.25 }
        },
        width = 32,
        height = 32,
        onPress = myApp.showScreen6,
    },
}

myApp.tabBar = widget.newTabBar{
    top =  display.contentHeight - 50,
    left = 0,
    width = display.contentWidth,
    backgroundFile = tabBarBackgroundFile,
    tabSelectedLeftFile = tabBarLeft,      -- New
    tabSelectedRightFile = tabBarRight,    -- New
    tabSelectedMiddleFile = tabBarMiddle,      -- New
    tabSelectedFrameWidth = 20,                                         -- New
    tabSelectedFrameHeight = 50,                                        -- New    
    buttons = tabButtons,
    height = 50,
    --background="images/tabBarBg7.png"
}


local background = display.newRect(0,0, display.contentWidth, display.contentHeight)
background:setFillColor( 1, 1, 1 )
background.x = display.contentCenterX
background.y = display.contentCenterY

local logo = display.newImageRect("Splash.png", 320, 480)
logo.x = display.contentCenterX
logo.y = display.contentCenterY

local title = display.newText("Business Sample App", 0, 0, myApp.fontBold, 28)
title:setFillColor( 0, 0, 0 )
title.x = display.contentCenterX
title.y = display.contentHeight - 64
--
-- now make the first tab active.align
--

local function closeSplash()
    display.remove(title)
    title = nil
    display.remove(logo)
    logo = nil
    display.remove(background)
    background = nil
    myApp.showScreen1()
end

timer.performWithDelay(1500, closeSplash)

