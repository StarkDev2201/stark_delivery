


--visit my discord: https://discord.gg/wsyryrC  CREATE BY Stark#5844 DO NOT REMOVE CREDITS
--visit my discord: https://discord.gg/wsyryrC  CREATE BY Stark#5844 DO NOT REMOVE CREDITS
--visit my discord: https://discord.gg/wsyryrC  CREATE BY Stark#5844 DO NOT REMOVE CREDITS

ESX  = nil
local QBCore = nil 

if Config.FrameWork == 'ESX' then 
	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif Config.FrameWork == 'QBUS' then 
	QBCore = exports['qb-core']:GetCoreObject()
end



RegisterServerEvent('ifood:darmoney')
AddEventHandler('ifood:darmoney', function()
	local _source = source 

	if ESX ~= nil then 
		local xPlayer = ESX.GetPlayerFromId(_source)
		xPlayer.addMoney(Config.Pagamento)
	elseif QBCore ~= nil then 
		local xPlayer = QBCore.Functions.GetPlayer(src)
		xPlayer.Functions.AddMoney('cash', Config.Pagamento, 'Pay Job')
	end

end)