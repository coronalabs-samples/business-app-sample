-- slideView.lua
-- 
-- Version 1.0 
--
-- Copyright (C) 2010 Corona Labs Inc. All Rights Reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of 
-- this software and associated documentation files (the "Software"), to deal in the 
-- Software without restriction, including without limitation the rights to use, copy, 
-- modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
-- and to permit persons to whom the Software is furnished to do so, subject to the 
-- following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all copies 
-- or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.


local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local widget = require("widget")

local myApp = require( "myapp" )
widget.setTheme(myApp.theme)

local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local imgNum = nil
local images = nil
local touchListener, nextImage, prevImage, cancelMove, initImage, jumpToImage
local background
local imageNumberText, imageNumberTextShadow
local backbutton


local function goBack(event)
	print(event.phase)
	if event.phase == "ended" then
		storyboard.hideOverlay()
	end
	return true
end

--function new( imageSet, slideBackground, top, bottom )	
function scene:createScene( event )
	local pad = 0
	local top = top or 0
	local bottom = bottom or 0

	local start = 1
	if event.params and event.params.start then
		start = event.params.start
	end
	local imageSet = event.params.images
	assert(imageSet, "Error: image list not set")

	viewableScreenW = display.contentWidth
	viewableScreenH = display.contentHeight - 120 -- status bar + top bar + tabBar

	g = self.view
		
    local background = display.newRect(0,0,display.contentWidth, display.contentHeight)
    background:setFillColor(242, 242, 242, 255)
    background.x = display.contentWidth / 2
    background.y = display.contentHeight / 2

    g:insert(background)

    local statusBarBackground = display.newImageRect(myApp.topBarBg, display.contentWidth, display.topStatusBarContentHeight)
    statusBarBackground.x = display.contentCenterX
    statusBarBackground.y = display.topStatusBarContentHeight * 0.5
    g:insert(statusBarBackground)
    --
    -- Create the other UI elements
    -- create toolbar to go at the top of the screen
    local titleBar = display.newImageRect(myApp.topBarBg, display.contentWidth, 50)
    titleBar.x = display.contentCenterX
    titleBar.y = 25 + display.topStatusBarContentHeight
    g:insert(titleBar)

    titleText = display.newText( "Photo Gallery", 0, 0, myApp.fontBold, 20 )
    titleText:setTextColor( 255, 255, 255 )
    titleText:setReferencePoint( display.CenterReferencePoint )
    titleText.x = display.contentCenterX
    titleText.y = titleBar.height * 0.5 + display.topStatusBarContentHeight
    g:insert(titleText)

    backButton = widget.newButton({
        width =  59,
        height = 32,
        defaultFile = "images/backbutton7_white.png",
        overFile = "images/backbutton7_white.png",
        onRelease = goBack
    })
    backButton.y = titleBar.y
    backButton.x = 32
    g:insert(backButton)
	
	images = {}
	for i = 1,#imageSet do
		local p = display.newImage(imageSet[i])
		local h = viewableScreenH-(top+bottom)
		if p.width > viewableScreenW or p.height > h then
			if p.width/viewableScreenW > p.height/h then 
					p.xScale = viewableScreenW/p.width
					p.yScale = viewableScreenW/p.width
			else
					p.xScale = h/p.height
					p.yScale = h/p.height
			end		 
		end
		g:insert(p)
	    
		if (i > 1) then
			p.x = screenW*1.5 + pad -- all images offscreen except the first one
		else 
			p.x = screenW*.5
		end
		
		p.y = h*.5 + 20 + 50

		images[i] = p
	end
	
	local defaultString = "1 of " .. #images

	local navBar = display.newGroup()
	g:insert(navBar)
	
	imgNum = 1
	
	g.x = 0
	g.y = top + display.screenOriginY
			
	function touchListener (self, touch) 
		local phase = touch.phase
		print("slides", phase)
		if ( phase == "began" ) then
            -- Subsequent touch events will target button even if they are outside the contentBounds of button
            display.getCurrentStage():setFocus( self )
            self.isFocus = true

			startPos = touch.x
			prevPos = touch.x
			
			transition.to( navBar,  { time=200, alpha=math.abs(navBar.alpha-1) } )
									
        elseif( self.isFocus ) then
        
			if ( phase == "moved" ) then
			
				transition.to(navBar,  { time=400, alpha=0 } )
						
				if tween then transition.cancel(tween) end
	
				print(imgNum)
				
				local delta = touch.x - prevPos
				prevPos = touch.x
				
				images[imgNum].x = images[imgNum].x + delta
				
				if (images[imgNum-1]) then
					images[imgNum-1].x = images[imgNum-1].x + delta
				end
				
				if (images[imgNum+1]) then
					images[imgNum+1].x = images[imgNum+1].x + delta
				end

			elseif ( phase == "ended" or phase == "cancelled" ) then
				
				dragDistance = touch.x - startPos
				print("dragDistance: " .. dragDistance)
				
				if (dragDistance < -40 and imgNum < #images) then
					nextImage()
				elseif (dragDistance > 40 and imgNum > 1) then
					prevImage()
				else
					cancelMove()
				end
									
				if ( phase == "cancelled" ) then		
					cancelMove()
				end

                -- Allow touch events to be sent normally to the objects they "hit"
                display.getCurrentStage():setFocus( nil )
                self.isFocus = false
														
			end
		end
					
		return true
		
	end
	
	function setSlideNumber()
		print("setSlideNumber", imgNum .. " of " .. #images)
		titleText.text = imgNum .. " of " .. #images
		--imageNumberTextShadow.text = imgNum .. " of " .. #images
	end
	
	function cancelTween()
		if prevTween then 
			transition.cancel(prevTween)
		end
		prevTween = tween 
	end
	
	function nextImage()
		tween = transition.to( images[imgNum], {time=400, x=(screenW*.5 + pad)*-1, transition=easing.outExpo } )
		tween = transition.to( images[imgNum+1], {time=400, x=screenW*.5, transition=easing.outExpo } )
		imgNum = imgNum + 1
		initImage(imgNum)
	end
	
	function prevImage()
		tween = transition.to( images[imgNum], {time=400, x=screenW*1.5+pad, transition=easing.outExpo } )
		tween = transition.to( images[imgNum-1], {time=400, x=screenW*.5, transition=easing.outExpo } )
		imgNum = imgNum - 1
		initImage(imgNum)
	end
	
	function cancelMove()
		tween = transition.to( images[imgNum], {time=400, x=screenW*.5, transition=easing.outExpo } )
		tween = transition.to( images[imgNum-1], {time=400, x=(screenW*.5 + pad)*-1, transition=easing.outExpo } )
		tween = transition.to( images[imgNum+1], {time=400, x=screenW*1.5+pad, transition=easing.outExpo } )
	end
	
	function initImage(num)
		if (num < #images) then
			images[num+1].x = screenW*1.5 + pad			
		end
		if (num > 1) then
			images[num-1].x = (screenW*.5 + pad)*-1
		end
		setSlideNumber()
	end

	background.touch = touchListener
	background:addEventListener( "touch", background )

	------------------------
	-- Define public methods
	
	function jumpToImage(num)
		local i
		print("jumpToImage")
		print("#images", #images)
		for i = 1, #images do
			if i < num then
				images[i].x = -screenW*.5;
			elseif i > num then
				images[i].x = screenW*1.5 + pad
			else
				images[i].x = screenW*.5 - pad
			end
		end
		imgNum = num
		initImage(imgNum)
	end

	jumpToImage(start)

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

