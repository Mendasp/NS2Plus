// ======= Elixer v.1.72 ========
//
//	Put this file in a UNIQUE subdirectory of your mod to avoid any conflicts with other
//	mods that also include Elixer
//
//	Call Elixer.UseVersion( versionNumber ) before trying to call any of these functions 
//	in your mod to ensure the right versions are loaded into memory
//
//	Example usage:
//		ReplaceUpValue( GUIMinimap.Update, "UpdateStaticBlips", NewUpdateStaticBlips, { LocateRecurse = true; CopyUpValues = true; } )
//		ReplaceUpValue( GUIMinimap.Initialize, "kBlipInfo", kBlipInfo, { LocateRecurse = true } )
//
// ==============================

Script.Load( "lua/Class.lua" )

local version = 1.72;

Elixer = Elixer or {}
Elixer.Debug = Elixer.Debug or false  
Elixer.Module = Elixer.Module or {}
Elixer.Module[1.4] = Elixer.Module[1.4] or {} -- Backwards Compatibility
Elixer.Module[1.3] = Elixer.Module[1.3] or {} -- Backwards Compatibility

local function EPrint( fmt, ... )
	local domain = Server and "Server" or Predict and "Predict" or Client and "Client" or "Unknown" 
	Shared.Message( string.format( "[Elixer (%s)] "..tostring(fmt), domain, ... ) )
end
local function EPrintDebug( fmt, ... ) if Elixer.Debug then EPrint( fmt, ... ) end end



if Elixer.Module[version] then
	-- Already loaded, just apply the loaded version
	EPrintDebug( "[Elixer] Skipped Loading Utility Scripts v.%.2f",version )
	Elixer.UseVersion( version )
	return
end


EPrint( "Loading Utility Scripts v.%.2f", version )


-- Replace UseVersion func table if this is a newer version
if type( Elixer.UseVersion ) ~= "table" or Elixer.UseVersion.Version < version then
		
	-- Create read-only func table
	local readonly = 
		{ 
			UseVersion = setmetatable( { Version = version }, 
			{ 
				__call = 
					function( t, version )
						if Elixer.Version ~= version then
							assert( Elixer.Module and Elixer.Module[version], string.format( "Elixer Utility v.%.2f could not be found.", version ) )
							EPrint( "Using Utility Scripts v.%.2f", version )
							if Elixer.Version and Elixer.Module and Elixer.Module[Elixer.Version] then
								for k,v in pairs( Elixer.Module[Elixer.Version] ) do
									_G[k] = nil;
								end
							end
							for k,v in pairs( Elixer.Module[version] ) do
								_G[k] = v;
							end
							Elixer.Version = version;
						end
					end;
			})
		}

	-- Prevent overwrites from older versions of Elixer
	setmetatable( Elixer, { __index = readonly; __newindex = function( t, k, v ) if rawget( readonly, k ) == nil then rawset(t,k,v) end end } )
					
end


-- Begin loading functions for this version
local ELIXER = {}

ELIXER.EPrint = EPrint
ELIXER.EPrintDebug = EPrintDebug

function ELIXER.Class_AddMethod( className, methodName, method )
	assert( _G[className][methodName] == nil or _G[className][methodName] == method, "Attempting to add new method when class already has one -- use Class_ReplaceMethod instead" )
	
	_G[className][methodName] = method

	local classes = Script.GetDerivedClasses(className)
	assert(classes ~= nil)

	for _, c in ipairs(classes) do
		Class_AddMethod(c, methodName, method )
	end
end;


function ELIXER.upvalues( func )
	local i = 0;
	if not func then
		return function() end
	else
		return function()
			i = i + 1
			local name, val = debug.getupvalue (func, i)
			if name then
				return i,name,val
			end -- if
		end
	end
end;


function ELIXER.PrintUpValues( func )

	local vals = nil;

	for _,name,_ in upvalues( func ) do
		vals = vals and vals..", "..name or name
	end

	EPrint( "Upvalues for "..tostring(func)..": local "..vals );

