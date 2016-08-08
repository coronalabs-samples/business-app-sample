--
-- RSS Reader and Pod Cast App Template
--
-- Copyright © 2011-2012 Omnigeek Media. All Rights Reserved.
--
-- The contents of this file are licensed under the MIT license.
--
-- rss.lua
-- takes a rss 2.0 feed and returns you a table of feed information including
-- a list of stories.
--

--module(..., package.seeall)  -- BGB: Removed to potential memory leak

local xml = require( "xml" ).newParser()
local M = {}                    -- BGB: added to update to current Module standards
function M.feed(filename, base)
    rssFile = "index.rss"
    if filename then
        rssFile = filename
    end
    baseDir = system.CachesDirectory
    if base then
        baseDir = base
    end
    
    local feed = {}
    local stories = {}
    --print("Parsing the feed")
    local myFeed = xml:loadFile(rssFile, baseDir)
    if myFeed == nil then return nil end
    local items = myFeed.child[1].child
    local i
    print("Number of items: " .. #items)
    local l = 1
    for i = 1, #items do
        local item = items[i]
        local enclosuers = {}
        local e = 1
        local story = {}
        local thumbnail = {}
        if item.name == "title" then feed.title = item.value end
        if item.name == "link"  then feed.link = item.value end
        if item.name == "description" then feed.description = item.value end
        if item.name == "lastBuildDate" then feed.lastBuildDate = item.value end
        if item.name == "language" then feed.language = item.value end
        if item.name == "generator" then feed.generator = item.value end
        if item.name == "pubDate" then feed.pubDate = item.value end
        if item.name == "ttl" then feed.ttl = item.value end
        if item.name == "managingEditor" then feed.managingEditor = item.value end
        if item.name == "webMaster" then feed.webMaster = item.value end
        if item.name == "image" then feed.image = item.value end
        if item.name == "rating" then feed.rating = item.value end
        feed.sy = {}
        if item.name == "sy:updateFrequency" then feed.sy.updateFrequency = item.value end
        if item.name == "sy:updatePeriod" then feed.sy.updatePeriod = item.value end

        if item.name == "item" then -- we have a story batman!
            local j
            for j = 1, #item.child do
                if item.child[j].name == "title" then
                    story.title = item.child[j].value
                end
                if item.child[j].name == "link" then
                    story.link = item.child[j].value
                end
                if item.child[j].name == "pubDate" then
                    story.pubDate = item.child[j].value
                end
                if item.child[j].name == "description" then
                    story.description = item.child[j].value
                end
                if item.child[j].name == "author" then story.author = item.child[j].value end
                if item.child[j].name == "comments" then story.comments = item.child[j].value end
                if item.child[j].name == "source" then story.source = item.child[j].value end
                if item.child[j].name == "dc:creator" then
                    story.dc_creator = item.child[j].value
                end
                if item.child[j].name == "guid" then
                    story.guid = item.child[j].value
                end
                if item.child[j].name == "media:thumbnail" then
                    print("********** has thumbnail ************")
                    thumbnail = item.child[j].properties
                end
                -- Podcast's we have to handle differently
                if item.child[j].name == "content:encoded" then
                    -- get the story body
                    --[[
                    print(item.child[j].value)
                    bodytag = {}
                    bodytag = item.child[j].child
                    local p;
                    story.content_encoded = ""
                    for p = 1, #bodytag do
                        if (bodytag[p].value) then
                            story.content_encoded = story.content_encoded .. bodytag[p].value .. "\n\n"
                        end
                    end
                    ]]--
                    story.content_encoded = item.child[j].value
                end
                if item.child[j].name == "enclosure" then
                    local properties = {}
                    properties = item.child[j].properties
                    enclosuers[e] = properties
                    e = e + 1
                end
            end
            stories[l] = {}
            stories[l].link = story.link
            stories[l].title = story.title
            stories[l].pubDate = story.pubDate
            stories[l].description = story.description
            stories[l].dc_creator = story.dc_creator
            stories[l].guid = story.guid
            stories[l].author = story.author
            stories[l].comments = story.comments
            stories[l].source = story.source
            stories[l].content_encoded = story.content_encoded
            stories[l].enclosures = enclosuers
            stories[l].thumbnail = thumbnail
            l = l + 1
        end
    end
    feed.items = stories
    return feed
end
return M  -- BGB: Added to update to current Module standards