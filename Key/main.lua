local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Replace with your GitHub repository info
local GITHUB_USERNAME = "Lunahubv2"
local GITHUB_REPO = "https://github.com/Lunahubv2/Devs"
local GITHUB_TOKEN = "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" -- Use a personal access token for authentication

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("YourGuiName") -- Replace with your actual GUI name
local textBox = gui:WaitForChild("TextBox") -- Make sure your TextBox is named correctly
local submitButton = gui:WaitForChild("TextButton") -- Make sure your TextButton is named correctly
local keysDisplay = gui:WaitForChild("KeysDisplay") -- TextLabel or TextBox to display loaded keys

-- Function to get the content of the user's key file
local function getFileContent(userId)
    local filePath = "keys/" .. userId .. ".txt" -- File path will be user-specific
    local url = "https://api.github.com/Lunahubv2/Devs" .. GITHUB_USERNAME .. "/" .. GITHUB_REPO .. "/contents/" .. filePath
    local headers = {
        ["Authorization"] = "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" .. GITHUB_TOKEN,
        ["Accept"] = "application/vnd.github.v3+json"
    }

    local success, response = pcall(function()
        return HttpService:GetAsync(url, true, headers)
    end)

    if success and response then
        local data = HttpService:JSONDecode(response)
        return HttpService:Base64Decode(data.content) -- Decode the content from Base64
    else
        warn("Failed to get file content: ", response)
        return nil
    end
end

-- Function to save the key to the user's file
local function saveKey(key)
    local userId = tostring(player.UserId) -- Get the player's User ID as a string
    local content = getFileContent(userId) or ""

    -- Add new key to the content
    content = content .. key .. "\n"

    local filePath = "keys/" .. userId .. ".txt" -- File path will be user-specific
    local url = "https://api.github.com/repos/" .. GITHUB_USERNAME .. "/" .. GITHUB_REPO .. "/contents/" .. filePath
    local headers = {
        ["Authorization"] = "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" .. GITHUB_TOKEN,
        ["Accept"] = "application/vnd.github.v3+json",
        ["Content-Type"] = "application/json"
    }

    local sha = nil
    if content then
        local existingContent = HttpService:JSONDecode(HttpService:GetAsync(url, true, headers))
        sha = existingContent.sha -- Get the SHA of the existing file
    end

    local body = {
        message = "Adding key for UserID: " .. userId,
        content = HttpService:Base64Encode(content),
        sha = sha -- Include SHA for updating
    }

    local success, response = pcall(function()
        return HttpService:PutAsync(url, HttpService:JSONEncode(body), Enum.HttpContentType.ApplicationJson, false, headers)
    end)

    if success then
        print("Key saved successfully for UserID: " .. userId)
    else
        warn("Failed to save key: ", response)
    end
end

-- Function to load keys for the user
local function loadKeys()
    local userId = tostring(player.UserId) -- Get the player's User ID as a string
    local content = getFileContent(userId)

    if content then
        -- Display the keys in the designated UI element
        keysDisplay.Text = "Your Keys:\n" .. content
    else
        keysDisplay.Text = "No keys found."
    end
end

-- Connect button click to saveKey function
submitButton.MouseButton1Click:Connect(function()
    local key = textBox.Text
    if key and key ~= "" then
        saveKey(key)
        textBox.Text = "" -- Clear the TextBox after saving the key
        loadKeys() -- Reload keys after saving a new one
    else
        warn("Please enter a valid key.")
    end
end)

-- Load keys when the player enters the game
loadKeys()
