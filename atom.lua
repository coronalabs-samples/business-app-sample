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

module(..., package.seeall)

local xml = require( "xml" ).newParser()

function feed(filename, base)
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
    --print("Number of items: " .. #items)
    local l = 1
    for i = 1, #items do
        local item = items[i]
        local enclosuers = {}
        local e = 1
        local story = {}
        --print(item.name)
        if item.name == "title" then feed.title = item.value end
        if item.name == "link"  then feed.link = item.value end
        if item.name == "description" then feed.description = item.value end
        if item.name == "subtitle" then feed.subtitle = item.value end
        if item.name == "id" then feed.id = item.value end
        if item.name == "updated" then feed.updated = item.value end
        if item.name == "rights" then feed.rights = item.value end

        if item.name == "entry" then -- we have a story batman!
            local entry = {}
            entry = item.child
            local j
            --print("Number of items: " .. #entry)
            for j = 1, #item.child do
                if entry[j].name == "title" then
                    story.title = entry[j].value
                end
                if entry[j].name == "link" then
                    story.link = entry[j].value
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
            end
            stories[l] = {}
            stories[l].link = story.link
            stories[l].title = story.title
            stories[l].pubDate = story.pubDate
            stories[l].description = story.description
            stories[l].author = story.author
            stories[l].guid = story.guid
            stories[l].comments = story.comments
            stories[l].content = story.content
            stories[l].enclosures = enclosuers
            l = l + 1
        end
    end
    feed.entries = stories
    return feed
end
