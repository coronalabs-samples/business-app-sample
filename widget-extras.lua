local widget = require( "widget" )
local json = require( "json" )
local myApp = require( "myapp" )

function widget.newSharingPanel( services )
    local function onRowTouch( event )
        local popupName = event.row.params.popupName
        local service = event.row.params.service

        if popupName == nil then -- the cancel button
            local myPanel = event.row.params.parent
            myPanel:hide()
            return true
        end

        if popupName == "mail" then
            native.showPopup( popupName, 
            {
                body = body,
                attachment = attachment,
            })
        elseif popupName == "sms" then
            native.showPopup( popupName, 
            {
                body = body,
            })
        elseif popupName == "social" then
            local isAvailable = native.canShowPopup( popupName, service )
            if isAvailable then
                native.showPopup( popupName, 
                {
                    service = service,
                    message = message,
                    image = image,
                    url = url
                })
            else
                if isSimulator then
                    native.showAlert( "Build for device", "This plugin is not supported on the Corona Simulator, please build for an iOS/Android device or the Xcode simulator", { "OK" } )
                else
                    -- Popup isn't available.. Show error message
                    native.showAlert( "Cannot send " .. service .. " message.", "Please setup your " .. service .. " account or check your network connection (on android this means that the package/app (ie Twitter) is not installed on the device)", { "OK" } )
                end
            end
        end

        return true
    end


    local function onRowRender( event )
        local row = event.row
        local id = row.index
        local params = event.row.params

        if row.isCategory then
            row.text = display.newText("Share", 0, 0, myApp.font, 14)
            row.text:setFillColor( 0.67 )
            row.text.x = display.contentCenterX
            row.text.y = row.contentHeight * 0.5
            row:insert(row.text)
        else
            row.text = display.newText(params.label, 0, 0, myApp.font, 18)
            row.text:setFillColor( 0.33, 0.5, 1.0 )
            row.text.x = display.contentCenterX
            row.text.y = row.contentHeight * 0.5
            row:insert(row.text)
        end

    end

    local panel = widget.newPanel({
        location = "bottom",
        width = display.contentWidth,
        height = 240,
        speed = 500,
    })

    local tableView = widget.newTableView({
        top = 0, 
        left = 0,
        width = display.contentWidth - 16, 
        height = 240, 
        hideBackground = false, 
        backgroundColor = { 0.9 },
        noLines = true,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch 
    })
    tableView.x = 0
    tableView.y = 0

    panel:insert( tableView )
    tableView:insertRow{
        rowHeight = 40,
        isCategory = true,
        rowColor = { 1, 1, 1 },
    }
    tableView:insertRow{
        rowHeight = 40,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        params = {
            popupName = "social",
            service = "facebook",
            label = "Facebook",
            message = "Some text to post to facebook",
            image = nil,  -- See the native.showPopup("social") plugin for image paramters.
            url = nil,    -- See the native.showPopup("social") plugin for url paramters.
        }
    }
    tableView:insertRow{
        rowHeight = 40,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        params = {
            popupName = "social",
            service = "twitter",
            label = "Twitter",
            message = "Some text to post to twitter",
            image = nil,  -- See the native.showPopup("social") plugin for image paramters.
            url = nil,    -- See the native.showPopup("social") plugin for url paramters.
        }
    }
    tableView:insertRow{
        rowHeight = 40,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        params = {
            popupName = "mail",
            label = "Email",
            body = "Some text to email",
            attachment = nil, -- See the native.showPopup("mail") API for attachment paramters.
        }
    }
    tableView:insertRow{
        rowHeight = 40,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        params = {
            popupName = "sms",
            label = "Message",
            body = "Some text to text",
        }
    }
    tableView:insertRow{
        rowHeight = 40,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        params = {
            label = "Cancel",
            parent = panel
        }
    }
    return panel
end


