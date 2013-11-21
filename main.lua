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
-- load in storyboard
--
local storyboard = require ( "storyboard" )
local widget = require( "widget" )
local json = require( "json" )
local myApp = require( "myapp" ) 

if (display.pixelHeight/display.pixelWidth) > 1.5 then
    myApp.isTall = true
end

if display.contentWidth > 320 then
    myApp.is_iPad = true
end

--
-- Handle Graphics 2.0 changes
myApp.colorDivisor = 255
myApp.isGraphics2 = true
if tonumber( system.getInfo("build") ) < 2013.2000 then
    -- we are a Graphics 1.0 build
    myApp.colorDivisor = 1
    myApp.isGraphics2 = false
end

--
-- turn on debugging
--
local debugMode = true

--
-- this little snippet will make a copy of the print function
-- and now will only print if debugMode is true
-- quick way to clean up your logging for production
--

reallyPrint = print
function print(...)
    if debugMode then
        reallyPrint(unpack(arg))
    end
end

math.randomseed(os.time())

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

if system.getInfo("platformName") == "Android" then
    myApp.theme = "widget_theme_android"
    myApp.font = "Droid Sans"
    myApp.fontBold = "Droid Sans Bold"
    myApp.fontItalic = "Droid Sans"
    myApp.fontBoldItalic = "Droid Sans Bold"
    myApp.topBarBg = "images/topBarBg7.png"

else
    myApp.theme = "widget_theme_ios7"
    local coronaBuild = system.getInfo("build")
    if tonumber(coronaBuild:sub(6,12)) < 1206 then
        myApp.theme = "widget_theme_ios"
    end
    myApp.font = "HelveticaNeue-Light"
    myApp.fontBold = "HelveticaNeue"
    myApp.fontItalic = "HelveticaNeue-LightItalic"
    myApp.fontBoldItalic = "Helvetica-BoldItalic"
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
-- The variable "storyboard" is just a Lua table that is returned from the 
-- require("storyboard" above.  As such, I can freely add members/attributes/entries
-- to the table.  By using this technique, I can quickly pass data between 
-- storyboard scenes.  It's like making them global without the penalties of 
-- making them global.  There is one catch... Corona Labs could come along and 
-- add theor own "displayMode" member (or any of them) later and trump yours
-- but the risk is minmal.
--

myApp.tabBar = {}

function myApp.showScreen1()
    myApp.tabBar:setSelected(1)
    storyboard.removeAll()
    storyboard.gotoScene("menu", {time=250, effect="crossFade"})
    return true
end

function myApp.showScreen2()
    myApp.tabBar:setSelected(2)
    local options = {
        feedName = "corona.rss",
        feedURL = "http://www.coronalabs.com/feed/",
        icons = "fixed",
        displayMode = "webpage",
        pageTitle = "Corona Labs"
    }
    storyboard.removeAll()
    storyboard.gotoScene("feed", {time=250, effect="crossFade", params = options})
    return true
end

function myApp.showScreen3()
    myApp.tabBar:setSelected(3)
    storyboard.removeAll()
    storyboard.gotoScene("photogallery", {time=250, effect="crossFade"})
    return true
end

function myApp.showScreen4()
    myApp.tabBar:setSelected(4)
    local options = {
        feedName = "video.rss",
        feedURL = "http://gdata.youtube.com/feeds/mobile/users/CoronaLabs/uploads?max-results=20&alt=rss&orderby=published&format=1",
        icons = "fixed",
        displayMode = "videoviewer",
        pageTitle = "Corona Videos"
    }
    storyboard.removeAll()
    storyboard.gotoScene("feed2", {time=250, effect="crossFade", params = options})
    return true
end

function myApp.showScreen5()
    myApp.tabBar:setSelected(5)
    local options = {

        pageTitle = "Corona Headquarters"
    }
    storyboard.removeAll()
    storyboard.gotoScene("mapscene", {time=250, effect="crossFade", params = options})
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
            default = { 64/myApp.colorDivisor, 64/myApp.colorDivisor, 64/myApp.colorDivisor }, 
            over = { 196/myApp.colorDivisor, 132/myApp.colorDivisor, 64/myApp.colorDivisor }
        },
        width = 32,
        height = 32,
        onPress = myApp.showScreen1,
        selected = true
    },
    {
        label = "Blogs",
        defaultFile = "images/tabbaricon.png",
        overFile = "images/tabbaricon-down.png",
        labelColor = { 
            default = { 64/myApp.colorDivisor, 64/myApp.colorDivisor, 64/myApp.colorDivisor }, 
            over = { 196/myApp.colorDivisor, 132/myApp.colorDivisor, 64/myApp.colorDivisor }
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
            default = { 64/myApp.colorDivisor, 64/myApp.colorDivisor, 64/myApp.colorDivisor }, 
            over = { 196/myApp.colorDivisor, 132/myApp.colorDivisor, 64/myApp.colorDivisor }
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
            default = { 64/myApp.colorDivisor, 64/myApp.colorDivisor, 64/myApp.colorDivisor }, 
            over = { 196/myApp.colorDivisor, 132/myApp.colorDivisor, 64/myApp.colorDivisor }
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
            default = { 64/myApp.colorDivisor, 64/myApp.colorDivisor, 64/myApp.colorDivisor }, 
            over = { 196/myApp.colorDivisor, 132/myApp.colorDivisor, 64/myApp.colorDivisor }
        },
        width = 32,
        height = 32,
        onPress = myApp.showScreen5,
    }
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
background:setFillColor(255/myApp.colorDivisor,255/myApp.colorDivisor,255/myApp.colorDivisor)
background.x = display.contentCenterX
background.y = display.contentCenterY

local logo = display.newImageRect("Splash.png", 320, 480)
logo.x = display.contentCenterX
logo.y = display.contentCenterY

local title = display.newText("Business Sample App", 0, 0, myApp.fontBold, 28)
if myApp.isGraphics2 then
    title:setFillColor( 0 )
else
    title:setTextColor(0)
end
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

