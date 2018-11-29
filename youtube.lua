--
-- RSS Reader and Pod Cast App Template
--
-- Copyright © 2011-2012 Omnigeek Media. All Rights Reserved.
--
-- The contents of this file are licensed under the MIT license.
--
-- atom.lua
-- takes an Atom based rss feed and returns you a table of stories.
--

--module(..., package.seeall)
local M={}
local utility = require("utility")

local xml = require( "xml" ).newParser()

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
    local items = myFeed.child
    local i
    --utility.print_r(items)
    print("Number of items: " .. #items)
    local l = 1
    for i = 1, #items do
        local item = items[i]
        --if item.name == "entry" then
        --    item = items[i].child
        --end
        local enclosuers = {}
        local e = 1
        local story = {}
        --utility.print_r( item )
        --print("Item name", item.name)
        if item.name == "title" then feed.title = item.value end
        if item.name == "link"  then feed.link = item.value end
        if item.name == "description" then feed.description = item.value end
        if item.name == "subtitle" then feed.subtitle = item.value end
        if item.name == "id" then feed.id = item.value end
        if item.name == "updated" then feed.updated = item.value end
        if item.name == "rights" then feed.rights = item.value end

        if item.name == "entry" then -- 
            --print("we have a story batman!")
            local entry = {}
            entry = item.child
            local j
            --print("Number of items: " .. #entry)
            for j = 1, #item.child do
                if entry[j].name == "title" then
                    story.title = entry[j].value
                end
                if entry[j].name == "link" then
                    story.link = entry[j].properties.href
                end
                if entry[j].name == "yt:videoId" then
                    story.youTubeId = entry[j].value
                end
                if entry[j].name == "published" then
                    story.pubDate = entry[j].value
                end
                if entry[j].name == "description" then
                    story.description = entry[j].value
                end
                if entry[j].name == "author" then
                    story.author = entry[j].child[1].value
                end
                if entry[j].name == "id" then
                    story.id = entry[j].value
                end
                -- Podcast's we have to handle differently
                if entry[j].name == "content" then
                    -- get the story body
                    --[[
                    print(entry[j].value)
                    bodytag = {}
                    bodytag = entry[j].child
                    local p;
                    story.content_encoded = ""
                    for p = 1, #bodytag do
                        if (bodytag[p].value) then
                            story.content_encoded = story.content_encoded .. bodytag[p].value .. "\n\n"
                        end
                    end
                    ]]--
                    story.content = entry[j].value
                end
                if entry[j].name == "enclosure" then
                    local properties = {}
                    properties = entry[j].properties
                    enclosuers[e] = properties
                    e = e + 1
                end
                if entry[j].name == "media:group" then
                    local mediaEntry = entry[j].child
                    --utility.print_r( mediaEntry )
                    --print("#mediaEntry", #mediaEntry)
                    for i = 1, #mediaEntry do
                        mediaItem = mediaEntry[i]
                        print(mediaItem.name)
                        if mediaItem.name == "media:title" then
                            story.title = mediaItem.value
                        end
                        if mediaItem.name == "media:content" then
                            story.content = mediaItem.value
                        end
                        if mediaItem.name == "media:description" then
                            story.description = mediaItem.value
                        end
                        if mediaItem.name == "media:thumbnail" then
                            story.thumbnail = mediaItem.value
                        end
                     end
                end
            end
            stories[l] = {}
            stories[l].link = story.link
            stories[l].title = story.title
            stories[l].pubDate = story.pubDate
            stories[l].description = story.description
            stories[l].author = story.author
            stories[l].guid = story.guid
            stories[l].comments = story.comments
            stories[l].content_encoded = story.content
            stories[l].enclosures = enclosuers
            stories[l].thumbnail = story.thumbnail
            stories[l].youTubeId = story.youTubeId
            l = l + 1
        end
    end
    feed.items = stories
    return feed
end
return M