function widget.newPanel( options )
    local customOptions = options or {}
    local opt = {}

    opt.location = customOptions.location or "top"
    
    local default_width, default_height
    if ( opt.location == "top" or opt.location == "bottom" ) then
        default_width = display.contentWidth
        default_height = display.contentHeight * 0.33
    else
        default_width = display.contentWidth * 0.33
        default_height = display.contentHeight
    end
    
    opt.width = customOptions.width or default_width
    opt.height = customOptions.height or default_height
    opt.speed = customOptions.speed or 500
    opt.inEasing = customOptions.inEasing or easing.linear
    opt.outEasing = customOptions.outEasing or easing.linear

    if ( customOptions.onComplete and type(customOptions.onComplete) == "function" ) then
        opt.listener = customOptions.onComplete
    else
        opt.listener = nil
    end
    
    local container = display.newContainer( opt.width, opt.height )
    if ( opt.location == "left" ) then
        container.anchorX = 1.0
        container.x = display.screenOriginX
        container.anchorY = 0.5
        container.y = display.contentCenterY
    elseif ( opt.location == "right" ) then
        container.anchorX = 0.0
        container.x = display.actualContentWidth
        container.anchorY = 0.5
        container.y = display.contentCenterY
    elseif ( opt.location == "top" ) then
        container.anchorX = 0.5
        container.x = display.contentCenterX
        container.anchorY = 1.0
        container.y = display.screenOriginY
    else
        container.anchorX = 0.5
        container.x = display.contentCenterX
        container.anchorY = 0.0
        container.y = display.actualContentHeight
    end

    function container:show()
        local options = {
            time = opt.speed,
            transition = opt.inEasing
        }
        if ( opt.listener ) then
            options.onComplete = opt.listener
            self.completeState = "shown"
        end
        if ( opt.location == "top" ) then
            options.y = display.screenOriginY + opt.height
        elseif ( opt.location == "bottom" ) then
            options.y = display.actualContentHeight - opt.height
        elseif ( opt.location == "left" ) then
            options.x = display.screenOriginX + opt.width
        else
            options.x = display.actualContentWidth - opt.width
        end
        transition.to( self, options )
    end

    function container:hide()
        local options = {
            time = opt.speed,
            transition = opt.outEasing
        }
        if ( opt.listener ) then
            options.onComplete = opt.listener
            self.completeState = "hidden"
        end
        if ( opt.location == "top" ) then
            options.y = display.screenOriginY
        elseif ( opt.location == "bottom" ) then
            options.y = display.actualContentHeight
        elseif ( opt.location == "left" ) then
            options.x = display.screenOriginX
        else
            options.x = display.actualContentWidth
        end
        transition.to( self, options )
    end
    return container
end

