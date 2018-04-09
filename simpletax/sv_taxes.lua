--Config--
simpleTax_maxTax = 25 -- The maximum percent that tax can be set to.
simpleTax_paydaysToNotify = 0 -- How many paydays before non-mayors are reminded of /gettax. Set to 0 to disable
--End of Config--
--Dont edit anything below this line--
simpleTax_totalTax = 0
simpleTax_taxToBePaid = 0
simpleTax_notifyOnCooldown = false

function getTaxCommand(ply, txt)
	local text = string.lower(txt)
	local cmd = string.sub(text, 1, 7)
	if cmd == "/settax" or cmd == "!settax" then
		if ply:isMayor() then
			if tonumber(string.sub(text, 9)) then
				local proposedTax = tonumber(string.sub(text, 9)) 
				if proposedTax < 1 then
					simpleTax_totalTax = 0
				elseif proposedTax > simpleTax_maxTax and simpleTax_maxTax <= 100 then
					simpleTax_totalTax = math.floor(simpleTax_maxTax)
				elseif proposedTax > simpleTax_maxTax and simpleTax_maxTax > 100 then
					simpleTax_totalTax = 100
				else
					simpleTax_totalTax = math.floor(proposedTax)
				end
				DarkRP.notifyAll(0, 4, "Tax has been set to " .. simpleTax_totalTax .. "%!")
				return ""
			else
				DarkRP.notify(ply, 1, 4, "Proposed tax is not a number!")
				return ""
			end
		else
			DarkRP.notify(ply, 1, 4, "You need to be the mayor to change taxes!")
			return ""
		end
	elseif cmd == "/gettax" or cmd == "!gettax" then
		DarkRP.notify(ply, 0, 4, "Tax is currently " .. simpleTax_totalTax .. "%.")
		return ""
	end
end
function getTax(ply, oldsalary) --Tax the citizens and give the money to the mayor
	if simpleTax_totalTax >= 1 and oldsalary >= 1 then -- Jobs with no salary will get the default message
		local tax = ((100 - simpleTax_totalTax) / 100) -- Turns value into decimal and inverts it (eg. 25 becoms 0.75)
		if not ply:isMayor() then
			local newsalary = math.floor(oldsalary * tax)
			local taxedcash = math.floor(oldsalary - newsalary)
			simpleTax_taxToBePaid = simpleTax_taxToBePaid + taxedcash
			return false, "Payday! You recieved " .. DarkRP.formatMoney(newsalary) .. "! (" .. DarkRP.formatMoney(taxedcash) .. " paid in tax)", newsalary
		else
			local mayorpay = oldsalary + simpleTax_taxToBePaid
			simpleTax_taxToBePaid = 0
			return false, "Payday! You recieved " .. DarkRP.formatMoney(mayorpay) .. " in tax and salary.", mayorpay
		end
	end
	if simpleTax_paydaysToNotify >= 1 and not simpleTax_notifyOnCooldown and simpleTax_totalTax >= 1 and not ply:isMayor() then -- Inform non mayors about /gettax
		DarkRP.notify(ply, 0, 4, "Use !gettax or /gettax to see the current income tax.")
		simpleTax_notifyOnCooldown = true
		timer.Simple(GAMEMODE.Config.paydelay * simpleTax_paydaysToNotify, function() simpleTax_notifyOnCooldown = false end)
	end
end
function checkTeamChange(ply,oldteam,newteam) 
	if oldteam == TEAM_MAYOR then -- Reset tax to 0 if mayor changes teams
		simpleTax_totalTax = 0
		DarkRP.notifyAll(0, 4, "The mayor has changed teams and tax has been reset to 0%!")
	elseif newteam == TEAM_MAYOR then -- Inform new mayors of the command
		DarkRP.notify(ply, 0, 6, "Use !settax or /settax to set income tax.")
	end
end

hook.Add("OnPlayerChangedTeam","checkchangehook",checkTeamChange)
hook.Add("PlayerSay","taxcommandhook",getTaxCommand)
hook.Add("playerGetSalary","gettaxhook",getTax)