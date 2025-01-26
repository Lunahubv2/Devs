local service = 362;  -- your service id, this is used to identify your service.
local secret = "b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad";  -- make sure to obfuscate this if you want to ensure security.
local useNonce = true;  -- use a nonce to prevent replay attacks and request tampering.

--! callbacks
local onMessage = function(message) end;

--! wait for game to load
repeat task.wait(1) until game:IsLoaded();

--! functions
local requestSending = false;
local fSetClipboard, fRequest, fStringChar, fToString, fStringSub, fOsTime, fMathRandom, fMathFloor, fGetHwid = setclipboard or toclipboard, request or http_request or syn_request, string.char, tostring, string.sub, os.time, math.random, math.floor, gethwid or function() return game:GetService("Players").LocalPlayer.UserId end
local cachedLink, cachedTime = "", 0;

--! pick host
local host = "https://api.platoboost.com";
local hostResponse = fRequest({
    Url = host .. "/public/connectivity",
    Method = "GET"
});
if hostResponse.StatusCode ~= 200 or hostResponse.StatusCode ~= 429 then
    host = "https://api.platoboost.net";
end

--!optimize 2
function cacheLink()
    if cachedTime + (10*60) < fOsTime() then
        local response = fRequest({
            Url = host .. "/public/start",
            Method = "POST",
            Body = lEncode({
                service = service,
                identifier = lDigest(fGetHwid())
            }),
            Headers = {
                ["Content-Type"] = "application/json"
            }
        });

        if response.StatusCode == 200 then
            local decoded = lDecode(response.Body);

            if decoded.success == true then
                cachedLink = decoded.data.url;
                cachedTime = fOsTime();
                return true, cachedLink;
            else
                onMessage(decoded.message);
                return false, decoded.message;
            end
        elseif response.StatusCode == 429 then
            local msg = "you are being rate limited, please wait 20 seconds and try again.";
            onMessage(msg);
            return false, msg;
        end

        local msg = "Failed to cache link.";
        onMessage(msg);
        return false, msg;
    else
        return true, cachedLink;
    end
end

cacheLink();

--!optimize 2
local generateNonce = function()
    local str = ""
    for _ = 1, 16 do
        str = str .. fStringChar(fMathFloor(fMathRandom() * (122 - 97 + 1)) + 97)
    end
    return str
end

--!optimize 1
for _ = 1, 5 do
    local oNonce = generateNonce();
    task.wait(0.2)
    if generateNonce() == oNonce then
        local msg = "platoboost nonce error.";
        onMessage(msg);
        error(msg);
    end
end

--!optimize 2
local copyLink = function()
    local success, link = cacheLink();
    
    if success then
        fSetClipboard(link);
    end
end

--!optimize 2
local redeemKey = function(key)
    local nonce = generateNonce();
    local endpoint = host .. "/public/redeem/" .. fToString(service);

    local body = {
        identifier = lDigest(fGetHwid()),
        key = key
    }

    if useNonce then
        body.nonce = nonce;
    end

    local response = fRequest({
        Url = endpoint,
        Method = "POST",
        Body = lEncode(body),
        Headers = {
            ["Content-Type"] = "application/json"
        }
    });

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body);

        if decoded.success == true then
            if decoded.data.valid == true then
                if useNonce then
                    if decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. secret) then
                        return true;
                    else
                        onMessage("failed to verify integrity.");
                        return false;
                    end    
                else
                    return true;
                end
            else
                onMessage("key is invalid.");
                return false;
            end
        else
            if fStringSub(decoded.message, 1, 27) == "unique constraint violation" then
                onMessage("you already have an active key, please wait for it to expire before redeeming it.");
                return false;
            else
                onMessage(decoded.message);
                return false;
            end
        end
    elseif response.StatusCode == 429 then
        onMessage("you are being rate limited, please wait 20 seconds and try again.");
        return false;
    else
        onMessage("server returned an invalid status code, please try again later.");
        return false; 
    end
end

--!optimize 2
local verifyKey = function(key)
    if requestSending == true then
        onMessage("a request is already being sent, please slow down.");
        return false;
    else
        requestSending = true;
    end

    local nonce = generateNonce();
    local endpoint = host .. "/public/whitelist/" .. fToString(service) .. "?identifier=" .. lDigest(fGetHwid()) .. "&key=" .. key;

    if useNonce then
        endpoint = endpoint .. "&nonce=" .. nonce;
    end

    local response = fRequest({
        Url = endpoint,
        Method = "GET",
    });

    requestSending = false;

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body);

        if decoded.success == true then
            if decoded.data.valid == true then
                if useNonce then
                    if decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. secret) then
                        return true;
                    else
                        onMessage("failed to verify integrity.");
                        return false;
                    end
                else
                    return true;
                end
            else
                if fStringSub(key, 1, 4) == "KEY_" then
                    return redeemKey(key);
                else
                    onMessage("key is invalid.");
                    return false;
                end
            end
        else
            onMessage(decoded.message);
            return false;
        end
    elseif response.StatusCode == 429 then
        onMessage("you are being rate limited, please wait 20 seconds and try again.");
        return false;
    else
        onMessage("server returned an invalid status code, please try again later.");
        return false;
    end
end

--!optimize 2
local getFlag = function(name)
    local nonce = generateNonce();
    local endpoint = host .. "/public/flag/" .. fToString(service) .. "?name=" .. name;

    if useNonce then
        endpoint = endpoint .. "&nonce=" .. nonce;
    end

    local response = fRequest({
        Url = endpoint,
        Method = "GET",
    });

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body);

        if decoded.success == true then
            if useNonce then
                if decoded.data.hash == lDigest(fToString(decoded.data.value) .. "-" .. nonce .. "-" .. secret) then
                    return decoded.data.value;
                else
                    onMessage("failed to verify integrity.");
                    return nil;
                end
            else
                return decoded.data.value;
            end
        else
            onMessage(decoded.message);
            return nil;
        end
    else
        return nil;
    end