function widget.newTextField(options)
    local customOptions = options or {}
    local opt = {}
    opt.left = customOptions.left or 0
    opt.top = customOptions.top or 0
    opt.x = customOptions.x or 0
    opt.y = customOptions.y or 0
    opt.width = customOptions.width or (display.contentWidth * 0.75)
    opt.height = customOptions.height or 20
    opt.id = customOptions.id
    opt.listener = customOptions.listener or nil
    opt.text = customOptions.text or ""
    opt.inputType = customOptions.inputType or "default"
    opt.isSecure = customOptions.isSecure or false
    opt.font = customOptions.font or native.systemFont
    opt.fontSize = customOptions.fontSize or opt.height * 0.67
    opt.fontColor = customOptions.fontColor or { 0.25, 0.25, 0.25 }
    opt.placeholder = customOptions.placeholder or nil
    opt.label = customOptions.label or ""
    opt.labelWidth = customOptions.labelWidth or opt.width * 0.10
    opt.labelFont = customOptions.labelFont or native.systemFontBold
    opt.labelFontSize = customOptions.labelFontSize or opt.fontSize
    opt.labelFontColor = customOptions.labelFontColor or { 0, 0, 0 }

    -- Vector options
    opt.strokeWidth = customOptions.strokeWidth or 2
    opt.cornerRadius = customOptions.cornerRadius or opt.height * 0.33 or 10
    opt.strokeColor = customOptions.strokeColor or {0, 0, 0}
    opt.backgroundColor = customOptions.backgroundColor or { 1, 1, 1 }

    local field = display.newGroup()

    local deviceScale = (display.pixelWidth / display.contentWidth) * 0.5
    
    local bgWidth = opt.width
    --if widget.isSeven() then
    --    bgWidth = bgWidth + opt.labelWidth -- make room in the box for the label
    --end

    local background = display.newRoundedRect( 0, 0, bgWidth, opt.height, opt.cornerRadius )
    background:setFillColor(unpack(opt.backgroundColor))
    background.strokeWidth = opt.strokeWidth
    background.stroke = opt.strokeColor
    field:insert(background)

    if opt.left then
        field.x = opt.left + opt.width * 0.5
    elseif opt.left then
        field.x = opt.x
    end
    if opt.top then
        field.y = opt.top + opt.height * 0.5
    elseif opt.top then
        field.y = opt.y
    end

    print("x", field.x, "y", field.y)
    --
    -- Support adding a label.
    -- iOS 6 and earlier and Android draw the Label above the field.
    -- iOS 7 draws it in the field.

    local labelParameters = {
        x = 0,
        y = 0, 
        text = opt.label,
        width = opt.labelWidth,
        height = 0,
        font = opt.labelFont,
        fontSize = opt.labelFontSize, 
        align = "left"
    }
    local fieldLabel = display.newText(labelParameters)
    fieldLabel:setFillColor(unpack(opt.labelFontColor))
    fieldLabel.x = background.x - bgWidth / 2 + opt.cornerRadius + opt.labelWidth * 0.5 + 5
    fieldLabel.y = background.y
    if not widget.isSeven() then
        fieldLabel.y = background.y + opt.height + 5
    end
    field:insert(fieldLabel)
    -- create the native.newTextField to handle the input

    local tHeight = opt.height - opt.strokeWidth * 2 - 4
    if "Android" == system.getInfo("platformName") then
        --
        -- Older Android devices have extra "chrome" that needs to be compesnated for.
        --
        tHeight = tHeight + 10
    end

    local labelPadding = 0
    if widget.isSeven() then
        labelPadding = opt.labelWidth
    end

    print(labelPadding, opt.labelWidth, field.x)

    field.textField = native.newTextField(0, 0, opt.width - opt.cornerRadius - labelPadding, tHeight )
    field.textField.x = field.x + labelPadding
    field.textField.y = field.y
    --field.textField.anchorX = 0
    field.textField.hasBackground = false
    field.textField.inputType = opt.inputType
    field.textField.text = opt.text
    field.textField.isSecure = opt.isSecure
    print(opt.listener, type(opt.listener))
    if opt.listener and type(opt.listener) == "function" then
        field.textField._listener = opt.listener
    end
    field.textField.placeholder = opt.placeholder

    -- Function to listen for textbox events
    --function field.textField:_inputListener( event )
    function field.textField._inputListener( event )
        local phase = event.phase
        
        if "began" == phase then
            -- make sure we are in a display group
            -- the trick is our master object is a group, so we need to make sure our 
            -- grandparent isn't the stage
            if display.getCurrentStage() ~= event.target.parent.parent then
                -- make a guess at the keyboard height.  
                local kbHeight = 0.5 * display.contentHeight
                local fieldLoc = 0.25 * display.contentHeight
                -- scroll into view
                if event.target.y > kbHeight then
                    event.target.yOrig = self.y
                    transition.to(event.target.parent.parent, {time=500, y = fieldLoc})
                end
            end 
        elseif "submitted" == phase or "ended" == phase then
            -- Hide keyboard
            if event.target.yOrig ~= event.target.y then -- we have been scrolled
                transition.to(event.target.parent.parent, {time=500, y = event.target.yOrig})
            end
        end
        
        -- If there is a listener defined, execute it
        local e = {}
        e.newCharacters = event.newCharacters
        e.numDeleted = event.numDeleted
        e.oldText = event.oldText
        e.phase = event.phase
        e.startPosition = event.startPosition
        e.target = event.target
        e.text = event.text
        print( json.prettify(e))
        if event.target._listener then
            event.target._listener( e )
        end
    end
    
    --field.textField.userInput = field.textField._inputListener
    field.textField:addEventListener( "userInput", field.textField._inputListener )
    field.textField.id = opt.id
    print(opt.font, opt.fontSize, deviceScale)

    field.textField.font = native.newFont( opt.font, opt.fontSize * deviceScale )
    field.textField.size = opt.fontSize * deviceScale

    local function syncFields(event)
        if field and field.textField then 
            field.textField.x = field.x + labelPadding
            field.textField.y = field.y
            field.textField.alpha = field.alpha
            if not field.isVisible then
                -- move the text field off screen when the display field is hidden
                field.textField.y = field.textField.y * -1 
            end
        end
    end
    --Runtime:addEventListener( "enterFrame", syncFields )

    function field.finalize( event )
        Runtime:removeEventListener( "enterFrame", syncFields )
        field.textField:removeSelf()
        field.textField = nil
    end

    field:addEventListener( "finalize" )

    return field
