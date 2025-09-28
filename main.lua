local owner = "scar17off"
local repo = "scarhack"

-- Get current place ID
local placeId = game.PlaceId

-- Construct the raw GitHub URL for the places directory
local baseUrl = string.format(
    "https://raw.githubusercontent.com/%s/%s/refs/heads/main/places/%d.lua",
    owner,
    repo,
    placeId
)

-- Try to load the place-specific script
local success, result = pcall(function()
    return game:HttpGet(baseUrl)
end)

if success then
    -- Execute the downloaded script
    loadstring(result)()
else
    warn("[ScarHack] No specific script found for place " .. placeId)
end