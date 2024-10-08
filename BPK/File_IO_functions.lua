local function exportstring( s )

	return string.format("%q", s)
  
end

--// The Save Function
function table.save(  tbl,filename )

	local charS,charE = "   ","\n"
	local file,err = io.open( filename, "w+" ) --edited
	if err then return err end

	-- initiate variables for save procedure
	local tables,lookup = { tbl },{ [tbl] = 1 }
	file:write( "return {"..charE )

	for idx,t in ipairs( tables ) do
	
		file:write( "-- Table: {"..idx.."}"..charE )
		file:write( "{"..charE )
		local thandled = {}
     
		for i,v in ipairs( t ) do
			thandled[i] = true
			local stype = type( v )
			-- only handle value
			if stype == "table" then
				if not lookup[v] then
					table.insert( tables, v )
					lookup[v] = #tables
				end
			   file:write( charS.."{"..lookup[v].."},"..charE )
			elseif stype == "string" then
			   file:write(  charS..exportstring( v )..","..charE )
			elseif stype == "number" then
			   file:write(  charS..tostring( v )..","..charE )
			end
			
		end

		for i,v in pairs( t ) do
		-- escape handled values
			if (not thandled[i]) then
			
				local str = ""
				local stype = type( i )
				-- handle index
				if stype == "table" then
					if not lookup[i] then
						table.insert( tables,i )
						lookup[i] = #tables
					end
					str = charS.."[{"..lookup[i].."}]="
				elseif stype == "string" then
					str = charS.."["..exportstring( i ).."]="
				elseif stype == "number" then
					str = charS.."["..tostring( i ).."]="
				end
			
				if str ~= "" then
					stype = type( v )
					-- handle value
					if stype == "table" then
						if not lookup[v] then
							table.insert( tables,v )
							lookup[v] = #tables
						end
						file:write( str.."{"..lookup[v].."},"..charE )
					elseif stype == "string" then
						file:write( str..exportstring( v )..","..charE )
					elseif stype == "number" then
						file:write( str..tostring( v )..","..charE )
					end
				end
			end
		end
		file:write( "},"..charE )
	end
	
	file:write( "}" )
	file:close()
	
end

--// The Load Function
function table.load( sfile )

	local ftables,err = loadfile( sfile )
	if err then return _,err end
	local tables = ftables()
	
	for idx = 1,#tables do
	
		local tolinki = {}
		for i,v in pairs( tables[idx] ) do
			if type( v ) == "table" then
				tables[idx][i] = tables[v[1]]
			end
			if type( i ) == "table" and tables[i[1]] then
				table.insert( tolinki,{ i,tables[i[1]] } )
			end
		end
	 -- link indices
		for _,v in ipairs( tolinki ) do
			tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
		end
		
	end
	
	return tables[1]
	
end




--supporting functions
function table.val_to_str ( v )

	if "string" == type( v ) then
		v = string.gsub( v, "\n", "\\n" )
		if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
			return "'" .. v .. "'"
		end
		return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
	else
		return "table" == type( v ) and table.tostring( v ) or
		tostring( v )
	end
  
end

function table.key_to_str ( k )

	if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
		return k
	else
		return "[" .. table.val_to_str( k ) .. "]"
	end
  
end

function table.tostring( tbl )

	local result, done = {}, {}
	for k, v in ipairs( tbl ) do
	
		table.insert( result, table.val_to_str( v ) )
		done[ k ] = true
		
	end
	
	for k, v in pairs( tbl ) do
	
		if not done[ k ] then
			table.insert( result,
			table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
		end
		
	end
	
	return "{" .. table.concat( result, "," ) .. "}"
  
end

function file_exists(name) --check if the file already exists for writing

    if lfs.attributes(name) then
		return true
    else
		return false 
	end
	
end


