// bawNg's awesome injection code from SparkMod
function InjectIntoScope(...)
	local scope_functions = {...}
	local inject_function = table.remove(scope_functions)

	local metatable = {
		__index = function(_, name)
			for _, scope_function in ipairs(scope_functions) do
				local i = 1
				local key, value = debug.getupvalue(scope_function, i)
				while key do
					if key == name then
						return value
					end
					i = i + 1
					key, value = debug.getupvalue(scope_function, i)
				end
			end
			return getfenv()[name]
		end,
		__newindex = function(_, name, set_value)
			for _, scope_function in ipairs(scope_functions) do
				local i = 1
				local key, value = debug.getupvalue(scope_function, i)
				while key do
					if key == name then
						debug.setupvalue(scope_function, i, set_value)
						return
					end
					i = i + 1
					key, value = debug.getupvalue(scope_function, i)
				end
			end
			getfenv()[name] = set_value
		end
	}

	local env = setmetatable({ }, metatable)

	if type(inject_function) == "function" then
		setfenv(inject_function, env)

		inject_function()
	elseif type(inject_function) == "string" then
		local actual_function = _G
		for name in inject_function:gmatch("[^.]+") do
			actual_function = actual_function[name]
		end
		setfenv(actual_function, env)
	else
		error("The last argument passed to InjectIntoScope must be a function or string containing a function name")
	end
end