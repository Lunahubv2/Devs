local KeyValid,KeyPremium, KeysystemLibrary, KeyGuardLibrary = false,false,loadstring(game:HttpGet("https://raw.githubusercontent.com/jessajeal02/Lunahub/refs/heads/main/data/gui.lua"))(),loadstring(game:HttpGet("https://raw.githubusercontent.com/jessajeal02/Lunahub/refs/heads/main/data/keyguardian.lua"))()

KeyGuardLibrary.Set({
	publicToken = "5c114f2ec1814466928cd4b947039530",
	privateToken = "7d13f39ae2d24926843a261e5d58c79c",
	trueData = "your trueData",
	falseData = "your falseData",
})

-- https://github.com/OopssSorry/LuaU-Free-Key-System-UI
local KSresponse = KeysystemLibrary:Init({
	Title="Luna Hub",  -- TITLE HERE
	
	SaveKey=true, 
	Debug=false, 
	Link=KeyGuardLibrary.getLink(), 
	Verify=function(key) 
		if KeyGuardLibrary.validateDefaultKey(key) then
			KeyValid=true
		elseif KeyGuardLibrary.validatePremiumKey(key) then
			KeyValid,KeyPremium=true,true
		end;
		return KeyValid
	end,
}) 

-- return nil on closing key system
if not KSresponse or not KeyValid then return end 

-- YOUR SCRIPT HERE
loadstring(game:HttpGet("https://raw.githubusercontent.com/jessajeal02/Lunahub/refs/heads/main/scripts/fisch.lua"))()

-- Example of checking is user have a premium:
if KeyPremium then
	print("Key is premium!")
end
