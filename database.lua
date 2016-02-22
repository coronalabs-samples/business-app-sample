--
-- db.lua -- database helper functions
-- 
-- abstract the SQLite functions to create a simple CRUD module
-- C-create, R-read, U-updatee, D-delete your database records.
--
local json = require( "json" )
local sqlite3 = require( "sqlite3" )

local db = {}
db.handle = nil
db.scheme = nil

--
-- .init - Initializes the database and opens the database
-- Required paramters
--      databaseName - String name for the filename of the database
-- 		scheme is a table in the format:
-- 			thisTable = {}
-- 			thisTable["__tableName"] = "users"
-- 			thisTable["someKey"] = "real"
-- 			thisTable["someOtherKey"] = "text"
-- 		etc.
-- 		Valid types are "integer", "real", "text", "blob"
-- 		Each table should have an "id" that will be a primary key created for you.

function db.init( databaseName, scheme )
	-- init
	local path = system.pathForFile( databaseName, system.DocumentsDirectory )
	db.handle = sqlite3.open( path )  
	db.scheme = scheme

	local tablesetup = [[CREATE TABLE IF NOT EXISTS ]] .. scheme["__tableName"] .. [[ (]]
	for k, v in pairs( scheme ) do
		print(k, v)
		if k == "__tableName" then
			-- skip this key
			print("skipping tablename")
		else
			tablesetup = tablesetup .. k .. " " .. v .. ", "
		end
	end
	tablesetup = tablesetup .. [[id INTEGER PRIMARY KEY);]]
	print(tablesetup)
	db.handle:exec( tablesetup )
end

--
-- .create - creates a single record in the database
-- Required parameters:
-- 		record - a lua table where each key is a valid entry in the scheme and its value is used
--      to populate the data. Invalid entries will be skipped.
--

function db.create( record )
	-- create
	local query = "INSERT INTO " .. db.scheme["__tableName"] .. [[ (]]
	local cols = ""
	local values = ""
	for k, v in pairs( record ) do
		-- skip any invalid columns.
		if db.scheme[ k ] then
			print("found key ", k, v)
			if k ~= "__tableName" then
				if string.len( cols ) == 0 then
					cols = cols .. k 
					if db.scheme[k] == "text" then
						values = values .. [["]] .. v .. [["]]
					else
						values = values .. v
					end
				else
					cols = cols .. ", " .. k
					if db.scheme[k] == "text" then
						values = values .. ", " .. [["]] .. v .. [["]]
					else
						values = values .. ", " .. v
					end
				end
			end
		end
	end
	query = query .. cols .. ") VALUES (" .. values .. ");"
	print( query )
	return( db.handle:exec( query ) )
end

--
-- .read - takes a valid SQL SELECT query string, executes it, returning a Lua table of all
--         the matching records
-- Required parameter - query - a valid SELECT fields FROM tablename WHERE clause;
-- KISS prinicple. Keep it Simple! No validty checks are made.

function db.read( query )
	-- read
	local results = {}
	for row in db.handle:nrows( query ) do
		results[ #results + 1 ] = row
	end
	return results
end

--
-- .update - updates a set of matching SQL records
-- Required parameter - record - a Lua table with a set of Key/Value pairs to update.
-- Invalid keys (columns) will be ignored.
-- An optional key value pair: ["__where"] = "where clause" can be passed to control 
-- which records get updated. You must include theh "WHERE" verb in the query. It does not
-- check the validty of the where clause.

function db.update( record )
	-- update
	local query = "UPDATE ".. db.scheme["__tableName"] .. " SET "
	local cols = ""
	for k, v in pairs( record ) do
		if db.scheme[ k ] then
			if k ~= "__tableName" and k ~= "__where" then
				if string.len( cols ) == 0 then
					cols = cols .. k 
					if db.scheme[k] == "text" then
						cols = cols .. [[ = "]] .. v .. [["]]
					else
						cols = cols .. [[ = ]] .. v
					end
				else
					cols = cols .. ", " .. k
					if db.scheme[k] == "text" then
						cols = cols .. [[ = "]] .. v .. [["]]
					else
						cols = cols .. [[ = ]] .. v
					end
				end			
			end
		end
	end
	query = query .. cols
	if record["__where"] and string.len( record["__where"] ) > 0 then
		if string.upper( string.sub(record["__where"], 1, 6) ) ~= "WHERE " then
			query = query .. " WHERE "
		end
		query = query .. " " .. record["__where"]
	end
	query = query .. ";" 
	print( query )
	return( db.handle:exec( query ) )
end

function db.delete( whereClause )
	-- delete
	local query = "DELETE FROM " .. db.scheme["__tableName"] .. " "
	if string.upper( string.sub(whereClause, 1, 6) ) ~= "WHERE " then
		query = query .. "WHERE "
	end
	query = query .. whereClause
	return( db.handle:exec( query ) )
end

--
-- .close - closes the database
--
function db.close( )
	-- close
	db.handle:close()
end

return db