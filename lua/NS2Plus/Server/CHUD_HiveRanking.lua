local kPlayerRankingUrl = "http://sabot.herokuapp.com/api/post/matchEnd"
local kPlayerRankingRequestUrl = "http://sabot.herokuapp.com/api/get/playerData/"

-- Require a map change when changing this setting
local hiveConnection = CHUDServerOptions["hiveconnection"].currentValue == true

local oldSendHTTPRequest = Shared.SendHTTPRequest
function Shared.SendHTTPRequest(url, method, params, callback)
	if hiveConnection or (url ~= kPlayerRankingUrl and not string.find(url, kPlayerRankingRequestUrl)) then
		oldSendHTTPRequest(url, method, params, callback)
	end
end