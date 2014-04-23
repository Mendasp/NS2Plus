Script.Load( "lua/Class.lua" )

function DPrint( string )
	Shared.Message( string )
end

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

local i = 1


local function ForEachUpValue( func, dowork )
	local shouldBreak = false
	local i = 1
	repeat
		name, val = debug.getupvalue (func, i)
		if name then
			shouldBreak = dowork( name, val, i )
			i = i + 1
		end -- if
	until not name or shouldBreak
end
	
	
-- Retrieve called local function
-- Useful if you need to override a local function in a local function with ReplaceLocals but lack a reference to it.
function GetLocalFunction( originalFunction, localFunctionName)
	
	local ret = nil

	ForEachUpValue( originalFunction, 
		function( name, val, i )
			if name == localFunctionName then
				ret = val
				return true
			end				
		end 
	)
	
	return ret
	
end

function PrintUpValues( func )
	
	local vals = nil
	ForEachUpValue( func, 
		function( name, val, i )
			vals = vals and vals..", "..name or name
		end 
	)
	Shared.Message( "Upvalues for "..tostring(func)..": local "..vals );
	
end

function GetUpValues( func )
	
	local data = {}
	
	ForEachUpValue( func, 
		function( name, val, i )
			data[name] = val
		end 
	)
	
	return data
	
end

function SetUpValues( func, source )
	
	DPrint( "Setting upvalue for "..tostring(func) )
	ForEachUpValue( func, 
		function( name, val, i )
			if source[name] then
				if val == nil then
					DPrint( "Setting upvalue "..name.." to "..tostring(source[name]) )
					assert( val == nil )
					debug.setupvalue( func, i, source[name] )
				else
					DPrint( "Upvalue "..name.." overwritten by new function" )
				end
				source[name] = nil
			end
		end 
	)
	
	for name,v in pairs( source ) do
		if v then
			DPrint( "Upvalue "..name.." was not ported to new function. Was this intentional?" )
		end
	end
	
end

function ReplaceUpValue( func, localname, newval )
	
	ForEachUpValue( func, 
		function( name, val, i )
			if name == localname then
				debug.setupvalue( func, i, newval )
			end
		end 
	)
	
end