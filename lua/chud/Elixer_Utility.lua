//
// Put this file in a subdirectory of your mod to avoid any conflicts
//

local version = 1.0;

if not Elixer or Elixer.Version ~= version then
	Shared.Message( "[Elixer] Loading Utility Scripts v."..string.format("%.1f",version) );
end

Elixer = Elixer or { Debug = false; }
Elixer.Version = 1.0;


local function DPrint( string )
	if Elixer.Debug then
		Shared.Message( string )
	end
end


Script.Load( "lua/Class.lua" )
function Class_AddMethod( className, methodName, method )
	if _G[className][methodName] and _G[className][methodName] ~= method then
		return
	end

	_G[className][methodName] = method

	local classes = Script.GetDerivedClasses(className)
	assert(classes ~= nil)

	for _, c in ipairs(classes) do
		Class_AddMethod(c, methodName, method )
	end
end


function upvalues( func )
	local i = 0;
	return function()
		i = i + 1
		local name, val = debug.getupvalue (func, i)
		if name then
			return i,name,val
		end -- if
	end
end


function PrintUpValues( func )

	local vals = nil;

	for _,name,_ in upvalues( func ) do
		vals = vals and vals..", "..name or name
	end

	Shared.Message( "Upvalues for "..tostring(func)..": local "..vals );

end


function GetUpValue( func, upname, options )
	return LocateUpValue( func, upname, options )[2];
end
	
function LocateUpValue( func, upname, options )
	for i,name,val in upvalues( func ) do
		if name == upname then
			DPrint( "LocateUpValue found "..upname )
			return func,val,i
		end
	end

	if options and options.LocateRecurse then
		for i,name,innerfunc in upvalues( func ) do
			if type( innerfunc ) == "function" then
				local r = { LocateUpValue( innerfunc, upname, recurse ) }
				if #r > 0 then
					DPrint( "\ttrace: "..name )
					return unpack( r )
				end
			end
		end
	end
end


function GetUpValues( func )

	local data = {}

	for _,name,val in upvalues( func ) do
		data[name] = val;
	end

	return data

end


function SetUpValues( func, source )

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

end

function CopyUpValues( dst, src )
	SetUpValues( dst, GetUpValues( src ) )
end


// Example usage:
// 		ReplaceUpValue( GUIMinimap.Update, "UpdateStaticBlips", NewUpdateStaticBlips, { LocateRecurse = true; CopyUpValues = true; } )
//		ReplaceUpValue( GUIMinimap.Initialize, "kBlipInfo", kBlipInfo, { LocateRecurse = true } )

function ReplaceUpValue( func, localname, newval, options )
	local val,i;

	DPrint( "Replacing upvalue "..localname )

	func, val, i = LocateUpValue( func, localname, options );

	if options and options.CopyUpValues then
		CopyUpValues( newval, val )
	end

	debug.setupvalue( func, i, newval )
end