end

local gui = Instance.new("ScreenGui")
gui.Parent = game.Players.LocalPlayer.PlayerGui
gui.ResetOnSpawn = false 

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.4, 0, 0.6, 0)
frame.Position = UDim2.new(0.3, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderColor3 = Color3.new(0, 0, 0)
frame.BorderSizePixel = 0
frame.Active = true
frame.BackgroundTransparency = 0 
frame.Draggable = true
frame.Parent = gui


local bruh = Instance.new("UICorner")
bruh.CornerRadius = UDim.new(0, 7)
bruh.Parent = frame


local bruh1 = Instance.new("TextLabel")
bruh1.Size = UDim2.new(0.3, 0, 0.15, 0)
bruh1.Position = UDim2.new(0.35, 0, 0.1, 0)
bruh1.BackgroundColor3 = Color3.new(0, 0, 0)
bruh1.BorderColor3 = Color3.new(0, 0, 0)
bruh1.BorderSizePixel = 1
bruh1.Text = "KEY SYSTEM GUI" --Name of your script
bruh1.BackgroundTransparency = 1
bruh1.TextColor3 = Color3.new(255, 255, 255)
bruh1.Font = Enum.Font.SourceSansBold
bruh1.TextSize =40
bruh1.Parent = frame


local bruh2 = Instance.new("TextLabel")
bruh2.Size = UDim2.new(0.3, 0, 0.15, 0)
bruh2.Position = UDim2.new(0.35, 0, 0.22, 0)
bruh2.BackgroundColor3 = Color3.new(0, 0, 0)
bruh2.BorderColor3 = Color3.new(0, 0, 0)
bruh2.BorderSizePixel = 0
bruh2.Text = "Get Key 🔑"
bruh2.BackgroundTransparency = 1
bruh2.TextColor3 = Color3.new(255, 255, 255)
bruh2.Font = Enum.Font.SourceSans
bruh2.TextSize = 30
bruh2.Parent = frame


local bruh3 = Instance.new("TextBox")
bruh3.Size = UDim2.new(0.499, 0, 0.18, 0)
bruh3.Position = UDim2.new(0.25, 0, 0.43, 0)
bruh3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
bruh3.BorderColor3 = Color3.new(0, 0, 0)
bruh3.BorderSizePixel = 0
bruh3.PlaceholderText = "Enter Key Here..."
bruh3.Text = ""
bruh3.TextColor3 = Color3.fromRGB(255, 255, 255)
bruh3.PlaceholderColor3 = Color3.fromRGB(255,255,255)
bruh3.BackgroundTransparency = 1
bruh3.Font = Enum.Font.Code
bruh3.TextSize = 15
bruh3.TextXAlignment = Enum.TextXAlignment.Center
bruh3.Parent = frame


local bruh4 = Instance.new("UICorner")
bruh4.CornerRadius = UDim.new(0, 5)
bruh4.Parent = bruh3


local bruh5 = Instance.new("UIStroke")
bruh5.Color = Color3.new(1, 1, 1)
bruh5.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bruh5.Thickness = 2
bruh5.Parent = bruh3


local bruh6 = Instance.new("TextButton")
bruh6.Size = UDim2.new(0.3, 0, 0.18, 0)
bruh6.Position = UDim2.new(0.1, 0, 0.73, 0)
bruh6.BackgroundColor3 = Color3.new(0, 0, 0)
bruh6.BorderColor3 = Color3.new(0, 0, 0)
bruh6.BorderSizePixel = 0
bruh6.Text = "Get Key"
bruh6.BackgroundTransparency = 1
bruh6.TextColor3 = Color3.new(255, 255, 255)
bruh6.Font = Enum.Font.SourceSans
bruh6.TextSize = 25
bruh6.Parent = frame


local bruh7 = Instance.new("UICorner")
bruh7.CornerRadius = UDim.new(0, 5)
bruh7.Parent = bruh6


local bruh8 = Instance.new("UIStroke")
bruh8.Color = Color3.new(1, 1, 1)
bruh8.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bruh8.Thickness = 2
bruh8.Parent = bruh6


local bruh9 = Instance.new("TextButton")
bruh9.Size = UDim2.new(0.3, 0, 0.18, 0)
bruh9.Position = UDim2.new(0.6, 0, 0.73, 0)
bruh9.BackgroundColor3 = Color3.new(0, 0, 0)
bruh9.BorderColor3 = Color3.new(0, 0, 0)
bruh9.BorderSizePixel = 0
bruh9.Text = "Check Key"
bruh9.BackgroundTransparency = 1
bruh9.TextColor3 = Color3.new(255, 255, 255)
bruh9.Font = Enum.Font.SourceSans
bruh9.TextSize = 25
bruh9.Parent = frame


local bruh10 = Instance.new("UICorner")
bruh10.CornerRadius = UDim.new(0, 5)
bruh10.Parent = bruh9


local bruh11 = Instance.new("UIStroke")
bruh11.Color = Color3.new(1, 1, 1)
bruh11.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bruh11.Thickness = 2
bruh11.Parent = bruh9

bruh6.MouseButton1Click:Connect(function()
  copyLink();
end)

bruh9.MouseButton1Click:Connect(function()
local key = TextBox.Text;
local Verify = verifyKey(TextBox.Text);
if Verify then
    wait(1)
    print("Hi World :D") --Change this to ur script
    gui:Destroy()
  end
end)
