local KeyValid,KeyPremium, KeysystemLibrary, KeyGuardLibrary = false,false,loadstring(game:HttpGet("https://raw.githubusercontent.com/OopssSorry/LuaU-Free-Key-System-UI/main/source.lua"))(),loadstring(game:HttpGet("https://cdn.keyguardian.org/library/v1.0.0.lua"))()
local trueData = "9cb8d16b35d548b7b04773541624d585"
local falseData = "b0565d02583e4cb483d652a9c877a1f6"

KeyGuardLibrary.Set({
	publicToken = "5c114f2ec1814466928cd4b947039530",
	privateToken = "7d13f39ae2d24926843a261e5d58c79c",
	trueData = "your trueData",
	falseData = "your falseData",
})

-- https://github.com/OopssSorry/LuaU-Free-Key-System-UI
local KSresponse = KeysystemLibrary:Init({
	Title="ExampleHub",  -- TITLE HERE
	
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

-- Example of checking is user have a premium:
if KeyPremium then
	print("Key is premium!")
end