end;


function ELIXER.GetUpValue( func, upname, options )
	local _,val = LocateUpValue( func, upname, options );
	return val;
end;
	
	
function ELIXER.LocateUpValue( func, upname, options )
	for i,name,val in upvalues( func ) do
		if name == upname then
			EPrintDebug( "LocateUpValue found "..upname )
			return func,val,i
		end
	end

	if options and options.LocateRecurse then
		for i,name,innerfunc in upvalues( func ) do
			if type( innerfunc ) == "function" then
				local r = { LocateUpValue( innerfunc, upname, options ) }
				if #r > 0 then
					EPrintDebug( "\ttrace: "..name )
					return unpack( r )
				end
			end
		end
	end
end;


function ELIXER.GetUpValues( func )

	local data = {}

	for _,name,val in upvalues( func ) do
		data[name] = val;
	end

	return data

end;


function ELIXER.SetUpValues( func, source )

	EPrintDebug( "Setting upvalue for "..tostring(func) )

	for i,name,val in upvalues( func ) do
		if source[name] then
			if val == nil then
				EPrintDebug( "Setting upvalue "..name.." to "..tostring(source[name]) )
				assert( val == nil )
				debug.setupvalue( func, i, source[name] )
			else
				EPrintDebug( "Upvalue "..name.." already overwritten by new function" )
			end
			source[name] = nil
		end
	end

	for name,v in pairs( source ) do
		if v then
			EPrintDebug( "Upvalue "..name.." was not ported to new function. Was this intentional?" )
		end
	end

end;

function ELIXER.CopyUpValues( dst, src )
	SetUpValues( dst, GetUpValues( src ) )
end;


// Example usage:
// 		ReplaceUpValue( GUIMinimap.Update, "UpdateStaticBlips", NewUpdateStaticBlips, { LocateRecurse = true; CopyUpValues = true; } )
//		ReplaceUpValue( GUIMinimap.Initialize, "kBlipInfo", kBlipInfo, { LocateRecurse = true } )

function ELIXER.ReplaceUpValue( func, localname, newval, options )
	local val,i;

	EPrintDebug( "Replacing upvalue "..localname )

	func, val, i = LocateUpValue( func, localname, options );

	if options and options.CopyUpValues then
		CopyUpValues( newval, val )
	end

	debug.setupvalue( func, i, newval )
end;


function ELIXER.AppendToEnum( tbl, key )
	if rawget(tbl,key) ~= nil then
		return
	end
	
	local maxVal = 0
	if tbl == kTechId then
		maxVal = tbl.Max - 1
		if maxVal == kTechIdMax then
			error( "Appending another value to the TechId enum would exceed network precision constraints" )
		end
		rawset( tbl, rawget( tbl, maxVal+2 ), nil )
		rawset( tbl, 'Max', maxVal+2 )
		rawset( tbl, maxVal+2, 'Max' )
	else
		for k, v in next, tbl do
			if type(v) == "number" and v > maxVal then
				maxVal = v 
			end
		end
	end	
	
	rawset( tbl, key, maxVal+1 )
	rawset( tbl, maxVal+1, key )
	
end


function ELIXER.list ( ... )
	local argv = {...}
	local argc = 0
	for i,v in pairs( {...} ) do
		if argc < i then
			argc = i
		end
	end
	
	local t = {}
	for i=1,argc do
		t[i] = tostring(argv[i])
	end
	return table.concat( t, ", " )
end


local set_mt = { __index = function() return false; end }
function ELIXER.set( tbl )
	local ret = {}
	for i,v in next,tbl do ret[v] = true end
	return setmetatable( ret, set_mt )
end


function ELIXER.EPrintCallHook( class, name )
	local old
	old = Class_ReplaceMethod( class, name, function(...) 
		EPrint( "%s.%s(%s) Called\n%s", class, name, list(...), debug.traceback() )
		
		return old(...) 
	end)
end


Elixer.Module[version], ELIXER = ELIXER, nil
Elixer.UseVersion( version );