end  


function widget.newNavigationBar( options )
    local customOptions = options or {}
    local opt = {}
    opt.left = customOptions.left or nil
    opt.top = customOptions.top or nil
    opt.width = customOptions.width or display.contentWidth
    opt.height = customOptions.height or 50
    if customOptions.includeStatusBar == nil then
        opt.includeStatusBar = true -- assume status bars for business apps
    else
        opt.includeStatusBar = customOptions.includeStatusBar
    end

    local statusBarPad = 0
    if opt.includeStatusBar then
        statusBarPad = display.topStatusBarContentHeight
    end

    opt.x = customOptions.x or display.contentCenterX
    opt.y = customOptions.y or (opt.height + statusBarPad) * 0.5
    opt.id = customOptions.id
    opt.isTransluscent = customOptions.isTransluscent or true
    opt.background = customOptions.background
    opt.backgroundColor = customOptions.backgroundColor
    opt.title = customOptions.title or ""
    opt.titleColor = customOptions.titleColor or { 0, 0, 0 }
    opt.font = customOptions.font or native.systemFontBold
    opt.fontSize = customOptions.fontSize or 18
    opt.leftButton = customOptions.leftButton or nil
    opt.rightButton = customOptions.rightButton or nil



    if opt.left then
    	opt.x = opt.left + opt.width * 0.5
    end
    if opt.top then
    	opt.y = opt.top + (opt.height + statusBarPad) * 0.5
    end

    local barContainer = display.newGroup()
    local background = display.newRect(barContainer, opt.x, opt.y, opt.width, opt.height + statusBarPad )
    if opt.background then
        background.fill = { type = "image", filename=opt.background}
    elseif opt.backgroundColor then
        background.fill = opt.backgroundColor
    else
        if widget.isSeven() then
            background.fill = {1,1,1} 
        else
            background.fill = { type = "gradient", color1={0.5, 0.5, 0.5}, color2={0, 0, 0}}
        end
    end

    barContainer._title = display.newText(opt.title, background.x, background.y + statusBarPad * 0.5, opt.font, opt.fontSize)
    barContainer._title:setFillColor(unpack(opt.titleColor))
    barContainer:insert(barContainer._title)

    local leftButton
    if opt.leftButton then
        if opt.leftButton.defaultFile then -- construct an image button
            leftButton = widget.newButton({
                id = opt.leftButton.id,
                width = opt.leftButton.width,
                height = opt.leftButton.height,
                baseDir = opt.leftButton.baseDir,
                defaultFile = opt.leftButton.defaultFile,
                overFile = opt.leftButton.overFile,
                onEvent = opt.leftButton.onEvent,
            })
        else -- construct a text button
            leftButton = widget.newButton({
                id = opt.leftButton.id,
                label = opt.leftButton.label,
                onEvent = opt.leftButton.onEvent,
                font = opt.leftButton.font or opt.font,
                fontSize = opt.fontSize,
                labelColor = opt.leftButton.labelColor or { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                labelAlign = "left",
            })
        end
        leftButton.x = 15 + leftButton.width * 0.5
        leftButton.y = barContainer._title.y
        barContainer:insert(leftButton)
    end

    local rightButton
    if opt.rightButton then
        if opt.rightButton.defaultFile then -- construct an image button
            rightButton = widget.newButton({
                id = opt.rightButton.id,
                width = opt.rightButton.width,
                height = opt.rightButton.height,
                baseDir = opt.rightButton.baseDir,
                defaultFile = opt.rightButton.defaultFile,
                overFile = opt.rightButton.overFile,
                onEvent = opt.rightButton.onEvent,
            })
        else -- construct a text button
            rightButton = widget.newButton({
                id = opt.rightButton.id,
                label = opt.rightButton.label or "Default",
                onEvent = opt.rightButton.onEvent,
                font = opt.rightButton.font or opt.font,
                fontSize = opt.fontSize,
                labelColor = opt.rightButton.labelColor or { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                labelAlign = "right",
            })
        end
        rightButton.x = display.contentWidth - (15 + rightButton.width * 0.5)
        rightButton.y = barContainer._title.y
        barContainer:insert(rightButton)
    end

    function barContainer:setLabel( text )
        self._title.text = text
    end

    function barContainer:getLabel()
        return(self._title.text)
    end


    return barContainer
end