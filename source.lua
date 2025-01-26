local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/OopssSorry/LuaU-Free-Key-System-UI/main/source.lua"))()
local KeyValid = false
local response = KeySystem:Init({
		
local service = 362;  -- your service id, this is used to identify your service.
local secret = "b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad";  -- make sure to obfuscate this if you want to ensure security.
local useNonce = true;  -- use a nonce to prevent replay attacks and request tampering.
	
	Debug=false, -- <bool> Prints some output in console when true
	Title="ExampleHub | Key System", -- <string or nil> Title of key system
	Description=nil, -- <string or nil> Description of key system
	Link="", -- <string> String to get key
	Discord="test", -- <string or nil> Button to join your discord server
	SaveKey=false, -- <bool or nil> Just auto save key
	Verify=function(key) -- <function> Verify is key valid
		if key=="1234" then
      KeyValid=true
			return true
		else
			return false
		end
	end,
	GuiParent = game.CoreGui, -- <object or nil> :3
})

if not response or not KeyValid then return end
-- HERE YOUR SCRIPT
