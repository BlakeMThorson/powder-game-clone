local json = require("json")

local screen_shot = { _version = "0.1.0" }

local screen_vc = gdt.VideoChip0
local pixel_data = {}
local screen_width = screen_vc.Width
local screen_height = screen_vc.Height
local screen_shot_button = gdt.ScreenButton0

local screenshot_count = 0

function screen_shot.take_screenshot(pd)
	gdt.Led0.State = true
	gdt.Led0.Color = color.yellow
	-- get the screen
	get_all_pixels(pd)
	pd:SetPixel(1,1,color.yellow)
	-- send the request
	send_to_server()
end

function get_all_pixels(pd)
	-- reset the data
	pixel_data = {}
	-- iterate over columns
	for i = 1, screen_height do
		for j = 1, screen_width do
			table.insert(pixel_data, pd:GetPixel(j,i))
		end
	end 
end

-- send out request
function send_to_server()
	screenshot_count += 1
	local url = "http://localhost:3000/create-image"
	local method = "POST"
	local customHeaderFields = {
    ["Content-Type"] = "application/json"
	}
	local pixelDataString = colors_to_string(pixel_data)
	local contentType = "application/json"
	local contentData = string.format([[
	{
    "width": %d,
    "height": %d,
    "pixelData": %s,
    "imageName": "screenshot%d"
	}
	]], screen_width, screen_height, pixelDataString, screenshot_count)

	gdt.Wifi0:WebCustomRequest(url, method, customHeaderFields, contentType, contentData)
end

-- web response
function eventChannel0(sender, response)
	gdt.Led0.State = false
	for i,k in pairs(response) do
		print(i)
		print(k)
		print("-----------------")
	end
end


function colors_to_string(colors)
    local parts = {}
    for _, vec in ipairs(colors) do
        -- Format each vector as a JavaScript-readable array string
        table.insert(parts, string.format('{"r":%.f,"g":%.f,"b":%.f}', vec.r, vec.g, vec.b))
    end
    -- Join all formatted strings with commas and enclose in brackets
    return "[ " .. table.concat(parts, ", ") .. " ]"
end


















return screen_shot
