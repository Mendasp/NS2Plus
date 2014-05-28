//
// Put this file in a subdirectory of your mod to avoid any conflicts
//

Script.Load( "lua/Class.lua" )

local version = 1.5;

Elixer = Elixer or {}
Elixer.Debug = Elixer.Debug or false  
Elixer.Module = Elixer.Module or {}
Elixer.Module[1.4] = Elixer.Module[1.4] or {} -- Backwards Compatibility
Elixer.Module[1.3] = Elixer.Module[1.3] or {} -- Backwards Compatibility

local function DPrint( string )
	if Elixer.Debug then
		Shared.Message( string )
	end
end


function Elixer.UseVersion( version ) 
	if Elixer.Version ~= version then
		assert( Elixer.Module and Elixer.Module[version], "Elixer Utility v."..string.format("%.1f",version).." could not be found." )
		Shared.Message( "[Elixer] Using Utility Scripts v."..string.format("%.1f",version) );
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
end

-- Already loaded, just apply the loaded version
if Elixer.Module[version] then
	DPrint( "[Elixer] Skipped Loading Utility Scripts v."..string.format("%.1f",version) )
	Elixer.UseVersion( version )
	return
end

Shared.Message( "[Elixer] Loading Utility Scripts v."..string.format("%.1f",version) );

local ELIXER = {}

function ELIXER.Class_AddMethod( className, methodName, method )
	if _G[className][methodName] and _G[className][methodName] ~= method then
		return
	end

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

	Shared.Message( "Upvalues for "..tostring(func)..": local "..vals );

end;


function ELIXER.GetUpValue( func, upname, options )
	local _,val = LocateUpValue( func, upname, options );
	return val;
end;
	
	
function ELIXER.LocateUpValue( func, upname, options )
	for i,name,val in upvalues( func ) do
		if name == upname then
			DPrint( "LocateUpValue found "..upname )
			return func,val,i
		end
	end

	if options and options.LocateRecurse then
		for i,name,innerfunc in upvalues( func ) do
			if type( innerfunc ) == "function" then
				local r = { LocateUpValue( innerfunc, upname, options ) }
				if #r > 0 then
					DPrint( "\ttrace: "..name )
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

	DPrint( "Setting upvalue for "..tostring(func) )

	for i,name,val in upvalues( func ) do
		if source[name] then
			if val == nil then
				DPrint( "Setting upvalue "..name.." to "..tostring(source[name]) )
				assert( val == nil )
				debug.setupvalue( func, i, source[name] )
			else
				DPrint( "Upvalue "..name.." already overwritten by new function" )
			end
			source[name] = nil
		end
	end

	for name,v in pairs( source ) do
		if v then
			DPrint( "Upvalue "..name.." was not ported to new function. Was this intentional?" )
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

	DPrint( "Replacing upvalue "..localname )

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

Elixer.Module[version] = ELIXER
ELIXER = nil
Elixer.UseVersion( version );
